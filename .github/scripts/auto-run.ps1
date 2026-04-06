#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Autonomous task orchestrator for the Agent Boilerplate.
    Executes all pending tasks via Claude Code CLI with security scans,
    checkpoints, rate-limit handling, and hard-stop on failure.

.DESCRIPTION
    Reads tasks from .agents/state.json, executes them sequentially via
    Claude Code CLI (--agent engineer), runs security scans between tasks,
    and handles rate limits gracefully.

    Prerequisites:
    - Claude Code CLI installed globally ('claude' command available)
    - Tool auto-approval configured (--dangerously-skip-permissions or settings)
    - Manager has pre-generated handoff files in .agents/handoffs/
    - Tasks defined in .agents/state.json with auto_run.task_order

    Usage Tracking:
    Uses --output-format json on every 'claude -p' call (a format flag only, NOT an extra
    API call or extra token spend). Parses the JSON output for cost_usd, input_tokens,
    output_tokens, and duration_ms. Displays usage inline after each task and shows a
    full breakdown table at the end. Falls back to wall-clock time if token data is absent.

.PARAMETER CheckpointSeconds
    Pause duration between tasks in seconds. Default: 45.
    During this window you can Ctrl+C to abort.

.PARAMETER MaxRetries
    Maximum retry attempts per task before halting. Default: 3.

.PARAMETER RateLimitWaitHours
    Hours to wait if Claude CLI hits rate limits. Default: 5.

.PARAMETER SkipSecurity
    Skip security scans between tasks. Not recommended.

.PARAMETER DryRun
    Preview the execution plan without invoking Claude CLI.

.EXAMPLE
    .\.github\scripts\auto-run.ps1
    .\.github\scripts\auto-run.ps1 -CheckpointSeconds 60 -MaxRetries 2
    .\.github\scripts\auto-run.ps1 -DryRun
#>

[CmdletBinding()]
param(
    [int]$CheckpointSeconds = 45,
    [int]$MaxRetries = 3,
    [double]$RateLimitWaitHours = 5,
    [switch]$SkipSecurity,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

# ─── Resolve Paths ────────────────────────────────────────────────────────────

$ProjectRoot = & git rev-parse --show-toplevel 2>$null
if (-not $ProjectRoot) { $ProjectRoot = (Get-Location).Path }

$AgentsDir    = Join-Path $ProjectRoot ".agents"
$StateFile    = Join-Path $AgentsDir "state.json"
$HandoffsDir  = Join-Path $AgentsDir "handoffs"
$HandoffFile  = Join-Path $AgentsDir "handoff.md"

# ─── Helpers ──────────────────────────────────────────────────────────────────

function Write-Banner {
    param([string]$Text, [ConsoleColor]$Color = "Cyan")
    $line = [string]::new([char]0x2550, 60)
    Write-Host ""
    Write-Host $line -ForegroundColor $Color
    Write-Host "  $Text" -ForegroundColor $Color
    Write-Host $line -ForegroundColor $Color
    Write-Host ""
}

function Write-TaskLine {
    param(
        [string]$TaskId,
        [string]$Title,
        [string]$Status,
        [int]$Current,
        [int]$Total
    )
    $icons = @{
        starting      = [char]0x25B6   # ▶
        running       = [char]0x231B   # ⌛
        security      = [char]0x2630  # ☰ (trigram for scan)
        done          = [char]0x2705   # ✅
        failed        = [char]0x274C   # ❌
        "rate-limited" = [char]0x23F8  # ⏸
    }
    $icon = if ($icons.ContainsKey($Status)) { $icons[$Status] } else { "-" }
    $color = switch ($Status) {
        "done"         { "Green"  }
        "failed"       { "Red"    }
        "rate-limited" { "Yellow" }
        default        { "White"  }
    }
    Write-Host "  [$Current/$Total] $icon $TaskId`: $Title  ($Status)" -ForegroundColor $color
}

function Read-StateFile {
    if (-not (Test-Path $StateFile)) {
        Write-Error "State file not found: $StateFile"
        exit 1
    }
    Get-Content $StateFile -Raw | ConvertFrom-Json
}

function Save-StateFile {
    param($State)
    $State | ConvertTo-Json -Depth 10 | Set-Content $StateFile -Encoding UTF8
}

function Get-PendingTasks {
    param($State)
    $tasks = [System.Collections.ArrayList]::new()

    # Explicit order from auto_run config, or natural sort
    $order = @()
    if ($State.auto_run -and $State.auto_run.task_order) {
        $order = @($State.auto_run.task_order)
    }

    $allTasks = @{}
    $State.tasks.PSObject.Properties | ForEach-Object {
        $allTasks[$_.Name] = $_.Value
    }

    if ($order.Count -gt 0) {
        foreach ($id in $order) {
            if ($allTasks.ContainsKey($id) -and $allTasks[$id].status -in @("pending", "not_started")) {
                [void]$tasks.Add(@{ id = $id; data = $allTasks[$id] })
            }
        }
    }
    else {
        $allTasks.GetEnumerator() | Sort-Object Name | ForEach-Object {
            if ($_.Value.status -in @("pending", "not_started")) {
                [void]$tasks.Add(@{ id = $_.Key; data = $_.Value })
            }
        }
    }

    return $tasks
}

function Test-RateLimited {
    param([string]$Output, [int]$ExitCode)
    if ($ExitCode -eq 0) { return $false }
    $patterns = @("rate.limit", "usage.limit", "too many requests", "429",
                   "throttl", "capacity", "overloaded", "quota")
    foreach ($p in $patterns) {
        if ($Output -match $p) { return $true }
    }
    return $false
}

function Get-UsageFromJsonOutput {
    # Parses claude --output-format json output for cost/token fields.
    # --output-format json is a format flag only - it does NOT make an extra API call.
    param([string]$RawOutput)

    $usage = @{
        InputTokens  = 0
        OutputTokens = 0
        CostUsd      = [double]0
        DurationMs   = 0
        Available    = $false
    }

    try {
        # The JSON blob may be mixed with stderr lines; find the last complete JSON object
        $jsonLines = @($RawOutput -split "`n" | Where-Object {
            $t = $_.Trim(); $t.StartsWith('{') -and $t.EndsWith('}')
        })
        if ($jsonLines.Count -eq 0) { return $usage }

        $data = $jsonLines[-1] | ConvertFrom-Json

        # Try root-level fields
        if ($data.PSObject.Properties.Name -contains 'input_tokens')  { $usage.InputTokens  = [int]$data.input_tokens }
        if ($data.PSObject.Properties.Name -contains 'output_tokens') { $usage.OutputTokens = [int]$data.output_tokens }
        if ($data.PSObject.Properties.Name -contains 'cost_usd')      { $usage.CostUsd      = [double]$data.cost_usd }
        if ($data.PSObject.Properties.Name -contains 'duration_ms')   { $usage.DurationMs   = [int]$data.duration_ms }

        # Try nested usage object (Anthropic API style)
        if ($data.usage) {
            if ($data.usage.PSObject.Properties.Name -contains 'input_tokens')  { $usage.InputTokens  = [int]$data.usage.input_tokens }
            if ($data.usage.PSObject.Properties.Name -contains 'output_tokens') { $usage.OutputTokens = [int]$data.usage.output_tokens }
        }
        # Try nested cost object (statusLine style)
        if ($data.cost) {
            if ($data.cost.PSObject.Properties.Name -contains 'total_cost_usd')    { $usage.CostUsd   = [double]$data.cost.total_cost_usd }
            if ($data.cost.PSObject.Properties.Name -contains 'total_duration_ms') { $usage.DurationMs = [int]$data.cost.total_duration_ms }
        }

        if ($usage.InputTokens -gt 0 -or $usage.OutputTokens -gt 0 -or $usage.CostUsd -gt 0) {
            $usage.Available = $true
        }
    }
    catch { }

    return $usage
}

function Write-InlineUsage {
    param([hashtable]$Usage, [long]$ElapsedMs)

    $ms       = if ($Usage.DurationMs -gt 0) { $Usage.DurationMs } else { $ElapsedMs }
    $sec      = [math]::Round($ms / 1000)
    $mins     = [math]::Floor($sec / 60)
    $secs     = $sec % 60
    $timeStr  = if ($mins -gt 0) { "${mins}m ${secs}s" } else { "${secs}s" }

    if ($Usage.Available) {
        $costStr = '${0:F4}' -f $Usage.CostUsd
        Write-Host ("    Usage: {0:N0} in / {1:N0} out tokens  |  {2}  |  {3}" -f `
            $Usage.InputTokens, $Usage.OutputTokens, $costStr, $timeStr) -ForegroundColor DarkCyan
    }
    else {
        Write-Host "    Duration: $timeStr  (token data not in CLI output)" -ForegroundColor DarkGray
    }
}

function Show-UsageTable {
    param(
        [hashtable]$Registry,
        [System.Collections.ArrayList]$CompletedIds,
        [long]$TotalElapsedMs
    )

    if ($Registry.Count -eq 0) { return }

    $anyAvailable = $false
    foreach ($u in $Registry.Values) { if ($u.Available) { $anyAvailable = $true; break } }

    Write-Host ""
    Write-Host "  Usage Breakdown:" -ForegroundColor White
    Write-Host "  $([string]::new([char]0x2500, 57))" -ForegroundColor DarkGray
    Write-Host ("  {0,-12}  {1,8}  {2,8}  {3,9}  {4}" -f "Task", "In tok", "Out tok", "Cost", "Time") -ForegroundColor Gray
    Write-Host "  $([string]::new([char]0x2500, 57))" -ForegroundColor DarkGray

    $totalIn   = 0
    $totalOut  = 0
    $totalCost = [double]0

    foreach ($id in $CompletedIds) {
        if (-not $Registry.ContainsKey($id)) { continue }
        $u    = $Registry[$id]
        $ms   = if ($u.DurationMs -gt 0) { $u.DurationMs } else { $u.ElapsedMs }
        $sec  = [math]::Round($ms / 1000)
        $mins = [math]::Floor($sec / 60)
        $secs = $sec % 60
        $tStr = if ($mins -gt 0) { "${mins}m ${secs}s" } else { "${secs}s" }

        if ($u.Available) {
            $totalIn   += $u.InputTokens
            $totalOut  += $u.OutputTokens
            $totalCost += $u.CostUsd
            $cStr = '${0:F4}' -f $u.CostUsd
            Write-Host ("  {0,-12}  {1,8:N0}  {2,8:N0}  {3,9}  {4}" -f $id, $u.InputTokens, $u.OutputTokens, $cStr, $tStr) -ForegroundColor Gray
        }
        else {
            Write-Host ("  {0,-12}  {'N/A',8}  {'N/A',8}  {'N/A',9}  {1}" -f $id, $tStr) -ForegroundColor DarkGray
        }
    }

    Write-Host "  $([string]::new([char]0x2500, 57))" -ForegroundColor DarkGray

    $eSec  = [math]::Round($TotalElapsedMs / 1000)
    $eMins = [math]::Floor($eSec / 60)
    $eSecs = $eSec % 60
    $eStr  = if ($eMins -gt 0) { "${eMins}m ${eSecs}s" } else { "${eSecs}s" }

    if ($anyAvailable) {
        $tCostStr = '${0:F4}' -f $totalCost
        Write-Host ("  {0,-12}  {1,8:N0}  {2,8:N0}  {3,9}  {4}" -f "TOTAL", $totalIn, $totalOut, $tCostStr, $eStr) -ForegroundColor Cyan
    }
    else {
        Write-Host "  Token data not available in CLI output." -ForegroundColor DarkGray
        Write-Host "  Wall-clock total: $eStr" -ForegroundColor DarkGray
        Write-Host "  Note: usage data requires Claude Code v2.1+ with --output-format json support." -ForegroundColor DarkGray
    }
}

function Invoke-Claude {
    param(
        [string]$Agent,
        [string]$Prompt
    )

    $emptyUsage = @{ InputTokens = 0; OutputTokens = 0; CostUsd = [double]0; DurationMs = 0; Available = $false }

    if ($DryRun) {
        Write-Host "    [DRY RUN] claude --agent $Agent -p ..." -ForegroundColor DarkGray
        return @{ ExitCode = 0; Output = "[dry run - no execution]"; RawOutput = ""; RateLimited = $false; Usage = $emptyUsage; ElapsedMs = 0 }
    }

    # Measure wall-clock time for this invocation
    $sw = [System.Diagnostics.Stopwatch]::StartNew()

    $rawOutput = $null
    try {
        # --output-format json: format flag only, NOT an extra API call or token spend.
        # Returns a JSON blob containing the result text plus cost/usage metadata.
        $rawOutput = & claude --agent $Agent -p --dangerously-skip-permissions --output-format json $Prompt 2>&1 |
                     Out-String
    }
    catch {
        $rawOutput = $_.Exception.Message
    }

    $sw.Stop()
    $exitCode = $LASTEXITCODE
    if ($null -eq $exitCode) { $exitCode = 0 }

    # Extract plain text from JSON .result field for pattern matching (rate limit, CRITICAL, etc.)
    $textOutput = $rawOutput
    try {
        $jsonLines = @($rawOutput -split "`n" | Where-Object {
            $t = $_.Trim(); $t.StartsWith('{') -and $t.EndsWith('}')
        })
        if ($jsonLines.Count -gt 0) {
            $parsed = $jsonLines[-1] | ConvertFrom-Json
            if ($parsed.result) { $textOutput = [string]$parsed.result }
        }
    }
    catch { }

    $rateLimited = Test-RateLimited -Output ($rawOutput + ' ' + $textOutput) -ExitCode $exitCode
    $usage       = Get-UsageFromJsonOutput -RawOutput $rawOutput

    return @{
        ExitCode    = $exitCode
        Output      = $textOutput
        RawOutput   = $rawOutput
        RateLimited = $rateLimited
        Usage       = $usage
        ElapsedMs   = $sw.ElapsedMilliseconds
    }
}

function Get-ChangedFiles {
    $files = & git diff --name-only HEAD~1 2>$null
    if (-not $files) { $files = & git diff --name-only --cached 2>$null }
    if (-not $files) { $files = & git diff --name-only 2>$null }
    if ($files) { return ($files -join ", ") }
    return "all recently modified files"
}

function Show-Countdown {
    param([int]$Seconds, [string]$NextTaskId)
    Write-Host ""
    Write-Host "    Next: $NextTaskId - starting in ${Seconds}s  (Ctrl+C to abort)" -ForegroundColor DarkCyan
    for ($i = $Seconds; $i -gt 0; $i--) {
        Write-Host "`r    $([char]0x23F1) ${i}s remaining...    " -NoNewline -ForegroundColor DarkGray
        Start-Sleep -Seconds 1
    }
    Write-Host "`r    Continuing...                " -ForegroundColor DarkGray
    Write-Host ""
}

function Wait-ForRateLimit {
    param([double]$Hours)
    $totalSec = [int]($Hours * 3600)
    Write-Banner "RATE LIMITED" Yellow
    Write-Host "    Claude Code CLI hit usage limits." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "    Options:" -ForegroundColor White
    Write-Host "      Press Enter  - wait $Hours hours, then resume" -ForegroundColor Gray
    Write-Host "      Ctrl+C       - abort and switch to Copilot native" -ForegroundColor Gray
    Write-Host ""
    Read-Host "    Press Enter to wait, or Ctrl+C to abort"

    Write-Host "    Waiting $Hours hours..." -ForegroundColor DarkGray
    for ($s = $totalSec; $s -gt 0; $s -= 60) {
        $h = [math]::Floor($s / 3600)
        $m = [math]::Floor(($s % 3600) / 60)
        Write-Host "`r    $([char]0x23F8) ${h}h ${m}m remaining...    " -NoNewline -ForegroundColor DarkGray
        Start-Sleep -Seconds ([math]::Min(60, $s))
    }
    Write-Host "`r    Rate limit window passed. Resuming...         " -ForegroundColor Green
    Write-Host ""
}

# ─── Pre-flight Checks ───────────────────────────────────────────────────────

# Verify claude CLI exists
$claudeCmd = Get-Command claude -ErrorAction SilentlyContinue
if (-not $claudeCmd -and -not $DryRun) {
    Write-Error "Claude Code CLI not found. Install it: https://github.com/anthropic-ai/claude-code"
    exit 1
}

# Read state
$state = Read-StateFile
$pendingTasks = Get-PendingTasks -State $state
$totalTasks = $pendingTasks.Count

if ($totalTasks -eq 0) {
    Write-Host "No pending tasks in state.json. Nothing to run." -ForegroundColor Yellow
    exit 0
}

# Override defaults from state.json auto_run config if present
if ($state.auto_run) {
    if ($state.auto_run.checkpoint_seconds -and -not $PSBoundParameters.ContainsKey('CheckpointSeconds')) {
        $CheckpointSeconds = $state.auto_run.checkpoint_seconds
    }
    if ($state.auto_run.max_retries -and -not $PSBoundParameters.ContainsKey('MaxRetries')) {
        $MaxRetries = $state.auto_run.max_retries
    }
    if ($state.auto_run.rate_limit_wait_hours -and -not $PSBoundParameters.ContainsKey('RateLimitWaitHours')) {
        $RateLimitWaitHours = $state.auto_run.rate_limit_wait_hours
    }
    if ($state.auto_run.PSObject.Properties.Name -contains 'security_between_tasks') {
        if (-not $state.auto_run.security_between_tasks -and -not $PSBoundParameters.ContainsKey('SkipSecurity')) {
            $SkipSecurity = [switch]::new($true)
        }
    }
}

# Verify handoff files
$missingHandoffs = @()
foreach ($t in $pendingTasks) {
    $path = Join-Path $HandoffsDir "$($t.id).md"
    if (-not (Test-Path $path)) { $missingHandoffs += $t.id }
}
if ($missingHandoffs.Count -gt 0) {
    Write-Host "Missing handoff files: $($missingHandoffs -join ', ')" -ForegroundColor Red
    Write-Host "Run /auto-run in Copilot first to generate them." -ForegroundColor Yellow
    exit 1
}

# ─── Display Plan ─────────────────────────────────────────────────────────────

Write-Banner "AUTONOMOUS TASK RUNNER"
Write-Host "  Project:     $($state.project)" -ForegroundColor White
Write-Host "  Tasks:       $totalTasks pending" -ForegroundColor White
Write-Host "  Checkpoint:  ${CheckpointSeconds}s" -ForegroundColor White
Write-Host "  Retries:     $MaxRetries per task" -ForegroundColor White
Write-Host "  Security:    $(if ($SkipSecurity) { 'SKIPPED' } else { 'after each task' })" -ForegroundColor White
Write-Host "  Rate limit:  wait ${RateLimitWaitHours}h on throttle" -ForegroundColor White
Write-Host "  Usage:       tracked per task (--output-format json, no extra tokens)" -ForegroundColor White
if ($DryRun) { Write-Host "  Mode:        DRY RUN" -ForegroundColor Yellow }
Write-Host ""
Write-Host "  Task queue:" -ForegroundColor Gray
foreach ($t in $pendingTasks) {
    Write-Host "    $($t.id): $($t.data.title)" -ForegroundColor Gray
}
Write-Host ""

if (-not $DryRun) {
    Write-Host "  Starting in 5 seconds... (Ctrl+C to abort)" -ForegroundColor Yellow
    Start-Sleep -Seconds 5
}

# ─── Main Loop ────────────────────────────────────────────────────────────────

$completed     = [System.Collections.ArrayList]::new()
$failed        = [System.Collections.ArrayList]::new()
$startTime     = Get-Date
$halted        = $false
$usageRegistry = @{}   # taskId -> @{InputTokens, OutputTokens, CostUsd, DurationMs, ElapsedMs, Available}

for ($i = 0; $i -lt $pendingTasks.Count; $i++) {
    $task     = $pendingTasks[$i]
    $taskId   = $task.id
    $taskTitle = $task.data.title
    $taskNum  = $i + 1

    Write-Banner "TASK $taskNum/$totalTasks  $([char]0x2014)  $taskId" White
    Write-TaskLine -TaskId $taskId -Title $taskTitle -Status "starting" -Current $taskNum -Total $totalTasks

    # Copy handoff file into place
    $srcHandoff = Join-Path $HandoffsDir "$taskId.md"
    Copy-Item $srcHandoff $HandoffFile -Force

    # Update state: in_progress
    $state = Read-StateFile
    $state.current_task.id          = $taskId
    $state.current_task.title       = $taskTitle
    $state.current_task.status      = "in_progress"
    $state.current_task.assigned_to = "engineer"
    $state.tasks.$taskId.status     = "in_progress"
    $state.last_updated             = (Get-Date -Format "o")
    $state.last_updated_by          = "auto-run"
    Save-StateFile -State $state

    # ── Engineer Execution (with retries) ──
    $success    = $false
    $attempts   = 0

    while (-not $success -and $attempts -lt $MaxRetries) {
        $attempts++
        if ($attempts -gt 1) {
            Write-Host "    Retry $attempts/$MaxRetries..." -ForegroundColor Yellow
        }

        Write-TaskLine -TaskId $taskId -Title $taskTitle -Status "running" -Current $taskNum -Total $totalTasks

        $engineerPrompt = "Read .agents/handoff.md and implement the assigned task ($taskId`: $taskTitle). " +
            "When complete: (1) commit changes with git add -A and git commit -m 'feat($taskId): [description]', " +
            "(2) update .agents/state.json - set tasks.$taskId.status to 'done', " +
            "(3) update .agents/state.md with a summary, " +
            "(4) update .agents/workspace-map.md if you created or moved files."

        $result = Invoke-Claude -Agent "engineer" -Prompt $engineerPrompt

        # Rate limit?
        if ($result.RateLimited) {
            Write-TaskLine -TaskId $taskId -Title $taskTitle -Status "rate-limited" -Current $taskNum -Total $totalTasks
            Wait-ForRateLimit -Hours $RateLimitWaitHours
            $attempts--  # Don't count rate-limit as a failed attempt
            continue
        }

        # Non-zero exit?
        if ($result.ExitCode -ne 0) {
            Write-Host "    Claude CLI exited with code $($result.ExitCode)" -ForegroundColor Red
            $tail = if ($result.Output.Length -gt 500) {
                $result.Output.Substring($result.Output.Length - 500)
            } else { $result.Output }
            Write-Host "    Last output:" -ForegroundColor DarkGray
            Write-Host $tail -ForegroundColor DarkGray
            continue
        }

        # Verify state.json updated
        $state      = Read-StateFile
        $taskStatus = $state.tasks.$taskId.status
        if ($taskStatus -eq "done") {
            $success = $true
        }
        else {
            Write-Host "    Claude exited OK but task status is '$taskStatus' (expected 'done'). Retrying..." -ForegroundColor Yellow
        }
    }

    # ── Handle failure ──
    if (-not $success) {
        Write-TaskLine -TaskId $taskId -Title $taskTitle -Status "failed" -Current $taskNum -Total $totalTasks
        Write-Banner "TASK FAILED  $([char]0x2014)  $taskId" Red
        Write-Host "    Failed after $MaxRetries attempts. Halting." -ForegroundColor Red
        Write-Host ""
        Write-Host "    To resume after fixing:" -ForegroundColor Yellow
        Write-Host "      .\.github\scripts\auto-run.ps1" -ForegroundColor White
        Write-Host "    (completed tasks are skipped automatically)" -ForegroundColor Gray

        [void]$failed.Add($taskId)

        $state = Read-StateFile
        $state.tasks.$taskId.status = "blocked"
        $state.context.blocked_on   = "$taskId failed after $MaxRetries attempts"
        $state.last_updated         = (Get-Date -Format "o")
        $state.last_updated_by      = "auto-run"
        Save-StateFile -State $state

        $halted = $true
        break
    }

    Write-TaskLine -TaskId $taskId -Title $taskTitle -Status "done" -Current $taskNum -Total $totalTasks
    [void]$completed.Add($taskId)

    # Record and display usage for this task
    $taskUsage = $result.Usage
    $taskUsage.ElapsedMs = $result.ElapsedMs
    $usageRegistry[$taskId] = $taskUsage
    Write-InlineUsage -Usage $taskUsage -ElapsedMs $result.ElapsedMs

    # ── Security Scan ──
    if (-not $SkipSecurity) {
        Write-TaskLine -TaskId $taskId -Title $taskTitle -Status "security" -Current $taskNum -Total $totalTasks

        $changedFiles  = Get-ChangedFiles
        $securityPrompt = "Audit the following files for security vulnerabilities: $changedFiles. " +
            "Task context: $taskId ($taskTitle). " +
            "Report findings in compact format. Any CRITICAL finding is a hard blocker."

        $secResult = Invoke-Claude -Agent "security" -Prompt $securityPrompt

        if ($secResult.RateLimited) {
            Write-Host "    Security scan rate limited - will need manual audit later." -ForegroundColor Yellow
        }
        elseif ($secResult.Output -match "CRITICAL") {
            Write-Banner "CRITICAL SECURITY FINDING  $([char]0x2014)  $taskId" Red
            Write-Host $secResult.Output -ForegroundColor Red
            Write-Host ""
            Write-Host "    Task queue HALTED. Review findings before continuing." -ForegroundColor Red

            $state = Read-StateFile
            $state.security_status.open_findings    += 1
            $state.security_status.cleared_for_push  = $false
            $state.context.blocked_on                = "CRITICAL security finding in $taskId"
            $state.last_updated                      = (Get-Date -Format "o")
            $state.last_updated_by                   = "auto-run"
            Save-StateFile -State $state

            $halted = $true
            break
        }
        else {
            Write-Host "    Security: PASS" -ForegroundColor Green
        }
    }

    # ── Checkpoint ──
    if ($i -lt $pendingTasks.Count - 1) {
        $nextTask = $pendingTasks[$i + 1]
        Show-Countdown -Seconds $CheckpointSeconds -NextTaskId $nextTask.id
    }
}

# ─── Final Summary ────────────────────────────────────────────────────────────

$elapsed = (Get-Date) - $startTime
$summaryColor = if ($failed.Count -eq 0 -and -not $halted) { "Green" } else { "Red" }

Write-Banner "EXECUTION COMPLETE" $summaryColor
Write-Host "  Duration:   $([math]::Round($elapsed.TotalMinutes, 1)) minutes" -ForegroundColor White
Write-Host "  Completed:  $($completed.Count)/$totalTasks" -ForegroundColor White

if ($completed.Count -gt 0) {
    Write-Host "  $([char]0x2705) $($completed -join ', ')" -ForegroundColor Green
}
if ($failed.Count -gt 0) {
    Write-Host "  $([char]0x274C) $($failed -join ', ')" -ForegroundColor Red
}

$remainingIds = $pendingTasks | Where-Object { $_.id -notin $completed -and $_.id -notin $failed } |
                ForEach-Object { $_.id }
if ($remainingIds.Count -gt 0) {
    Write-Host "  $([char]0x23F8) $($remainingIds -join ', ')" -ForegroundColor Yellow
}

# Show per-task usage breakdown and totals
Show-UsageTable -Registry $usageRegistry -CompletedIds $completed -TotalElapsedMs ([long]$elapsed.TotalMilliseconds)

Write-Host ""
if (-not $halted) {
    Write-Host "  All tasks complete. Return to Copilot Manager for final review and push." -ForegroundColor Cyan
}
else {
    Write-Host "  Execution halted. Fix the issue, then re-run to continue." -ForegroundColor Yellow
}
Write-Host ""

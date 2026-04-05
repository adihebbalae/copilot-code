# Skill: Autonomous Task Runner (`auto-run`)

> **Purpose**: Run the full task queue to completion without manual intervention. Manager pre-generates all handoffs, then an orchestrator script drives Claude Code CLI through every task sequentially — with security scans, checkpoints, rate-limit handling, and hard-stop on failure.

## When to Use

This skill applies when the user says:
- "start all tasks", "run everything", "auto-run", "run to completion"
- "I just want to click start", "do all the tasks", "autonomous mode"
- "run the queue", "execute all pending tasks"

## Prerequisites

Before invoking this skill, verify:

1. **Approved task list** — `.agents/state.json` has tasks with `status: "pending"` or `"not_started"`. The user has reviewed and approved the plan.
2. **Claude Code CLI available** — `claude` is installed and accessible from the terminal. If not available, fall back to Copilot-native subagent loop (Section A below).
3. **Tasks have sufficient detail** — Each task in `state.json` has at minimum: `title`, `assigned_to`, `status`. You will expand these into full handoff files.

## Routing Decision

Before generating anything, determine the execution path:

| Condition | Route | Why |
|-----------|-------|-----|
| All tasks ≤3 files, ≤1 module each | **Copilot-native** (Section A) | Fast, no tool-switching, fits in 160k context |
| Any task spans 4+ files or 2+ modules | **Claude CLI script** (Section B) | Needs 1M context; 10-20 min tasks shouldn't block Copilot |
| Mixed — some small, some large | **Claude CLI script for all** (Section B) | Consistency > micro-optimization; one execution path is simpler |

Tell the user which route you chose and why.

---

## Section A: Copilot-Native Loop (Small Tasks Only)

Use this when ALL tasks are small enough for Copilot's context window.

### Execution Flow

For each pending task in order:

1. **Generate handoff** — Write `.agents/handoff.md` with full context (use standard Handoff Format)
2. **Spawn engineer subagent**:
   ```
   Use the engineer subagent to implement [TASK-ID]: [title].
   Read .agents/handoff.md for full context.
   When done: update .agents/state.json status for [TASK-ID] to "done".
   ```
3. **Evaluate result** — Check if the subagent reported success
4. **Run security subagent** (anti-bias: only pass file paths, not implementation details):
   ```
   Use the security subagent to audit [changed files/directories].
   Report findings in compact format. CRITICAL = hard blocker.
   ```
5. **Check security result** — If CRITICAL finding, halt immediately
6. **Update state** — Mark task done in `state.json`, update `state.md`
7. **Report progress** — Show task completion, then continue to next task

### Break Conditions
- Engineer subagent fails → retry up to 3 times → halt and surface to user
- CRITICAL security finding → halt immediately
- User sends a message → pause and respond

---

## Section B: Claude CLI Orchestrator (Default Path)

Use this when any task needs Claude Code CLI's full context window, or when you want consistent autonomous execution.

### Step 1: Generate All Handoff Files

Create `.agents/handoffs/` directory. For EACH pending task, generate a dedicated handoff file:

**File**: `.agents/handoffs/[TASK-ID].md`

Use the standard Handoff Format from your protocol, but with these additions for autonomous execution:

```markdown
# Handoff: [Task Title]
**Task ID**: [TASK-ID]
**Mode**: autonomous (no user interaction available)

## Context
[Full project context — the Claude CLI session is isolated, it knows nothing]

## Task
[Exactly what to build — be specific, Claude CLI can't ask clarifying questions]

## Acceptance Criteria
- [ ] [criterion]

## Validation Gates
- [ ] All tests pass
- [ ] Code compiles without errors
- [ ] git commit with descriptive message

## Files to Read First
- .agents/workspace-map.md
- [other relevant files]

## Constraints
- Do NOT ask questions — make reasonable assumptions and document them
- Do NOT install packages not listed here
- Commit when done: git add -A && git commit -m "feat([TASK-ID]): [description]"
```

**For dependent tasks** (task N depends on output of task N-1):
Add to the Context section:
> This task builds on [TASK-ID]. Read the files created/modified by that task before starting. Check git log for the most recent commit to understand what changed.

### Step 2: Configure Auto-Run

Add the `auto_run` field to `.agents/state.json`:

```json
"auto_run": {
  "task_order": ["TASK-001", "TASK-002", "TASK-003"],
  "checkpoint_seconds": 45,
  "max_retries": 3,
  "security_between_tasks": true,
  "rate_limit_wait_hours": 5
}
```

- `task_order`: Explicit execution order (respects dependencies)
- `checkpoint_seconds`: Pause between tasks (user can Ctrl+C during this window)
- `max_retries`: Per-task retry limit before halting
- `security_between_tasks`: Run security scan after each task
- `rate_limit_wait_hours`: How long to wait if Claude CLI is rate-limited

### Step 3: Launch the Script

Tell the user:

```
╔══════════════════════════════════════════════════════════════╗
║  🚀 AUTO-RUN READY                                         ║
║                                                              ║
║  Handoffs generated: [N] tasks                               ║
║  Route: Claude Code CLI (autonomous)                         ║
║  Security: after each task                                   ║
║  Checkpoint: [N]s between tasks                              ║
╚══════════════════════════════════════════════════════════════╝

Run this in your terminal:

  .\.github\scripts\auto-run.ps1

Options:
  -CheckpointSeconds 60    # Longer pause between tasks
  -MaxRetries 2            # Fewer retries before halting
  -SkipSecurity            # Skip security scans (not recommended)
  -DryRun                  # Preview without executing

The script will:
1. Execute each task via Claude Code CLI
2. Run security audit after each task
3. Pause [N]s between tasks (Ctrl+C to abort)
4. Halt on failure or CRITICAL security finding
5. Update state.json throughout

When complete, return here for final review and push.
```

### Step 4: Post-Completion Review

When the user returns after the script finishes:

1. Read `.agents/state.json` — check all task statuses
2. Read `.agents/state.md` — review summaries
3. Run a final security sweep if needed
4. Review git log for all commits
5. Generate push readiness report
6. Push only after confirming everything is clean

---

## Error Recovery

### Script halted on task failure
```
The auto-run script stopped at [TASK-ID] after [N] retries.

Options:
  a) I'll review the error and update the handoff — then re-run the script
     (it skips completed tasks automatically)
  b) Let me take this task manually, then re-run for the remaining tasks
  c) Skip this task and continue: remove it from auto_run.task_order
     in state.json, then re-run
```

### Script halted on CRITICAL security finding
```
CRITICAL security finding in [TASK-ID]. Task queue halted.

I'll review the finding and either:
  a) Write a fix into the handoff and re-run
  b) Flag it for manual remediation
  c) If it's a false positive, acknowledge and re-run with the task marked done
```

### Claude CLI rate limited
The script will pause and display options. If the user returns to Copilot:
- Offer to continue remaining tasks via Copilot-native subagent loop (Section A)
- Or advise waiting for the rate limit to reset

---

## Configurable Defaults

| Parameter | Default | Override |
|-----------|---------|---------|
| Checkpoint between tasks | 45 seconds | `-CheckpointSeconds N` |
| Max retries per task | 3 | `-MaxRetries N` |
| Rate limit cooldown | 5 hours | `-RateLimitWaitHours N` |
| Security scans | Enabled | `-SkipSecurity` |
| Claude CLI agent | `engineer` | Configured in script |
| Security CLI agent | `security` | Configured in script |

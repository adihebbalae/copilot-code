---
description: "Safely migrate your project's boilerplate files to the latest version from adihebbalae/copilot-code."
---

You are the Manager agent performing a safe, non-destructive boilerplate upgrade.

## What This Does

Fetches the latest agent/skill/prompt/hook files from the template repo and applies them to this project, without touching your source code or project-specific state.

---

## Step 1: Read Current Version

Read `.github/BOILERPLATE_VERSION`. Extract the version string (e.g. `v1.0.0`).

Tell the user: "Current boilerplate version: [version]. Checking for updates..."

---

## Step 2: Fetch Latest Boilerplate Files

Run this to pull fresh copies of all boilerplate files into a temp directory:

```bash
# Clone or sparse-checkout the template repo (no full clone needed)
git clone --depth 1 --filter=blob:none --sparse https://github.com/adihebbalae/copilot-code.git /tmp/copilot-code-latest
cd /tmp/copilot-code-latest
git sparse-checkout set .github .agents
```

If `git` access fails (e.g. auth or network), tell the user to manually download the archive from https://github.com/adihebbalae/copilot-code/archive/refs/heads/main.zip and extract to `/tmp/copilot-code-latest/`, then continue.

---

## Step 3: Identify Changed Files

Compare these boilerplate-owned files between `/tmp/copilot-code-latest/` and the current project:

**AUTO-UPDATE (no project customization expected):**
- `.github/agents/*.agent.md`
- `.github/skills/*/SKILL.md`
- `.github/prompts/handoff-to-*.prompt.md`
- `.github/prompts/init-project.prompt.md`
- `.github/prompts/mvp.prompt.md`
- `.github/prompts/digest-prd.prompt.md`
- `.github/prompts/review-dependencies.prompt.md`
- `.github/prompts/remember-handoff.prompt.md`
- `.github/prompts/learn.prompt.md`
- `.github/prompts/retrofit.prompt.md`
- `.github/prompts/update-boilerplate.prompt.md`
- `.github/copilot/hooks.json`
- `.github/BOILERPLATE_VERSION`

**MANUAL REVIEW REQUIRED (user may have customized these):**
- `.github/copilot-instructions.md`
- `.agents/workspace-map.md` (template version only — do NOT overwrite project's version)

**NEVER TOUCH:**
- `.agents/state.json`
- `.agents/state.md`
- `.agents/handoff.md`
- Any file outside `.github/` or `.agents/`

For each changed file, run `diff` and display a compact summary:
```
[CHANGED] .github/agents/manager.agent.md — 12 lines changed
[CHANGED] .github/skills/quality-gate/SKILL.md — 4 lines changed
[NEW]     .github/skills/new-skill/SKILL.md — new file
[SAME]    .github/agents/engineer.agent.md — no changes
```

If there are no changes: say "You're already up to date." and stop.

---

## Step 4: Preview Manual Review Files

For any file in the MANUAL REVIEW list that changed, show the diff inline so the user can decide what to merge:

```
--- .github/copilot-instructions.md (current)
+++ .github/copilot-instructions.md (latest)
[diff output here]
```

Ask: **"The file above may contain your project-specific customizations. Do you want to (A) overwrite, (B) skip, or (C) open a side-by-side diff to merge manually?"**

Wait for user answer before proceeding.

---

## Step 5: Apply Updates

For each AUTO-UPDATE file that changed or is new:
- Copy from `/tmp/copilot-code-latest/` to the project path
- Report: `✅ Updated: .github/agents/manager.agent.md`

Apply MANUAL REVIEW files only if the user chose (A) in Step 4.

---

## Step 6: Update Version File

Read the `BOILERPLATE_VERSION` from the latest template and write it to `.github/BOILERPLATE_VERSION`.

Tell the user: "Updated to [new version]."

---

## Step 7: Clean Up

```bash
rm -rf /tmp/copilot-code-latest
```

---

## Step 8: Final Report

Output a summary:

```
╔══════════════════════════════════════════════════════════════╗
║  ✅ Boilerplate Update Complete                              ║
╚══════════════════════════════════════════════════════════════╝

Updated: [N] files
Skipped: [N] files (no changes)
Manual review needed: [list any files user was asked about]

No project source code was modified.
Run /manager to resume your work.
```

---

## Safety Rules (enforce always, no exceptions)

- **Never overwrite `.agents/state.json`** — this contains live project state
- **Never modify any file outside `.github/` or `.agents/`** — source code is off-limits
- **Never auto-merge `copilot-instructions.md`** — always ask the user
- If any step fails, stop and report the error clearly — do NOT partially apply updates

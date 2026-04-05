---
description: "Run all approved tasks to completion autonomously. Generates handoff files for every pending task, then launches the orchestrator script or Copilot-native loop."
---

# Auto-Run: Autonomous Task Execution

**Step 1: Load the skill.**
Read `.github/skills/auto-run/SKILL.md` — it contains the full protocol for this command.

**Step 2: Validate prerequisites.**
Read `.agents/state.json`. Confirm:
- There are tasks with `status: "pending"` or `"not_started"`
- The user has approved the task list (ask if unclear)
- Check `context.blocked_on` — if set, surface the blocker and stop

If no pending tasks exist:
> "No pending tasks in state.json. Use `/init-project` or `/prd-builder` to plan tasks first."

**Step 3: Follow the skill.**
Execute the auto-run skill protocol:
1. Make the routing decision (Copilot-native vs Claude CLI)
2. Generate all handoff files
3. Configure `auto_run` in state.json
4. Launch execution (subagent loop or script)

**Step 4: Update state.**
After completion (or if halted), update `.agents/state.json` and `.agents/state.md`.

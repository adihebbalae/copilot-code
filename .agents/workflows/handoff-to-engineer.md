---
description: "Hand off the current task to the Engineer agent. Writes a structured brief to .agents/handoff.md and launches the Engineer via task group."
---

# Handoff to Engineer

Hand off the current task to the Engineer agent.

## Steps

1. Read `.agents/state.json` to identify the current task.
2. Write a complete handoff prompt to `.agents/handoff.md` including: Context, WHY, Task, Acceptance Criteria, Validation Gates, Files to Read, Constraints.
3. Update `.agents/state.json` → `handoff` field.
4. Launch the Engineer via a new task group or conversation.

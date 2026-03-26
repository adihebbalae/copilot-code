---
description: "Hand off a task to the Engineer agent by TASK-ID. Reads task title and context automatically."
agent: "engineer"
argument-hint: "Just the TASK-ID — e.g. TASK-001"
---

Your TASK-ID: $ARGUMENTS

**Step 1: Get the task title.**
Read `.agents/state.json`. Find the entry in `tasks` matching the TASK-ID above. Extract the `title` field.

If `$ARGUMENTS` is blank or the task is not found in state.json, read `.agents/handoff.md` and extract the title from the `# Handoff:` heading instead.

**Step 2: Output your rename line first — before anything else:**
```
💬 Rename this chat: "[TASK-ID]: [task title] → @engineer"
```

**Step 3: Load context.**
Read `.agents/handoff.md` for the full task brief (context, acceptance criteria, files to read, constraints).
Read `.agents/workspace-map.md` to orient yourself in the codebase.
Read `.agents/state.json` for project mode (check `mode` — if `"mvp"`, apply MVP mode behavior).

**Step 4: Execute.**
Implement the task following your protocol in `engineer.agent.md`.

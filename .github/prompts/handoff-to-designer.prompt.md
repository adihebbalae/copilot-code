---
description: "Hand off a task to the Designer agent by TASK-ID. Reads task title and context automatically."
agent: "designer"
argument-hint: "Just the TASK-ID — e.g. TASK-004"
---

Your TASK-ID: $ARGUMENTS

**Step 1: Get the task title.**
Read `.agents/state.json`. Find the entry in `tasks` matching the TASK-ID above. Extract the `title` field.

If `$ARGUMENTS` is blank or the task is not found in state.json, read `.agents/handoff.md` and extract the title from the `# Handoff:` heading instead.

**Step 2: Output your rename line first — before anything else:**
```
💬 Rename this chat: "[TASK-ID]: [task title] → @designer"
```

**Step 3: Load context.**
Read `.agents/handoff.md` for the full design brief.
Read `.agents/state.json` for project context.

**Step 4: Execute.**
Provide design guidance, feedback, or specs following your protocol in `designer.agent.md`. Write your output back to `.agents/handoff.md`.

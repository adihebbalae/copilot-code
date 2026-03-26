---
description: "Hand off a decision to the Consultant agent by TASK-ID. Reads task title and context automatically."
agent: "consultant"
argument-hint: "Just the TASK-ID — e.g. TASK-005"
---

Your TASK-ID: $ARGUMENTS

**Step 1: Get the task title.**
Read `.agents/state.json`. Find the entry in `tasks` matching the TASK-ID above. Extract the `title` field.

If `$ARGUMENTS` is blank or the task is not found in state.json, read `.agents/handoff.md` and extract the title from the `# Handoff:` heading instead.

**Step 2: Output your rename line first — before anything else:**
```
💬 Rename this chat: "[TASK-ID]: [task title] → @consultant"
```

**Step 3: Load context.**
Read `.agents/handoff.md` for the architectural question or decision.
Read `.agents/state.json` for full project context.
Read ALL files referenced in the handoff.

**Step 4: Execute.**
Provide deep structured analysis following your protocol in `consultant.agent.md`. Write your recommendation back to `.agents/handoff.md`.

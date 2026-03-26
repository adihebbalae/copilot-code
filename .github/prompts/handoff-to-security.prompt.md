---
description: "Hand off a task to the Security agent by TASK-ID. Reads task title and context automatically."
agent: "security"
argument-hint: "Just the TASK-ID — e.g. TASK-003"
---

Your TASK-ID: $ARGUMENTS

**Step 1: Get the task title.**
Read `.agents/state.json`. Find the entry in `tasks` matching the TASK-ID above. Extract the `title` field.

If `$ARGUMENTS` is blank or the task is not found in state.json, read `.agents/handoff.md` and extract the title from the `# Handoff:` heading instead.

**Step 2: Output your rename line first — before anything else:**
```
💬 Rename this chat: "[TASK-ID]: [task title] → @security"
```

**Step 3: Load context.**
Read `.agents/handoff.md` for the full security review brief.
Read `.agents/state.json` to understand what changed and the current security status.

**Step 4: Execute.**
Perform a full adversarial security audit following your protocol in `security.agent.md`. Write your report back to `.agents/handoff.md`.

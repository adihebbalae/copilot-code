---
description: "Hand off to the Consultant for deep architectural reasoning. Use after 3 Engineer failures on the same task or for irreversible architecture decisions."
---

# Handoff to Consultant

Escalate to the Consultant for deep reasoning on a complex or blocked problem.

## Steps

1. Read `.agents/state.json` to confirm the problem: check `context.blocked_on` or the failing task.
2. Write a reasoning brief to `.agents/handoff.md` including:
   - The specific architectural question or decision point
   - Options considered and their tradeoffs
   - What the Engineer tried (if applicable) and why it failed
   - The constraint: what outcome is needed
3. Update `.agents/state.json` → `handoff` field.
4. Launch the Consultant via a new task group or conversation.
5. Once the Consultant returns a recommendation, present it to the user for approval before implementing.

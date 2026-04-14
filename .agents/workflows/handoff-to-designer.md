---
description: "Hand off a UI/UX question to the Designer. Use when reviewing designs, planning user flows, writing component specs, or checking accessibility. Designer never writes code."
---

# Handoff to Designer

Hand off a UI/UX task to the Designer agent.

## Steps

1. Read `.agents/state.json` to identify the design scope (task or feature).
2. Write a design brief to `.agents/handoff.md` including:
   - What needs to be designed or reviewed
   - User flow context (what happens before and after this screen/component)
   - Existing design system or style constraints (if any)
   - Specific questions to answer (e.g., "Is this form layout clear?", "What's the best empty state?")
3. Update `.agents/state.json` → `handoff` field.
4. Launch the Designer via a new task group or conversation.
5. Relay Designer's spec or feedback to the Engineer in the next handoff.

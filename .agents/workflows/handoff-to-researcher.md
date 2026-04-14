---
description: "Hand off to the Researcher for competitive analysis, market sizing, or user pain extraction. Run before building features with unknown competitive landscape."
---

# Handoff to Researcher

Hand off a research task to the Researcher agent.

## Steps

1. Read `.agents/state.json` to identify the feature or decision needing research.
2. Write a research brief to `.agents/handoff.md` including:
   - The specific research question (e.g., "What do competitors charge for X?", "What are the top complaints users have about Y?")
   - Relevant market or user segment to analyze
   - What decision this research will inform
   - Deliverable format expected (e.g., competitive matrix, pain point list, pricing table)
3. Update `.agents/state.json` → `handoff` field.
4. Launch the Researcher via a new task group or conversation.
5. Researcher writes findings to `.agents/research/`. Review and incorporate into the plan.

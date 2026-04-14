---
description: "Hand off changed files for adversarial security audit. Passes ONLY file paths to avoid bias. Halts all tasks on CRITICAL findings."
---

# Handoff to Security

Hand off files for adversarial security audit.

## Steps

1. Identify all files changed since the last security scan.
2. Write a security audit prompt to `.agents/handoff.md` with ONLY the file paths — no implementation context.
3. Update `.agents/state.json` → `handoff` field.
4. Launch the Security agent via a new task group or conversation.
5. If CRITICAL findings: halt all tasks immediately.

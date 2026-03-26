---
description: "Write current task state to Copilot Memory so the next agent picks it up automatically — no copy-paste required. Replaces the two-window handoff with a single memory read."
agent: "manager"
---

You are running `/remember-handoff`. Your job is to compress the current task state into Copilot's persistent memory so the receiving agent can start working immediately, without the user copy-pasting `.agents/handoff.md`.

---

## Step 1: Read Current State

Read these files:
- `.agents/state.json` — current task, active agent, blockers
- `.agents/handoff.md` — the full handoff prompt (if one exists)

Extract the essential handoff payload:
- **Task ID** (from state.json `active_task`)
- **Target agent** (from state.json `handoff.target_agent`)
- **Model** (from state.json `handoff.model`)
- **Task summary** (1–2 sentences from handoff.md `## Task`)
- **Acceptance criteria** (bullet list from handoff.md)
- **Key files** (from handoff.md `## Files to Read First`)
- **Constraints** (from handoff.md `## Constraints`)
- **Vibe mode** (true/false from handoff.md, if present)

---

## Step 2: Write to Copilot Memory

Save this memory entry using Copilot's memory tool:

**Memory key**: `handoff:[task-id]`

**Memory value** (compact format):
```
HANDOFF | Task: [TASK-ID] | Agent: @[agent] | Model: [model]
Summary: [1-sentence task description]
Criteria: [comma-separated acceptance criteria]
Files: [comma-separated file paths]
Constraints: [comma-separated constraints]
Vibe: [true/false]
State: .agents/state.json | Handoff: .agents/handoff.md
```

Also write a "latest handoff" pointer:

**Memory key**: `handoff:latest`
**Memory value**: `[TASK-ID]` — so any agent can find the current handoff without knowing the task ID.

---

## Step 3: Verify

After writing, read back the memory entry to confirm it was saved correctly. Report:

```
✅ Handoff written to Memory

Key: handoff:[TASK-ID]
Target: @[agent] | [model]
Task: [1-sentence summary]

The next agent can retrieve this with:
  "Read the handoff from memory: handoff:[TASK-ID]"
  or: "What's the latest handoff?"
```

---

## Step 4: Show Handoff Banner

```
╔══════════════════════════════════════════════════════════════╗
║  🔀 SWITCH TO:  @[agent]   |   MODEL:  [Model]             ║
╚══════════════════════════════════════════════════════════════╝

  Open a new chat → select @[agent] → say:
  "Read my latest handoff from memory and begin."

  No copy-paste required.
```

---

## Note: How the Receiving Agent Reads Memory

The receiving agent (Engineer, Security, etc.) should start their session with:
> "Read the latest handoff from Copilot Memory and begin working."

Copilot will retrieve `handoff:latest` → look up the full handoff entry → the agent has everything needed to start immediately.

This eliminates the two-window copy-paste problem entirely.

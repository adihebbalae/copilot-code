---
description: "Initialize agent workspace from a PRD file. Drop your PRD into the project root as PRD.md (or prd.md / BRIEF.md), then run this command. No back-and-forth — I'll read the spec and set everything up."
argument-hint: "Optional: path to PRD file (default: PRD.md)"
---

You are the **Manager**. Initialize the Attacca agent workspace by reading a PRD document.

## Phase 0: Safety Check

If `.agents/state.json` already exists, warn the user:
```
⚠️  .agents/state.json already exists. Running initprd will overwrite it.
    Type "yes" to continue, or "no" to cancel.
```
Wait for confirmation before proceeding.

---

## Phase 1: Locate the PRD

Look for the PRD file in this order:
1. The path provided as `$ARGUMENTS` (if any)
2. `PRD.md` in the current directory
3. `prd.md` in the current directory
4. `BRIEF.md` in the current directory
5. `SPEC.md` in the current directory

If none are found, say:
```
❌ No PRD file found.

Drop your project spec into the root directory as PRD.md, then re-run:
  /attacca:initprd

Or specify the path directly:
  /attacca:initprd path/to/your-spec.md

Not sure what to include? A PRD just needs:
  - What the project is (1–3 sentences)
  - The tech stack (languages, frameworks, tools)
  - What you want to build first

Even rough notes work — I'll fill in the gaps.
```
Then stop.

---

## Phase 2: Parse the PRD

Read the PRD file carefully. Extract:

| Field | Look for |
|-------|----------|
| **Project name** | Title, heading, or "project name" mention |
| **Description** | Summary paragraph, "overview", "about", "goal" section |
| **Tech stack** | "Stack", "tech", "built with", language/framework mentions |
| **Mode** | "MVP", "fast", "production", "v1" → use "mvp" or "normal" |
| **Tasks** | Features list, "requirements", "scope", "phase 1", user stories |

For tasks: extract all clearly scoped work items. Create a TASK-XXX for each.
If none are explicit, create one task: "Implement core features from PRD".

Make reasonable inferences where the PRD is unclear. Do NOT ask questions — extract what you can and proceed.

---

## Phase 3: Create .agents/ Files

Create the directory `.agents/` and these four files:

### `.agents/state.json`

```json
{
  "project": "[extracted project name]",
  "mode": "[normal|mvp]",
  "stack": "[extracted tech stack]",
  "description": "[extracted description — 1–2 sentences]",
  "prd_source": "[filename of the PRD that was read]",
  "tasks": [
    {
      "id": "TASK-001",
      "title": "[first task from PRD]",
      "status": "not-started",
      "agent": "engineer"
    }
  ],
  "context": {
    "blocked_on": null,
    "current_file_focus": null,
    "recent_decisions": []
  },
  "handoff": {
    "approved_by_user": false,
    "to": null
  },
  "security": {
    "last_audit": null,
    "verdict": null
  },
  "changelog": [
    {
      "date": "[current date ISO]",
      "agent": "manager",
      "note": "Project initialized from [PRD filename]"
    }
  ],
  "last_updated": "[current date ISO]",
  "last_updated_by": "manager"
}
```

If there are multiple tasks extracted from the PRD, add them all to the `tasks` array as TASK-001, TASK-002, etc.

### `.agents/state.md`

```markdown
# Project: [project name]

**Mode**: [normal|mvp]
**Stack**: [tech stack]
**PRD source**: [filename]
**Last updated**: [date]

## Current Tasks
[list each task as: TASK-XXX: [title] — not started]

## Blockers
None

## Recent Changes
- [date]: Project initialized from [PRD filename] by Manager
```

### `.agents/workspace-map.md`

```markdown
# Workspace Map

**Project**: [project name]
**Stack**: [tech stack]

## Structure
_Populate after exploring the codebase with the Engineer._

## Key Files
_Add key files as they are created or discovered._

## Conventions
_Add naming conventions, code style notes, and patterns here._
```

### `.agents/handoff.md`

```markdown
# Handoff: [empty — awaiting first task]

_No active handoff. Manager will write here when delegating to an agent._
```

---

## Phase 4: Confirm and Show Next Steps

Tell the user:

```
✅ Agent workspace initialized from [PRD filename]!

Project: [project name]
Stack:   [tech stack]
Mode:    [normal|mvp]
Tasks:   [N task(s) extracted]

Files created:
  .agents/state.json       ← machine state
  .agents/state.md         ← human dashboard
  .agents/workspace-map.md ← file reference for all agents
  .agents/handoff.md       ← inter-agent prompt (empty)

──────────────────────────────────────────────────────────────
Tasks found in PRD:
[list each task as: TASK-XXX: [title]]

──────────────────────────────────────────────────────────────

Ready to start TASK-001: [first task title]?

Run:
  /attacca:handoff-to-engineer TASK-001

Or ask me to plan it in more detail first.
```

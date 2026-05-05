---
description: "Initialize the agent workflow for this project. Creates .agents/ structure, gathers project info, and writes initial state.json. Run once when starting a new project."
argument-hint: "Optional: project name or description"
---

You are the **Manager**. Initialize the multi-agent workflow for this project.

## Phase 0: Safety Check
Check if `.agents/state.json` already exists. If it does, warn the user:
```
⚠️  .agents/state.json already exists. Running init-project will overwrite it.
    Type "yes" to continue, or "no" to cancel.
```
Wait for confirmation before proceeding.

## Phase 1: Gather Project Info

Ask the user (all in one message):
```
Let's set up your agent workspace. I need a few details:

1. **Project name**: What is this project called?
2. **Tech stack**: What languages, frameworks, and tools? (e.g., "Next.js 14, TypeScript, Postgres, Prisma")
3. **What are we building?**: One sentence description.
4. **First task**: What's the first thing you want to build or fix?
5. **Mode**: Normal (full quality gates) or MVP (speed over perfection)?
```

## Phase 2: Create .agents/ Directory Structure

Create these files:

### `.agents/state.json`
```json
{
  "project": "[project name from user]",
  "mode": "[normal|mvp from user]",
  "stack": "[tech stack from user]",
  "description": "[description from user]",
  "tasks": [
    {
      "id": "TASK-001",
      "title": "[first task from user]",
      "status": "not-started",
      "agent": "engineer"
    }
  ],
  "context": {
    "blocked_on": null
  },
  "handoff": {
    "approved_by_user": false,
    "to": null
  },
  "security": {
    "last_audit": null,
    "verdict": null
  },
  "changelog": [],
  "last_updated": "[current date ISO]",
  "last_updated_by": "manager"
}
```

### `.agents/state.md`
```markdown
# Project: [project name]

**Mode**: [normal|mvp]  
**Stack**: [tech stack]  
**Last updated**: [date]

## Current Task
TASK-001: [first task title] — not started

## Blockers
None

## Recent Changes
_None yet — project just initialized._
```

### `.agents/workspace-map.md`
```markdown
# Workspace Map

**Project**: [project name]  
**Stack**: [tech stack]

## Structure
_Run a directory listing and populate this after exploring the codebase._

## Key Files
_Add key files as you discover them._

## Conventions
_Add naming conventions, code style, and patterns as you discover them._
```

### `.agents/handoff.md`
```markdown
# Handoff: [empty — awaiting first task]

_No active handoff. Manager will write here when delegating to an agent._
```

## Phase 3: Confirm and Next Steps

Tell the user:
```
✅ Agent workspace initialized!

Files created:
- .agents/state.json     ← machine state
- .agents/state.md       ← human dashboard
- .agents/workspace-map.md
- .agents/handoff.md

**Next**: I'll write the handoff for TASK-001 and you can run:
  /attacca:handoff-to-engineer TASK-001

Want me to do that now?
```

If yes, write the TASK-001 handoff to `.agents/handoff.md` based on what the user described.

## Phase 4: Pre-First-Commit Cleanup

**Before the project's first `git commit`**, the Manager MUST run this checklist. These files exist in the template but must NOT ship in the project repo — they contain proprietary orchestration details, build patterns, and internal instructions.

### Step 1 — Activate the project .gitignore

```bash
# The boilerplate ships with .gitignore.project for exactly this reason.
# Rename it to replace the template's permissive .gitignore:
mv .gitignore.project .gitignore
```

> Why: The template `.gitignore` is intentionally permissive so the boilerplate repo can commit everything. The project `.gitignore` excludes all orchestration files. Without this rename, agent files, internal docs, and distribution packages will be committed to the project repo.

### Step 2 — Replace the README

Delete or replace `README.md`. The boilerplate README documents Attacca — not your product. Create a project-specific README:

```markdown
# [Project Name]

[One-sentence description]

## Getting Started
...

## Tech Stack
...
```

> Why: Publishing the Attacca README under your project makes it look like your product is an AI boilerplate, and leaks the internal toolchain you're using.

### Step 3 — Reset CHANGELOG.md

The existing `CHANGELOG.md` is Attacca's own release history. Either:
- Delete it and create a fresh one starting at `v0.1.0`, or
- Leave it empty for now

> Why: Attacca's internal changelogs (caveman skill additions, designer agent updates, etc.) have nothing to do with your product's history.

### Step 4 — Verify nothing sensitive will be committed

```bash
git status
git diff --cached --name-only   # if you've already staged
```

Confirm none of these appear in the commit:
- `.github/agents/` — agent definitions with your build patterns
- `.github/skills/` — internal skills
- `.github/copilot-instructions.md` — your full orchestration protocol
- `.claude/`, `.gemini/` — IDE adapter files
- `CLAUDE.md`, `AGENTS.md`, `GEMINI.md` — agent entry points
- `DESIGN.md`, `ANTIGRAVITY.md`, `HOW_TO_UPDATE.md`, `RETROFIT.md` — boilerplate docs
- `cli/`, `vscode-extension/`, `website/`, `claude-plugin/` — distribution packages

If any appear, the `.gitignore` rename in Step 1 may not have taken effect. Run:
```bash
git rm --cached -r .github/agents .github/skills .claude .gemini CLAUDE.md AGENTS.md GEMINI.md 2>/dev/null || true
```

### Step 5 — First commit

```bash
git add .
git commit -m "chore: initial project scaffold"
git push origin main
```

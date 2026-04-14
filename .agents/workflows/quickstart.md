---
description: "First-time setup wizard. Prints the welcome banner, detects existing project state, and routes to init-project, initprd, or continues where you left off."
---

# Quickstart

Entry point for new users or new projects.

## Steps

1. Print this welcome banner verbatim:
   ```
   ╔══════════════════════════════════════════════════════════════╗
   ║                                                              ║
   ║    ⚡  ATTACCA — build without pause.                        ║
   ║                                                              ║
   ║    Agents assembled. Give me the mission.                    ║
   ║                                                              ║
   ╚══════════════════════════════════════════════════════════════╝

     Agents on standby:
       Manager    — you're talking to me right now
       Engineer   — implements code, runs tests, commits
       Security   — adversarial auditor before every push
       Designer   — UI/UX review and specs
       Researcher — competitive/market research
       Consultant — deep architectural reasoning
       Medic      — emergency incident response (SEV 1)
   ```

2. Check if `.agents/state.json` already exists.

   **If it exists**: Read it and reply:
   ```
   Project: [project name]
   Last updated: [last_updated]

   Options:
     A) Continue — tell me your next task
     B) Re-initialize — run /init-project to start fresh
   ```
   Then wait for user choice and proceed accordingly.

   **If it does NOT exist**: Ask the user:
   ```
   Let's get you started. Which fits your situation?

   A) I have a PRD or spec file  → run /init-project
   B) I want to describe my idea → run /init-project
   C) Just tell me what to build → describe it and I'll set up the workspace
   ```
   Route to /init-project or proceed directly based on their answer.

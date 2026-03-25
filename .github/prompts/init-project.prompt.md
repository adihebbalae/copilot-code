---
description: "Initialize a new project from a PRD. Give the Manager your product requirements and it will scaffold the entire project pipeline."
agent: "manager"
argument-hint: "Paste your PRD or describe what you want to build"
---

The user is starting a new project. Your job:

1. Read the PRD or description provided below
2. Ask clarifying questions until there is ZERO ambiguity — interrogate endlessly
3. Once clear, scaffold the project:
   - **Rename `.gitignore.project` → `.gitignore`** (replaces the template .gitignore with the project one)
   - Fill out `.agents/state.json` with the project plan, phases, and initial tasks
   - Update `.agents/state.md` with project overview
   - Update `.agents/workspace-map.md` with planned structure
   - Update `.github/copilot-instructions.md` with project-specific standards
   - Identify and list any MCPs, skills, or tools needed for this specific project
4. Present the full plan to the user for approval before proceeding

PRD / Description:
$ARGUMENTS

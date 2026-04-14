---
description: "Initialize the agent workspace from a PRD, file, or idea. Creates .agents/ structure, task list, and workspace-map. Run once when starting a new project."
---

# Init Project

Initialize a new project from a PRD, file, or idea.

## Steps

1. Ask the user for their project input: a PRD document, file upload, or description of the idea.
2. Research: gather market/competitive/tech intelligence if applicable.
3. Ask clarifying questions until there is zero ambiguity.
4. Break the project into discrete, testable tasks with acceptance criteria.
5. Write the task list to `.agents/state.json`.
6. Scaffold the initial file structure.
7. Update `.agents/workspace-map.md` with the new structure.
8. Present the plan to the user and ask: "Any changes before I proceed?"

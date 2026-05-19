# Parallelize: Fan Out Task Execution

## Command: `/parallelize`

Run parallelization setup for 2+ isolated tasks.

## Input
A list of 2+ task IDs (e.g., `TASK-A`, `TASK-B`, `TASK-C`)

## Output
1. Validate the isolation checklist from `.agents/parallelization-protocol.md`:
   - Each task operates on separate directory trees
   - No task is a dependency of another in the set
   - All tasks depend on same prior-completed task (or no dependencies)
   - Handoff files will use distinct filenames
   - Manager will track via state.json array form

2. Create per-task handoff files:
   - `.agents/handoff.md` → Primary task
   - `.agents/handoff-TASK-B.md` → Task B
   - `.agents/handoff-TASK-C.md` → Task C
   - (Copy relevant sections from planning into each file)

3. Update `.agents/state.json` → `handoff` field to array form:
   ```json
   "handoff": [
     { "task_id": "TASK-A", "status": "in_progress", "prompt_file": ".agents/handoff.md" },
     { "task_id": "TASK-B", "status": "in_progress", "prompt_file": ".agents/handoff-TASK-B.md" },
     { "task_id": "TASK-C", "status": "in_progress", "prompt_file": ".agents/handoff-TASK-C.md" }
   ]
   ```

4. Tell the user how to dispatch:
   - **Claude Code (VS Code native)**: "I'll spawn subagents for each task — check the sidebar for parallel runs."
   - **Copilot / Cursor / Cline / Windsurf / Codex / Gemini**: "Open N separate sessions (one per task), each reading their assigned `.agents/handoff-TASK-X.md` file. I'll show you the handoff banners below."

5. Show per-task handoff banners:
   ```
   ╔══════════════════════════════════════════════════════════════╗
   ║  🔀 SWITCH TO:  @engineer   |   MODEL:  Sonnet              ║
   ║     TASK-B (primary)
   ╚══════════════════════════════════════════════════════════════╝
   
   ╔══════════════════════════════════════════════════════════════╗
   ║  🔀 SWITCH TO:  @engineer   |   MODEL:  Sonnet              ║
   ║     TASK-C (parallel)
   ╚══════════════════════════════════════════════════════════════╝
   ```

## Rules
- Only parallelize if isolation checklist is 100% satisfied
- If any task has overlapping files with another, block parallelization and ask user to refactor
- If any task is a dependency of another, block parallelization and explain the dependency chain
- Do NOT proceed with parallelization if validation fails

## Key Handoff Rules for Engineers
When an Engineer reads their assigned handoff file:
- If it's `.agents/handoff.md`, they read the primary task
- If it's `.agents/handoff-TASK-X.md`, they read the parallel task
- On completion, they **delete only their own handoff file** — never touch other parallel files
- Deletion signals to Manager that their task slot is free

For full protocol, see `.agents/parallelization-protocol.md`.

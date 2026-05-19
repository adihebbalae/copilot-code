# Parallelization Protocol

When 2+ independent tasks are in flight, the Manager fans out work using this protocol to coordinate parallel Engineer runs.

## Key Rules for Parallel Task Execution

### 1. Task Isolation is Mandatory
- Each task must operate on **completely separate directory trees**
- No shared file paths or overlapping code concerns
- Example of safe parallelization:
  - TASK-A: `src/modules/dashboard/`
  - TASK-B: `src/lib/api/` + `src/api/`
  - TASK-C: `src/components/canvas/`

### 2. Handoff File Naming Convention
- **Primary task**: `.agents/handoff.md`
- **Parallel task 1**: `.agents/handoff-TASK-A.md`
- **Parallel task 2**: `.agents/handoff-TASK-B.md`
- Each engineer receives a dedicated handoff file — no shared prompts

### 3. Engineer Cleanup Responsibility
When a parallel task completes, the engineer **MUST**:
1. Commit all work
2. Delete **ONLY your own handoff file** (e.g., if your prompt came from `.agents/handoff-TASK-A.md`, delete that one file ONLY)
3. **DO NOT** delete other `handoff-*.md` files — other parallel engineers may still be reading them
4. This signals to the Manager that your task slot is free

**Failure to cleanup leaves stale handoff files** that confuse future state tracking.  
**Deleting other engineers' files breaks their task execution** — keep hands off!

### 4. Manager State Coordination
Manager tracks parallel tasks as an array in `state.json`:
```json
"handoff": [
  { "task_id": "TASK-A", "status": "in_progress", "prompt_file": ".agents/handoff.md" },
  { "task_id": "TASK-B", "status": "in_progress", "prompt_file": ".agents/handoff-TASK-B.md" },
  { "task_id": "TASK-C", "status": "in_progress", "prompt_file": ".agents/handoff-TASK-C.md" }
]
```

### 5. Zero Dependencies Required
Only parallelize tasks where:
- All tasks depend on the same earlier-completed task (or no dependencies)
- No task depends on another task in the parallelization set
- All tasks may depend on prior-completed work

**Bad example**: Don't parallelize TASK-B + TASK-D if TASK-B is a dependency of TASK-D.

## Decision Checklist Before Parallelizing

Before proposing a parallelization, verify:

- [ ] Each task operates on separate directory trees (no code conflicts)
- [ ] No task is a dependency of another in the set
- [ ] All tasks depend on same prior task (or no dependencies)
- [ ] Handoff files use distinct filenames (`.agents/handoff-TASK-*.md`)
- [ ] Each task has explicit cleanup instruction
- [ ] State.json array structure is used for tracking

## Example: TASK-A, TASK-B, TASK-C

✅ **Safe to parallelize**:
- TASK-A (Dashboard): `src/modules/dashboard/`
- TASK-B (API layer): `src/lib/api/`, `src/api/`
- TASK-C (Canvas component): `src/components/canvas/`, `src/modules/dashboard/canvas/`

All depend only on TASK-Z (prior completed) ✅, zero overlap, zero dependencies within set.

## Isolation Verification Steps

1. **Scan file paths**: List all files each task will modify. Ensure zero overlaps.
2. **Check dependencies**: Verify each task only depends on completed tasks or common base tasks.
3. **Naming convention**: Confirm handoff files follow `handoff.md` and `handoff-TASK-*.md` pattern.
4. **Cleanup contract**: Each Engineer understands they delete only their own handoff file.
5. **State schema**: Manager will update `state.json` `handoff` field to array form during fan-out.

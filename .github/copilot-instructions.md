# Project Instructions

## Agent System Protocol

This project uses a multi-agent architecture. Every agent MUST follow this protocol.

### On Session Start
1. Read `.agents/state.json` to understand current project state, active task, and context
2. Read `.agents/workspace-map.md` if you need to locate files or understand project structure
3. Identify your role and act within your boundaries
4. Do NOT proceed on a handoff if `handoff.approved_by_user` is `false` — wait for user approval

### On Session End
1. Update `.agents/state.json` with:
   - What you accomplished (add to `changelog`)
   - Current task status
   - Any blockers or decisions made
   - Updated `last_updated` and `last_updated_by`
2. Update `.agents/state.md` with a human-readable summary of changes
3. If you created or moved files, update `.agents/workspace-map.md`

### Handoff Protocol
When work needs to transfer between agents:
1. The sending agent writes the handoff prompt to `.agents/handoff.md`
2. The sending agent updates `state.json` → `handoff` field with target agent, model, and context
3. The sending agent shows a prominent banner to the user:
   ```
   ╔══════════════════════════════════════════════════════════════╗
   ║  🔀 SWITCH TO:  @[agent]   |   MODEL:  [Model]             ║
   ╚══════════════════════════════════════════════════════════════╝
   ```
   Then tells the user to run `/handoff-to-[agent]` or copy `.agents/handoff.md` to the target agent.

### State Files — Do Not Proliferate
- `.agents/state.json` — Machine state (single source of truth)
- `.agents/state.md` — Human-readable dashboard
- `.agents/workspace-map.md` — File/directory reference
- `.agents/handoff.md` — Current handoff prompt
- **No other state/summary files.** If it's not in these four files, it doesn't exist.

## Code Standards
- Write clean, readable code with meaningful names
- Handle errors at system boundaries (user input, API calls, external data)
- Never commit secrets, API keys, or credentials
- Run tests before declaring work complete
- Run the `quality-gate` skill before every push (lint → type-check → tests → security scan). Do not push with any stage failing.

## Communication Principles
- **Always include WHY**: When making a decision, choosing a priority, or recommending an approach, explain the reasoning. "Do X because Y" not just "Do X."
- **Research first**: Before making changes, search the codebase for existing patterns and conventions. Understand what exists before creating something new.
- **Close the loop**: If tests fail, fix them and re-run. If a build breaks, fix it. Don't report back with broken state — iterate until green.
- **Keep workspace organized**: Update `.agents/workspace-map.md` when files are created or moved. An organized workspace saves tokens and prevents drift.

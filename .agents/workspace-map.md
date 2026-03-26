# Workspace Map

> Updated by agents whenever files are created, moved, or deleted.
> Agents read this to orient themselves instead of scanning the entire codebase.

## Project Structure

```
.github/
  copilot-instructions.md       # Base project instructions (always loaded)
  agents/
    manager.agent.md             # Planner/orchestrator — user's primary contact
    engineer.agent.md            # Code executor — implements features
    security.agent.md            # Adversarial security auditor
    designer.agent.md            # UI/UX design consultant
    consultant.agent.md          # Deep reasoning specialist (Opus)
  prompts/
    handoff-to-engineer.prompt.md   # Quick handoff template → Engineer
    handoff-to-security.prompt.md   # Quick handoff template → Security
    handoff-to-designer.prompt.md   # Quick handoff template → Designer
    handoff-to-consultant.prompt.md # Quick handoff template → Consultant
    init-project.prompt.md          # PRD intake and project scaffolding
    digest-prd.prompt.md            # Digest large PRDs (500-2000+ lines) into brief + task backlog
    review-dependencies.prompt.md   # Pre-handoff dependency vetting for supply chain security
    learn.prompt.md                 # Extract session patterns → copilot-instructions.md
  skills/
    code-review/SKILL.md         # On-demand code review checklist
    security-audit/SKILL.md      # On-demand security audit checklist
    tdd/SKILL.md                 # TDD workflow — RED → GREEN → REFACTOR
    quality-gate/SKILL.md        # Pre-push gate: lint + type-check + test + security scan

.agents/
  state.json                     # Machine-readable project state (source of truth)
  state.md                       # Human-readable project dashboard
  workspace-map.md               # THIS FILE — directory reference
  handoff.md                     # Current inter-agent handoff prompt

.gitignore                       # TEMPLATE .gitignore (commits all agent files)
.gitignore.project               # PROJECT .gitignore (rename after cloning — strips agent files)
README.md                        # Boilerplate documentation
```

## Key Directories
_To be populated when the project is scaffolded by the Manager._

## Key Files
_To be populated as the project grows._

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
  copilot/
    hooks.json                       # Copilot lifecycle hooks (pre-push → quality-gate, pre-commit → workspace-map)
  prompts/
    handoff-to-engineer.prompt.md   # Quick handoff template → Engineer
    handoff-to-security.prompt.md   # Quick handoff template → Security
    handoff-to-designer.prompt.md   # Quick handoff template → Designer
    handoff-to-consultant.prompt.md # Quick handoff template → Consultant
    init-project.prompt.md          # PRD intake (file/paste/idea), research, scaffolding, GitHub Issues, Context7 MCP
    mvp.prompt.md                   # MVP mode: max velocity, aggressive parallelization, deferred gates
    review-dependencies.prompt.md   # Pre-handoff dependency vetting for supply chain security
    retrofit.prompt.md              # Retrofit existing projects; IDE-specific (VS Code, JetBrains, Eclipse, Xcode)
    learn.prompt.md                 # Extract session patterns → copilot-instructions.md + Copilot Memory
    remember-handoff.prompt.md      # Write handoff to Copilot Memory — eliminates copy-paste between agents
  skills/
    code-review/SKILL.md              # On-demand code review checklist
    security-audit/SKILL.md           # On-demand security audit checklist
    tdd/SKILL.md                      # TDD workflow — RED → GREEN → REFACTOR
    quality-gate/SKILL.md             # Pre-push gate: lint + type-check + test + security scan
    update-workspace-map/SKILL.md     # Auto-regenerate workspace-map.md post-commit
    supply-chain/SKILL.md             # Standalone 4-gate supply chain security (submittable to awesome-copilot)
    sbom/SKILL.md                     # Native SBOM generation via syft/cdxgen + CVE scan via osv-scanner

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

# Workspace Map

> Updated by agents whenever files are created, moved, or deleted.
> Agents read this to orient themselves instead of scanning the entire codebase.

## Project Structure

```
.github/
  copilot-instructions.md       # Base project instructions (always loaded)
  BOILERPLATE_VERSION           # Semantic version (v3.0.0)
  agents/
    manager.agent.md             # Planner/orchestrator — user's primary contact
    engineer.agent.md            # Code executor — implements features
    security.agent.md            # Adversarial security auditor
    designer.agent.md            # UI/UX design consultant
    consultant.agent.md          # Deep reasoning specialist (Opus)
    medic.agent.md               # Emergency incident responder
    researcher.agent.md          # Product/market researcher
    meta-manager.agent.md        # Boilerplate dev meta-manager
    meta-researcher.agent.md     # Boilerplate dev meta-researcher
  copilot/
    hooks.json                   # Copilot lifecycle hooks
  prompts/
    handoff-to-engineer.prompt.md
    handoff-to-security.prompt.md
    handoff-to-designer.prompt.md
    handoff-to-consultant.prompt.md
    handoff-to-researcher.prompt.md
    init-project.prompt.md
    mvp.prompt.md
    review-dependencies.prompt.md
    retrofit.prompt.md
    learn.prompt.md
    remember-handoff.prompt.md
    auto-run.prompt.md
    prd-builder.prompt.md
    quickstart.prompt.md
    setup-budget.prompt.md
    list-modules.prompt.md
    show-graph.prompt.md
    update-boilerplate.prompt.md
    parallelize.prompt.md           # Parallel task fanout (v3.9.0+)
    git.prompt.md
    hotfix.prompt.md
    meta.prompt.md
    btw.prompt.md
    disable-agent.prompt.md
    enable-agent.prompt.md
  skills/                          # Source of truth for all auto-loaded skills.
                                   # Mirror this dir to .claude/skills/ via
                                   # scripts/sync-skills.mjs.
    code-review/SKILL.md
    security-audit/SKILL.md
    tdd/SKILL.md
    quality-gate/SKILL.md
    update-workspace-map/SKILL.md
    supply-chain/SKILL.md
    sbom/SKILL.md
    auto-run/SKILL.md
    incident-response/SKILL.md
    caveman/SKILL.md
    karpathy-guidelines/SKILL.md
    llm-wiki/SKILL.md
    # Alignment & design discipline (adapted from mattpocock/skills, v3.8.0):
    grill-me/SKILL.md
    grill-with-docs/SKILL.md       # also: CONTEXT-FORMAT.md, ADR-FORMAT.md
    diagnose/SKILL.md
    zoom-out/SKILL.md
    to-prd/SKILL.md
    to-issues/SKILL.md
    improve-codebase-architecture/SKILL.md   # also: LANGUAGE.md, INTERFACE-DESIGN.md, DEEPENING.md
    prototype/SKILL.md             # also: LOGIC.md, UI.md
  scripts/
    auto-run.ps1                 # PowerShell orchestrator for CLI autonomous execution
    backup.ps1

packs/                             # Opt-in skill packs (NOT auto-loaded by agents)
  marketing/
    skills/                        # 33 marketing skills — moved here in v3.8.0
                                   # so they don't pollute coding-project context
      ab-test-setup/, ad-creative/, ai-seo/, analytics-tracking/,
      churn-prevention/, cold-email/, competitor-alternatives/,
      content-strategy/, copy-editing/, copywriting/, email-sequence/,
      form-cro/, free-tool-strategy/, launch-strategy/, marketing-ideas/,
      marketing-psychology/, onboarding-cro/, page-cro/, paid-ads/,
      paywall-upgrade-cro/, popup-cro/, pricing-strategy/,
      product-marketing-context/, product-research/, programmatic-seo/,
      referral-program/, revops/, sales-enablement/, schema-markup/,
      seo-audit/, signup-flow-cro/, site-architecture/, social-content/

scripts/                           # Boilerplate-dev helper scripts (not shipped to projects)
  sync-skills.mjs                  # Mirror .github/skills/ -> .claude/skills/ (added v3.8.0)

.agents/
  state.json                     # Machine-readable project state (source of truth)
  state.md                       # Human-readable project dashboard
  workspace-map.md               # THIS FILE
  handoff.md                     # Current inter-agent handoff prompt
  handoff-TASK-*.md              # Parallel task handoffs (v3.9.0+)
  parallelization-protocol.md    # Protocol for fanout of 2+ independent tasks (v3.9.0+)
  MODULES.md                     # Module registry (complex projects)
  rules/                         # Antigravity adapter rules
    protocol.md                  # Core protocol (Antigravity)
    manager.md                   # Manager agent (Antigravity)
    engineer.md                  # Engineer agent (Antigravity)
    security.md                  # Security agent (Antigravity)
  workflows/                     # Antigravity adapter workflows
    init-project.md              # /init-project workflow
    handoff-to-engineer.md       # /handoff-to-engineer workflow
    handoff-to-security.md       # /handoff-to-security workflow

claude-plugin/                   # Claude Code native plugin (install with /plugin install)
  .claude-plugin/
    plugin.json                  # Plugin manifest (name: agent-boilerplate, v3.1.0)
  agents/                        # Self-contained agents (inline protocol, no .github/ refs)
    manager.md                   # Orchestrator — default agent via settings.json
    engineer.md                  # Code implementation
    security.md                  # Adversarial auditor (read-only)
    designer.md                  # UI/UX reviewer
    researcher.md                # Market/competitive research
    consultant.md                # Architectural decisions (Opus)
    medic.md                     # SEV 1 incident responder (Opus)
  skills/                        # Model-invoked skill checklist (same SKILL.md format)
    code-review/SKILL.md
    quality-gate/SKILL.md
    tdd/SKILL.md
    security-audit/SKILL.md
  commands/                      # User-invoked: /agent-boilerplate:<command>
    init-project.md
    handoff-to-engineer.md
    handoff-to-security.md
    handoff-to-designer.md
    handoff-to-researcher.md
    handoff-to-consultant.md
  hooks/
    hooks.json                   # PostToolUse lint hook
  settings.json                  # Sets "agent": "manager"
  README.md                      # Install instructions + quick start

.cursor/                         # Cursor adapter
  rules/
    protocol.mdc                 # Core protocol (alwaysApply: true)
    manager.mdc                  # Manager agent
    engineer.mdc                 # Engineer agent
    security.mdc                 # Security agent
    skill-code-review.mdc        # Code review skill
    skill-quality-gate.mdc       # Quality gate skill
    skill-tdd.mdc                # TDD skill

.clinerules/                     # Cline adapter
  protocol.md                    # Core protocol (always active)
  manager.md                     # Manager agent
  engineer.md                    # Engineer agent (paths: src/**, lib/**)
  security.md                    # Security agent
  testing.md                     # Testing rules (paths: **/*.test.*)
  quality-gate.md                # Quality gate

.windsurfrules                   # Windsurf adapter (single concatenated file)

.claude/                         # Claude Code CLI adapter
  agents/                        # Subagent definitions
  settings.json                  # Model, permissions, hooks

.gemini/                         # Gemini CLI adapter
  settings.json                  # Hooks configuration

cli/                             # npx create-agent-boilerplate
  package.json                   # CLI package config
  bin/
    index.js                     # Entry point (#!/usr/bin/env node)
  src/
    adapters.js                  # Adapter file generators (all 8 adapters)
    shared.js                    # Shared state files generator

CLAUDE.md                        # Claude Code CLI bootstrap
AGENTS.md                        # Codex CLI bootstrap
GEMINI.md                        # Gemini CLI bootstrap
README.md                        # Boilerplate documentation
CHANGELOG.md                     # Version history
RETROFIT.md                      # Existing project migration guide
.gitignore                       # Template .gitignore (commits agent files)
.gitignore.project               # Project .gitignore (strips agent files)
.claudeignore                    # Claude Code CLI token savings
```

## Key Directories
_To be populated when the project is scaffolded by the Manager._

## Key Files
_To be populated as the project grows._

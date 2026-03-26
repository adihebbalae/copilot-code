# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.1] - 2026-03-26

### Fixed
- Updated Researcher agent identity to match Consultant's powerful "observed more than any human" framing

## [1.2.0] - 2026-03-26

### Added
- **Researcher agent** — 6th agent for competitive analysis, market research, and feature gap identification
  - PM lens: user needs, JTBD, prioritization signals
  - PMM lens: competitive positioning, market language, GTM patterns
  - Epistemic labeling: [CONFIRMED], [INFERRED], [UNVERIFIED], [GAP]
  - Outputs to `.agents/research/[topic-slug].md` (persists across sessions)
- **product-research skill** — 6 frameworks: ICP Analysis, Competitive Landscape, TAM/SAM/SOM, JTBD, Positioning Gap Analysis, GTM Patterns
- `/handoff-to-researcher` prompt with TASK-ID auto-lookup
- Web Search MCP setup in `/init-project` (Tavily/Brave/Perplexity)
- Manager Section 8: Researcher Routing Rules

## [1.1.0] - 2026-03-26

### Added
- `/meta` prompt — Answer framework meta questions about agents, tools, skills, workflow
- `/git` prompt — Query GitHub repo state (issues, PRs, commits, workflows, branches)

## [1.0.0] - 2026-03-26

### Added
- TASK-ID auto-lookup in all 4 handoff prompts — just run `/handoff-to-engineer TASK-001`, agent reads title from `state.json` automatically
- Manager now writes structured `tasks{}` to `state.json` on every handoff
- `/update-boilerplate` prompt — safely migrate boilerplate-owned files from template repo
- `BOILERPLATE_VERSION` file for version tracking

### Changed
- Handoff banner instruction simplified: `"/handoff-to-engineer TASK-001"` instead of typing full task name

## [0.9.0] - 2026-03-25

### Added
- Specific chat names for handoff prompts — agents output rename suggestion as first line
- `argument-hint` field in all 4 handoff prompts

## [0.8.0] - 2026-03-25

### Added
- **MVP mode** — maximum velocity, aggressive parallelization, deferred gates
- Manager MVP Mode section: scope freeze, parallel push, deferred security
- Engineer MVP Mode section: vibe mode always on, smoke tests only
- `/mvp` prompt: 60-second intake, scope razor, parallel execution plan

## [0.7.0] - 2026-03-24

### Added
- Manager reads all skills on session start (`SKILL.md` files)
- Skill Suggestion Rules lookup table in Manager
- Proactive skill surfacing — Manager suggests relevant skills based on user's request

## [0.6.0] - 2026-03-24

### Added
- **Vibe mode** — compact reporting for rapid iteration, saves ~20% context
- Engineer outputs `✅ COMPLETE | Commit: [hash]` format when vibe_mode enabled

## [0.5.0] - 2026-03-23

### Added
- 30-day package age policy — all new dependencies must be ≥30 days old
- `/retrofit` prompt — retrofit existing projects (VS Code, JetBrains, Eclipse, Xcode)
- RETROFIT.md guide for gradual adoption

## [0.4.0] - 2026-03-22

### Added
- **Supply chain security** — defense-in-depth 4-gate system
  - Gate 1: Handoff constraint (Manager approves deps before handoff)
  - Gate 2: Pre-review (`/review-dependencies` vets packages)
  - Gate 3: Quality gate (dependency audit)
  - Gate 4: Security audit (SBOM review)
- `supply-chain` skill — standalone 4-gate supply chain defense
- `sbom` skill — native SBOM generation via syft/cdxgen + CVE scan

## [0.3.0] - 2026-03-21

### Added
- GitHub Issues backlog in `/init-project` — creates tasks via `gh issue create`
- Context7 MCP auto-detection in `/init-project` — generates `.vscode/mcp.json` based on detected stack
- `/learn` extended to Copilot Memory
- `/remember-handoff` prompt — writes compressed handoff to Copilot Memory
- `update-workspace-map` skill
- Copilot Hooks (`.github/copilot/hooks.json`): `pre-push` → quality-gate, `pre-commit` → update-workspace-map
- Manager Section 8: Consultant auto-escalation rules

## [0.2.0] - 2026-03-20

### Added
- All 5 agents migrated to official GitHub Copilot tool names (`codebase`, `editFiles`, `browser`, `githubRepo`, `search`, `problems`, `runCommands`, `terminal`)
- `/digest-prd` prompt — digest large PRDs (500–2000+ lines) into brief + task backlog
- Boilerplate dev mode guard in `copilot-instructions.md`

### Changed
- README quickstart: one-command template clone via `gh repo create --template`

## [0.1.0] - 2026-03-19

### Added
- Initial boilerplate: 5 agents (Manager, Engineer, Security, Designer, Consultant)
- 7 skills: code-review, security-audit, tdd, quality-gate, supply-chain, sbom, update-workspace-map
- 10 prompts: init-project, digest-prd, review-dependencies, retrofit, remember-handoff, learn, handoff-to-*
- State management: `state.json`, `state.md`, `workspace-map.md`, `handoff.md`
- `.gitignore.project` pattern (template .gitignore vs project .gitignore)

---

## Version Numbering

- **MAJOR** (X.0.0): Breaking changes to agent/prompt/skill interfaces or workflow
- **MINOR** (0.X.0): New agents, skills, prompts, or significant feature additions
- **PATCH** (0.0.X): Bug fixes, documentation, minor text updates

Next planned: v1.3.0 will include [describe next feature set if known]

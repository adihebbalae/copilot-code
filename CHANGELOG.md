# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.4.0] - 2026-03-31

### Breaking Change
- **`/digest-prd` removed** — Deleted entirely. `/init-project` now handles all input types: PRD file path, inline paste, or raw idea with no PRD. The architectural reason for two commands (inline context limit) is obsolete — agents read files directly. There is no migration needed: just use `/init-project`.

### Added
- **Phase 0: Safety check** — `/init-project` now detects existing `state.json` at startup. If the project is already initialized, it shows the current project name, status, and active task, then offers choices: continue (switch to engineer) or overwrite (requires explicit confirmation `"yes overwrite"`). Prevents silent data loss.
- **Phase 1: Smart PRD detection** — Priority order: (1) file path in `$ARGUMENTS`, (2) auto-scan root for `prd.md`, `PRD.md`, `*prd*.md`, `*spec*.md`, `*requirements*.md`, (3) if multiple files found, list and ask user to pick, (4) if none found, build PRD inline via Socratic questioning. No second command needed.
- **Inline PRD Builder** — When no PRD exists, `/init-project` runs the full Socratic interrogation (problem, users, features, constraints, stack, timeline) inline. Saves result to `.dev/prd/original.md` and continues. User never needs to know `/prd-builder` exists.
- **PRD compression step (Phase 2)** — Immediately after reading any PRD, compresses to a ~50-line Project Brief and drops the raw PRD from context. Solves context overflow for large PRDs (2000+ lines) without sacrificing depth — Manager operates only on the brief from this point forward.
- **Architecture decision phase** — Explicit phase for surfacing and resolving architecture choices (monolith vs. microservice, REST vs. GraphQL, auth strategy) before scaffolding. Choices recorded in `state.json`.
- **Unified 11-phase flow**: Phase 0 (safety), 1 (detect), 1.5 (stage), 2 (compress), 3 (research), 4 (team setup), 5 (zero ambiguity), 6 (architecture), 7 (tasks), 8 (plan review), 9 (scaffold), 10 (summary), 11 (handoff).

### Changed
- **`/init-project` description** updated to reflect universal input handling
- **README** prompts table updated — removed `/digest-prd` row, updated `/init-project` description
- **RETROFIT.md** — all references to `/digest-prd` replaced with `/init-project`
- **`.agents/workspace-map.md`** — removed `digest-prd.prompt.md` entry, updated `init-project` description
- **`update-boilerplate.prompt.md`** — removed `digest-prd` from auto-update list

### Why
Two commands for one workflow created confusion (users ran both, getting questions skipped or work overwritten). The only technical reason for `/digest-prd` was `$ARGUMENTS` context limits — now irrelevant since agents read files directly. One command with smart detection is strictly better: less cognitive overhead, no accidental double-initialization, no stale/skipped phases. Context compression via brief extraction solves the large-PRD problem cleanly without multi-chat complexity.

## [2.3.2] - 2026-03-31

### Added
- **Manager model selection strategy** — Both `/init-project` and `/digest-prd` now explicitly specify model allocation: Opus/Sonnet for planning phases (1–6), default to Haiku for clarifying questions to conserve tokens. Tasks get their optimal model assignment (Engineer: Sonnet, Security: Opus, etc.). Provides clear guidance on token efficiency without sacrificing quality.
- **PRD staging system** — New Phase 0.5 in `/init-project` and Phase 1.5 in `/digest-prd` move raw PRDs to `.dev/prd/original.md` immediately after intake. Keeps workspace root clean, prevents accidental commits of planning artifacts, and establishes `.dev/` as the canonical temporary folder for all projects.
- **`.dev/` folder gitignore requirement** — Both prompts now ensure `.dev/` and `_dev/` are in final `.gitignore`. Phase 5 (cleanup) verifies and adds entries if missing. Guarantees temporary planning files never commit.

### Why
Long PRDs and planning processes create temporary artifacts that clutter the project root and risk accidental commits. By systematically staging PRDs into `.dev/prd/` and ensuring it's gitignored, every project starts clean. Model selection guidance makes token allocation explicit — a clear win for budget-conscious workflows.

## [2.3.1] - 2026-03-31

### Changed
- **`/digest-prd` zero-ambiguity gate** — Upgraded Phase 3 from "Clarify Blockers Only" to "Clarify Until Zero Ambiguity" with explicit criteria and deeper probing instructions. Phase 9 Reflection Gate now explicitly confirms "Zero Ambiguity Cleared" and validates no hidden assumptions remain. Matches robustness of `/init-project` when handling long, complex PRDs. Prevents downstream agents from inheriting vague requirements.

### Why
`/digest-prd` is designed for 500–2000+ line PRDs where ambiguity risk is highest. By applying the same zero-ambiguity interrogation pattern from `/init-project`, agents can execute with confidence rather than guessing at intent. Critical when PRDs are dense and contradictory.

## [2.3.0] - 2026-03-29

### Added
- **🚨 ANTI-HALLUCINATION PROTOCOLS** — Mandatory verification standards for Researcher and Meta-Researcher agents. Prevents false research findings from causing downstream business failures. Includes: (1) Never claim something doesn't exist without `[GAP]` qualifier, (2) Distinguish training knowledge from live verification, (3) Explicit confidence levels `[CONFIRMED]`/`[LIKELY]`/`[INFERRED]`/`[GAP]`, (4) Source everything with date, (5) 6-point verification checklist before report submission, (6) "When in doubt, say so" principle. **Critical fix**: Original researcher hallucinated that Meta Tribe V2 doesn't exist; it does (ai.meta.com, Hugging Face model, public demo).
- **`/btw` prompt** — Context-free question or steering command. Ask quick questions or provide mid-task steering without derailing the agent. Agent answers concisely (1-3 sentences) and resumes previous task automatically. Reduces friction for "wait, what does X mean?" interruptions during implementation.
- **Meta-Researcher agent** — Internal research arm for framework development. Writes competitive analyses, roadmap research, and technical feasibility studies to `.agents/_dev/` (gitignored). Used by Meta-Manager for architectural decisions. Distinct from regular Researcher (which helps users build products). Includes same anti-hallucination protocols.
- **`implementable-features-copilot-code-2026.md`** — Analysis document extracting 7 next-level optimizations from copilot-code research: context budget tracking, auto-enable vibe mode, PostToolUse hooks, IDE-specific guides, auto-generate Claude agents, randomized security audits, context pressure detection. Prioritized for v2.3-v2.4 roadmap.
- **`correction-tribe-v2.md`** — Root cause analysis and corrected findings for Meta Tribe V2 hallucination. Documents what went wrong, correct information (Tribe V2 exists with Hugging Face API), and revised advertising agent recommendation.

### Fixed
- **🚨 CRITICAL: Researcher hallucination prevention** — Added 7 mandatory anti-hallucination rules to prevent false negatives. Original research falsely claimed "Meta Tribe V2 doesn't exist" when it does (public blog, demo, Hugging Face model). This would have caused incorrect architectural decisions for advertising agent. Now requires explicit confidence tagging, source citations, and distinction between training knowledge vs. live verification.
- **Researcher agent web access** — Corrected tools from `[browser, search]` (non-existent in VS Code) to `[fetch_webpage]` (actual available tool). Added prominent documentation explaining web access limitations when spawned as subagent vs. separate chat with web MCP server. Previous researcher invocations synthesized from training knowledge instead of live web research.

### Changed
- **v2.1 roadmap status** — Marked Feature 1 (Complex Project Mode) as ✅ SHIPPED, Feature 2 (Deployer agent) as ⏸️ PINNED FOR FUTURE. Deployer research complete and technically feasible, but deferred to v2.4+ in favor of v2.3 optimizations (context budget tracking, PostToolUse hooks).
- **Researcher agent instructions** — Added "Web Access Limitations" section explaining when to recommend separate chat vs. subagent mode. Researcher now explicitly tells Manager when research requires full web access. Added mandatory 6-point verification checklist before submitting reports.
- **Meta-Researcher agent instructions** — Same anti-hallucination protocols as Researcher. Framework architectural decisions must be evidence-based.

### Why
**This release prevents research hallucinations** — the single most dangerous failure mode in agent systems. False research findings cause cascading business failures (wrong tech stack, missed opportunities, incorrect market sizing). The original researcher hallucinated that Meta Tribe V2 doesn't exist, which would have excluded it from advertising agent consideration. With mandatory anti-hallucination protocols, every claim now requires confidence tagging, source citations, and explicit "I don't know" when verification is impossible. The `/btw` command reduces conversational overhead. Meta-Researcher enables evidence-based framework development. The copilot-code analysis provides a clear roadmap for v2.3-v2.4.

## [2.2.1] - 2026-03-29

### Added
- **`/prd-builder` prompt** — Socratic method PRD construction tool. Interrogates user endlessly (problem, solution, feasibility, GTM) until zero ambiguity, then generates a production-grade PRD ready for `/init-project`. Eliminates "I thought we were building X but you meant Y" disasters. Particularly useful for first-time users who don't know how to structure a PRD.
- **`/quickstart` prompt** — Interactive onboarding walkthrough for first-time users. Explains the repo, asks about tools/experience level, provides tailored guides (beginner vs power user), and nudges user to start their first project with `/prd-builder` or `/init-project`. Reduces time-to-first-commit from hours to minutes.
- **README prompts table** — Added `/prd-builder` and `/quickstart` to main documentation. Prompts now lead with onboarding tools to reduce first-time friction.

### Changed
- README prompts table — now leads with `/quickstart` (start here!) and `/prd-builder` before `/init-project`

### Why
New users cloning the template faced two blockers: (1) "What is this system?" (no clear entry point), and (2) "How do I write a PRD?" (assumed knowledge). `/quickstart` onboards in <10 minutes with tailored guides based on experience level. `/prd-builder` constructs PRDs from scratch using Socratic questioning — no prior knowledge required. Together, these tools reduce onboarding friction from "intimidating" to "guided."

## [2.2.0] - 2026-03-29

### Added
- **Research-First Phase** — `/init-project` now invokes Researcher before scaffolding. Manager identifies research opportunities in the PRD (new market, competitive analysis, tech validation, free tools), spawns Researcher subagent autonomously, and shows findings to user before asking setup questions or clarifications.
- **Research Attribution** — All project scaffolding references `.agents/research/[slug].md`. Future sessions know decisions are grounded in market evidence, not hunches. Added to `.agents/state.json` → `research_source` and `research_findings_incorporated`.
- **7-Phase Init Workflow** — `/init-project` execution now follows: (1) PRD intake + research scoping, (2) invoke Researcher, (3) show findings, (4) team setup questionnaire, (5) PRD clarifications, (6) present plan, (7) scaffold with research incorporated
- **Phase 7 Sub-Steps** — GitHub Issues, MCP config, web search MCP, MODULES.md, and post-scaffolding messaging as structured sub-steps of the main scaffolding phase

### Changed
- `/init-project` prompt — completely restructured into 7 phases with explicit research intake phase
- Manager Section 1 (Planning & Scoping) — "Research first" now refers to invoking Researcher subagent on PRD intake
- README Quick Start — now shows "PRD → Research → Project" instead of "PRD → Project"
- README Adaptive Workflow — updated to explain research findings impact on tech stack recommendations

### Why
Developers often scaffold projects based on hunches — "React is fast", "PostgreSQL scales", "we should offer free tier." This release adds Researcher as a mandatory gate: every PRD triggers research first, findings are shown to user, and all tech recommendations are evidenced. Over 3-6 month timelines, this prevents expensive pivot-backs mid-project.

## [2.1.1] - 2026-03-29

### Added
- **Team Setup Questionnaire** — `/init-project` now asks two adaptive questions at the start:
  - "Do you have Claude Code CLI available?" → determines if Complex Project Mode routing is active
  - "What's your project budget?" → triggers free-tier research task if needed
- **Adaptive workflow** — workflow adapts based on answers: Copilot-only users get pure GitHub Copilot routing (no context overflow handling), free-budget teams get research tasks for free services, paid teams get production defaults
- **`context.tools` and `context.budget`** — new fields in `.agents/state.json` store user's setup; used by Manager for routing decisions
- **`/setup-budget` prompt** — reconfigure tools and budget settings after `/init-project` without re-scaffolding
- **Manager routing logic (Section 12)** — now checks `context.tools.claude_code_cli` before offering Claude Code CLI routing; if unavailable, suggests installing or using `/mvp` mode for large projects

### Changed
- `/init-project` — now includes Team Setup Questionnaire before PRD scaffolding
- Manager Section 12 — prerequisites now include check for Claude Code CLI availability
- README — added "Adaptive Workflow" section explaining tools & budget impact
- README Quick Start — now mentions setup questionnaire

### Why
Users have different setups: GitHub Copilot only, Copilot + Claude Code CLI, free vs paid budgets. The boilerplate now adapts automatically instead of assuming everyone has the same tools. Works for solo devs with GitHub Copilot, teams on a budget using free services, and power users with full Claude Code access.

## [2.1.0] - 2026-03-29

### Added
- **Complex Project Mode** — For solo projects with 3+ modules: auto-generated `MODULES.md` registry tracks module dependencies, statuses, and ownership across long development timelines
- **Context Budget Routing** — Manager automatically routes tasks to Copilot subagent (≤3 files) or Claude Code CLI (10+ files / 3+ modules); eliminates 160k context overflow on large codebases
- **Module Status Checkpoint** — After every Engineer commit, Manager updates MODULES.md, detects newly unblocked modules, and surfaces the next recommended task
- **`/init-project` complex mode** — When PRD contains 3+ functional areas, generates MODULES.md with full dependency ordering and parallel build plan before any code is written
- **`/list-modules` prompt** — Status table (✅ complete | 🔄 in-progress | ⏸ blocked | ⏳ design) with unblocked-next recommendations
- **`/show-graph` prompt** — ASCII dependency graph with build order and critical path; shows which modules can be built in parallel
- **Manager Section 12** — Full routing rules, MODULES.md maintenance contract, and module status checkpoint protocol
- **Engineer Section 6** — Module status update protocol added to implementation checklist
- **`.agents/MODULES.md`** — Template file added to boilerplate

### Changed
- Manager Section 7 (Project Scaffolding) — now generates MODULES.md for PRDs with 3+ modules
- Engineer Session End Checklist — step 5 added: update MODULES.md for all modules touched
- `copilot-instructions.md` — MODULES.md added to the five canonical state files

### Architecture
Adds a **module registry layer** between PRD intake and task execution. Manager reads MODULES.md before every routing decision, preventing 160k context overflow by automatically delegating large tasks to Claude Code CLI's 1M context window. Designed for solo projects with 3–6 month timelines.

## [2.0.0] - 2026-01-01

### Added
- **Native subagent orchestration (VS Code Feb 2026)** — Manager can autonomously spawn worker agents using `runSubagent`, eliminating manual copy-paste handoffs after PRD approval
- **Enforced model routing** — all 7 agents now declare `model:` in frontmatter (VS Code enforces this when switching/spawning agents); no longer advisory-only
- **Manager handoff buttons** — native `handoffs:` frontmatter creates clickable UI buttons for → Engineer, → Security Audit, → Designer
- **Anti-bias Security spawning** — Manager Section 11 enforces that Security subagent prompts never include implementation context; context isolation is the adversarial advantage
- **Break conditions** — Manager halts autonomously: 3 consecutive Engineer failures trigger user escalation; any CRITICAL security finding halts the full task queue
- **Engineer retry protocol (Section 5)** — tracks attempt count in `context.engineer_notes`, escalates via `context.blocked_on` after 3 failures; operates without user questions in subagent mode
- **Security compact output format** — when invoked as subagent, Security returns concise `CRITICAL: n | HIGH: n | VERDICT: PASS/FAIL` block to keep Manager context lean
- **`CLAUDE.md`** — root-level Claude Code CLI bootstrap; concise Manager summary with startup protocol, core rules, and state file references
- **`.claude/agents/` directory** — 6 Claude-format agent files (`engineer.md`, `security.md`, `designer.md`, `researcher.md`, `consultant.md`, `medic.md`) for native Claude Code CLI subagent use
- **`.claude/settings.json`** — PostToolUse hooks: runs `npm run lint` or `flake8` automatically after every file Write/Edit; deterministic guarantee vs advisory instructions
- **Dual-mode workflow** — same agent definitions work in both VS Code (`.github/agents/*.agent.md`) and Claude Code CLI (`.claude/agents/*.md`)
- **Manager Session End Checklist** — new section; ensures state.json and state.md are always updated before session close
- **Manager `agents:` frontmatter** — declares allowed subagents for VS Code subagent orchestration feature

### Changed
- Manager, Engineer, Security, Designer, Researcher, Consultant, Medic — all frontmatter updated with `model:` field (VS Code-enforced routing)
- Manager Session Start Checklist — now also checks `context.blocked_on` and `handoff.approved_by_user` before responding
- README — added Dual-Mode Workflow section documenting VS Code vs Claude Code CLI usage

### Architecture
This release introduces the shift from **manual handoff mode** (user copies prompts between agent chat windows) to **autonomous subagent mode** (Manager spawns workers automatically). Manual mode remains fully supported for backward compatibility.



### Added
- **Medic agent** — 7th agent, emergency production incident responder
  - Autonomous triage, diagnosis, fix, and deployment for SEV 1 incidents
  - 6-phase protocol with 20-minute time budget (triage → diagnose → fix strategy → execute → deploy → document)
  - Fast Security Protocol: 6 checks before deploy (not full Security audit for speed)
  - Writes incident logs to `.agents/incidents/<timestamp>-<slug>.md`
  - Opens hardening PRs for workarounds
  - Model: Opus (high-stakes debugging, autonomous decision-making)
- **incident-response skill** — Emergency runbooks, triage decision trees, incident log templates, postmortem format
  - 8 runbooks: app crashes, 500 errors, DB failures, pipeline failures, test suite failures, API dependencies, memory leaks, security breaches
  - Rollback vs patch forward decision framework
  - Monitoring integration patterns
- `/hotfix` prompt — Direct Medic invocation for production emergencies
- Manager Section 10: Medic Emergency Response Rules — when to invoke (SEV 1 only), how to delegate

### Changed
- Manager model assignments now include: `Medic → Opus (emergency only)`
- Manager "What You Do NOT Do" updated: Never respond to SEV 1 incidents yourself → delegate to Medic immediately
- Manager skill suggestion table updated: `"app crashed", "500 error", "deploy failed"` → `incident-response` (via Medic)

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

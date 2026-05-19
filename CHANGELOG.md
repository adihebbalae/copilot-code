# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.10.0] - 2026-05-19

### Added
- **`.claude/agents/critic.md`** — Critic agent for Claude Code CLI (read-only code reviewer). Reviews Engineer commits for over-engineering, slop, and redundancy. Outputs `.agents/critic-report.md` with verdict: CLEAN | MINOR | REVIEW | NEEDS_REVISION. Model: Sonnet 4.5.
- **`.github/agents/critic.agent.md`** — Critic agent for Copilot (read-only code reviewer). Full protocol with three scans (over-engineering, slop, redundancy) and report format. Never edits code; produces recommendations only.
- **`.agents/plans/PLAN-EXAMPLE.md`** — Template showing the plan-first protocol. Plans document Contract (what task delivers) / Acceptance Criteria (falsifiable checks) / Rejected Alternatives / Non-Scope. User reviews plan before Engineer implementation.
- **`.agents/templates/bdr-commit.md`** — BDR commit message template (Business/Decision/Rationale). Documents why each commit was made, not just what changed. Captures Contract / Acceptance / Rejected / Non-scope to make commits auditable and prevent re-arguing design decisions.
- **`scripts/validate-falsifiable-eng.mjs`** — Validation script that checks: Critic agents exist, plan template exists, BDR template exists, Manager and Engineer protocols reference the new feature, workspace-map is updated. Exit 0 if all checks pass, 1 otherwise. CI-safe.

### Changed
- **`CLAUDE.md`** — Added "Falsifiable Engineering (v3.10.0+)" section listing three components: plan-first, critic review, and BDR commits. Added `critic` to Agents list.
- **`.github/copilot-instructions.md`** — Added "Falsifiable Engineering (v3.10.0+)" section under Parallel Mode. Explains plan-first phase, Critic review phase, and BDR commits.
- **`.github/agents/manager.agent.md`** — Added new section "Falsifiable Engineering Protocol (v3.10.0+)" with full workflow: (1) Manager writes plan to `.agents/plans/TASK-NNN.md`, (2) User reviews and approves plan, (3) Engineer implements to plan spec, (4) Manager invokes Critic after commit, (5) Engineer acts on feedback, (6) Security audit, (7) Push. Also added Critic to handoffs array in frontmatter.
- **`.github/agents/engineer.agent.md`** — Updated "Implementation Process" step 1 to reference `.agents/plans/TASK-NNN.md` from handoff. Step 9 now requires BDR-formatted commits with Contract/Acceptance/Rejected/Non-scope. Added new section "Critic Review (Post-Commit)" explaining what happens after commit and how to respond to Critic feedback.
- **`.agents/workspace-map.md`** — Added `plans/` directory, `templates/` directory with `bdr-commit.md`, `critic-report.md`, and `_dev/research/` reference. Added Critic agent to `.claude/agents/` and `.github/agents/` sections.

### Why
This release ships the **Falsifiable Engineering protocol** — a config-only feature that reduces AI slop and code churn by making engineering decisions auditable and preventing scope creep.

Three structural changes work together:

1. **Plan-First** — Forces clarity before coding. Captures what the task delivers (Contract), how to verify it (Acceptance), why this approach (Rejected), and what's deliberately out-of-scope (Non-Scope). User approves before Engineer writes code. Eliminates "we were building X but you meant Y" surprises.

2. **Critic Review** — Reads every commit post-implementation and flags waste: one-time helpers (over-engineering), comments that repeat code (slop), and duplicated logic (redundancy). Read-only role; produces recommendations. Engineer decides what to act on. Keeps code lean.

3. **BDR Commits** — Every commit documents Business/Decision/Rationale. Captures the *why* alongside the *what*. Makes commits auditable. Prevents the next engineer from re-proposing rejected alternatives. Turns `git log` into institutional knowledge instead of opaque history.

**Why now**: AI tends to over-engineer (adding layers "for future flexibility"), over-comment (including obvious docstrings), and re-implement instead of reach for stdlib. The protocol provides three guardrails. It's not about perfection — it's about catching preventable waste before it ships. All three components are **config-only** (no new tools, no new infrastructure) — the boilerplate just documents and enforces best practices.

## [3.9.0] - 2026-05-19

### Added
- **`.agents/parallelization-protocol.md`** — Generic parallelization protocol for fanout of 2+ independent tasks to multiple Engineers. Covers task isolation, handoff naming convention, cleanup responsibility, state coordination, and dependency rules. Replaces project-specific patterns (originally from TutorOS) with a boilerplate-wide standard.
- **`.github/prompts/parallelize.prompt.md`** — `/parallelize` slash command for Copilot. Validates isolation checklist, creates per-task handoff files, updates state.json to array form, and shows user how to dispatch on their platform (Claude Code auto-spawns; other IDEs require manual session opens).

### Changed
- **`.agents/state.json`** — `handoff` field now supports two forms: single object (default, single-task mode) or array (parallel mode). Added `_schema_notes` field documenting both forms. See `.agents/parallelization-protocol.md`.
- **Manager protocol (8 mode files)** — Added "Parallel Mode" subsection to: `CLAUDE.md`, `.github/agents/manager.agent.md` (Section 8, renumbered remaining sections 9→14), `.github/copilot-instructions.md`, `.cursor/rules/manager.mdc`, `.clinerules/manager.md`, `.windsurfrules`, `AGENTS.md`, `GEMINI.md`, `.agents/rules/manager.md`. Each section includes isolation checklist reference and fan-out instructions (modal per IDE/CLI).
- **Engineer protocol** — Added "Parallel Mode Handoff Handling" section to `.github/agents/engineer.agent.md` and mirrors, specifying cleanup contract (delete only own handoff file, never touch other parallel files, commit before deletion).
- **`.gitignore`** — Added `.dev/` to template's ignore list. `.dev/` is for project-specific scratch (Copilot memory exports, design drafts). Never committed to boilerplate or downstream projects.

### Why
First external request on Attacca (Luca King, 2026-05-18) asked how Attacca scales code review when multiple agent runs are in flight. Current protocol serialized all work (NEVER push without clean Security report + single handoff field). TutorOS already worked out parallelization pattern (per-task handoffs, isolation checklist, per-engineer cleanup). This v3.9.0 generalizes TutorOS's pattern into the boilerplate, enabling fanout of independent work to accelerate delivery. Tier 2 (parallel per-PR Security review, separate handoff) deferred for later.

## [3.8.0] - 2026-05-18

### Added
- **`.github/skills/grill-me/`, `grill-with-docs/`, `diagnose/`, `zoom-out/`, `to-prd/`, `to-issues/`, `improve-codebase-architecture/`, `prototype/`** — Eight alignment & design-discipline skills adapted from [mattpocock/skills](https://github.com/mattpocock/skills). Includes companion files (`CONTEXT-FORMAT.md`, `ADR-FORMAT.md`, `LANGUAGE.md`, `INTERFACE-DESIGN.md`, `DEEPENING.md`, `LOGIC.md`, `UI.md`). `to-prd` and `to-issues` were lightly adapted to point at Attacca's GitHub Issues integration (configured by `/init-project`) instead of Matt's `/setup-matt-pocock-skills` bootstrap.
- **`scripts/sync-skills.mjs`** — Boilerplate-dev helper. Mirrors `.github/skills/` (source of truth) to `.claude/skills/`. Supports `--prune` (also remove stale entries) and `--check` (CI drift detector). `claude-plugin/skills/` is intentionally NOT synced because it ships self-contained variants with the Claude marketplace plugin.
- **`packs/marketing/skills/`** — New top-level directory holding all 33 marketing skills. NOT auto-loaded by agents.
- **`cli/bin/index.js`** — `--pack=engineering|marketing|all|none` CLI flag for non-interactive scaffolding. Engineering pack expanded to include the 8 new alignment skills plus `caveman`, `karpathy-guidelines`, `llm-wiki` (which had been live in the template but missing from the CLI's pack list).
- **`README.md`** — "Alignment & design discipline" skills sub-table, opt-in marketing-pack instructions, `scripts/sync-skills.mjs` usage docs, and an `agentmemory` row in the Companion Tools table (one-line, no MCP wiring — see "Why" below).

### Changed
- **`packs/marketing/skills/` over `.github/skills/<marketing>/`** — Moved all 33 marketing skills (`ab-test-setup`, `paid-ads`, `pricing-strategy`, etc.) out of `.github/skills/` and `.claude/skills/` into `packs/marketing/skills/`. Agents no longer auto-load them on coding-project work. This is **breaking for anyone who relied on the old paths**, mitigated by: (a) all marketing-skill content is preserved at the new path, (b) `npx create-attacca --pack=marketing` continues to scaffold the same set, (c) git history confirms zero edits to any of these 33 files in 7 months (`2ff9f62`, v2.5.0).
- **`.claude/skills/`** is now strictly a generated mirror of `.github/skills/`. Manual edits to `.claude/skills/` will be overwritten by the next `sync-skills.mjs` run. Edit `.github/skills/` instead.
- **`cli/package.json`** version bumped to `3.8.0`.
- **`.agents/workspace-map.md`** — Updated to reflect new `packs/marketing/skills/`, `scripts/sync-skills.mjs`, and the expanded engineering skill catalog.

### Removed
- **`.github/workflows/deploy-website2.yml`** — Byte-identical duplicate of `deploy-website.yml`. Both triggered on the same `website/**` push path, causing duplicate GitHub Pages deploys per commit.
- **`.kiro/`** — Empty orphan directory, zero references anywhere in the repo. Likely a stale IDE artifact.

### Why
Two external developments converged: the user asked about integrating [rohitg00/agentmemory](https://github.com/rohitg00/agentmemory) and [mattpocock/skills](https://github.com/mattpocock/skills), and on inspection the boilerplate had drifted — 40+ skills shipping by default (most marketing, never edited since v2.5.0), the `.github/skills/` and `.claude/skills/` mirrors silently diverging, a duplicate CI workflow doing the same deploy twice. The fix is three-pronged:

1. **Adopt Matt's engineering skills directly.** They're high-leverage and drop-in (same `SKILL.md` format). `grill-with-docs` in particular gives projects a structured `CONTEXT.md` + `docs/adr/` discipline — file-based, grep-able, no infrastructure — which addresses the same "agent forgets your project's vocabulary" problem that agentmemory tackles with a Node server + native runtime, at roughly 1% the operational cost.
2. **Stop auto-loading marketing skills on every coding project.** Moving them to `packs/marketing/skills/` keeps the content reachable but out of the default agent context window. Coding projects load 20 skills, not 53.
3. **Make `.github/skills/` the single source of truth.** A 100-line sync script eliminates the manual-mirror drift that allowed `.claude/skills/` to fall behind by 8 skills the moment Matt's were added. `--check` mode means this can become a CI gate later if drift recurs.

agentmemory was evaluated and documented as a **Companion Tool** (one row in `README.md`) rather than baked in. It is a heavyweight standalone product (server + `iii-engine` native binary or Docker, pinned to a fragile `iii-engine` version, per-developer install) — appropriate for users who need cross-session memory on projects too complex for `CONTEXT.md` + `.agents/state.json`, but the wrong default for a template used to scaffold every new project.

## [3.7.1] - 2026-05-05

### Added
- **`.gitignore.project`** — Added `DESIGN.md`, `ANTIGRAVITY.md`, `HOW_TO_UPDATE.md`, `RETROFIT.md`, `cli/`, `vscode-extension/`, `website/`, `claude-plugin/` to the project gitignore. These are boilerplate-internal files and must never ship in a project repo.
- **`claude-plugin/commands/init-project.md`** — New Phase 4: Pre-First-Commit Cleanup. Five explicit steps: activate project gitignore, replace README, reset CHANGELOG, verify `git status`, then first commit. Includes `git rm --cached` recovery command for already-tracked files.
- **`.github/agents/manager.agent.md`** — Section 7a: First Commit Checklist. Mandatory pre-push protocol for new projects with a full reference table of every file category that must stay out of the project repo, and the reason why.

### Why
When a new project is cloned from the template and scaffolded, the Manager had no explicit instruction to clean up before the first commit. Agent definitions, internal skills, IDE adapters, boilerplate docs, and distribution packages would all get committed to the project repo — exposing proprietary orchestration details and cluttering the codebase with files that have nothing to do with the product.

## [3.7.0] - 2026-05-05

### Added
- **`.github/skills/caveman/SKILL.md`** — Token compression skill. Three levels: `lite` (~30% output reduction), `full` (~65%), `ultra` (~75%). Activates when context window is filling up, on long-running sessions, or when Manager sets `compression: <level>` in the handoff. Also covers `caveman-compress` (input filtering: skip redundant comments, collapse repeated patterns, read state files structurally). State file compression guidance included: targets `state.md` ≤40 lines, `handoff.md` ≤25 lines.
- **`.github/agents/designer.agent.md`** — Added **Design Tools** section covering:
  - **Impeccable** (`pbakaus/impeccable`, 25.2k ⭐): 23 design commands (`/impeccable audit`, `/impeccable polish`, `/impeccable critique`, etc.), 7 domain reference files, 27 deterministic anti-pattern rules. Designer now knows when and how to surface it to users.
  - **design-extract / designlang** (`Manavarya09/design-extract`, 2.2k ⭐): Extracts complete design system from any live URL — DTCG tokens, Tailwind config, shadcn theme, component anatomy, brand voice. Designer recommends it when user provides a reference site.
- **`README.md`** — `caveman` added to Skills table. New **Companion Tools** table documenting impeccable, designlang, and codeburn as per-project installs.

### Why
Three gaps in the designer agent and token economy: (1) No design vocabulary — designer had no concrete anti-slop rules or commands to offer; impeccable fills this. (2) No way to extract reference design systems — designer had to guess from screenshots; designlang solves this with one CLI command. (3) No token budget management — long sessions degrade context quality; the caveman skill gives agents a structured way to compress output before the window fills.

## [3.6.1] - 2026-04-22

### Changed
- **`.github/prompts/init-project.prompt.md`** Phase 9A — Manager now deletes all unused adapter directories during scaffold (e.g., if user selects Copilot only, it removes `.cursor/`, `.windsurf/`, `CLAUDE.md`, `GEMINI.md`, `.claude/`, `.agents/workflows/`, etc.). Keeps only what was selected. Reports deleted paths in the Phase 10 summary.
- **`.github/agents/engineer.agent.md`** — Attribution checklist item reworded from "Attribution present" (passive verification) to "Attribution DONE" (imperative action). Engineer now adds the Attacca footer/README line without asking — never prompts the user about it.

### Why
Two papercuts: (1) The engineer was asking users "do you want to keep the Built with Attacca line?" instead of just adding it — attribution is non-negotiable per project rules. (2) init-project was leaving Gemini/Claude/Cursor folders in projects that don't use those tools, creating noise and confusion.

## [3.6.0] - 2026-04-14

### Added
- **`claude-plugin/commands/demo.md`** — `/attacca:demo` command: a 2-minute live walkthrough of Attacca that writes no files. Narrates a simulated Expense Tracker API project through the full Manager → Researcher → Engineer → Security pipeline, shows the `.agents/` structure, supported tools table, and skills list. Ends with a CTA to run `/init-project` or `npx create-attacca`.
- **`.agents/workflows/demo.md`** — Antigravity-native `/demo` workflow that delegates to the same script.

### Why
No low-friction demo path existed. `/quickstart` starts a real project — not appropriate for showing someone the system. `/demo` runs in any IDE, writes nothing, and covers the full value proposition in under 2 minutes.

## [3.5.0] - 2026-04-14

### Added
- **`.github/skills/llm-wiki/SKILL.md`** — LLM Wiki skill based on Karpathy's persistent knowledge base pattern. Covers full `/wiki-setup`, `/ingest`, `/query`, and `/lint-brain` operations with defined wiki directory structure (`wiki/`, `raw/`), `index.md` + `log.md` conventions, and token cost table by scale. Includes markitdown (Microsoft) integration for PDF/DOCX/PPTX/YouTube → markdown conversion (CLI + MCP server setup), Obsidian integration instructions, Google Drive sync notes, weekly GitHub Actions lint schedule, and a self-learning gap-finding extension to the lint operation.

### Why
LLM Wiki pattern (Karpathy, April 2026, 5K+ stars) is a significant improvement over RAG for persistent project knowledge bases: knowledge is compiled once and compounded rather than re-derived per query. This dramatically reduces token cost on large codebases and research projects. markitdown (108K stars) is the standard tool for converting PDFs and office docs to LLM-ready markdown. Adding both as a unified skill makes them immediately usable by any agent in any project using this boilerplate.

## [3.4.0] - 2026-04-14

### Added
- **`ANTIGRAVITY.md`** — Root-level manager instructions for Google Antigravity IDE, consistent with `CLAUDE.md`, `GEMINI.md`, and `AGENTS.md`. Documents the Antigravity-specific file layout and lists all available workflows.
- **`.agents/workflows/quickstart.md`** — First-time setup wizard workflow. Prints welcome banner, detects existing `.agents/state.json`, and routes to `/init-project` or continues from last state.
- **`.agents/workflows/handoff-to-consultant.md`** — Escalation workflow for deep architectural reasoning after 3 Engineer failures or irreversible decisions.
- **`.agents/workflows/handoff-to-designer.md`** — UI/UX delegation workflow with design brief format.
- **`.agents/workflows/handoff-to-researcher.md`** — Research delegation workflow with deliverable format for competitive/market analysis.
- **`.agents/workflows/quality-gate.md`** — Pre-push quality gate workflow (lint → type-check → tests → security scan). Wraps the skill as a directly invocable `/quality-gate` slash command.
- **`.agents/skills/`** — Antigravity-native skills directory with 4 core engineering skills: `code-review`, `quality-gate`, `security-audit`, `tdd`. Same `SKILL.md` frontmatter format as `.github/skills/` but placed where Antigravity IDE auto-discovers them.

### Changed
- **`.agents/workflows/init-project.md`**, **`handoff-to-engineer.md`**, **`handoff-to-security.md`** — Added `description` YAML frontmatter (max 250 chars) for Antigravity's workflow description field.

### Why
Google Antigravity is Google's next-gen local IDE (successor to Firebase Studio, announced March 2026, released to GA April 2026). It uses `.agents/workflows/` for slash-command workflows, `.agents/rules/` for workspace rules, and `.agents/skills/` for auto-loaded skills — all within the `.agents/` directory already used by this boilerplate. The partial Antigravity support added in v3.0.0 was missing the `description` frontmatter on workflows, 4 of the 7 handoff workflows, and the skills directory. This release completes parity.

## [3.3.0] - 2026-04-08

### Added
- **`/attacca:quickstart`** (`claude-plugin/commands/quickstart.md`) — First-time welcome wizard. Prints the "Agents assembled. Give me the mission." banner, detects existing project state, and routes users to `initprd`, `init-project`, or a plain-English explainer. Catches users who type their task directly and guides them through setup.
- **`/attacca:initprd`** (`claude-plugin/commands/initprd.md`) — Zero-questions init from a PRD file. Looks for `PRD.md`, `prd.md`, `BRIEF.md`, or `SPEC.md` in the project root, extracts project name/stack/tasks/mode, and writes the full `.agents/` workspace.
- **`.claude-plugin/marketplace.json`** — Turns the Attacca repo into a distributable Claude Code marketplace. Install via `/plugin marketplace add adihebbalae/Attacca` + `/plugin install attacca@attacca`.
- **`website/`** — Astro static site for the product landing page. Sections: hero with terminal install preview, 7-agent grid, 3-path onboarding, quality gates explainer, full commands table.
- **`.github/workflows/deploy-website.yml`** — Auto-deploys the Astro site to GitHub Pages on push to `main` when `website/` files change.

### Why
Users had no guided entry point. `quickstart` + `initprd` give first-timers a clear path. The marketplace.json makes installation a two-command operation. The website gives the project a public face.

## [3.2.0] - 2026-04-07

### Added
- **`karpathy-guidelines` skill** (`.github/skills/karpathy-guidelines/SKILL.md`) — Behavioral skill derived from Andrej Karpathy's [LLM coding pitfall observations](https://x.com/karpathy/status/2015883857489522876). Covers four principles: Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution. Loadable on-demand by any agent or Copilot.

### Changed
- **`copilot-instructions.md`** — Added new `## Implementation Discipline` section with: don't delete pre-existing dead code (mention it), senior engineer overcomplicated test, and ambiguity presentation directive (don't pick interpretations silently).
- **`AGENTS.md` / `GEMINI.md`** — Synced `## Implementation Discipline` section to keep all base instruction files consistent.
- **`engineer.agent.md`** — Updated Engineering Quality Checklist: dead code item now clarifies *your changes* vs pre-existing (mention, don't delete), and added explicit Simplicity check.

### Why
Karpathy's principles address the most common LLM coding failure modes: silent assumption-picking, bloated abstractions, and touching code you shouldn't. The three genuinely new additions (ambiguity surfacing, mention-don't-delete, overcomplicated test) weren't covered by existing principles. Everything else (research first, close the loop, no speculative features) was already present.

## [3.1.0] - 2026-07-26

### Added
- **Claude Code native plugin** (`claude-plugin/`) — Self-contained distributable plugin for Claude Code CLI users. Install with `/plugin install <git-url>` — no cloning required. Includes all 7 agents (manager as default via `settings.json`), 4 core engineering skills, 6 commands, and a lint post-hook.
- **`claude-plugin/.claude-plugin/plugin.json`** — Plugin manifest with name `agent-boilerplate`, version, and repository metadata.
- **`claude-plugin/agents/`** — Self-contained agent files (manager, engineer, security, designer, researcher, consultant, medic). Unlike the `.claude/agents/` versions, these have full inline protocol — no cross-references to `.github/agents/*.agent.md`. The Manager agent is entirely new: it didn't exist as a standalone agent file before (only as `CLAUDE.md` instructions).
- **`claude-plugin/skills/`** — Direct copies of the 4 core engineering skills from `.github/skills/`: `code-review`, `quality-gate`, `tdd`, `security-audit`. Plugin skills use the same `name`/`description` frontmatter format and are model-invoked automatically.
- **`claude-plugin/commands/`** — 6 slash commands: `init-project` (creates `.agents/` structure), `handoff-to-engineer`, `handoff-to-security`, `handoff-to-designer`, `handoff-to-researcher`, `handoff-to-consultant`. Namespaced as `/agent-boilerplate:<command>`.
- **`claude-plugin/hooks/hooks.json`** — PostToolUse lint hook: runs `npm run lint` or `python flake8` after every file write. Simplified portable version of the `.claude/settings.json` hooks.
- **`claude-plugin/settings.json`** — Sets `"agent": "manager"` so Manager activates automatically when the plugin is enabled.
- **`claude-plugin/README.md`** — Install instructions, quick start, workflow overview.

### Why
Claude Code CLI users previously had to clone the full template to get the agent workflow. The native plugin system allows one-command installation (`/plugin install`) that works globally across all projects. The existing SKILL.md format and agent frontmatter are 100% compatible with the plugin format — this required mostly reorganization and making agents self-contained rather than refactoring.

## [3.0.0] - 2026-07-25

### Added
- **Multi-IDE adapter system** — Native config files for Cursor (`.cursor/rules/*.mdc`), Cline (`.clinerules/*.md`), Windsurf (`.windsurfrules`), and Google Antigravity (`.agents/rules/` + `.agents/workflows/`). Each adapter follows the target IDE's native format with proper frontmatter, activation modes, and path conditionals.
- **`npx create-agent-boilerplate` CLI** — Zero-dependency Node.js scaffold tool. Interactive setup asks which tools, LLM backend (cloud/local/hybrid), agent complexity (full/simplified), and skill packs (engineering/marketing/all/none). Generates only selected adapters, moves unused to `.boilerplate/templates/`, writes `boilerplate.config.json`. Works with both interactive and piped input.
- **Cursor adapter** (7 files) — `.mdc` format with YAML frontmatter (`description`, `alwaysApply`, `globs`). Protocol rule is always-on; agent and skill rules use Cursor's agent-decision activation.
- **Cline adapter** (6 files) — Markdown with optional `paths:` YAML frontmatter for conditional activation. Engineer rules scoped to `src/**`, `lib/**`, `app/**`; testing rules scoped to test file globs.
- **Windsurf adapter** (1 file) — Single `.windsurfrules` concatenated file covering protocol, agent roles, and quality gate.
- **Antigravity adapter** (7 files) — `.agents/rules/*.md` for workspace rules + `.agents/workflows/*.md` for slash-command workflows. Leverages Antigravity's native `.agents/skills/<name>/SKILL.md` format which matches existing boilerplate structure.
- **`.boilerplate/templates/`** — Storage for unused adapter templates (generated by CLI scaffold). Keeps project root clean while preserving all adapters for later activation.
- **`boilerplate.config.json`** — Records scaffold choices (tools, LLM mode, agent complexity, skills) for reproducibility and `/update-boilerplate` compatibility.
- **Local LLM support** — `hybrid` and `local` LLM modes with recommended model guidance (Qwen 2.5 Coder 32B, DeepSeek Coder V2 33B, Codestral 22B, Llama 3.1 70B). Warns about instruction-following limitations for models under 13B.

### Changed
- **BREAKING**: Version bump to 3.0.0 — new multi-IDE architecture. Existing single-IDE setups continue to work but should run `/update-boilerplate` to get new adapter options.

### Why
The boilerplate previously only supported GitHub Copilot, Claude Code CLI, Codex CLI, and Gemini CLI. Users on Cursor, Cline, Windsurf, and Antigravity had to manually adapt rules. This release makes the boilerplate truly universal — one template works across all major AI coding tools. The CLI scaffold ensures users only get the files they need, while `.boilerplate/templates/` preserves everything for later.

## [2.7.3] - 2026-04-06

### Fixed
- **`auto-run.ps1` UTF-8 BOM encoding** — `Read-StateFile` now uses `[System.IO.File]::ReadAllText` with explicit UTF-8 encoding; `Save-StateFile` writes with `UTF8Encoding($false)` (no BOM). Prevents `ConvertFrom-Json` failures caused by PS 5.1's default BOM-prefixed UTF-8 output.
- **`auto-run.ps1` resume `in_progress` tasks** — Tasks with status `in_progress` are now included in the pending task queue alongside `pending` and `not_started`, so interrupted runs resume correctly instead of skipping partially-completed tasks.

### Added
- **`-SecurityBetweenTasks` flag in `auto-run.ps1`** — New switch parameter. Default behavior is now one security scan after all tasks complete. Pass `-SecurityBetweenTasks` to restore the previous behavior of scanning after each individual task.

### Changed
- **`auto-run/SKILL.md`** — Updated launch banner and option docs to reflect new security default (end-only scan). Added `-SecurityBetweenTasks` to the options reference.

## [2.7.2] - 2026-04-05

### Added
- **`.claudeignore`** — Stops Claude Code CLI from reading `node_modules/`, `dist/`, lock files, build output, binary assets, and other folders that waste tokens without adding value. Savings compound on every prompt.
- **`.claude/hooks/read-once.sh`** — Per-session cache that blocks Claude from re-reading files it already loaded. Benchmarked at ~38K tokens saved per session (~40-90% reduction in Read tool token usage).

### Changed
- **`.claude/settings.json`** — Now defaults to `sonnet` model (~60% cheaper than Opus 4.6), caps hidden thinking tokens at 10K (was 32K default, ~70% saving), sets context autocompact at 50% instead of 95% (healthier sessions), routes subagents to `haiku` (~80% cheaper). Added `PreToolUse` hook wiring for `read-once.sh`. Combined effect: 60-80% reduction in token consumption per session.
- **`CLAUDE.md`** — Reduced from ~100 lines to 36 lines. CLAUDE.md loads on every single message; the full protocol is now loaded on-demand from `.github/agents/manager.agent.md`. Estimated saving: ~1,000 tokens per message at startup.

### Why
All four changes come directly from the Claude Code CLI community's most-measured optimizations (B1-B4 from the ongoing usage limits megathread). The settings.json block alone is reported to cut consumption 60-80%. The read-once hook is the single highest-leverage hook available — one session in the benchmark saved 38K tokens out of 94K total reads. Lean CLAUDE.md is the easiest win: the file loads on every message, so every token you remove is saved repeatedly throughout the session.

## [2.7.1] - 2026-04-05

### Added
- **Per-task usage tracking in `auto-run.ps1`** — `--output-format json` flag on the Claude CLI `-p` call (format flag only, zero extra tokens). `Get-UsageFromJsonOutput` parses `cost_usd`, `input_tokens`, `output_tokens`, `duration_ms` fields. `Write-InlineUsage` prints usage after each task. `Show-UsageTable` prints a final breakdown with totals. Falls back to wall-clock time if token data is absent.

## [2.7.0] - 2026-04-05

### Added
- **`/auto-run` prompt + skill** — Run all approved tasks to completion without manual intervention. Manager pre-generates handoff files for every pending task, then either loops through Copilot-native subagents (small tasks) or launches the CLI orchestrator script (large tasks).
- **`.github/scripts/auto-run.ps1`** — PowerShell orchestrator that drives Claude Code CLI through the full task queue. Features: sequential execution via `claude --agent engineer -p`, security scans between tasks (`claude --agent security -p`), configurable checkpoints (default 45s), rate-limit detection with 5-hour cooldown, max 3 retries per task with hard-stop on failure, dry-run mode, and automatic state.json updates throughout.
- **`.github/skills/auto-run/SKILL.md`** — Full protocol for the Manager: routing decision (Copilot-native vs CLI), handoff generation, auto_run config in state.json, script launch, post-completion review, and error recovery guidance.
- **Section 13 in `manager.agent.md`** — Autonomous Task Runner documentation and skill suggestion routing.
- **`auto_run` field in state.json** — New optional config: `task_order`, `checkpoint_seconds`, `max_retries`, `security_between_tasks`, `rate_limit_wait_hours`.

### Why
The manual ping-pong workflow (Manager writes handoff → user switches to CLI → Engineer runs → user switches back → repeat) is the single biggest friction point when executing multi-task plans. For a 10-task project, that's 20+ manual context switches. The auto-run system eliminates all of them: one `/auto-run` command generates everything, one script execution drives it to completion. Rate-limit handling (auto-detect + 5h cooldown) addresses Claude Code CLI's ~5-10 task throttle window. The 45-second checkpoint between tasks preserves the user's ability to Ctrl+C and intervene without requiring active monitoring.

## [2.6.0] - 2026-04-02

### Added
- **`AGENTS.md`** — Codex CLI bootstrap. Codex reads `AGENTS.md` from the project root as its context file. Configures the Manager role, agent protocol, state file references, and manual handoff instructions for OpenAI's Codex CLI (`@openai/codex`).
- **`GEMINI.md`** — Gemini CLI bootstrap. Gemini reads `GEMINI.md` from the project root as its context file. Identical protocol structure to `CLAUDE.md`/`AGENTS.md` with Gemini-specific notes (context refresh, hooks, approval mode).
- **`.gemini/settings.json`** — Project-level Gemini CLI settings. Enables `auto_edit` approval mode and adds an `AfterTool` hook that runs lint automatically after every file write — mirrors the behavior of `.claude/settings.json`.
- **Mode 3 (Codex CLI)** and **Mode 4 (Gemini CLI)** in `README.md` — "Dual-Mode Workflow" renamed to "Multi-Mode Workflow". Added install instructions, startup commands, and mode selection guidance for both new CLIs.

### Changed
- **README.md**: "Dual-Mode Workflow" → "Multi-Mode Workflow". Switching Modes table updated to include Codex (OpenAI billing, ChatGPT plan) and Gemini (free tier, Google auth) as options. Adaptive Workflow question updated from "Claude Code CLI?" to "a CLI agent?" to cover all three CLIs.
- **README.md description** updated to list all four supported tools: GitHub Copilot, Claude Code, Codex CLI, and Gemini CLI.

### Why
Claude Code is not the only terminal-first AI CLI. Codex CLI (OpenAI) and Gemini CLI (Google, 60 req/min free tier) are now production-grade alternatives used by large segments of the developer community. Adding `AGENTS.md` and `GEMINI.md` costs near-zero maintenance (same content as `CLAUDE.md`, different CLI conventions) and opens the boilerplate to users on OpenAI billing, ChatGPT plans, or those who prefer Gemini's free tier. The `.gemini/settings.json` hook mirrors the Claude Code lint-on-save behavior, ensuring all three CLI modes have equivalent automatic quality gates.

## [2.5.0] - 2026-04-01

### Added
- **41 marketing & engineering skills** — Added full skill library to both `.github/skills/` and `.claude/skills/`: ab-test-setup, ad-creative, ai-seo, analytics-tracking, churn-prevention, cold-email, competitor-alternatives, content-strategy, copy-editing, copywriting, email-sequence, form-cro, free-tool-strategy, launch-strategy, marketing-ideas, marketing-psychology, onboarding-cro, page-cro, paid-ads, paywall-upgrade-cro, popup-cro, pricing-strategy, product-marketing-context, programmatic-seo, referral-program, revops, sales-enablement, schema-markup, seo-audit, signup-flow-cro, site-architecture, social-content (plus existing technical skills).
- **`.claude/skills/` tree** — All skills now mirrored under `.claude/skills/` for Claude Code compatibility. Files are byte-for-byte identical to `.github/skills/` counterparts.

### Changed
- **`CLAUDE.md` synced with `copilot-instructions.md`** — Added Boilerplate Dev Mode notes, Version Management guidance, Retrofit Mode note, Agent System Protocol, Code Standards, and Communication Principles to `CLAUDE.md`. Both files now share the same core protocol content, ensuring Claude Code and GitHub Copilot get equivalent project context.

### Why
Skills added to one AI tool's folder must exist in the other to prevent context drift — agents switching between Claude Code and GitHub Copilot must see the same skill library. `CLAUDE.md` was missing the boilerplate meta-notes and shared agent protocol that `copilot-instructions.md` carries, creating a gap where Claude Code sessions would lack critical operational context.

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

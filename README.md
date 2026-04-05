# Agent Boilerplate

**PRD → Project.** Paste a product requirements doc, answer a few questions, and a multi-agent system plans, builds, tests, and commits the code — while you review.

Orchestration layer for GitHub Copilot, Claude Code, Codex CLI, and Gemini CLI: Manager (Haiku) coordinates, Engineer (Sonnet) implements, Security audits before every push. All modes share the same state files.

## Quick Start

```powershell
# One command: creates a new GitHub repo from this template AND clones it
gh repo create my-project-name --template adihebbalae/copilot-code --public --clone
cd my-project-name
```

Then:
1. Open the folder in VS Code with GitHub Copilot + Claude models enabled
2. Select the **Manager** agent in the Copilot chat panel
3. For any project: use `/init-project` with your PRD
4. Manager runs: PRD → Research → Setup Questions → Clarifications → Scaffold
   - **Research Phase**: Researcher gathers competitive/market/tech intelligence
   - **Setup Questions**: Tools & budget adapted automatically
   - **Clarifications**: PRD edge cases resolved
   - **Scaffold**: All decisions grounded in research findings

Paste your PRD. Research runs automatically. That's it — **PRD → Research → Project.**

> **Note**: `/init-project` handles the `.gitignore.project` rename automatically.

## Adaptive Workflow (Tools & Budget)

When you run `/init-project`, Manager asks two setup questions to adapt the workflow:

| Question | Options | Impact |
|----------|---------|--------|
| **Do you have a CLI agent?** | Yes / No | No CLI? Everything routes through GitHub Copilot (160k context). Have CLI (Claude Code, Codex, or Gemini)? Unlock Complex Project Mode for 20+ file projects. |
| **What's your budget?** | Free tier / Paid / TBD | Free? Manager adds a research task to find free deployment options. Paid? Use production-grade tools from day one. |

**Why?** This ensures the boilerplate works for everyone: Copilot-only users, budget-conscious teams, and power users with CLI access. Your answers are saved in `.agents/state.json` and used by Manager for routing decisions.

**Want to change your answers later?** Run `/setup-budget` anytime.

## Version History

**Current version**: `v2.1.0` — See [CHANGELOG.md](CHANGELOG.md) for full version history and upgrade notes.

To update an existing project to the latest boilerplate version, run `/update-boilerplate` from the Manager agent.

## Multi-Mode Workflow

This boilerplate works in four modes. All share the same state files.

### Mode 1: VS Code (GitHub Copilot)

Agents live in `.github/agents/*.agent.md`. Open the Copilot chat panel, select **Manager**, and start.

- **Autonomous (VS Code Feb 2026+)**: Manager spawns subagents automatically after you approve the plan. No copy-pasting prompts. Requires `github.copilot.chat.claudeAgent.enabled: true` in VS Code settings.
- **Manual (any VS Code version)**: Manager writes handoffs to `.agents/handoff.md`. You copy them to the target agent using `/handoff-to-[agent]` prompts.

### Mode 2: Claude Code CLI

Agents live in `.claude/agents/*.md`. Install Claude Code, run `claude` from the project root. Claude reads `CLAUDE.md` as a bootstrap and uses `.claude/agents/` for subagent definitions.

```bash
# Install
npm install -g @anthropic-ai/claude-code

# Start from project root
claude
```

Hooks in `.claude/settings.json` automatically run lint after every file edit — no manual gate-running needed.

### Mode 3: Codex CLI

Install Codex CLI, run `codex` from the project root. Codex reads `AGENTS.md` as a bootstrap.

```bash
# Install
npm install -g @openai/codex
# or: brew install --cask codex

# Start from project root
codex
```

Codex operates in **manual handoff mode** — the Manager plans and writes to `.agents/handoff.md`, and you open a new `codex` session for each agent role. All state is shared via `.agents/`.

### Mode 4: Gemini CLI

Install Gemini CLI, run `gemini` from the project root. Gemini reads `GEMINI.md` as a bootstrap.

```bash
# Install
npm install -g @google/gemini-cli

# Start from project root (sign in with Google on first run)
gemini
```

Hooks in `.gemini/settings.json` automatically run lint after every file write. Gemini operates in **manual handoff mode** — the Manager plans and writes to `.agents/handoff.md`, and you open a new `gemini` session for each agent role.

### Switching Modes

All modes share the same state files (`.agents/state.json`, `.agents/state.md`). You can switch mid-project:

| What you need | Use |
|---------------|-----|
| VS Code native IDE experience, Copilot billing | Mode 1 |
| Autonomous subagents, long-running tasks, Claude billing | Mode 2 |
| Maximum autonomy (1M context, hooks, extended thinking) | Mode 2 |
| OpenAI models, ChatGPT plan billing | Mode 3 |
| Free tier (60 req/min, 1k req/day), Google account auth | Mode 4 |
| Tight VS Code integration (extensions, LSP, editor tools) | Mode 1 |

## Architecture

```
YOU ←→ Manager (Haiku) ←→ Engineer (Sonnet)
                        ←→ Security (Sonnet)
                        ←→ Designer (Haiku)
                        ←→ Researcher (Sonnet)
                        ←→ Medic (Opus) [emergency]
                        ←→ Consultant (Opus) [rare]
```

### Agents

| Agent | Model | Role | Writes Code? |
|-------|-------|------|-----------|
| **Manager** | Haiku | Plans, delegates, coordinates, pushes | No |
| **Engineer** | Sonnet | Implements features, fixes bugs, commits | Yes |
| **Security** | Sonnet | Adversarial auditing, finds vulnerabilities | No |
| **Designer** | Haiku | UI/UX review and design specs | No |
| **Researcher** | Sonnet | Competitive analysis, market research, feature gaps | No || **Medic** | Opus | Emergency incident response, autonomous fix+deploy | Yes || **Consultant** | Opus | Deep architectural reasoning | No |

### Workflow

**Autonomous mode (v2.0 default — VS Code Feb 2026+ or Claude Code CLI)**:
1. **You → Manager**: Paste PRD, answer clarifying questions, approve the plan
2. **Manager**: Spawns Engineer, Security, and other agents automatically as subagents
3. **Manager**: Reports final result when complete or surfaces blockers to you

**Manual mode (backward compatible — any VS Code version)**:
1. **You → Manager**: Describe what you want
2. **Manager**: Plans the work, writes a handoff to `.agents/handoff.md`
3. **Manager → You**: "Copy `.agents/handoff.md` to @engineer using Sonnet"
4. **You → Engineer**: Paste the handoff, Engineer implements & commits
5. **You → Manager**: Report completion, continue to next task
6. **Before push**: Manager generates security review → You send to Security agent
7. **Security**: Reports findings → Engineer fixes → repeat until clean
8. **Manager**: Pushes to repo

### Complex Project Mode

**Requirements**: 3+ modules in your PRD AND Claude Code CLI available.

**What it does:**
- **Module registry** — tracks status, owner, and dependencies for every functional area across sessions
- **Context routing** — routes ≤3-file tasks to Copilot (160k context), 10+-file or multi-module tasks to Claude Code CLI (1M context) automatically
- **Dependency ordering** — identifies which modules can be built in parallel vs must be sequential
- **Cross-session continuity** — MODULES.md persists so you never lose track across a 3-month build

```powershell
# After /init-project generates MODULES.md:
/list-modules    # Status table: done / in-progress / blocked / design
/show-graph      # ASCII dependency graph + critical path + parallel build plan
```

### Handoff Flow (solving the copy-paste problem)

Instead of copying full prompts, agents write to `.agents/handoff.md` and you use the `/handoff-to-*` prompts:

- `/handoff-to-engineer` — Sends current handoff to Engineer
- `/handoff-to-security` — Sends current handoff to Security
- `/handoff-to-designer` — Sends current handoff to Designer
- `/handoff-to-consultant` — Sends current handoff to Consultant

### Vibe Mode (Compact Reporting)

For rapid iteration projects, reduce context usage by ~20%:

In the handoff, add:
```
vibe_mode: true
```

Engineer will suppress all intermediate explanations and only report final result:
```
✅ COMPLETE | Commit: [hash]
Files changed: [count]
Tests: [count] passed
```

Use when you just want the end result, not step-by-step narration of the work.

### State Files

| File | Purpose | Updated By |
|------|---------|-----------|
| `.agents/state.json` | Machine-readable project state | All agents |
| `.agents/state.md` | Human-readable dashboard | All agents |
| `.agents/workspace-map.md` | Directory structure reference | Engineer, Manager |
| `.agents/handoff.md` | Current inter-agent prompt | Sending agent |

### Skills

| Skill | Purpose |
|-------|----------|
| `code-review` | On-demand code review checklist |
| `security-audit` | OWASP Top 10 security audit checklist |
| `tdd` | TDD workflow enforcing RED → GREEN → REFACTOR |
| `quality-gate` | Pre-push gate: lint + type-check + test + security scan |
| `update-workspace-map` | Auto-regenerate `.agents/workspace-map.md` post-commit |
| `supply-chain` | Standalone 4-gate supply chain security (submittable to [awesome-copilot](https://github.com/github/awesome-copilot)) |
| `sbom` | Native SBOM generation via syft/cdxgen + CVE scan via osv-scanner |
| `product-research` | Research frameworks: ICP analysis, competitive landscape, TAM/SAM/SOM, JTBD, positioning gaps, GTM patterns |
| `incident-response` | Emergency runbooks: triage, diagnosis, rollback vs patch, incident logs, postmortems |

## Supply Chain Security

**Engineer cannot add arbitrary packages.** We use defense-in-depth to prevent malware/typosquats from reaching production:

```
Gate 1: Handoff         →  Manager approves dependencies before handoff
        Constraint       →  Engineer forbidden from adding unapproved packages
        
Gate 2: Pre-Review      →  /review-dependencies vets packages (typosquats, abandoned, trust)
        
Gate 3: Quality Gate    →  Lint + Type + Test + Dependency Audit (direct + transitive)
        
Gate 4: Security Audit  →  @security agent reviews SBOM, maintainers, lock files
        (Mandatory       →  Required before ANY push with dependency changes
         on changes)
```

**Workflow**:
1. **Task needs a package?** Manager calls `/review-dependencies` first — vets typosquats, maintainers, CVEs
2. **Approved?** Added to handoff; Engineer implements with it locked
3. **Engineer finishes?** Quality gate runs — catches HIGH/CRITICAL vulns
4. **Dependencies changed?** Security agent MUST review before push — full SBOM generation
5. **Passed all checks?** Safe to ship

See [Security Agent](Security.agent.md) for full dependency review process.



| Prompt | Purpose |
|--------|----------|
| `/quickstart` | Interactive onboarding for first-time users (start here!) |
| `/prd-builder` | Build a comprehensive PRD from scratch using Socratic questioning |
| `/init-project` | PRD intake (file, paste, or idea), full scaffolding, research, GitHub Issues, Context7 MCP |
| `/mvp` | Max velocity mode: aggressive parallelization, deferred gates, scope razor, parallel Engineer sessions |
| `/review-dependencies` | Pre-handoff dependency vetting (supply chain security) |
| `/remember-handoff` | Write handoff to Copilot Memory — next agent reads it automatically |
| `/retrofit` | Retrofit existing projects (VS Code, JetBrains, Eclipse, Xcode) |
| `/handoff-to-engineer` | Trigger handoff to Engineer agent |
| `/handoff-to-security` | Trigger handoff to Security agent |
| `/handoff-to-designer` | Trigger handoff to Designer agent |
| `/handoff-to-consultant` | Trigger handoff to Consultant agent |
| `/handoff-to-researcher` | Trigger handoff to Researcher agent |
| `/learn` | Extract session patterns into `copilot-instructions.md` + Copilot Memory |
| `/meta` | Answer framework meta questions (agents, tools, skills, workflow) |
| `/git` | Query GitHub repo state (issues, PRs, commits, workflows, branches) |
| `/hotfix` | Emergency production incident response via Medic agent |
| `/setup-budget` | Reconfigure your tools and budget (run after `/init-project` if you want to change settings) |
| `/list-modules` | Status table of all project modules: complete/in-progress/blocked (complex projects) |
| `/show-graph` | ASCII dependency graph with build order and critical path (complex projects) |

## Package Age Policy

**All new dependencies must be ≥30 days old** to allow time for vulnerabilities to surface and be patched.

- **Exception**: Security patches (Z-version bumps, e.g., 1.2.5 → 1.2.6) can be applied immediately if all tests pass
- **Enforced by**: `/review-dependencies` (Manager), quality gate, and `@security` agent

## Retrofitting Existing Projects

Already have a project? Use `/retrofit` to add agents **without disrupting existing code**:

```bash
@manager: /retrofit
```

Manager detects your IDE (VS Code, JetBrains, Eclipse, Xcode), audits your project, and generates a customized retrofit plan. The `.agent.md` format is cross-IDE — one boilerplate works everywhere.

See [RETROFIT.md](RETROFIT.md) for full migration guide.

## For New Projects

This template uses a **two-gitignore strategy**:

| File | Purpose |
|------|---------|
| `.gitignore` | Template version — commits all agent files so GitHub has the full boilerplate |
| `.gitignore.project` | Project version — excludes agent orchestration files from project repos |

After cloning for a new project, rename `.gitignore.project` → `.gitignore`. This keeps your project repo clean (just code), while the template repo stays complete on GitHub.

The Manager will add project-specific MCPs, skills, and instructions based on your PRD during `/init-project`.

## Requirements

- VS Code (or JetBrains / Eclipse / Xcode) with GitHub Copilot
- Claude models enabled (Haiku, Sonnet, Opus)
- Context7 MCP — auto-configured by `/init-project` based on your stack
- GitHub CLI (`gh`) — required for GitHub Issues task backlog
- `syft` or `cdxgen` — required for SBOM generation (installed automatically by `sbom` skill if missing)

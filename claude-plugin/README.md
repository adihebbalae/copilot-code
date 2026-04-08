# Attacca — Claude Code Plugin

Multi-agent AI coding orchestrator. Manager coordinates, Engineer builds, Security audits. Install once and it works across all your Claude Code projects.

## Included

**Agents** (auto-activated via `settings.json`):
- **Manager** — your primary contact; plans, delegates, coordinates
- **Engineer** — implements features, fixes bugs, runs tests
- **Security** — adversarial auditor; reviews before every push
- **Designer** — UI/UX reviewer, accessibility audits, component specs
- **Researcher** — market/competitive research, writes to `.agents/research/`
- **Consultant** — deep architectural reasoning (expensive; use sparingly)
- **Medic** — emergency incident responder (SEV 1 only)

**Skills** (model-invoked automatically):
- `code-review` — checklist for correctness, readability, performance, security
- `quality-gate` — 5-stage pre-push gate (lint → type-check → tests → security → verdict)
- `tdd` — RED → GREEN → REFACTOR workflow enforcement
- `security-audit` — OWASP Top 10 checklist

**Commands** (user-invoked):
- `/attacca:quickstart` — **start here**: welcome wizard, detects your situation, routes you to the right setup
- `/attacca:initprd` — drop a `PRD.md` in your project root and let me set up everything automatically
- `/attacca:init-project` — interactive setup wizard (answers a few questions, builds `.agents/`)
- `/attacca:handoff-to-engineer TASK-001` — delegate to Engineer
- `/attacca:handoff-to-security TASK-001` — trigger security audit
- `/attacca:handoff-to-designer TASK-001` — request design review
- `/attacca:handoff-to-researcher TASK-001` — start market research
- `/attacca:handoff-to-consultant TASK-001` — architectural decisions

**Hooks**:
- PostToolUse lint — runs `npm run lint` or `python -m flake8` after every file write

---

## Install

### Option 1: One-step from GitHub (recommended)
```bash
# Step 1 — add the Attacca marketplace (one-time, any machine)
/plugin marketplace add adihebbalae/Attacca

# Step 2 — install the plugin
/plugin install attacca@attacca

# Step 3 — run the welcome wizard
/attacca:quickstart
```

### Option 2: Official marketplace (once approved)
```bash
/plugin install attacca@claude-plugins-official
/attacca:quickstart
```

### Option 3: Test locally
```bash
git clone https://github.com/adihebbalae/Attacca
claude --plugin-dir ./Attacca/claude-plugin
/attacca:quickstart
```

### Submit to Anthropic Plugin Marketplace
After testing, submit at: `claude.ai/settings/plugins/submit`

---

## Quick Start

Once the plugin is enabled:

```
# Start a new project
/attacca:init-project

# When you have a task ready, delegate it:
/attacca:handoff-to-engineer TASK-001

# Before pushing, run a security audit:
/attacca:handoff-to-security TASK-001
```

The Manager agent is set as the default — it loads automatically. Just start chatting.

---

## How it Works

### State Files (created in your project)
```
.agents/
  state.json          ← machine state (single source of truth)
  state.md            ← human-readable dashboard
  workspace-map.md    ← file/directory reference for agents
  handoff.md          ← current inter-agent prompt
  research/           ← researcher outputs (persistent)
  incidents/          ← medic incident logs
```

### Workflow
1. **Manager** reads `.agents/state.json` at the start of every session
2. **Manager** writes task handoffs to `.agents/handoff.md`
3. You run `/attacca:handoff-to-[agent] TASK-ID` to activate the right agent
4. Agent executes, updates state, writes results back to `.agents/handoff.md`
5. **Security** reviews before every push — Manager will not allow a push with CRITICAL findings

### MVP Mode
When you select `mode: mvp` during `/attacca:init-project`, agents skip non-essential quality checks and move faster. Useful for prototyping.

---

## Updating the Plugin URL

Before distributing, replace the placeholder URLs in `.claude-plugin/plugin.json`:
```json
{
  "repository": "https://github.com/YOUR_USERNAME/YOUR_REPO/tree/main/claude-plugin",
  "homepage": "https://github.com/YOUR_USERNAME/YOUR_REPO"
}
```

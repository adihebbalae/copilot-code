# Agent Boilerplate

A multi-agent orchestration framework for GitHub Copilot using Claude models — recreating Claude Code's agentic workflow patterns in VS Code.

## Quick Start

1. **Use this template** on GitHub (or clone it)
2. **Rename `.gitignore.project` → `.gitignore`** (this strips agent files from your project's git history)
3. Open in VS Code with GitHub Copilot + Claude models enabled
4. Select the **Manager** agent in the Copilot chat panel
5. Use the `/init-project` prompt and paste your PRD
6. The Manager will interrogate you, scaffold the project, and begin coordinating work

> **Note**: The Manager's `/init-project` does the gitignore rename automatically if you forget.

## Architecture

```
YOU ←→ Manager (Haiku) ←→ Engineer (Sonnet)
                        ←→ Security (Sonnet)
                        ←→ Designer (Haiku)
                        ←→ Consultant (Opus) [rare]
```

### Agents

| Agent | Model | Role | Writes Code? |
|-------|-------|------|-------------|
| **Manager** | Haiku | Plans, delegates, coordinates, pushes | No |
| **Engineer** | Sonnet | Implements features, fixes bugs, commits | Yes |
| **Security** | Sonnet | Adversarial auditing, finds vulnerabilities | No |
| **Designer** | Haiku | UI/UX review and design specs | No |
| **Consultant** | Opus | Deep architectural reasoning | No |

### Workflow

1. **You → Manager**: Describe what you want
2. **Manager**: Plans the work, writes a handoff to `.agents/handoff.md`
3. **Manager → You**: "Copy `.agents/handoff.md` to @engineer using Sonnet"
4. **You → Engineer**: Paste the handoff, Engineer implements & commits
5. **You → Manager**: Report completion, continue to next task
6. **Before push**: Manager generates security review → You send to Security agent
7. **Security**: Reports findings → Engineer fixes → repeat until clean
8. **Manager**: Pushes to repo

### Handoff Flow (solving the copy-paste problem)

Instead of copying full prompts, agents write to `.agents/handoff.md` and you use the `/handoff-to-*` prompts:

- `/handoff-to-engineer` — Sends current handoff to Engineer
- `/handoff-to-security` — Sends current handoff to Security
- `/handoff-to-designer` — Sends current handoff to Designer
- `/handoff-to-consultant` — Sends current handoff to Consultant

### State Files

| File | Purpose | Updated By |
|------|---------|-----------|
| `.agents/state.json` | Machine-readable project state | All agents |
| `.agents/state.md` | Human-readable dashboard | All agents |
| `.agents/workspace-map.md` | Directory structure reference | Engineer, Manager |
| `.agents/handoff.md` | Current inter-agent prompt | Sending agent |

### Skills

| Skill | Purpose |
|-------|---------|
| `code-review` | On-demand code review checklist |
| `security-audit` | OWASP Top 10 security audit checklist || `tdd` | TDD workflow enforcing RED → GREEN → REFACTOR |
| `quality-gate` | Pre-push gate: lint + type-check + test + security scan |

### Prompts

| Prompt | Purpose |
|--------|----------|
| `/init-project` | PRD intake and full project scaffolding |
| `/handoff-to-engineer` | Trigger handoff to Engineer agent |
| `/handoff-to-security` | Trigger handoff to Security agent |
| `/handoff-to-designer` | Trigger handoff to Designer agent |
| `/handoff-to-consultant` | Trigger handoff to Consultant agent |
| `/learn` | Extract session patterns into `copilot-instructions.md` |
## For New Projects

This template uses a **two-gitignore strategy**:

| File | Purpose |
|------|---------|
| `.gitignore` | Template version — commits all agent files so GitHub has the full boilerplate |
| `.gitignore.project` | Project version — excludes agent orchestration files from project repos |

After cloning for a new project, rename `.gitignore.project` → `.gitignore`. This keeps your project repo clean (just code), while the template repo stays complete on GitHub.

The Manager will add project-specific MCPs, skills, and instructions based on your PRD during `/init-project`.

## Requirements

- VS Code with GitHub Copilot (Pro Individual or higher)
- Claude models enabled (Haiku, Sonnet, Opus)
- Context7 MCP configured (recommended for library docs)

# Agent Boilerplate

A multi-agent orchestration framework for GitHub Copilot using Claude models — recreating Claude Code's agentic workflow patterns in VS Code.

## Quick Start

```powershell
# One command: creates a new GitHub repo from this template AND clones it
gh repo create my-project-name --template adihebbalae/copilot-code --public --clone
cd my-project-name
```

Then:
1. Open the folder in VS Code with GitHub Copilot + Claude models enabled
2. Select the **Manager** agent in the Copilot chat panel
3. For a standard PRD: use `/init-project` and paste your PRD
4. For a large PRD (500+ lines): use `/digest-prd` instead — compresses it into a task backlog first

> **Note**: `/init-project` and `/digest-prd` both handle the `.gitignore.project` rename automatically.

## Version History

**Current version**: `v1.2.1` — See [CHANGELOG.md](CHANGELOG.md) for full version history and upgrade notes.

To update an existing project to the latest boilerplate version, run `/update-boilerplate` from the Manager agent.

## Architecture

```
YOU ←→ Manager (Haiku) ←→ Engineer (Sonnet)
                        ←→ Security (Sonnet)
                        ←→ Designer (Haiku)
                        ←→ Researcher (Sonnet)
                        ←→ Consultant (Opus) [rare]
```

### Agents

| Agent | Model | Role | Writes Code? |
|-------|-------|------|-----------|
| **Manager** | Haiku | Plans, delegates, coordinates, pushes | No |
| **Engineer** | Sonnet | Implements features, fixes bugs, commits | Yes |
| **Security** | Sonnet | Adversarial auditing, finds vulnerabilities | No |
| **Designer** | Haiku | UI/UX review and design specs | No |
| **Researcher** | Sonnet | Competitive analysis, market research, feature gaps | No |
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
| `/init-project` | PRD intake, full scaffolding, GitHub Issues backlog, Context7 MCP config |
| `/mvp` | Max velocity mode: aggressive parallelization, deferred gates, scope razor, parallel Engineer sessions |
| `/digest-prd` | Digest large PRDs (500–2000+ lines) into brief + task backlog |
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

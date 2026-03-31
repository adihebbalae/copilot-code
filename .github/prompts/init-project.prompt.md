---
description: "Initialize a new project. Works with any input: point to a PRD file, paste one inline, or describe your idea and the Manager will build the PRD with you. One command for everything."
agent: "manager"
argument-hint: "Path to PRD file (e.g. prd.md), or describe what you want to build"
---

You are running `/init-project` — the single entry point for starting any new project. You handle every input type: existing PRD file, inline PRD paste, or raw idea with no PRD yet.

Work through the phases below in order. Do not skip phases. Do not scaffold until the user has approved the plan.

---

## Model Selection Strategy

**Before starting**: Set your model allocation:
- **Phase 1–3 (PRD intake, research)**: Use **Opus** or **Sonnet** — deep reading and research coordination requires full capacity
- **Phase 4+ (clarifications, setup questions)**: Default to **Haiku** — sufficient for Q&A once the brief is built
- **Task assignment** (Phase 7): Each task gets its optimal model (Engineer: Sonnet, Designer: Sonnet, Security: Opus, Consultant: Opus)

Rationale: PRD ingestion and research coordination are the most expensive cognitive steps. Everything after compression is tactical.

---

## Phase 0: Safety Check

Before anything else, check for an existing project:

```
If .agents/state.json exists AND status == "planning_complete" or "in_progress":
  STOP. Show this message:

  ⚠️  This project is already initialized.

  Current project: [project.name from state.json]
  Status: [status]
  Active task: [active_task]

  Running /init-project again will OVERWRITE all existing planning work.

  Options:
  1. Continue with current project → close this chat, open @engineer and run /handoff-to-engineer
  2. Start fresh (DESTRUCTIVE) → type "yes overwrite" to confirm

  Wait for user response before proceeding.
```

---

## Phase 1: PRD Detection & Intake

Determine what the user provided. Check in this priority order:

### 1A: File provided in `$ARGUMENTS`
If `$ARGUMENTS` contains a file path (e.g., `prd.md`, `./docs/prd.md`):
- Read the file fully with `read_file`. Do NOT skim.
- Note: `$ARGUMENTS` = `$ARGUMENTS`

### 1B: No arguments — scan root for PRD file
If `$ARGUMENTS` is empty, scan the workspace root for:
- `prd.md`, `PRD.md`, `prd.MD`
- Any file matching: `*prd*.md`, `*spec*.md`, `*requirements*.md`, `*brief*.md`

If exactly one match: confirm with user — "Found `[filename]` — using this as your PRD. Correct?"
If multiple matches: list them and ask user to pick one.
If no match: go to Phase 1C.

### 1C: No PRD found — build one with the user
If no PRD exists anywhere, run the Socratic PRD-building process inline:

Tell the user:
```
No PRD found. Let's build one together — I'll ask questions until we have zero ambiguity.
This usually takes 5–10 minutes and prevents weeks of wrong direction.

Start here:
1. What problem are you solving?
2. Who has this problem? (be specific — not "developers" but "solo devs shipping SaaS")
3. How do they solve it today?
4. What are the 3–5 features that MUST exist for v1 to be useful?
5. What are you explicitly NOT building in v1?
```

Wait for answers. Ask follow-up questions until you can answer all of these without guessing:
- What does the product do, exactly?
- Who uses it and what job does it do for them?
- What's the tech stack and deployment model?
- What ships in v1 vs later?
- What are the hard constraints (compliance, budget, timeline)?

Once you have full clarity, generate a PRD using the full format from the Project Brief template below, save it to `.dev/prd/original.md`, then continue to Phase 2.

---

## Phase 1.5: Stage the PRD File

Immediately after reading or generating the PRD:

1. Create `.dev/prd/` folder
2. Copy/save the PRD to `.dev/prd/original.md`
3. If the PRD was already at root (`prd.md` etc.), it stays where it is — just copy it. Do not delete the original.

**Why**: Raw PRD stays in `.dev/` (gitignored). The compressed brief in `state.json` becomes the canonical reference for all agents. The raw file is never needed again after compression.

---

## Phase 2: Compress Into Project Brief

Read the full PRD (from working memory or `.dev/prd/original.md`) and produce a **~50-line Project Brief**. This is the only thing agents will ever read. The raw PRD is dropped from context after this step.

```
## Project Brief

**Product**: [one-sentence description]
**User**: [specific persona, not generic category]
**Problem**: [what it solves and why it matters]

**Stack**: [languages, frameworks, databases, services]

**Core Features** (must ship in v1):
1. [feature] — [one-line description]
2. ...

**Non-Functional Requirements**:
- [perf / scale / security / a11y targets]

**Constraints**:
- [hard constraints: no X, must use Y, deadline Z, compliance requirements]

**Out of Scope** (v1):
- [explicit exclusions]

**Open Questions** (needs user input):
1. [question]
```

Write this brief to `.agents/state.md` under `## Project Brief`. **After writing, drop the raw PRD from active context — work only from the brief going forward.**

---

## Phase 3: Research Scoping

Assess the brief for research opportunities. **Before asking the user anything else**, evaluate:

- **New market / product category?** → Research competitive landscape, user pain, market size
- **"Free tier" or budget-conscious?** → Research free + open-source options in the stack
- **Competitors mentioned?** → Research their features, pricing, positioning
- **Tech stack unclear or debated?** → Research frameworks, databases, hosting options
- **Ambitious performance/scale claims?** → Research what "best in class" actually does

If **any apply**, invoke the Researcher subagent automatically (no user action needed):

```
Researcher task prompt:

PRD Summary: [2-3 sentence summary from brief]

Research scope:
1. Competitive landscape: [competitors from brief, or closest analogues]
2. Market sizing: [if a segment is mentioned]
3. User pain validation: [what problems are users hiring this to solve?]
4. Tech stack validation: [is the proposed stack the right choice for this scale/use case?]
5. Free-tier options: [if budget-conscious — what's free, what are the limits?]

Output: Save to .agents/research/[prd-slug].md with:
- Executive Summary (3-5 bullets)
- Competitive Analysis
- Tech Stack Recommendation
- Free Tools (if applicable)
- Key Gaps / Assumptions
- Recommendations

Return a brief summary to Manager when done.
```

Wait for Researcher to return. Then show findings to user:

```
## Research Complete

[Executive Summary bullets from .agents/research/[slug].md]

Full report: .agents/research/[slug].md

Key answers:
- [question from brief]: [answer from research]
- [question from brief]: [answer from research]

Gaps:
- [data not available / assumptions made]
```

If no research is needed, skip directly to Phase 4.

---

## Phase 4: Team Setup Questionnaire

Ask the user (one message, all questions at once):

```
## Team Setup

A few quick questions before I finalize the plan:

**Q1: Development environment?**
- [ ] GitHub Copilot + VS Code only
- [ ] GitHub Copilot + Claude Code CLI (recommended for complex projects)
- [ ] Other (describe)

**Q2: Project budget?**
- [ ] Free tier only — I'll find free options for everything
- [ ] Paid services available — use production-grade tooling
- [ ] Undecided — show me both options

**Q3: Team size and timeline?**
- Solo or team?
- When does v1 need to ship?
```

Wait for answers before proceeding.

---

## Phase 5: Clarify Until Zero Ambiguity

Using the brief + research findings + team setup answers, ask clarifying questions until there is **ZERO ambiguity**. One message, numbered list.

Must be resolved before scaffolding:
- **Exactly what the product does** (test: could you hand this brief to an engineer with no questions?)
- **Who uses it and why** (specific persona, not a category)
- **Tech stack confirmed** (research recommendation accepted or overridden with reason)
- **Deployment target** (where does it run?)
- **v1 scope locked** (what ships, what doesn't, hard deadline if any)
- **Any compliance / regulatory constraints** (GDPR, HIPAA, SOC 2, etc.)

If an answer is vague, probe deeper. If the brief contradicts itself, resolve it. If a feature has two interpretations, pick one.

Wait for answers. Update the brief in `.agents/state.md` with the resolved answers before proceeding.

---

## Phase 6: Architecture Decisions (if needed)

If the brief implies meaningful architecture choices NOT locked in by constraints (monolith vs. microservice, REST vs. GraphQL, ORM choice, auth strategy, realtime vs. polling, etc.):

Present 2–3 options with tradeoffs. Recommend one with explicit WHY. Ask user to confirm.

```
### Architecture Decision: [topic]

**Option A**: [name] — [1-line description]
- Pro: [key advantage]
- Con: [key tradeoff]

**Option B**: [name] — [1-line description]
- Pro: ...
- Con: ...

**Recommendation**: Option [X] because [specific reason tied to their project constraints].

Confirm? Or choose differently?
```

Update `state.json` with confirmed decisions under `project.architecture_decisions`.

---

## Phase 7: Break Down Into Tasks

Decompose confirmed features into an ordered task backlog. Each task:
- Scoped to a single agent session (max 2–4 hours of work)
- Assigned to one agent (Engineer / Security / Designer / Consultant)
- Sequenced correctly (respect dependencies)
- Sized correctly (not too big — if a task feels like 2 sessions, split it)

```json
{
  "id": "TASK-001",
  "title": "Short action title",
  "agent": "engineer",
  "model": "claude-sonnet",
  "depends_on": [],
  "description": "What to build",
  "acceptance_criteria": ["criterion 1", "criterion 2"],
  "why": "Why this comes first / why this approach"
}
```

Aim for 8–20 tasks. Group smaller tasks if needed. If 3+ distinct functional areas exist, generate `.agents/MODULES.md` (see Phase 8C).

---

## Phase 8: Full Plan Review

Before scaffolding anything, present the complete plan and ask for approval:

```
## Project Plan — Ready for Review

✅ Zero Ambiguity Confirmed
- All questions resolved, no hidden assumptions remain

### Summary
- Product: [one sentence]
- Stack: [confirmed stack]
- Deployment: [target]
- Team: [solo/team, tools, budget]

### Research Findings
- [key finding 1]
- [key finding 2]
(Full report: .agents/research/[slug].md)

### Architecture Decisions
- [decision]: [choice and why]

### Task Backlog ([N] tasks)
| ID | Title | Agent | Depends On |
|----|-------|-------|------------|
| TASK-001 | ... | engineer | — |
| TASK-002 | ... | engineer | TASK-001 |
...

### First 3 tasks:
1. TASK-001: [description]
2. TASK-002: [description]
3. TASK-003: [description]

---
Approve this plan? Or adjust before I scaffold?
```

**Do NOT begin scaffolding until user says yes.**

---

## Phase 9: Scaffold the Project

Once user approves:

### 9A: Clean Up Boilerplate Files
1. Delete `.gitignore` (template version)
2. Rename `.gitignore.project` → `.gitignore` (project version — strips agent files from git history)
3. Ensure `.dev/` and `_dev/` are in `.gitignore`:
   ```
   # Development / temporary planning files
   .dev/
   _dev/
   ```

### 9B: Write `.agents/state.json`
```json
{
  "project": {
    "name": "[project name]",
    "description": "[one-sentence description]",
    "tech_stack": ["..."],
    "architecture_decisions": {},
    "external_dependencies": []
  },
  "research_source": ".agents/research/[slug].md",
  "research_findings_incorporated": ["..."],
  "context": {
    "tools": {
      "copilot": true,
      "claude_code_cli": [true/false]
    },
    "budget": "[free/paid/tbd]"
  },
  "project_brief": "[compressed brief from Phase 2]",
  "tasks": [...],
  "active_task": "TASK-001",
  "status": "planning_complete",
  "handoff": {
    "approved_by_user": false,
    "target_agent": null
  },
  "changelog": ["init-project: project scaffolded [date]"],
  "last_updated": "[date]",
  "last_updated_by": "manager"
}
```

### 9C: Update `.agents/state.md`
Human-readable project overview. Include: project name, brief, confirmed stack, task count, first task.

### 9D: Update `.agents/workspace-map.md`
Add planned directory structure (prefix with `[planned]` for not-yet-created paths).

### 9E: Update `.github/copilot-instructions.md`
Add project-specific standards: stack, naming conventions, test framework, linting rules.

### 9F: Create GitHub Issues (one per task)
```bash
gh issue create \
  --title "[TASK-001] [Task title]" \
  --body "..." \
  --label "agent,task" \
  --assignee "@me"
```

Create labels first if needed:
```bash
gh label create "agent" --description "AI agent task" --color "0075ca"
gh label create "task" --description "Planned task" --color "e4e669"
gh label create "blocked" --description "Agent is blocked" --color "d93f0b"
```

Report all created issue URLs to user.

### 9G: Auto-Generate MCP Config
Detect tech stack from brief, generate `.vscode/mcp.json` with Context7 for library docs:
```json
{
  "servers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"],
      "type": "stdio"
    }
  }
}
```

Ask: **"Do you want web search for the Researcher agent? Options: (1) Tavily, (2) Brave Search, (3) Perplexity, (4) Skip"**

Add chosen server to `.vscode/mcp.json`.

### 9H: MODULES.md (complex projects only)
If 3+ distinct functional areas: generate `.agents/MODULES.md` with module registry, statuses, dependencies, and build order. Tell user to run `/list-modules` or `/show-graph`.

### 9I: Budget Research Task (free tier only)
If budget = free, create TASK-000 GitHub issue to research free deployment options before TASK-001.

---

## Phase 10: Post-Scaffold Summary

```
## ✅ Project Initialized

**[Project Name]** is ready to build.

Setup:
- Tools: [Copilot only / Copilot + CLI]
- Budget: [Free / Paid / TBD]
- Stack: [confirmed stack]
- Tasks: [N] tasks queued

Research: .agents/research/[slug].md
GitHub Issues: [repo link]

Next: TASK-001 — [title]
```

---

## Phase 11: Handoff to TASK-001

```
╔══════════════════════════════════════════════════════════════╗
║  🔀 SWITCH TO:  @engineer   |   MODEL:  Sonnet             ║
╚══════════════════════════════════════════════════════════════╝
```

1. Set `state.json` → `handoff.approved_by_user: true`, `handoff.target_agent: "[agent]"`
2. Write TASK-001 details to `.agents/handoff.md`
3. Tell the user:

> Open a **new chat** and select the **@[agent]** agent from the Copilot chat panel. Then run `/handoff-to-[agent]` to begin TASK-001.
>
> The agent will read `.agents/state.json` and `.agents/handoff.md` automatically — no context needed from this chat.

---

## Notes

- The raw PRD is **never stored** in state files — too large, too noisy. The brief is the canonical reference.
- If the PRD has phase/milestone structure, preserve that as task groupings (`phase: "MVP"`, `phase: "v1.1"`).
- Third-party integrations (Stripe, Supabase, etc.) → flag in `state.json` under `project.external_dependencies`.
- If the user runs `/init-project` a second time on the same project (Phase 0 triggers), they lost context from a previous chat. The safety check prevents data loss.

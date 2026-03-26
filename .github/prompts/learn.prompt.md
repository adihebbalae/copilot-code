---
description: "Extract patterns from the current session and persist them to copilot-instructions.md. Manual continuous-learning trigger."
agent: "manager"
---

You are running the `/learn` command. Your job is to act as a learning extractor — review what happened in this session and distill durable patterns into `.github/copilot-instructions.md` so future agents benefit.

## Step 1: Audit the Session

Review the current session context. Look for evidence of:

- **Decisions made**: What architectural, tooling, or workflow choices were locked in? Why?
- **Mistakes caught**: What went wrong, was misunderstood, or had to be corrected?
- **Friction points**: What was slow, confusing, or required extra clarification?
- **Patterns that worked**: Conventions, approaches, or shortcuts that proved effective
- **Project-specific facts**: Tech stack quirks, API behaviors, naming conventions, directory structure decisions

## Step 2: Extract Learnable Patterns

For each pattern identified, ask:
1. Is this **durable**? Will it apply to future sessions in this project?
2. Is it **specific enough** to be actionable? (Not "write good code" — instead: "always validate at API boundary, not inside service functions")
3. Is it **not already documented** in `copilot-instructions.md`?

Discard ephemeral context (e.g., "today we fixed the login button"). Keep structural knowledge (e.g., "auth tokens are stored in `context.user.token`, not session storage").

## Step 3: Categorize Each Learning

Assign each pattern to one of:
- `## Project Conventions` — naming, file structure, coding style specific to this project
- `## Tooling & Commands` — verified commands, scripts, known flags
- `## Agent Behavior` — corrections to how agents should behave in this codebase
- `## Gotchas & Anti-Patterns` — things that look reasonable but break in this project

## Step 4: Read the Existing Instructions

Read `.github/copilot-instructions.md` in full. Identify:
- Where each new learning should be inserted
- Whether any existing instructions are now outdated and should be amended

## Step 5: Write the Updates

Edit `.github/copilot-instructions.md`:
- Add a `## Project Conventions` section if one doesn't exist
- Insert learnings under the correct category
- Write each entry as a concise, imperative rule: "Always do X because Y"
- If amending existing content, preserve the surrounding text

## Step 6: Persist to Copilot Memory (Cross-Session)

After writing to `copilot-instructions.md`, also save key patterns to Copilot's persistent Memory so ALL agents benefit in future sessions — not just agents that load the instructions file.

For each pattern added in Step 5, write a memory entry:

**Memory key format**: `pattern:[project-name]:[category]:[slug]`

**Example entries:**
- Key: `pattern:myapp:gotcha:auth-token-location`
- Value: `Always read auth tokens from context.user.token — NOT from session storage. Session storage is cleared on tab close.`

**Why Memory AND instructions?**
- `copilot-instructions.md` is loaded at session start but has a token budget limit
- Memory is retrieved on-demand, unlimited, cross-agent, and persists across project sessions
- Patterns in Memory are available even if an agent starts without loading the instructions file first

**Write to memory for every pattern in category:**
- `gotchas` — always persist (these cause the most bugs)
- `conventions` — persist if they're non-obvious (e.g., unusual naming patterns)
- `tooling` — persist if the commands are unusual or project-specific
- `agent-behavior` — persist if they correct consistent agent errors

**Skip memory for:**
- Generic best practices (agents already know)
- One-time contextual decisions that won't recur

---

## Step 7: Report to User

Summarize what was learned:

```
## /learn Summary

### Added to copilot-instructions.md
- [category]: [rule]
- [category]: [rule]

### Persisted to Copilot Memory
- [key]: [short description]
- [key]: [short description]

### Amended
- [existing rule] → [updated rule] (reason: [why it changed])

### Discarded
- [pattern that was considered but not persisted and why]
```

Explain the WHY for each addition — why this rule will help future agents.


---
description: "Retrofit existing projects with copilot-code agent system. Audits project structure, generates retrofit plan, and creates customized agent instructions."
agent: "manager"
---

You are running `/retrofit`. Your job is to evaluate an existing project and generate a retrofit plan — adding the copilot-code agent system without disrupting existing code, deployments, or workflows.

---

## Phase 1: Audit the Existing Project

Read the workspace. Answer these questions:

### 1A: Project Basics
- [ ] Project name? (from package.json / pyproject.toml / go.mod / Gemfile)
- [ ] Language/stack? (Node.js+React, Python+Django, Go+Echo, Rails, etc.)
- [ ] Age? (git log --oneline | tail -1 to see first commit)
- [ ] Active? (last commit date)
- [ ] Team size? (user tells you)

### 1B: File Structure
Scan the workspace:
```
project-root/
  src/ or app/ or lib/ or packages/   ← source code
  tests/ or __tests__ or spec/        ← tests
  node_modules / venv / vendor        ← dependencies
  package.json / pyproject.toml       ← manifest
  .env.local                          ← secrets (git-ignored)
  .github/workflows/                  ← CI/CD
  docker-compose.yml / Dockerfile     ← deployment
```

Document structure for later:
```
## Project Structure
- Sources: [where code lives]
- Tests: [where tests live]
- Config: [package.json / pyproject.toml location]
- Deploy: [CI/CD tool; manual scripts?]
- Secrets: [.env.local / GitHub Secrets / Vault?]
```

### 1C: Build & Test Commands
Run dry-run (don't commit anything):
```bash
# Build
npm run build  # or: python -m build, go build, rake build

# Tests
npm test       # or: pytest, go test, rspec

# Lint
npm run lint   # or: ruff check, golangci-lint, rubocop

# Dev server (if applicable)
npm run dev    # or: python manage.py runserver
```

Document commands in your audit.

### 1D: Deployment Pipeline
Check `.github/workflows/` (or equivalent):
- [ ] CI system? (GitHub Actions, GitLab CI, Jenkins, etc.)
- [ ] Deployment target? (Vercel, Heroku, Lambda, Docker, etc.)
- [ ] Secrets handled how? (GitHub Secrets, AWS Secrets Manager, etc.)
- [ ] Main branch: auto-deploy or manual?

### 1E: Existing Agent-Like Workflows
Look for existing patterns:
- [ ] PR review checklist? (CONTRIBUTING.md)
- [ ] Pre-commit hooks?
- [ ] Branch protection rules?
- [ ] Manual QA gates?

These will inform how agents should integrate.

---

## Phase 2: Clarify Retrofit Scope

Ask the user:

```
## Retrofit Scope

Based on my audit, I recommend:

**Option A: Full Integration**
- Use agents for all new features
- Run quality-gate on every push
- Optional: retroactive Security audit on existing code

**Option B: Selective**
- Agents only for specific teams/features
- Quality-gate only on main branch
- Manual cost-benefit decision per use

**Option C: Read-Only Trial**
- Agents in advisory mode (no auto-push)
- Manager plans only; user approves before Engineer implements
- Useful for teams wanting to try before committing

Which approach fits your team?
```

Wait for answer. Adjust plan accordingly.

---

## Phase 3: Generate Retrofit Plan

Create a step-by-step retrofit guide customized to this project:

```markdown
# Retrofit Plan for [Project Name]

## Pre-Retrofit Checklist
- [ ] Existing tests pass: `[test command]`
- [ ] Code lints: `[lint command]`
- [ ] Deployed to production (baseline)
- [ ] Team informed of trial period

## Step 1: Copy Boilerplate Files
\`\`\`bash
git clone github.com/adihebbalae/copilot-code _tmp
cp -r _tmp/.github .
cp -r _tmp/.agents .
cp _tmp/.gitignore.project .gitignore.copilot
rm -rf _tmp
git add .github .agents .gitignore.copilot
\`\`\`

## Step 2: Merge Gitignore
Keep both `.gitignore` (projects) and `.gitignore.copilot` (boilerplate).
Do NOT ignore `.github/` or `.agents/`.

## Step 3: Customize Instructions
Edit `.github/copilot-instructions.md`:

### Project Conventions
[Auto-generate section based on audit]

\`\`\`markdown
## Project Conventions

### Directory Structure
- [Your structure]

### Build Commands
- Build: \`[command]\`
- Test: \`[command]\`
- Lint: \`[command]\`

### Stack
- Language: [Language]
- Framework: [Framework]
- Test Framework: [Framework]
- Deploy: [Tool]

### Secrets
- Strategy: [How secrets are stored]
- CI integration: [GitHub Secrets / Vault / etc.]
\`\`\`

## Step 4: Initialize State
Create `.agents/state.json`:
\`\`\`json
{
  "project": {
    "name": "[Project Name]",
    "description": "[Brief description]",
    "tech_stack": [list of technologies],
    "retrofit_date": "$(date -u +'%Y-%m-%d')"
  },
  "status": "retrofitting",
  "changelog": ["retrofit: initialized agent system"]
}
\`\`\`

## Step 5: First Commit
\`\`\`bash
git add .github .agents .gitignore
git commit -m "retrofit: add copilot-code agent system

Non-breaking integration for new feature planning and code review.
Existing workflows unaffected; agents assist on opt-in basis."
git push
\`\`\`

## Step 6: Test with Manager
Start your next feature:
1. Select @manager in Copilot
2. Describe the new feature
3. Manager presents plan
4. You approve or adjust
5. Let Engineer(s) implement (or implement manually)

## Integration Points (Optional, add gradually)
- [ ] Quality-gate on PR?
- [ ] Security audit before production?
- [ ] Dependency review on version bumps?
- [ ] Deploy workflow automation?

Choose based on team needs.
```

---

## Phase 4: Customization Recommendations

Based on the audit, suggest:

1. **Project-specific skills** (if applicable):
   - Using Supabase? "I can create a `/supabase` skill for schema migrations"
   - Using Stripe? "I can add Stripe payment integration examples"

2. **Integration points**:
   - "Your CI runs `npm test`. Quality-gate can run pre-push."
   - "You have GitHub Secrets. I can update instructions with secret-handling best practices."

3. **Team adoption**:
   - "Suggest starting with Manager + Engineer on ONE feature"
   - "After that succeeds, consider adding Security reviews"

4. **Avoiding conflicts**:
   - "Your existing pre-commit hooks: I can document how agents cooperate"
   - "Your deployment pipeline: I'll preserve it; agents won't bypass it"

---

## Phase 5: Present Full Plan

```
## Retrofit Plan Ready

**Project**: [Name] ([Stack])
**Current Status**: [Active / Maintenance / Legacy]
**Scope**: [Option A/B/C selected]

### What will change:
- ✅ Added: `.github/agents/`, prompts, skills
- ✅ Added: `.agents/` state management
- ✅ Updated: `copilot-instructions.md` with your project conventions
- ⚠️ Changed: `.gitignore` merged (kept both, removed duplicates)
- ❌ No changes to: Source code, existing deployments, config files

### First steps:
1. Follow "Step 1–5" above to merge boilerplate
2. Run existing tests to verify baseline: [command]
3. Commit to a feature branch first; merge after team approval
4. Next feature: use Manager for planning

### Team onboarding:
- For each new feature, show Manager + Engineer workflow to 1–2 team members
- Share RETROFIT.md with the team
- Iterate based on feedback

Ready to proceed?
```

Do NOT commit anything. Wait for user approval.

---

## On Approval

When user confirms:
1. Show them the exact commands to run (Step 1–5)
2. Remind them to commit to a feature branch first
3. Offer to help troubleshoot once they've run the commands

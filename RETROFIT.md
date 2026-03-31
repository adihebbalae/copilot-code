# Retrofitting Existing Projects with copilot-code

This guide helps you add the agent orchestration system to projects that already exist and have code/tests/deployments running.

---

## **When NOT to Retrofit (Use for New Projects Instead)**

Below scenarios, just clone the template fresh:
- Brand new project (< 1 month old)
- No existing git history you need to preserve
- No complex deployment pipeline
- Team is comfortable starting over

**For everything else**, retrofit selectively.

---

## **Retrofit Philosophy**

- **Non-invasive**: Drop `.github/` and `.agents/` alongside existing code
- **Gradual adoption**: Start agents on NEW features and refactors, not the entire codebase
- **Preserve workflows**: Don't force changes; optional integration
- **Project-specific tuning**: Agents adapt to your directory structure, naming, stack

The boilerplate is a **tool you adopt incrementally**, not a overhaul.

---

## **Step 1: Audit Your Project**

Before retrofitting, understand:
- [ ] **Project structure**: Where are source files? (`src/`, `lib/`, `app/`, `packages/`?)
- [ ] **Build system**: npm/yarn/pip/go/make?
- [ ] **Tests**: Where? What framework? (jest/pytest/rspec/go test)
- [ ] **Linting/formatting**: ESLint/Black/Rubocop/gofmt configured?
- [ ] **Deployment**: CI/CD pipeline? (GitHub Actions, GitLab, Jenkins, manual?)
- [ ] **Access**: Can you run Copilot agents? Do you have API keys/credentials?

Run the `/retrofit` prompt with the Manager to auto-generate this audit.

---

## **Step 2: Merge Boilerplate Files**

```bash
# In your existing project root:
git clone github.com/adihebbalae/copilot-code _copilot_template
cp -r _copilot_template/.github .
cp -r _copilot_template/.agents .
cp _copilot_template/.gitignore.project .gitignore.copilot
rm -rf _copilot_template
git add .github .agents .gitignore.copilot
```

**Do NOT rename `.gitignore` yet** — your project has its own. Keep both.

---

## **Step 3: Merge Gitignore Strategies**

You now have:
- `.gitignore` — your existing ignores
- `.gitignore.copilot` — template boilerplate ignores

**Merge them** (don't replace):
```bash
cat .gitignore.copilot >> .gitignore
# Remove duplicates manually, or:
sort .gitignore | uniq > .gitignore.tmp && mv .gitignore.tmp .gitignore
rm .gitignore.copilot
```

**Do NOT ignore `.github/` or `.agents/`** in your project. You want them committed (so agents can read them).

---

## **Step 4: Customize Agent Instructions**

Edit `.github/copilot-instructions.md`:

1. **Read "BOILERPLATE DEV MODE" block** at the top — since you're retrofitting, you're NOT editing the template, so this doesn't apply
2. **Customize project conventions** — add a section for YOUR project:

```markdown
## Project Conventions

### Directory Structure
- `src/` — React components
- `src/pages/` — Next.js pages
- `src/api/` — API routes
- `tests/` — Jest tests
- `public/` — Static assets

### File Naming
- Components: PascalCase (`Button.tsx`, `UserProfile.tsx`)
- Utilities: camelCase (`utils.ts`, `hooks.ts`)
- Styles: match component name + `.module.css`

### Code Style
- Prettier config: `.prettierrc.json`
- ESLint: `.eslintrc.json`
- TypeScript strict mode: enabled

### Testing
- Framework: Jest + React Testing Library
- Test location: `__tests__/` folder adjacent to source
- Coverage minimum: 80%

### Build & Deployment
- Build: `npm run build`
- Deploy: GitHub Actions → Vercel
- Main branch: always deployable
```

3. **Update dependencies constraint** in `.github/agents/engineer.agent.md` section 1.5 with YOUR package managers (npm/yarn/pip/go/etc.)

---

## **Step 5: Initialize `.agents/state.json`**

Create an initial project state (or use `/retrofit` prompt to auto-generate):

```json
{
  "project": {
    "name": "my-existing-project",
    "description": "Existing project with agent retrofitting",
    "tech_stack": ["Next.js", "React", "TypeScript", "Tailwind", "Supabase"],
    "started_date": "2023-06-15",
    "retrofit_date": "2026-03-25"
  },
  "active_task": null,
  "status": "retrofitting",
  "changelog": [
    "retrofit: merged boilerplate .github + .agents into existing project"
  ],
  "handoff": {
    "target_agent": null,
    "context": "",
    "approved_by_user": false
  }
}
```

---

## **Step 6: Commit & Test**

```bash
git add .github .agents .gitignore
git commit -m "retrofit: add copilot-code agent system

Non-breaking integration of multi-agent orchestration.
- Added .github/agents, prompts, skills
- Added .agents/ state management
- Project conventions in copilot-instructions.md
- Existing workflows unchanged; agents available for new tasks"

git push
```

---

## **Step 7: Use Agents for NEW Work**

**Don't** retrofit agents onto 2 years of existing code. Instead:

1. **Next feature?** Select Manager, run `/init-project` (works with any PRD size — point to a file or paste inline)
2. **Bug fix?** Select Engineer, describe the fix, paste relevant code
3. **Security review?** Select Security, paste code paths
4. **Code refactor?** Start with Engineer; if risky, add Security review

Agents integrate **forward**, not backward.

---

## **Step 8: Project-Specific MCPs & Skills**

The boilerplate includes generic skills (`code-review`, `security-audit`, `tdd`, `quality-gate`).

For your project, you might add:
- Supabase-specific skill (if using Supabase)
- Strpi payment skill (if using Stripe)
- Vercel deployment skill
- Custom lint rules

When Manager starts a task, it mentions: *"I'll add project-specific MCPs/skills as needed."* Leverage that.

---

## **Step 9: Gradual Team Adoption**

**Don't force** agents on the whole team. Instead:

| When | Who | Usage |
|------|-----|-------|
| New feature | PM + Lead Eng | Run `/init-project`, plan with Manager |
| Implementation | Engineer | Use `/handoff-to-engineer` for complex parts |
| Code review | Tech Lead | Run Security audit before merging |
| Deployment | DevOps | Use quality-gate before pushing main |

Agents are **tools**, not process.

---

## **Common Retrofit Issues**

### Issue: Agent can't find files
**Cause**: Project structure not in `.agents/workspace-map.md`

**Fix**: Update workspace-map with your actual structure:
```markdown
## Key Directories
- `src/components/` — React components
- `src/pages/` — Next.js pages
- `tests/` — Jest tests
- `api/` — Backend API routes
```

### Issue: "/init-project doesn't recognize my stack"
**Cause**: Boilerplate assumes generic stack; yours is custom

**Fix**: Edit `.github/prompts/init-project.prompt.md` to add your assumptions:
```
## Project Context (Specific to this repo)
- Stack: Next.js, React, TypeScript, Tailwind, Supabase
- Test framework: Jest + React Testing Library
- Deployment: Vercel + GitHub Actions
- Package manager: npm (pnpm alternative: yarn)
```

### Issue: Security audit doesn't know about my secrets strategy
**Cause**: Boilerplate assumes `.env.local` but you use something else

**Fix**: In `.github/copilot-instructions.md`, add:
```markdown
### Secrets Management
- Local dev: `.env.local` (git-ignored)
- Staging: GitHub Org Secrets (automatically loaded in CI)
- Production: Vault (reference in deployment script)
```

---

## **When to Retrofit vs. When to Start Fresh**

| Scenario | Retrofit? | Reason |
|----------|-----------|--------|
| 6-month-old project, active | Yes | Preserve git history; add agents for new work |
| Brand new 2-person project | No | Clone fresh; simpler onboarding |
| Legacy codebase, refactoring | Maybe | Retrofit for refactor tasks, not old code |
| Migrating from one framework to another | Yes | Keep old code; use agents for new framework |
| Large team, multiple projects | Yes | Retrofit each; standardize across org |

---

## **Next Steps After Retrofitting**

1. **Invite team**: Show them `/init-project` for next feature
2. **Document conventions**: Fill out "Project Conventions" section in copilot-instructions.md
3. **Run a test task**: Pick a small feature, let Manager plan it; let Engineer implement
4. **Iterate**: Adjust instructions based on what works/doesn't work
5. **Monitor & improve**: After 3–5 tasks, consider which agents were most useful; tune accordingly

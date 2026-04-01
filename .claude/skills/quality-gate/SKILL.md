---
name: quality-gate
description: "Pre-push quality gate checklist. Use when: before any git push, before opening a PR, after implementing a full feature, when Manager says 'run quality gate'. Runs lint, type-check, tests, and a security scan as a single sequential gate. Fails fast — does not proceed past a failing stage."
---

# Quality Gate Skill

## When to Use
- Before every `git push` (mandatory)
- Before opening or merging a PR
- After implementing a complete feature
- When Manager explicitly says "run quality gate"
- As the final step before any deployment

This gate answers one question: **Is this code safe to ship?**

---

## Gate Sequence

Run stages in this exact order. **Stop on first failure.** Do not report "gate passed" if any stage fails.

```
Stage 1: Lint
Stage 2: Type-Check
Stage 3: Tests
Stage 4: Security Scan
Stage 5: Final Verdict
```

---

## Stage 1: Lint

Catch style violations, unused imports, and obvious errors before they reach review.

### Run
```bash
# JavaScript / TypeScript
npx eslint . --ext .ts,.tsx,.js,.jsx --max-warnings 0

# Python
ruff check .

# Go
golangci-lint run

# Ruby
rubocop
```

Adapt the command to the project's package.json scripts if a lint script exists (prefer `npm run lint`).

### Pass Criteria
- [ ] Zero lint errors
- [ ] Zero lint warnings (warnings left in = technical debt shipped)

### On Failure
Fix all lint issues. Do not disable lint rules without explicit user approval. Do not proceed to Stage 2 until Stage 1 is clean.

---

## Stage 2: Type-Check

Catch type errors that slip past lint.

### Run
```bash
# TypeScript
npx tsc --noEmit

# Python (mypy)
mypy .

# Go (built into build)
go build ./...
```

Adapt to the project's `typecheck` script if one exists in `package.json`.

### Pass Criteria
- [ ] Zero type errors
- [ ] `--noEmit` used (do not emit output files as a side effect)

### On Failure
Fix all type errors. Do not use `// @ts-ignore` or `any` to silence errors without user approval. Do not proceed to Stage 3 until Stage 2 is clean.

---

## Stage 3: Tests

Validate correctness end-to-end.

### Run
```bash
# Jest / Vitest
npm test -- --run --reporter=verbose

# pytest
pytest -v --tb=short

# Go
go test ./... -v

# RSpec
bundle exec rspec --format documentation
```

Use the project's test script if defined (prefer `npm test`, `yarn test`, etc.).

### Pass Criteria
- [ ] All tests pass (0 failures, 0 errors)
- [ ] No skipped tests that should be running (review `test.skip` / `xit` / `pending`)
- [ ] If coverage is configured: coverage does not decrease below baseline

### On Failure
Run the failing tests in isolation to diagnose. Fix the failure. Re-run the full suite. Do not proceed to Stage 4 until Stage 3 is clean.

---

## Stage 4: Security Scan

Quick surface-level scan for critical issues introduced in this changeset.

### 4A: Dependency Audit
```bash
# Node.js
npm audit --audit-level=high

# Python
pip-audit

# Ruby
bundle audit check --update
```

### 4B: Secrets Scan
Check that no credentials, tokens, or keys were accidentally committed:
```bash
# If git-secrets or gitleaks is available
gitleaks detect --source . --no-git

# Otherwise: manual grep
grep -rn "password\s*=\s*['\"]" --include="*.ts" --include="*.js" --include="*.py" .
grep -rn "api_key\s*=\s*['\"]" --include="*.ts" --include="*.js" --include="*.py" .
grep -rn "secret\s*=\s*['\"]" --include="*.ts" --include="*.js" --include="*.py" .
```

### 4B2: Dependency Supply Chain Audit (HIGH PRIORITY)
**If package.json / requirements.txt / Gemfile / go.mod changed, invoke @security agent BEFORE pushing.**

Do NOT assume the quality gate audit is sufficient. Security performs:
- Typosquatting detection (name similarity to popular packages)
- Maintainer verification (unexpected changes, abandoned packages)
- Transitive dependency audit (indirect deps)
- SBOM generation (artifacts for compliance/inventory)
- Lock file integrity validation

See Security agent documentation for full dependency review process.

### 4C: Quick OWASP Check (for changed files only)
For each file modified in this push, verify:
- [ ] User input is validated before use
- [ ] No raw SQL string concatenation
- [ ] No `eval()` or equivalent dynamic code execution
- [ ] No hardcoded credentials
- [ ] Auth checks present on any new route/endpoint

For a full audit, invoke the `@security` agent separately.

### Pass Criteria
- [ ] Zero HIGH or CRITICAL dependency vulnerabilities (direct)
- [ ] Transitive dependencies also checked (npm audit includes this)
- [ ] No secrets found in source files
- [ ] No obvious OWASP violations in changed files
- [ ] If dependencies changed: SBOM generated + @security agent cleared before push

### On Failure
- **Dependency vulnerability**: Update the package or document the exception with user approval. Do not push with unmitigated HIGH/CRITICAL CVEs.
- **Secret found**: Remove immediately, rotate the credential, force-push if already committed.
- **OWASP violation**: Fix before pushing. Tag `@security` for a full audit if the scope is large.

---

## Stage 5: Final Verdict

Only after all four stages pass:

```markdown
## Quality Gate: PASSED ✅

| Stage        | Result  | Notes                        |
|:-------------|:--------|:-----------------------------|
| Lint         | ✅ Pass | 0 errors, 0 warnings         |
| Type-Check   | ✅ Pass | 0 errors                     |
| Tests        | ✅ Pass | 142 passed, 0 failed         |
| Security     | ✅ Pass | 0 vulns, 0 secrets           |

**Safe to push.**
```

If any stage fails, output:

```markdown
## Quality Gate: BLOCKED ❌

| Stage      | Result  | Notes                              |
|:-----------|:--------|:-----------------------------------|
| Lint       | ✅ Pass |                                    |
| Type-Check | ❌ FAIL | 3 type errors in auth/session.ts   |
| Tests      | ⏭ Skip | Blocked by Stage 2 failure         |
| Security   | ⏭ Skip | Blocked by Stage 2 failure         |

**Do NOT push. Fix Stage 2 failures first.**
```

---

## Integration with Security Agent

The quality gate's Stage 4 is a quick surface scan, not a full audit.

**Mandatory @security review for:**
- Any dependency changes (stages 4A2 covers the full supply chain audit)
- Auth, payments, file uploads
- New API surface
- Any HIGH/CRITICAL findings in 4A or 4B

Always invoke `@security` after the gate if any of the above apply.

The gate catches the obvious. The Security agent catches the subtle. **Supply chain attacks are sophisticated — never skip the Security agent review for dependency changes.**

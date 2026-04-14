---
name: quality-gate
description: "Pre-push quality gate checklist. Use when: before any git push, before opening a PR, after implementing a full feature, when Manager says 'run quality gate'. Runs lint, type-check, tests, and a security scan as a single sequential gate. Fails fast."
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

### Pass Criteria
- [ ] Zero lint errors
- [ ] Zero lint warnings

### On Failure
Fix all lint issues. Do not proceed to Stage 2 until Stage 1 is clean.

---

## Stage 2: Type-Check

### Run
```bash
# TypeScript
npx tsc --noEmit

# Python
mypy .

# Go
go build ./...
```

### Pass Criteria
- [ ] Zero type errors

### On Failure
Fix all type errors. Do not use `// @ts-ignore` or `any` without user approval. Do not proceed to Stage 3.

---

## Stage 3: Tests

### Run
```bash
# Jest / Vitest
npm test -- --run --reporter=verbose

# pytest
pytest -v --tb=short

# Go
go test ./... -v
```

### Pass Criteria
- [ ] All tests pass (0 failures, 0 errors)
- [ ] No skipped tests that should be running

### On Failure
Run failing tests in isolation to diagnose. Fix, re-run full suite. Do not proceed to Stage 4.

---

## Stage 4: Security Scan

### 4A: Dependency Audit
```bash
npm audit --audit-level=high   # Node.js
pip-audit                       # Python
bundle audit check --update     # Ruby
```

### 4B: Secrets Scan
```bash
gitleaks detect --source . --no-git
# Or manual grep:
grep -rn "password\s*=\s*['\"]" --include="*.ts" --include="*.py" .
grep -rn "api_key\s*=\s*['\"]" --include="*.ts" --include="*.py" .
```

### 4C: Quick OWASP Check (changed files only)
- [ ] User input validated before use
- [ ] No raw SQL string concatenation
- [ ] No `eval()` or dynamic code execution
- [ ] No hardcoded credentials
- [ ] Auth checks on any new route/endpoint

### Pass Criteria
- [ ] Zero HIGH or CRITICAL dependency vulnerabilities
- [ ] No secrets in source files
- [ ] No obvious OWASP violations in changed files

### On Failure
- **Dependency vulnerability**: Update or document exception with user approval. Do not push with unmitigated HIGH/CRITICAL CVEs.
- **Secret found**: Remove immediately, rotate the credential.
- **OWASP violation**: Fix before pushing. Tag `@security` for full audit.

---

## Stage 5: Final Verdict

```markdown
## Quality Gate: PASSED ✅
| Stage      | Result  | Notes               |
|:-----------|:--------|:--------------------|
| Lint       | ✅ Pass | 0 errors            |
| Type-Check | ✅ Pass | 0 errors            |
| Tests      | ✅ Pass | all passed          |
| Security   | ✅ Pass | 0 vulns, 0 secrets  |
**Safe to push.**
```

---

## Integration with Security Agent

Stage 4 is a quick surface scan. Invoke `@security` agent separately for:
- Any dependency changes
- Auth, payments, file uploads
- New API surface
- Any HIGH/CRITICAL findings

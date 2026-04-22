---
name: quality-gate
description: Pre-push quality gate checklist. Use when before any git push, before opening a PR, after implementing a full feature, or when asked to run the quality gate. Runs lint, type-check, tests, and a security scan as a single sequential gate. Fails fast — does not proceed past a failing stage.
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

**Pass criteria**: Zero warnings, zero errors.
**On failure**: Fix all lint errors before proceeding. Do not use `--fix` blindly — review each change.

---

## Stage 2: Type-Check

```bash
# TypeScript
npx tsc --noEmit

# Python (mypy)
mypy .

# Go (built-in)
go build ./...
```

**Pass criteria**: Zero type errors.
**On failure**: Fix type errors. If a type error requires a larger refactor, flag it to the Manager — do not use `any` to silence it.

---

## Stage 3: Tests

```bash
# JavaScript / TypeScript
npx vitest run          # Vitest
npx jest --ci           # Jest

# Python
pytest --tb=short -q

# Go
go test ./... -count=1

# Ruby
bundle exec rspec
```

**Pass criteria**: All tests pass. Zero skipped tests that weren't already skipped before your changes.
**On failure**: Fix the failing tests. Do not delete or skip tests to make the gate pass.

---

## Stage 4: Security Scan

Run a dependency vulnerability scan:

```bash
# Node.js
npm audit --audit-level=high

# Python
pip-audit --desc

# Go
go list -json -m all | nancy sleuth

# Ruby
bundle audit check --update
```

Then invoke the `security-audit` skill for a manual code review of any changed files.

**Pass criteria**: Zero HIGH or CRITICAL vulnerabilities. MEDIUM and LOW findings must be documented in `.agents/state.md` with a remediation plan.
**On failure**: Do not push. Resolve CRITICAL and HIGH findings first.

---

## Stage 5: Final Verdict

Only after all four stages pass:

```
✅ GATE PASSED — Safe to push
  Stage 1 (Lint): PASS
  Stage 2 (Type-Check): PASS
  Stage 3 (Tests): PASS
  Stage 4 (Security): PASS
```

If any stage failed:

```
❌ GATE FAILED — Do NOT push
  Stage 1 (Lint): PASS
  Stage 2 (Type-Check): FAIL — [brief description]
  Stage 3 (Tests): SKIPPED
  Stage 4 (Security): SKIPPED
```

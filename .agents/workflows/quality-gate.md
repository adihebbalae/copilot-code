---
description: "Run the pre-push quality gate: lint → type-check → tests → security scan. Fails fast. Do not push with any stage failing. Run after every feature implementation."
---

# Quality Gate

Run the sequential quality gate before any push or PR.

## Steps

1. **Stage 1 — Lint**: Run the project linter (`npm run lint`, `ruff check .`, `golangci-lint run`, etc.). Stop if there are any errors or warnings. Fix all issues before proceeding.

2. **Stage 2 — Type-Check**: Run the type checker (`npx tsc --noEmit`, `mypy .`, etc.). Stop if there are type errors. Fix before proceeding.

3. **Stage 3 — Tests**: Run the full test suite (`npm test`, `pytest`, `go test ./...`, etc.). All tests must pass. Fix failures before proceeding.

4. **Stage 4 — Security Scan**: Run `npm audit --audit-level=high` (or equivalent). For a full OWASP-based audit, invoke the security-audit skill or run /handoff-to-security.

5. **Final Verdict**: Report the result:
   - ✅ All stages green → safe to push
   - ❌ Any stage failed → list failures, fix them, re-run gate from the beginning

**Do not skip stages. Do not report "gate passed" if any stage failed.**

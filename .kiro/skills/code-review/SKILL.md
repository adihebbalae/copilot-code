---
name: code-review
description: On-demand code review checklist. Use when reviewing code changes, doing a PR review, self-reviewing before committing, or checking code quality after implementation. Covers readability, correctness, performance, security, and maintainability.
---

# Code Review Skill

## When to Use
- Before opening a PR
- When reviewing someone else's code
- As a self-review after implementation
- When Manager or Engineer requests a quality check

---

## Phase 1: Understand Before Judging

Before reviewing any line, understand the intent:
- What problem does this change solve?
- What was the alternative approach? Why was this one chosen?
- Is this a refactor, a new feature, a bug fix, or a hotfix?

If the intent is unclear, ask — don't guess.

---

## Phase 2: Correctness

- [ ] Does the code do what it claims to do?
- [ ] Are edge cases handled? (empty inputs, null values, zero, negative numbers, max values)
- [ ] Are error conditions handled at system boundaries (API calls, DB queries, file I/O)?
- [ ] Are there off-by-one errors in loops or index operations?
- [ ] Are async operations awaited properly? No floating promises?
- [ ] Are race conditions possible in concurrent operations?
- [ ] Does the logic match the spec/PRD or the ticket description?
- [ ] Are there any unintended side effects?

---

## Phase 3: Readability

- [ ] Can you understand what the code does without reading every line?
- [ ] Are function and variable names self-documenting?
- [ ] Is each function doing one thing? (Single Responsibility Principle)
- [ ] Are magic numbers or strings replaced with named constants?
- [ ] Is there dead code (commented out, never called)?
- [ ] Are comments explaining WHY (not WHAT the code does)?
- [ ] Is the code formatted consistently with the project style?

---

## Phase 4: Performance

- [ ] Are there N+1 query patterns? (loop with DB call inside)
- [ ] Are expensive operations (network, DB, compute) happening inside loops?
- [ ] Is data fetched that is never used?
- [ ] Are large datasets paginated or streamed, not loaded in full?
- [ ] Are database queries using indexes where expected?
- [ ] Are there unnecessary re-renders or re-computations in the UI?

---

## Phase 5: Security

- [ ] Is all user input validated and sanitized?
- [ ] Are SQL queries parameterized (no string concatenation)?
- [ ] Is authorization checked on each endpoint, not just in the UI?
- [ ] Are secrets handled through environment variables, not hardcoded?
- [ ] Are sensitive data fields excluded from logs?
- [ ] Are new dependencies vetted? (See `security-audit` skill for full scan)

---

## Phase 6: Maintainability

- [ ] Is the change backward compatible? If not, is the migration plan documented?
- [ ] Are new abstractions justified? (Is this pattern used 3+ times?)
- [ ] Is there test coverage for the new behavior?
- [ ] Do existing tests still pass without modification?
- [ ] Is the PR small enough to review in one sitting (<400 lines)? If not, flag for splitting.
- [ ] Will a new team member understand this code in 6 months?

---

## Report Format

Use this format to structure feedback:

```markdown
## Code Review: [PR / Feature Name]

### Summary
[1-2 sentences on overall quality — not praise, just calibration]

### Required Changes (Blockers)
- **[file:line]** — [Issue]. [Why it matters]. [How to fix].

### Suggested Changes (Non-blocking)
- **[file:line]** — [Observation]. [Better approach].

### Observations (No action needed)
- [Pattern worth noting for future reference]

### Verdict
APPROVE ✅ / REQUEST CHANGES ❌ / APPROVE WITH SUGGESTIONS ⚠️
```

### Severity Calibration
- **Required**: Correctness, security, or data integrity issues. PR cannot merge as-is.
- **Suggested**: Code quality, readability, or performance improvements. Merge after author acknowledges.
- **Observations**: Style, patterns, or educational notes. No action required.

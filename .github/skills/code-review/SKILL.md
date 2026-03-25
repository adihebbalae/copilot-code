---
name: code-review
description: "On-demand code review checklist. Use when: reviewing code changes, PR review, self-review before committing, checking code quality after implementation. Covers readability, correctness, performance, security, and maintainability."
---

# Code Review Skill

## When to Use
- After implementing a feature (self-review)
- Before committing code
- When asked to review a PR or diff
- When the Manager's handoff includes a code review gate

## Review Process

### 1. Understand the Change
- What problem does this code solve?
- Read the relevant `.agents/state.json` task for context
- Identify all modified files

### 2. Correctness
- [ ] Does the code do what it claims to do?
- [ ] Are edge cases handled? (null, empty, zero, negative, overflow, max length)
- [ ] Are error paths tested, not just happy paths?
- [ ] Are race conditions possible? (concurrent access, async operations)
- [ ] Do function contracts match their callers' expectations?

### 3. Readability
- [ ] Are names descriptive and consistent with codebase conventions?
- [ ] Is the code self-documenting, or does it need comments for non-obvious logic?
- [ ] Are functions small and single-purpose?
- [ ] Is nesting depth reasonable (max 3 levels)?
- [ ] Would a new team member understand this without explanation?

### 4. Performance
- [ ] No unnecessary database queries (N+1 problem)
- [ ] No unnecessary re-renders or re-computations
- [ ] Large data sets handled efficiently (pagination, streaming, lazy loading)
- [ ] No blocking operations on the main thread
- [ ] Appropriate use of caching where applicable

### 5. Security (Quick Check)
- [ ] No secrets, API keys, or credentials in code
- [ ] User input validated and sanitized
- [ ] SQL queries parameterized (no string concatenation)
- [ ] No dangerouslySetInnerHTML or equivalent without sanitization
- [ ] Authentication/authorization checked on every protected route

### 6. Maintainability
- [ ] No dead code or commented-out code
- [ ] No duplicate code that should be extracted
- [ ] Dependencies are justified (not adding a library for one function)
- [ ] Tests cover the new code paths
- [ ] Error messages are helpful for debugging

### 7. Report Format
```markdown
## Code Review: [Feature/Change]

### Summary
[One sentence: what was reviewed]

### Findings
| # | Severity | File:Line | Issue | Suggestion |
|---|----------|-----------|-------|------------|
| 1 | High     | file.ts:42 | [issue] | [fix] |
| 2 | Medium   | file.ts:88 | [issue] | [fix] |

### Verdict
APPROVE / REQUEST CHANGES / NEEDS DISCUSSION
```

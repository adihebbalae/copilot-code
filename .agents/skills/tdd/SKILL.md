---
name: tdd
description: "TDD workflow skill enforcing RED → GREEN → REFACTOR. Use when: implementing any feature test-first, writing unit or integration tests, building with a test-heavy stack (Jest, Vitest, pytest, RSpec, etc.). Prevents writing implementation before a failing test exists."
---

# TDD Skill

## When to Use
- Any feature implementation when tests are in scope
- When the Manager's handoff says "write tests first" or "TDD"
- When working with testing-heavy stacks (React + Jest/Vitest, Python + pytest, Rails + RSpec, Go + testing package)
- When building pure functions, API handlers, service logic, validators, or utilities

## The TDD Cycle

```
RED    → Write a failing test first. It MUST fail before you write code.
GREEN  → Write the minimum code to make the test pass. No more.
REFACTOR → Clean up the code. Tests must stay green after refactor.
```

Never skip to GREEN. Never write implementation before a failing test exists.

---

## Phase 1: RED — Write the Failing Test

### 1.1 Understand the Contract
Before writing a single line of test code, define the contract:
- What input does this function/component accept?
- What output or side effect does it produce?
- What error conditions exist?

### 1.2 Write the Test
- Name tests descriptively: `it("returns 401 when token is expired")` not `it("works")`
- Test one behavior per test case
- Use AAA structure: **Arrange** → **Act** → **Assert**
- Test the interface, not the implementation

### 1.3 Verify it Fails
Run the test suite. **Confirm the test fails for the right reason.**
- ❌ "Cannot find module X" — wrong failure. Create the module stub first.
- ✅ Test runs and assertion fails on the actual behavior.

Do not proceed to GREEN until the test fails for the correct reason.

---

## Phase 2: GREEN — Write Minimum Passing Code

### 2.1 Implement the Minimum
Write only what's needed to make the failing test pass. Do not add:
- Extra error handling not yet tested
- Performance optimizations
- Abstractions for future use cases (YAGNI)

### 2.2 Run the Full Suite
Run the **entire test suite** to catch regressions. Never leave the suite broken.

### 2.3 Verify GREEN
All tests must pass. Then and only then proceed to REFACTOR.

---

## Phase 3: REFACTOR — Clean Without Changing Behavior

### 3.1 What to Refactor
- Remove duplication
- Rename variables/functions to better names
- Extract helpers if logic is complex
- Apply project conventions

### 3.2 What NOT to Refactor
- Do not add new behavior during refactor
- Do not change test assertions (they define the contract)

### 3.3 Verify GREEN Again
Run the full test suite after each refactor step. Tests must remain green.

---

## Checklist Per Feature

- [ ] Contract defined (inputs, outputs, error cases) before any code written
- [ ] Test written first, not after
- [ ] Test confirmed to **fail** before writing implementation
- [ ] Failure reason is correct (not "module not found")
- [ ] Implementation written to make test pass
- [ ] No over-engineering in GREEN phase
- [ ] Full suite green after GREEN phase
- [ ] Refactor applied without changing behavior
- [ ] Full suite still green after REFACTOR
- [ ] All edge cases have their own RED → GREEN → REFACTOR cycles

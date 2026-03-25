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
RED  →  Write a failing test first. It MUST fail before you write code.
GREEN  →  Write the minimum code to make the test pass. No more.
REFACTOR  →  Clean up the code. Tests must stay green after refactor.
```

Never skip to GREEN. Never write implementation before a failing test exists.

---

## Phase 1: RED — Write the Failing Test

### 1.1 Understand the Contract
Before writing a single line of test code, define the contract:
- What input does this function/component accept?
- What output or side effect does it produce?
- What error conditions exist?

Write this contract as a comment block at the top of the test file.

### 1.2 Write the Test
- Name tests descriptively: `it("returns 401 when token is expired")` not `it("works")`
- Test one behavior per test case
- Use AAA structure: **Arrange** → **Act** → **Assert**
- Test the interface, not the implementation (no testing private methods)

```ts
// Example (Vitest / Jest)
it("rejects login when password is wrong", async () => {
  // Arrange
  const user = await createTestUser({ password: "correct-password" });

  // Act
  const result = await loginService({ email: user.email, password: "wrong" });

  // Assert
  expect(result.success).toBe(false);
  expect(result.error).toBe("INVALID_CREDENTIALS");
});
```

### 1.3 Verify it Fails
Run the test suite. **Confirm the test fails for the right reason.**
- ❌ "Cannot find module X" — wrong failure. Create the module stub first.
- ❌ "expect(undefined).toBe(false)" — wrong failure if function doesn't exist yet.
- ✅ Test runs and assertion fails on the actual behavior.

Do not proceed to GREEN until the test fails for the correct reason.

---

## Phase 2: GREEN — Write Minimum Passing Code

### 2.1 Implement the Minimum
Write only what's needed to make the failing test pass. Do not add:
- Extra error handling not yet tested
- Extra branches not yet covered
- Performance optimizations
- Abstractions for future use cases (YAGNI)

The ugliest code that makes the test green is correct at this stage.

### 2.2 Run the Full Suite
Don't just run the new test. Run the **entire test suite** to catch regressions.
- If existing tests break, fix them before continuing.
- Never leave the suite in a broken state between cycles.

### 2.3 Verify GREEN
All tests must pass. Then and only then proceed to REFACTOR.

---

## Phase 3: REFACTOR — Clean Without Changing Behavior

### 3.1 What to Refactor
- Remove duplication (DRY within reason)
- Rename variables/functions to better names
- Extract helper functions if logic is complex
- Apply project conventions (naming, file structure)
- Improve readability

### 3.2 What NOT to Refactor
- Do not add new behavior during refactor
- Do not change test assertions (tests define the contract — if tests need changing, that's a new RED cycle)
- Do not extract abstractions not validated by multiple use cases

### 3.3 Verify GREEN Again
Run the full test suite after each refactor step. Tests must remain green.

---

## Checklist Per Feature

- [ ] Contract defined (inputs, outputs, error cases) before any code written
- [ ] Test written first, not after
- [ ] Test confirmed to **fail** before writing implementation
- [ ] Failure reason is correct (not "module not found" or "is not a function")
- [ ] Implementation written to make test pass
- [ ] No over-engineering in GREEN phase
- [ ] Full suite runs green after GREEN phase
- [ ] Refactor applied without changing behavior
- [ ] Full suite still green after REFACTOR
- [ ] All edge cases have their own RED → GREEN → REFACTOR cycles

---

## Common Edge Cases to Test (Don't Skip These)

| Category | What to Cover |
|---|---|
| Input validation | null, undefined, empty string, wrong type, boundary values |
| Auth boundary | unauthenticated, wrong role, expired token |
| Async behavior | resolved promise, rejected promise, timeout |
| Side effects | database writes, emails, events emitted |
| Error paths | service throws, dependency unavailable, partial failure |

---

## Test Organization

```
src/
  features/
    auth/
      login.ts           ← implementation
      login.test.ts      ← tests live beside the code they test
```

- Co-locate test files with source files (not in a separate `__tests__` folder unless project convention differs)
- One test file per module
- Group related tests with `describe` blocks

---

## Self-Test Loop (Engineer Must Follow)

Before reporting back to Manager:
1. Run full test suite
2. If any test fails → fix → re-run
3. Repeat until 100% green
4. Report: tests added, tests passing, coverage delta if measurable

Never report "tests should pass" — verify they do.

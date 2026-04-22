---
name: tdd
description: TDD workflow skill enforcing RED to GREEN to REFACTOR. Use when implementing any feature test-first, writing unit or integration tests, or building with a test-heavy stack like Jest, Vitest, pytest, or RSpec. Prevents writing implementation before a failing test exists.
---

# TDD Skill

## The Only Rule
**Never write implementation code without a failing test that demands it.**

This rule has no exceptions. If you find yourself writing a function before a test, stop, write the test first, watch it fail, then write the function.

---

## The Cycle

```
RED → GREEN → REFACTOR → repeat
```

Each cycle is one behavior, not one file. Keep cycles small.

---

## Phase 1: RED — Write a Failing Test

1. **State the behavior in plain English first**:
   ```
   "A logged-in user can view their order history"
   ```

2. **Write the smallest test that captures this behavior**:
   ```ts
   // Jest / Vitest
   it('returns order history for authenticated user', async () => {
     const user = await createTestUser({ authenticated: true });
     const response = await request(app)
       .get('/api/orders')
       .set('Authorization', `Bearer ${user.token}`);
     
     expect(response.status).toBe(200);
     expect(response.body.orders).toBeInstanceOf(Array);
   });
   ```

3. **Run the test suite and confirm it FAILS**:
   ```bash
   npx vitest run --reporter=verbose
   # Must see: FAIL — [test name]
   ```

4. **If the test passes without implementation, the test is wrong.** Delete it and reconsider.

**Exit criteria**: At least one clearly failing test.

---

## Phase 2: GREEN — Make It Pass (Minimal Code Only)

1. **Write the minimum code needed to make the test pass** — no more, no less
   - Hardcoded return values are acceptable temporarily
   - No premature abstractions
   - No "while I'm here" improvements

2. **Run the full test suite**:
   ```bash
   npx vitest run
   ```

3. **If new failures appear**, the implementation broke something. Fix it before continuing.

4. **Do not refactor yet** — getting to green is the only goal of this phase.

**Exit criteria**: All tests pass, including your new one.

---

## Phase 3: REFACTOR — Improve Without Breaking

Only after tests are green:

1. **Eliminate duplication** — extract shared logic, merge similar patterns
2. **Improve naming** — variables, functions, classes should be self-documenting
3. **Simplify conditionals** — if you need a comment to explain an `if`, refactor it
4. **Remove dead code** — no commented-out code, no unused variables
5. **Apply abstractions** — only when the same logic appears 3+ times

After every refactor, run tests:
```bash
npx vitest run
```

Tests must remain green throughout. If they go red, undo the refactor.

**Exit criteria**: Tests still green, code is cleaner than before.

---

## Repeat
Go back to Phase 1 with the next behavior.

---

## Test Quality Checklist

Before calling a test "done":
- [ ] The test name describes behavior, not implementation (`returns 200` → `allows authenticated user to access orders`)
- [ ] One assertion per test (or tightly related assertions for one behavior)
- [ ] No `sleep()` or arbitrary delays — use mocks or async/await properly
- [ ] Test is deterministic — passes every time regardless of order
- [ ] No test depends on state left by another test
- [ ] Happy path tested AND at least one error/edge case tested

---

## When TDD Feels Hard

**"I don't know what to test"** — Write the interface first (function signature, API contract), then test that contract.

**"The test requires too much setup"** — That's a design signal. Decouple the code, reduce dependencies.

**"I need to test a private function"** — Don't. Test the public behavior that exercises it.

**"I'll write tests after"** — No. Green code without a test is unverified code. Do not skip the red phase.

# BDR Commit Message Template

**BDR** = **Business/Behavior** · **Decision** · **Rationale**

Use this template for all commits (especially those from Engineer tasks). It captures *why* the change was made, not just *what* was changed.

## Template

```
<type>(<scope>): <one-line summary>

Contract: <what externally observable behavior this commit delivers>

Acceptance: <how to verify this works — reference specific test files, commands, or user-facing checks>

Rejected: <brief note on alternatives considered and why this approach was chosen instead>

Non-scope: <what this commit deliberately doesn't address, to prevent future confusion>

<optional longer body explaining context, tradeoffs, or implementation notes>

Co-Authored-By: [Agent Name] <[email]>
```

## Field Definitions

### `<type>(<scope>): <one-line summary>`
Standard conventional commit. Examples:
- `feat(auth): add OAuth 2.0 Google login`
- `fix(search): handle null query parameters`
- `refactor(database): extract connection pooling to separate module`
- `test(api): add edge case coverage for rate limiting`

Keep summary under 50 characters. Use lowercase. No period.

### `Contract:`
**One sentence**: What does this commit make true? What can the user or QA do differently after this commit?

Examples:
- "Users can now sign in with Google OAuth credentials instead of password only."
- "Database connections reuse a pool instead of creating a new connection per query, reducing 503 errors during traffic spikes."
- "Email validation now rejects addresses with + character, matching SMTP RFC 5321 requirements."

This is the **external behavior promise**. It's what you'd write in release notes (briefly).

### `Acceptance:`
**How to verify**: What test should pass? What manual check confirms this works?

Examples:
- `test('auth/google.test.ts') covers sign-in flow, token refresh, and logout. Run: npm test -- --grep "google"`
- `npm run build && npm run performance-test; verify database query time <50ms (was 200ms). See benchmark/pool-comparison.txt.`
- `Integration test 'validates email rejects plus addressing' in 'email.test.ts' line 127 passes. Run: npm test -- email.test.ts`

Be specific. A reviewer or CI system should be able to run exactly what you describe.

### `Rejected:`
**Why this approach**: What other ways could this have been solved? Why did you choose this one?

Examples:
- "Rejected using Passport.js (would add 50KB to bundle); rejected custom OAuth (would need to maintain security patches ourselves). This approach uses Firebase Auth (15KB, security maintained by Google)."
- "Rejected Redis connection pooling (adds infrastructure dependency); rejected simple queue (no backpressure); chose native pg module with built-in pooling (zero dependencies, proven stable)."
- "Rejected strict regex for email validation (RFC 5322 is 9KB, too complex for this use case); rejected allowing + character (breaks downstream systems). Chose RFC 5321 subset (simpler, safer)."

This prevents the next engineer from re-proposing the same alternative.

### `Non-scope:`
**What's NOT in this commit**: What could have been done but wasn't? What does this NOT fix?

Examples:
- "Not adding OAuth for Microsoft/GitHub (can be next sprint after Google proves stable in production)."
- "Not migrating existing connections to use the pool (would require full schema migration; new code uses pool, legacy code gradually migrates)."
- "Not optimizing for offline email validation (requires larger regex library; this is cloud-only for now)."

This documents *deliberate scope boundaries* and prevents misalignment later.

### `Co-Authored-By:`
**Agent attribution**: Which AI agent or person created this commit?

Examples:
```
Co-Authored-By: Engineer Agent <noreply@anthropic.com>
Co-Authored-By: Claude Haiku 4.5 <noreply@anthropic.com>
```

Required for boilerplate commits. Optional but encouraged for project work.

---

## Why This Format?

**Traditional commit messages** (`feat: add X`) describe *what* changed. They're useful for release notes. But they don't explain why this approach was chosen, blocking the next engineer from understanding trade-offs.

**BDR commits** document the decision and reasoning alongside the code. This reduces:
- **Bikeshedding**: The rejected alternatives section stops others from re-proposing the same idea
- **Context loss**: Six months later, a new engineer understands why this path was taken
- **Scope creep**: Non-scope section makes it clear what wasn't attempted
- **Integration errors**: Acceptance criteria link to specific tests, making the success condition unambiguous

**Falsifiability**: Every field is checkable:
- **Contract** is true or false (user can/cannot do X)
- **Acceptance** passes or fails (test runs, result is yes/no)
- **Rejected** is accurate or inaccurate (these alternatives were considered or weren't)
- **Non-scope** is honest or dishonest (this was deliberately left out or was missed)

This makes commits **auditable** — a security or compliance review can verify each one against its promise.

---

## Example Full Commit

```
feat(auth): add OAuth 2.0 Google login

Contract: Users can authenticate with a Google account instead of email+password only.

Acceptance: Run `npm test -- --grep "google"` — 8 tests pass covering sign-in flow, token refresh, logout, and error handling. Manually: Visit /login, click "Sign in with Google", complete Google consent, confirm session created in database.

Rejected: Passport.js (oversized for single provider, 50KB), custom OAuth implementation (maintenance burden for security patches), Auth0 (adds external dependency and cost). Chose Firebase Auth because: works offline-first, maintained by Google, <15KB, zero additional dependencies.

Non-scope: OAuth for Microsoft or GitHub (can be TASK-043). Single sign-on federation (requires directory service). Automatic account linking if user has existing email account (manual migration for now).

Implementation notes:
- Stores Google ID + email in users.google_id, users.email
- Refresh tokens rotated every 7 days (Firebase default)
- Logout clears local session + revokes refresh token
- Error messages are generic (no info leakage if account doesn't exist)

Co-Authored-By: Engineer Agent <noreply@anthropic.com>
```

---

## Checklist for Engineer

Before committing:
- [ ] **Contract is testable** — can user/QA verify this works without code review?
- [ ] **Acceptance is runnable** — someone can execute exactly what you wrote
- [ ] **Rejected alternatives are real** — you actually considered them (don't fabricate)
- [ ] **Non-scope is honest** — these are deliberate boundaries, not overlooked work
- [ ] **Co-Authored-By is included** (required in Attacca projects)

If you can't fill in a section, it means you haven't finished thinking through the task. Stop, think, then write.

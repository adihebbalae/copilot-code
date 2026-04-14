---
name: security-audit
description: "On-demand security audit checklist based on OWASP Top 10. Use when: pre-push security review, auditing new features for vulnerabilities, checking authentication/authorization flows, reviewing API security, validating input sanitization."
---

# Security Audit Skill

## When to Use
- Before any git push (mandatory)
- After implementing authentication or authorization features
- When adding new API endpoints
- When handling user input or file uploads
- When adding new dependencies
- When the Manager flags a security review

## Audit Process

### Phase 1: Static Analysis

#### A1. Broken Access Control
- [ ] Every route/endpoint has explicit authorization checks
- [ ] Role-based access control is enforced server-side, not just UI
- [ ] Direct object references are validated (user A cannot access user B's data)
- [ ] API endpoints return 403/404 for unauthorized access

#### A2. Cryptographic Failures
- [ ] No secrets, API keys, or passwords in source code
- [ ] No secrets in `.env` files committed to git
- [ ] Passwords hashed with bcrypt/argon2 (not MD5/SHA1)
- [ ] Sensitive data encrypted at rest and in transit

#### A3. Injection
- [ ] SQL queries use parameterized statements (no string concatenation)
- [ ] HTML output is escaped (no raw user content in DOM)
- [ ] Command-line arguments are sanitized
- [ ] File paths are validated (no path traversal)

#### A4. Insecure Design
- [ ] Rate limiting on login, signup, password reset, API endpoints
- [ ] Input validation on both client and server
- [ ] File upload: type checking, size limits
- [ ] No debug endpoints or verbose error messages in production

#### A5. Security Misconfiguration
- [ ] CORS configured restrictively (not `*`)
- [ ] Security headers present (CSP, HSTS, X-Frame-Options, etc.)
- [ ] Stack traces not exposed to users

#### A6. Vulnerable Components
- [ ] `npm audit` / `pip audit` shows no critical vulnerabilities
- [ ] No deprecated or unmaintained dependencies

#### A7. Authentication Failures
- [ ] Session tokens are random, long, and httpOnly
- [ ] JWT tokens have expiration and are validated server-side
- [ ] Logout invalidates the session server-side
- [ ] Password reset tokens are single-use and time-limited

#### A8. Data Integrity Failures
- [ ] CSRF protection on state-changing operations
- [ ] Deserialization of untrusted data is avoided

#### A9. Logging & Monitoring
- [ ] Authentication events are logged
- [ ] Sensitive data NOT in logs (passwords, tokens, PII)

#### A10. SSRF
- [ ] User-supplied URLs are validated against allowlist
- [ ] Internal network addresses are blocked in URL inputs

### Phase 2: Dynamic Checks
- [ ] Run dependency audit tool
- [ ] Check for exposed environment variables in build output
- [ ] Verify HTTPS enforcement
- [ ] Test error pages don't leak information

### Report Template
```markdown
# Security Audit Report
**Date**: [Date]
**Scope**: [What was audited]

## Verdict: PASS / FAIL / CONDITIONAL PASS

## Critical (Block Push)
| # | Category | Location | Finding | Impact |
|---|----------|----------|---------|--------|

## High (Fix Before Next Push)
| # | Category | Location | Finding | Impact |
|---|----------|----------|---------|--------|

## Passed Checks
- [x] [List all checks that passed]
```

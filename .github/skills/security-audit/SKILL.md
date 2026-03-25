---
name: security-audit
description: "On-demand security audit checklist based on OWASP Top 10. Use when: pre-push security review, auditing new features for vulnerabilities, checking authentication/authorization flows, reviewing API security, validating input sanitization, dependency vulnerability scanning."
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
Review the code without running it.

#### A1. Broken Access Control
- [ ] Every route/endpoint has explicit authorization checks
- [ ] Role-based access control is enforced server-side, not just UI
- [ ] Direct object references are validated (can user A access user B's data?)
- [ ] API endpoints return 403/404 for unauthorized access (not 200 with empty data)
- [ ] Admin functions are not accessible through parameter manipulation

#### A2. Cryptographic Failures
- [ ] No secrets, API keys, or passwords in source code
- [ ] No secrets in `.env` files committed to git
- [ ] Passwords hashed with bcrypt/argon2 (not MD5/SHA1)
- [ ] Sensitive data encrypted at rest and in transit
- [ ] No custom cryptography implementations

#### A3. Injection
- [ ] SQL queries use parameterized statements (no string concatenation)
- [ ] NoSQL queries are parameterized
- [ ] HTML output is escaped (no raw user content in DOM)
- [ ] Command-line arguments are sanitized (no shell injection)
- [ ] File paths are validated (no path traversal)
- [ ] GraphQL has depth/complexity limits

#### A4. Insecure Design
- [ ] Rate limiting on login, signup, password reset, API endpoints
- [ ] Input validation on both client and server
- [ ] File upload: type checking, size limits, virus scanning
- [ ] No debug endpoints or verbose error messages in production
- [ ] Principle of least privilege applied throughout

#### A5. Security Misconfiguration
- [ ] CORS configured restrictively (not `*`)
- [ ] Security headers present (CSP, HSTS, X-Frame-Options, etc.)
- [ ] Default credentials changed
- [ ] Directory listing disabled
- [ ] Stack traces not exposed to users
- [ ] Unnecessary features/services disabled

#### A6. Vulnerable Components
- [ ] `npm audit` / `pip audit` / equivalent shows no critical vulnerabilities
- [ ] No deprecated or unmaintained dependencies
- [ ] Dependencies pinned to specific versions
- [ ] No known CVEs in dependency tree

#### A7. Authentication Failures
- [ ] Strong password requirements enforced
- [ ] Account lockout after N failed attempts
- [ ] Session tokens are random, long, and httpOnly
- [ ] JWT tokens have expiration and are validated server-side
- [ ] Logout invalidates the session server-side
- [ ] Password reset tokens are single-use and time-limited

#### A8. Data Integrity Failures
- [ ] CSRF protection on state-changing operations
- [ ] API requests authenticated with tokens (not cookies alone)
- [ ] Software updates verified with signatures
- [ ] Deserialization of untrusted data is avoided

#### A9. Logging & Monitoring
- [ ] Authentication events are logged (login, failed login, logout)
- [ ] Authorization failures are logged
- [ ] Sensitive data is NOT in logs (passwords, tokens, PII)
- [ ] Logs are tamper-resistant
- [ ] Alerting exists for suspicious patterns

#### A10. SSRF
- [ ] User-supplied URLs are validated against allowlist
- [ ] Internal network addresses are blocked in URL inputs
- [ ] Redirects don't follow to internal services

### Phase 2: Dynamic Checks (if applicable)
- [ ] Run dependency audit tool
- [ ] Check for exposed environment variables in build output
- [ ] Verify HTTPS enforcement
- [ ] Test error pages don't leak information

### Report Template
```markdown
# Security Audit Report
**Date**: [Date]
**Scope**: [What was audited]
**Auditor**: Security Agent

## Verdict: PASS / FAIL / CONDITIONAL PASS

## Critical (Block Push)
| # | Category | Location | Finding | Impact |
|---|----------|----------|---------|--------|
| 1 | A3-Injection | file:line | [finding] | [impact] |

## High (Fix Before Next Push)
| # | Category | Location | Finding | Impact |
|---|----------|----------|---------|--------|

## Medium (Fix This Sprint)
| # | Category | Location | Finding | Impact |
|---|----------|----------|---------|--------|

## Low (Track & Fix)
| # | Category | Location | Finding | Impact |
|---|----------|----------|---------|--------|

## Passed Checks
- [x] [List all checks that passed]

## Recommendations
- [Any architectural security suggestions]
```

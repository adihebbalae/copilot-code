---
name: security-audit
description: On-demand security audit checklist based on OWASP Top 10. Use when running pre-push security reviews, auditing new features for vulnerabilities, checking authentication or authorization flows, reviewing API security, validating input sanitization, or scanning dependency vulnerabilities.
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
- [ ] Role-based access control is enforced server-side, not just in the UI
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
- [ ] `npm audit` / `pip-audit` / equivalent shows no critical vulnerabilities
- [ ] No deprecated or unmaintained dependencies (check last commit date)
- [ ] All packages sourced from official registries
- [ ] No typosquatted package names

#### A7. Authentication Failures
- [ ] Session tokens are sufficiently random (≥128 bits)
- [ ] Sessions invalidated on logout
- [ ] Account lockout after failed login attempts
- [ ] Password reset tokens expire (≤15 minutes)
- [ ] JWT signatures verified, not just decoded

#### A8. Data Integrity Failures
- [ ] CSRF protection on state-changing requests
- [ ] Serialized data is validated before use
- [ ] File uploads are scanned/sandboxed before processing
- [ ] CI/CD pipelines are secured against malicious code injection

#### A9. Logging Failures
- [ ] Auth events (login, logout, failed attempts) are logged
- [ ] No PII or credentials in log output
- [ ] Logs are tamper-resistant and retained appropriately
- [ ] Anomaly detection or alerting exists for suspicious patterns

#### A10. SSRF
- [ ] User-supplied URLs are not fetched server-side without allowlisting
- [ ] Cloud metadata endpoints are blocked (169.254.169.254)
- [ ] Internal network ranges are blocked from user-initiated requests

### Phase 2: Dependency Audit

```bash
# Node.js
npm audit --audit-level=high

# Python
pip-audit --desc

# Go
go list -json -m all | nancy sleuth
```

For each NEW dependency added, verify:
- Published more than 30 days ago
- Active maintenance (commits in last 6 months)
- No obvious typosquatting (compare against known-good package name)

### Phase 3: Secrets Scan

```bash
# Check for committed secrets
git log --all --full-diff -p | grep -E "(password|secret|api_key|token|private_key)" -i | head -50

# Or use truffleHog / gitleaks if available
trufflehog git file://. --only-verified
```

## Report Format

```markdown
## Security Audit Report

### Severity Summary
| Severity | Count |
|----------|-------|
| CRITICAL | X |
| HIGH     | X |
| MEDIUM   | X |
| LOW      | X |

### Findings

#### [SEVERITY] Title
**File**: path/to/file:line
**Description**: What the vulnerability is
**Attack Vector**: How an attacker exploits this
**Evidence**: `code snippet`
**Recommendation**: What needs to change

### Verdict
PASS ✅ / FAIL ❌
```

## Severity Definitions
- **CRITICAL**: Exploitable remotely, leads to RCE, data breach, or auth bypass → block push
- **HIGH**: Significant risk, likely exploitable → block push
- **MEDIUM**: Requires specific conditions, moderate impact → document + remediation plan
- **LOW**: Defense-in-depth concern → document for future sprint

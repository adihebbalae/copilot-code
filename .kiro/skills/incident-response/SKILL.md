---
name: incident-response
description: Production incident response runbooks. Use when responding to production incidents, critical failures, or emergency deployments. Contains runbooks for common incident types and decision frameworks for triage. For SEV 1 emergencies, also activate the medic agent persona.
---

# Incident Response Skill

## Incident Classification

| Severity | Impact | Response Time | Who | Escalation |
|----------|--------|---------------|-----|------------|
| **SEV 1 (Critical)** | Service fully down, data loss risk, security breach | < 15 min | Medic persona | Immediate |
| **SEV 2 (High)** | Degraded service, non-critical feature broken | < 2 hours | Engineer | If not fixed in 4h |
| **SEV 3 (Medium)** | Minor bug, workaround exists | < 1 day | Engineer | If user-facing |
| **SEV 4 (Low)** | Cosmetic, no user impact | Next sprint | Engineer | None |

**Medic is for SEV 1 only.** SEV 2-4 go to Engineer.

---

## Runbook Index

1. App Won't Start / Crashes on Boot
2. 500 Errors on Critical Flow
3. Database Connection Failure
4. Build or Deploy Pipeline Failure
5. Test Suite Completely Broken
6. Third-Party API Dependency Failure
7. Memory Leak / Resource Exhaustion
8. Security Breach (Urgent)

---

### Runbook 1: App Won't Start / Crashes on Boot

**Common causes**: Missing env var, bad config, dependency version conflict, port already in use, failed DB migration

**Diagnosis**:
1. Read startup logs (first 50 lines)
2. Check for missing env vars in error message
3. `git log --since="6 hours ago"` — what changed?
4. Check for recent dependency updates

**Fix strategies**:
| Cause | Fix |
|-------|-----|
| Missing env var | Add to deployment config, redeploy |
| Bad config | Revert config file, validate manually |
| Dependency conflict | Pin to last-known-good version, rebuild |
| Port conflict | Change port or kill conflicting process |
| Migration failed | Rollback migration, fix, re-run |

**Fast rollback**: If last deploy caused it → `git revert HEAD` → deploy.

---

### Runbook 2: 500 Errors on Critical Flow

**Common causes**: Null pointer, DB query failure, external API timeout, unhandled exception in new code

**Diagnosis**:
1. Find the stack trace in logs
2. Identify the exact line throwing the error
3. Trace backwards: What data was passed in?
4. Check recent commits touching that file

**Fix strategies**:
| Cause | Fix |
|-------|-----|
| Null pointer | Add null check: `if (!obj) return fallback` |
| DB schema mismatch | Fix query or add migration |
| API timeout | Add timeout + fallback, or cache |
| Unhandled exception | Wrap in try-catch, log, return 503 |

**Workaround**: If fix is complex → comment out the broken feature, return cached/default data, fix properly later.

---

### Runbook 3: Database Connection Failure

**Common causes**: DB server down, wrong connection string, connection pool exhausted, firewall rule changed, SSL cert expired

**Diagnosis**:
1. Try connecting manually: `psql -h <host> -U <user> -d <db>` or equivalent
2. Check connection string in env vars
3. Check DB server status (cloud dashboard, `systemctl status postgresql`)
4. Check connection pool settings

**Fix strategies**:
| Cause | Fix |
|-------|-----|
| DB server down | Restart server, check why it crashed |
| Wrong connection string | Fix env var, redeploy |
| Pool exhausted | Increase pool size, find connection leak |
| Firewall | Update security group rules |
| Cert expired | Renew cert, update config |

**Emergency workaround**: If DB is down and can't be fixed quickly → serve static HTML with "under maintenance" message.

---

### Runbook 4: Build or Deploy Pipeline Failure

**Common causes**: Failing test in CI, missing build dependency, env var not set in CI, out-of-disk space, registry/artifact service down

**Diagnosis**:
1. Read the failed CI step output (don't skim — read it fully)
2. Identify the exact failing command
3. Try to reproduce the failure locally
4. Check if any external services the build depends on are down

**Fix strategies**:
| Cause | Fix |
|-------|-----|
| Failing test | Fix the test or revert the commit that broke it |
| Missing dependency | Add to package file, commit |
| Missing CI env var | Add secret to CI environment settings |
| Disk space | Clean up artifacts, prune Docker images |
| Registry down | Wait or switch to a mirror |

---

### Runbook 5: Test Suite Completely Broken

**Common causes**: Config change broke test setup, shared test fixture corrupted, wrong environment, missing test database

**Diagnosis**:
1. Run a single test in isolation: `npx jest path/to/test.test.ts`
2. If single test fails: the test itself is broken
3. If single test passes but suite fails: setup/teardown issue

**Fix strategies**:
- Restore `jest.config.js` / `vitest.config.ts` to last known good
- Check test database connection and migrations
- Check test setup files (`setupTests.ts`, `conftest.py`)
- Look for `beforeAll`/`afterAll` that mutate shared state

---

### Runbook 6: Third-Party API Dependency Failure

**Common causes**: API rate limits hit, API key expired, upstream service outage, breaking API change

**Diagnosis**:
1. Check the upstream service status page
2. Test the API key manually: `curl -H "Authorization: Bearer $TOKEN" https://api.example.com/health`
3. Check if rate limits appear in response headers

**Fix strategies**:
| Cause | Fix |
|-------|-----|
| Rate limit | Implement backoff, cache responses, reduce call frequency |
| Expired key | Rotate API key in env vars |
| Service outage | Return cached data or graceful degradation |
| Breaking change | Pin to API version, update integration |

---

### Runbook 7: Memory Leak / Resource Exhaustion

**Symptoms**: OOM kills, process slowing down over time, disk filling up

**Diagnosis**:
1. `ps aux --sort=-%mem | head -20` — what's using memory?
2. Check for event listeners not being removed
3. Check for caches with no eviction policy
4. Check for log files or temp files accumulating

**Fix strategies**:
- Add `WeakRef` or `WeakMap` for cached object references
- Add eviction policies to in-memory caches
- Add `removeEventListener` / cleanup in component unmount
- Add log rotation configuration

---

### Runbook 8: Security Breach (Urgent)

**Symptoms**: Unauthorized access detected, credentials leaked, unusual traffic patterns

**Immediate steps (do this before anything else)**:
1. **Rotate all exposed credentials** — API keys, tokens, DB passwords, OAuth secrets
2. **Revoke active sessions** if auth system supports it
3. **Enable read-only mode** or take the service offline if data exfiltration is active
4. **Preserve logs** — do not restart or redeploy until logs are captured
5. Invoke the `security-audit` skill for post-incident analysis

**After stabilization**:
- Document what was accessed and when
- Identify the attack vector
- Patch the vulnerability
- Notify affected users if required by law/policy

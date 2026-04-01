# Incident Response Skill

> Load this skill when responding to production incidents, critical failures, or emergency deployments. Contains runbooks for common incident types and decision frameworks for triage.

## Incident Classification

Use this framework to classify severity and choose response strategy.

| Severity | Impact | Response Time | Who | Escalation |
|----------|--------|---------------|-----|------------|
| **SEV 1 (Critical)** | Service fully down, data loss risk, security breach | < 15 min | Medic (Opus) | Immediate |
| **SEV 2 (High)** | Degraded service, non-critical feature broken | < 2 hours | Engineer (Sonnet) | If not fixed in 4h |
| **SEV 3 (Medium)** | Minor bug, workaround exists | < 1 day | Engineer (Sonnet) | If user-facing |
| **SEV 4 (Low)** | Cosmetic, no user impact | Next sprint | Engineer (Sonnet) | None |

**Medic is for SEV 1 only.** SEV 2-4 go to Engineer.

---

## Runbook Index

Select the appropriate runbook based on incident type:

1. **App Won't Start / Crashes on Boot**
2. **500 Errors on Critical Flow**
3. **Database Connection Failure**
4. **Build or Deploy Pipeline Failure**
5. **Test Suite Completely Broken**
6. **Third-Party API Dependency Failure**
7. **Memory Leak / Resource Exhaustion**
8. **Security Breach (Urgent)**

---

### Runbook 1: App Won't Start / Crashes on Boot

**Symptoms**: Process exits immediately, logs show crash, health check fails.

**Common causes**:
- Missing environment variable
- Bad config file
- Dependency version conflict
- Port already in use
- Database migration failed

**Diagnosis steps**:
1. Read startup logs (first 50 lines)
2. Check for missing env vars in error message
3. `git log --since="6 hours ago"` — what changed?
4. Check for recent dependency updates in `package.json`/`requirements.txt`

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

**Symptoms**: Specific endpoint returns 500, stack trace in logs, users blocked.

**Common causes**:
- Null pointer / undefined reference
- Database query failure (wrong schema, missing column)
- External API timeout
- Unhandled exception in new code

**Diagnosis steps**:
1. Find the stack trace in logs (search for most recent 500)
2. Identify the exact line throwing the error
3. Trace backwards: What data was passed in? What was expected?
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

**Symptoms**: "Cannot connect to database", "Connection refused", all DB queries fail.

**Common causes**:
- DB server down
- Connection string wrong (host, port, password)
- Connection pool exhausted
- Firewall rule changed
- SSL/TLS cert expired

**Diagnosis steps**:
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

**Symptoms**: CI fails, Docker build fails, deployment rejected.

**Common causes**:
- Test failures
- Linting errors
- Docker layer cache invalidated (slow but not broken)
- Deployment script bug
- Cloud provider outage

**Diagnosis steps**:
1. Read CI logs (last 50 lines usually show root cause)
2. Check if tests fail locally: `npm test` or equivalent
3. Check if build works locally: `docker build .`
4. Check cloud provider status page

**Fix strategies**:
| Cause | Fix |
|-------|-----|
| Test failures | Fix tests or fix code, re-run |
| Lint errors | Run `npm run lint --fix`, commit |
| Docker build fail | Check for missing dependencies in Dockerfile |
| Deployment script | Fix script, test locally first |
| Cloud outage | Wait or switch region |

**Fast path**: If tests are broken but code is fine → temporarily skip tests in CI (add flag), deploy, fix tests after.

---

### Runbook 5: Test Suite Completely Broken

**Symptoms**: All tests fail, or test runner won't start.

**Common causes**:
- Test framework version conflict
- Test database not seeded
- Environment variable missing in test env
- Test setup script broken

**Diagnosis steps**:
1. Run tests locally: `npm test` — do they pass locally?
2. Check test framework version in `package.json`
3. Check test setup file (usually `jest.setup.js`, `conftest.py`, etc.)

**Fix strategies**:
| Cause | Fix |
|-------|-----|
| Version conflict | Pin test framework to last-good version |
| DB not seeded | Fix seed script, re-run |
| Missing env var | Add to test config |
| Setup broken | Revert setup file, check logs |

**Emergency**: If tests are blocking deployment but code is verified manually → skip tests, deploy, fix tests as hotfix PR.

---

### Runbook 6: Third-Party API Dependency Failure

**Symptoms**: External API returns errors, timeouts, or is down.

**Common causes**:
- API provider outage
- Rate limit exceeded
- API key expired
- Breaking change in API

**Diagnosis steps**:
1. Check API provider status page
2. Test API manually: `curl https://api.example.com/health`
3. Check rate limit headers in logs
4. Check for API version deprecation notices

**Fix strategies**:
| Cause | Fix |
|-------|-----|
| API down | Deploy fallback (cached data, degraded mode) |
| Rate limited | Add backoff, increase limit with provider |
| Key expired | Rotate key, deploy new one |
| Breaking change | Update integration code, test thoroughly |

**Workaround**: Return cached data or disable feature temporarily → fix properly later.

---

### Runbook 7: Memory Leak / Resource Exhaustion

**Symptoms**: App slows down over time, eventually crashes. Restart temporarily fixes it.

**Common causes**:
- Event listeners not cleaned up
- Large objects held in memory indefinitely
- Database connection leak
- Logging too verbose (disk full)

**Diagnosis steps**:
1. Check memory usage trends in monitoring
2. Check for connection pool leaks
3. Profile with heap snapshot (if time permits)

**Fix strategies**:
| Cause | Fix |
|-------|-----|
| Event leak | Remove listeners in cleanup: `removeEventListener` |
| Object retention | Clear cache periodically, use WeakMap |
| Connection leak | Always close connections in `finally` block |
| Disk full | Rotate logs, delete old ones |

**Emergency**: Restart the service to buy time → profile and fix properly as follow-up.

---

### Runbook 8: Security Breach (Urgent)

**Symptoms**: Unauthorized access detected, data exfiltration, malicious activity in logs.

**Common causes**:
- Leaked credentials
- SQL injection exploit
- XSS exploit
- Compromised dependency

**Immediate steps**:
1. **Rotate all secrets immediately** (API keys, DB passwords, tokens)
2. **Block suspicious IPs** in firewall
3. **Take affected service offline** if data is at risk
4. **Notify stakeholders** (security team, legal, users if needed)

**DO NOT attempt to patch and deploy yourself.** Escalate to Security agent immediately.

**Medic's role**: Only execute the immediate containment (rotate secrets, block IPs). Security agent handles investigation and long-term fix.

---

## Decision Framework: Rollback vs Patch Forward

Use this decision tree when an incident is caused by a recent deploy:

```
Did the last deploy cause this incident?
├─ YES
│  └─ Will rolling back lose data or break migrations?
│     ├─ NO → ROLLBACK (safest, fastest)
│     └─ YES → PATCH FORWARD (rollback too risky)
└─ NO (older bug, environment change, dependency issue)
   └─ PATCH FORWARD (rollback won't help)
```

**When to rollback**:
- Last deploy was < 2 hours ago
- No database migrations were run
- No user data was created that depends on new schema
- Rollback is a single git revert

**When to patch forward**:
- Migrations already ran (rolling back breaks schema)
- Users created data using new features
- External systems were updated (can't un-notify a webhook)
- Root cause is environmental (not code)

---

## Monitoring Integration

If the project has monitoring MCPs configured (Sentry, Datadog, New Relic), use them:

1. **Error rate spike detection**:
   ```bash
   # Check if error rate > 5% in last 10 minutes
   ```

2. **Recent errors**:
   ```bash
   # Fetch last 50 errors from Sentry
   # Group by error message to find pattern
   ```

3. **Performance metrics**:
   ```bash
   # Check response time p99
   # Check memory/CPU usage trends
   ```

If no monitoring MCP → ask user to paste recent logs/errors.

---

## Incident Log Template

Every incident MUST generate a log file at `.agents/incidents/<timestamp>-<slug>.md`:

```markdown
# Incident: <title>
**Date**: <YYYY-MM-DD HH:MM UTC> | **Severity**: SEV 1 | **Resolved by**: @medic

## Timeline
- **HH:MM**: Incident started (user reported / monitoring alert)
- **HH:MM**: Medic engaged
- **HH:MM**: Root cause identified
- **HH:MM**: Fix deployed
- **HH:MM**: Service restored
- **Total downtime**: <X minutes>

## Symptoms
<What users saw / what broke>

## Root Cause
<Why it broke — be specific>

## Fix Deployed
**Commit**: <hash>
**Changed files**: <list>
**Strategy**: Rollback / Patch / Workaround / Config

<What changed and why it's safe>

## Temporary Workarounds
<If the fix was a workaround, list it here>

## Follow-Up Actions
- [ ] Security audit of the fix (assign to @security if auth/input/data touched)
- [ ] Add regression test to catch this in future
- [ ] Replace workaround with proper fix (if applicable)
- [ ] Update runbook if this was a new incident type

## Blast Radius
- Users affected: <count or %>
- Data at risk: Yes / No
- External systems impacted: <list or None>

## Prevention
<What would have caught this before production?>
```

---

## Non-Negotiable Rules

1. **Never skip the incident log** — future incidents depend on learning from past ones
2. **Never deploy without testing** — even in emergency, run smoke tests
3. **Never touch production data without confirmation** — dropping tables, deleting records, etc.
4. **Always explain your fix** — if you can't articulate why it's safe, it's not safe
5. **Escalate security breaches immediately** — don't try to patch them yourself

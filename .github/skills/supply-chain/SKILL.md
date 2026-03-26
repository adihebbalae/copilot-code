---
name: supply-chain
description: "4-gate supply chain security defense for any project with dependencies. Prevents malicious packages, typosquatting, and abandoned maintainer attacks before they reach production. Covers: package approval gates, 30-day age policy, typosquatting detection, SBOM generation, and lock file integrity. Can be used standalone — no other boilerplate required."
---

# Supply Chain Security Skill

A defense-in-depth framework to prevent malicious packages, typosquatting, and abandoned maintainer attacks. Works with any Node.js, Python, Go, or Ruby project. No CI/CD required — gates are enforced in the agent workflow.

---

## The 4-Gate Model

A malicious or vulnerable package must bypass ALL 4 gates to reach production:

```
Gate 1 — Handoff Constraint
  Engineer cannot add packages not listed in the approved handoff.
  Stops: unauthorized installs, scope creep, accidental additions.

Gate 2 — Pre-Review (/review-dependencies)
  Manager vets every proposed package before sending to Engineer.
  Stops: typosquats, abandoned packages, known CVEs, too-new packages.

Gate 3 — Quality Gate Audit
  Dependency audit runs as part of pre-push gate.
  Stops: transitive vulnerabilities, packages introduced post-approval.

Gate 4 — Security Agent Review
  Full SBOM + maintainer history + lock file integrity.
  Stops: subtle supply chain compromises missed by automated tools.
```

---

## Gate 1: Handoff Constraint

Add this rule to your Engineer's instructions (`.github/agents/engineer.agent.md` or equivalent):

```markdown
### Dependency Constraint (Supply Chain Gate 1)
YOU CANNOT ADD, UPDATE, OR REMOVE PACKAGES WITHOUT EXPLICIT APPROVAL IN THE HANDOFF.

If you identify a missing dependency:
1. Stop implementation
2. Document the needed package with: name, exact version (no ^ or ~), WHY needed, alternatives considered
3. Flag as a blocker in state.json
4. Wait for Manager to run /review-dependencies and update the handoff

Exception: Security patches (X.Y.Z → X.Y.Z+1) can be applied autonomously
IF zero breaking changes AND all tests pass.
```

---

## Gate 2: Pre-Review Checklist

Run this before adding ANY package to a handoff. Work through each check in order.

### 2A: Registry Verification

Confirm the package exists on the official registry under the correct name:

```bash
# Node.js
npm view [package-name] versions --json | tail -5

# Python
pip index versions [package-name]

# Go
go list -m [module-path]@latest

# Ruby
gem list -r [gem-name]
```

**Red flags:**
- Package doesn't exist on registry → abort
- Package name has extra characters vs the commonly-known name (`Requests` vs `requests`)
- Published less than 30 days ago (see 2B)

### 2B: Package Age (30-Day Rule)

**REJECT any package published less than 30 days ago** unless it is a Z-version security patch.

Why: Supply chain attacks often exploit the window between package publication and when security scanners catch the malicious version. 30 days gives the community time to find and flag issues.

```bash
# Node.js — check published date
npm view [package-name] time.created

# Python — check first release date
pip index versions [package-name] 2>/dev/null | head -5
# Then check: https://pypi.org/pypi/[package-name]/json (created field)

# Go — check first commit date via go list
go list -m -json [module]@latest | grep -i time
```

**Exception**: Security patches (X.Y.Z → X.Y.Z+1) may be approved immediately IF:
- The previous version has a confirmed CVE
- The patch version fixes only the vulnerability
- All existing tests pass after upgrade

### 2C: Typosquatting Check

Compare the proposed package name against known legitimate packages:

```bash
# Manual check: does the name closely resemble a well-known package?
# Common typosquatting patterns:
#   lodash → 1odash (one instead of letter L)
#   express → expres, expresss
#   react → raect, reeact
#   requests → reqeusts, request (no s)
#   numpy → nuumpy, numpyy

# Automated (Node.js)
npx package-name-check [package-name]

# Automated (Python)
pip-audit --package [package-name] --require-hashes
```

**Verify by cross-referencing:**
1. GitHub stars / open issues (legitimate packages have activity)
2. npm/PyPI weekly download count (established packages have millions)
3. Package author: is the maintainer verified / known?

### 2D: Maintainer Trust

```bash
# Node.js — check maintainers
npm view [package-name] maintainers

# Python — check author
pip show [package-name]

# Check maintainer's GitHub profile
# Red flags: account created recently, no other projects, no followers
```

**Ask:**
- Is the maintainer account active?
- Have there been recent ownership transfers? (high risk — new owner may be malicious)
- Does the repo have recent commits that match the published version?

### 2E: Known CVE Pre-Check

```bash
# Node.js
npm audit --package-lock-only

# Python
pip-audit -r requirements.txt

# Go  
govulncheck ./...

# Ruby
bundle audit check --update
```

If any HIGH or CRITICAL CVE is found for the proposed package: **REJECT**.

### 2F: Alternative Assessment

Before approving, consider:
- Is there a well-maintained alternative with more trust signals?
- Can this functionality be implemented without a dependency (< 50 LOC)?
- Is this a transitive dependency of another approved package (no need to add again)?

### Gate 2 Verdict

```
## Dependency Review: [package-name]@[version]

Registry: ✅ / ❌ Found on official registry
Age: ✅ / ❌ [n] days old (threshold: 30)
Typosquatting: ✅ / ❌ No match to known packages
Maintainer: ✅ / ❌ Active, verified
CVE: ✅ / ❌ No HIGH/CRITICAL vulnerabilities
Alternatives: ✅ / ❌ No lower-risk alternative

VERDICT: APPROVE / WARN / REJECT
```

---

## Gate 3: Quality Gate Integration

Add this stage to your pre-push quality gate:

```markdown
### Stage 4B: Dependency Audit (Supply Chain)

Run dependency audit for direct AND transitive dependencies:

```bash
# Node.js
npm audit --audit-level=high

# Python
pip-audit

# Go
govulncheck ./...

# Ruby
bundle audit check --update
```

**Pass criteria:**
- Zero HIGH or CRITICAL vulnerabilities
- All packages ≥30 days old (spot-check 3 random deps)
- Lock file present and committed (package-lock.json / poetry.lock / go.sum / Gemfile.lock)
- No packages added since last Gate 2 approval
```

---

## Gate 4: Security Agent Review (SBOM + Lock Files)

### 4A: Check for Dependency Changes

```bash
git diff HEAD~1 --name-only | grep -E 'package.json|requirements|go.mod|Gemfile'
```

If any dependency file changed: **Gate 4 is MANDATORY before push.**

### 4B: Generate SBOM

```bash
# Using syft (recommended)
syft . -o spdx-json > sbom.json
# or: syft . -o cyclonedx-json > sbom.json

# Fallback: cdxgen
npx @cyclonedx/cdxgen -o sbom.json

# Node.js fallback
npm sbom --sbom-format spdx > sbom.spdx.json

# Python fallback
pip-audit --format=cyclonedx-json > sbom.json
```

Review the SBOM for:
- [ ] Unexpected packages not in the approved handoff
- [ ] Packages with known CVEs (check against `osv.dev`)
- [ ] Packages with suspicious origins (unusual registries, non-standard URLs)

### 4C: Lock File Integrity

```bash
# Node.js — verify lockfile is not tampered
npm ci --dry-run

# Python — verify hashes
pip install --require-hashes -r requirements.txt --dry-run

# Go — verify checksums
go mod verify

# Ruby
bundle install --frozen
```

**Lock file rules:**
- MUST be committed (never in `.gitignore`)
- MUST match the package manifest exactly
- Any discrepancy → FAIL review

### Gate 4 Output

```
## Security Review: Dependencies

SBOM Generated: ✅ sbom.json (n packages)
Lock File: ✅ Committed and verified
Unexpected Packages: ✅ None found
CVE Scan (SBOM): ✅ / ❌ No HIGH/CRITICAL
Private Registry Usage: ✅ / ❌ Official registries only

GATE 4: PASSED ✅ / FAILED ❌

Findings:
[list any issues]

Recommendation: SAFE TO PUSH / DO NOT PUSH
```

---

## Package Age Policy Reference

| Version bump type | Age requirement | Example |
|------------------|----------------|---------|
| Major (X.0.0) | ≥ 30 days | 1.0.0 → 2.0.0 |
| Minor (X.Y.0) | ≥ 30 days | 1.0.0 → 1.1.0 |
| Patch (X.Y.Z) | ≥ 30 days | 1.0.0 → 1.0.1 |
| Security patch (Z-only) | Immediate OK | 1.0.4 → 1.0.5 (fixes CVE) |

---

## Quick Reference

| Gate | When | Enforced By | Stops |
|------|------|-------------|-------|
| 1 — Handoff constraint | Before coding | Engineer agent | Unauthorized installs |
| 2 — Pre-review | Before handoff | Manager + `/review-dependencies` | Typosquats, bad actors, new packages |
| 3 — Quality audit | Pre-push | Quality gate skill | Transitive vulns, post-approval drift |
| 4 — Security review | Pre-push (deps changed) | Security agent | SBOM anomalies, lock file tampering |

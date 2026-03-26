---
description: "Pre-handoff dependency vetting prompt. Use BEFORE handing off a task that requires new packages. Manager calls this to audit proposed dependencies for supply chain risk before they reach Engineer."
agent: "manager"
---

You are running `/review-dependencies`. Your job is to vet proposed packages for supply chain risk **before** they go into a task handoff for the Engineer.

This is **Gate 1** of the defense-in-depth dependency security system. You catch typosquats, abandoned packages, and suspicious maintainers *before* the Engineer even touches them.

---

## Input: Proposed Dependencies

You're given a list of dependencies to add/update. Format:

```
Package: package-name
Version: 1.2.3 (exact version, not ^1.2.3)
Why: [brief description of why it's needed]
```

---

## Phase 1: Registry Verification

For each package:

### 1A: Check Official Registry
```bash
# Node.js
npm view package-name

# Python
pip show package-name

# Ruby
gem info package-name

# Go
go get -u package-name
```

Look for:
- [ ] Package exists in official registry
- [ ] Version exists (not pre-release or yanked)
- [ ] Published date is reasonable (not yesterday for "express" equivalent)
- [ ] Maintainer info is present

### 1B: Package Age Verification (30-Day Rule)
**REJECT any package version published < 30 days ago** (unless documented security patch). This allows time for:
- Known vulnerabilities to surface and be patched
- Typosquats to be detected and reported  
- Community testing to reveal issues

```bash
# Node.js
npm view package-name@version time
# Look for the version publish date. Calculate: today - publish_date >= 30 days

# Python
pip index versions package-name  # shows all versions + dates
# OR check PyPI directly: pypi.org/project/package-name

# Ruby
gem list -r package-name --all  # shows versions + dates
```

**Exception**: Security patches (X.Y.Z → X.Y.Z+1) with zero breaking changes may be used if:
- Original version is >30 days old
- Only Z version changed (patch version)
- Patch fixes a known CVE
- All tests pass with the new patch

**Red flags**:
- ❌ Published yesterday, version 1.0.0 of a new package
- ❌ 0.0.x experimental version needed in production
- ✅ lodash 4.17.22 published 3 years ago (established, proven)
- ✅ lodash 4.17.21 (security patch of 4.17.20 from 3 years ago)

### 1C: Typosquatting Detection
Compare the package name against popular packages in the same category. Look for:
- [ ] Similar but misspelled names (e.g., `expres`, `reactt`, `djnago`)
- [ ] Extra characters (e.g., `express2`, `react-new`)
- [ ] Common unicode tricks (Cyrillic lookalikes — usually not visible)
- [ ] Namespace confusion (e.g., `axios` vs `@axios/client`)

**Tool help:**
- npm: `npm search <package>` (see similar packages)
- pip: PyPI search + check GitHub link
- Ruby: RubyGems search + click maintainer profile

---

## Phase 2: Maintainer & Trust Verification

### 2A: Check Package Metadata
```bash
npm view package-name | grep -E "maintainers|time|dist:tarball"
```

For each maintainer/author:
- [ ] Has GitHub profile (click link, verify it's real)
- [ ] GitHub has commit history + multiple repositories (not brand new, not just this package)
- [ ] Package has recent commits (not abandoned)
- [ ] Check for unexpected maintainer changes (use `npm view <pkg> time` to see version history)

### 2B: Maintenance Status
- [ ] Recent releases (within last 3 months for active projects)
- [ ] Issue response time (check GitHub issues — are open issues getting responses?)
- [ ] Test coverage visible (README should mention tests)
- [ ] Dependencies of the package itself are up-to-date (run: `npm ls <package>` to see its tree)

**Red flags:**
- ❌ Package last updated 2+ years ago (unless it's stable/complete)
- ❌ 100+ open issues with no responses
- ❌ Maintainer account shows suspicious activity (sudden uploads after long dormancy)
- ❌ Package depends on deeply outdated dependencies

---

## Phase 3: Vulnerability & SBOM Pre-Check

### 3A: Known Vulnerabilities
```bash
# Node.js
npm view package-name | grep -A5 "vulnerabilities"
# OR use online tool
curl https://api.snyk.io/v1/npm/package-name

# Python
pip install safety && safety check --package package-name

# Ruby
bundle check  # (after adding to Gemfile temporarily)
```

### 3B: Transitive Dependencies
Check what this package itself depends on:
```bash
# Node.js
npm view package-name dependencies

# Python
pip show package-name | grep "Requires"

# Ruby
gem dependency package-name
```

Look for:
- [ ] No more than 3-5 transitive  deps (fewer is better)
- [ ] No known-vulnerable dependencies in its tree
- [ ] Versions pinned (not loose ranges like `>1.0.0`)

---

## Phase 4: Alternative Assessment

If the package seems questionable, research alternatives:

1. Is there a more popular/maintained alternative?
2. Could we solve this with existing dependencies?
3. Is this package actually necessary, or is it a "nice to have"?

Update the proposal:
```
Package: package-name
Version: 1.2.3
Why: [why it's needed]
Alternatives considered:
  - alt1: [why rejected]
  - alt2: [why rejected]
Recommendation: APPROVE / WARN / REJECT [reasoning]
```

---

## Phase 5: Risk Verdict

Make a call: **APPROVE / WARN / REJECT**

### APPROVE ✅
Clear to hand off to Engineer. Include in task handoff as approved dependency.

### WARN ⚠️
Package is acceptable but has risks. Document them:
```
Package: lodash
Version: 4.17.21
Risks:
  - Large package (1+ MB minified) — consider alternatives like es-toolkit
  - Maintenance is slow but stable
Mitigation:
  - Pinned version in package.json
  - Dependency audit runs on every push
  - Will be reviewed in quality-gate
Recommendation: APPROVE WITH MONITORING
```

Include the risk doc in the handoff so Engineer knows.

### REJECT ❌
Do NOT include in handoff. Explain to user:
```
Package: lodash
Version: 4.17.100 (hypothetical)
Reason: **Package age violation**
  - Published 5 days ago (< 30-day minimum)
  - Wait until [date] to use this version
  - OR use established version: lodash 4.17.21 (3+ years old, proven stable)

Alternative: Use [legitimate version] instead.
```

---

## Phase 6: Handoff Integration

Write approved dependencies to the task handoff in `.agents/handoff.md`:

```markdown
## Approved Dependencies

| Package | Version | Rationale | Risk Level |
|---------|---------|-----------|------------|
| lodash | 4.17.21 | Utility functions for array/object manipulation | Low |
| jest | 29.1.0 | Testing framework | Low |
| stripe | 12.3.0 | Payment processing — WARN: Large, popular, but review SBOM | Medium |

**Note**: All approved dependencies are pinned to exact versions. Engineer must not upgrade or add others without approval.
```

---

## Summary for User

Present findings:
```
## Dependency Review Complete

**Approved for handoff**: [list]
**Approved with warnings**: [list] — see risks above
**Rejected**: [list] — do not use

Next step: Engineer will implement with these dependencies locked. Quality gate + Security audit will verify before push.
```

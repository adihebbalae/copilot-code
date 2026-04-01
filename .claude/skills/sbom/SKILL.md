---
name: sbom
description: "Generate a real Software Bill of Materials (SBOM) using syft or cdxgen and pipe output to Security agent for review. The only agent framework with automated SBOM in its security gate — enterprise-grade supply chain visibility. Use when: before any production push, when dependency files change, on security request, or as part of quality-gate Stage 4B2."
---

# SBOM Generation Skill

Generates a real, machine-readable Software Bill of Materials (SBOM) capturing every direct and transitive dependency in the project. Feeds the output to the Security agent for review.

---

## When to Use
- Before every push that changes dependency files (`package.json`, `requirements.txt`, `go.mod`, etc.)
- On Security agent's explicit request  
- Monthly audit of long-lived production systems
- As part of quality-gate Stage 4B2 (dependency changes detected)

---

## Step 1: Detect Available SBOM Tool

Check which tool is installed, in order of preference:

```bash
# Check syft (recommended — broadest format support)
syft version 2>/dev/null && echo "syft available"

# Check cdxgen (good for monorepos)
npx @cyclonedx/cdxgen --version 2>/dev/null && echo "cdxgen available"

# Native package manager fallback (no extra install)
npm sbom --version 2>/dev/null && echo "npm-sbom available"
pip-audit --version 2>/dev/null && echo "pip-audit available"
```

Use the first available tool. If none: fall back to Step 1B.

### Step 1B: Install syft (if nothing available)

```bash
# Mac / Linux
curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin

# Windows (PowerShell)
winget install anchore.syft

# Verify
syft version
```

---

## Step 2: Generate the SBOM

Run the appropriate command based on detected tool:

### Option A: syft (preferred)

```bash
# CycloneDX format (best for tooling compatibility)
syft . -o cyclonedx-json=sbom.cyclonedx.json

# SPDX format (required for some enterprise compliance)
syft . -o spdx-json=sbom.spdx.json

# Both (if storage allows)
syft . -o cyclonedx-json=sbom.cyclonedx.json -o spdx-json=sbom.spdx.json
```

### Option B: cdxgen (monorepos / polyglot)

```bash
npx @cyclonedx/cdxgen -o sbom.cyclonedx.json -t [detected-lang]
# -t options: nodejs, python, go, ruby, java, swift, rust, dotnet
```

### Option C: Native package manager fallback

```bash
# Node.js (npm 10+)
npm sbom --sbom-format cyclonedx --sbom-type library > sbom.cyclonedx.json

# Python
pip-audit --format=cyclonedx-json -o sbom.cyclonedx.json

# Go
go list -m -json all > sbom-go-modules.json  # Not full SBOM but lists all modules

# Ruby
bundler-audit check --format json > sbom-audit.json
```

---

## Step 3: Parse and Summarize

After generation, parse the SBOM to extract a summary for the Security agent:

```bash
# Node.js: count packages and list all components
cat sbom.cyclonedx.json | python3 -c "
import json,sys
sbom = json.load(sys.stdin)
comps = sbom.get('components', [])
print(f'Total packages: {len(comps)}')
for c in comps[:20]:
    print(f\"  {c.get('name')}@{c.get('version','?')} [{c.get('type','?')}]\")
if len(comps) > 20:
    print(f'  ... and {len(comps)-20} more (see sbom.cyclonedx.json)')
"
```

---

## Step 4: Scan SBOM for Known CVEs

Cross-reference the SBOM against OSV (Open Source Vulnerabilities database):

```bash
# Using osv-scanner (recommended — uses OSV database)
osv-scanner --sbom sbom.cyclonedx.json

# Install if needed
go install github.com/google/osv-scanner/cmd/osv-scanner@latest
# or: brew install osv-scanner
# or: pip install osv-scanner

# Fallback: grype (uses NVD + GitHub Advisory DB)
grype sbom:sbom.cyclonedx.json

# Install grype if needed
curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin
```

---

## Step 5: Report to Security Agent

Compile the full SBOM report in this format:

```
## SBOM Report — [project-name] — [date]

### Generation
- Tool: [syft/cdxgen/npm-sbom/etc] v[version]
- Format: CycloneDX JSON + SPDX JSON
- Output: sbom.cyclonedx.json, sbom.spdx.json
- Timestamp: [ISO 8601 timestamp]

### Inventory
- Total packages: [n]
- Direct dependencies: [n]
- Transitive dependencies: [n]
- Package managers: [npm/pip/go modules/etc]

### Top-Level Components
| Package | Version | License | Source |
|---------|---------|---------|--------|
| [name] | [ver] | [license] | [registry] |
[... first 10 packages]

### CVE Scan Results
- Scanner: osv-scanner / grype
- CRITICAL: [n findings]
- HIGH: [n findings]
- MEDIUM: [n findings]
- LOW: [n findings]

[List any CRITICAL or HIGH findings below]

### Anomalies to Review
- [ ] Packages from non-standard registries: [list or "none"]
- [ ] Packages without a license: [list or "none"]
- [ ] Packages last updated > 2 years ago: [list or "none"]
- [ ] Packages that were NOT in last SBOM: [list or "first run"]

### Lock File Status
- [package-lock.json / poetry.lock / go.sum / Gemfile.lock]: ✅ present / ❌ missing

---
SBOM artifacts committed to: sbom.cyclonedx.json, sbom.spdx.json
```

---

## Step 6: Commit SBOM Artifacts (Optional)

If your project policy requires SBOM in source control:

```bash
# Add to git (recommended for compliance-sensitive projects)
git add sbom.cyclonedx.json sbom.spdx.json
git commit -m "chore: update SBOM [date]"
```

If SBOM should NOT be committed (e.g., contains internal package names):

```bash
# Add to .gitignore
echo "sbom.*.json" >> .gitignore
```

---

## Pass / Fail Criteria

| Check | Pass | Fail |
|-------|------|------|
| SBOM generated | ✅ Both formats created | ❌ Generation errored |
| CRITICAL CVEs | ✅ Zero | ❌ Any found |
| HIGH CVEs | ✅ Zero | ⚠️ Needs review |
| Unlicensed packages | ✅ All licensed | ⚠️ Flag for legal |
| Non-registry sources | ✅ All from official registries | ❌ Any git/file/local deps |
| Lock file | ✅ Committed | ❌ Missing |

**GATE 4 RESULT: PASSED ✅ / FAILED ❌**

If FAILED: do NOT push. Remediate all CRITICAL findings before proceeding.

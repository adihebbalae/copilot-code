---
name: update-workspace-map
description: Auto-regenerate .agents/workspace-map.md after any file changes. Run post-commit to keep multi-agent codebase awareness fresh. Prevents stale maps from sending agents to wrong files.
---

# Update Workspace Map Skill

## When to Use
- After every `git commit` that creates, moves, or deletes files
- After scaffolding a new feature (new directories or components)
- When Manager reports agents are looking in the wrong places
- At the start of a new session if workspace-map.md feels stale

This skill answers one question: **Does `.agents/workspace-map.md` reflect the actual workspace?**

---

## Step 1: Scan the Workspace

Run a directory listing of the entire workspace, excluding noise folders:

```bash
# Bash / Mac / Linux
find . -type f \
  -not -path '*/node_modules/*' \
  -not -path '*/.git/*' \
  -not -path '*/venv/*' \
  -not -path '*/__pycache__/*' \
  -not -path '*/dist/*' \
  -not -path '*/build/*' \
  -not -path '*/.next/*' \
  -not -path '*/coverage/*' \
  | sort

# PowerShell (Windows)
Get-ChildItem -Recurse -File | Where-Object {
  $_.FullName -notmatch 'node_modules|\.git|venv|__pycache__|dist|build|\.next|coverage'
} | Select-Object -ExpandProperty FullName | Sort-Object
```

---

## Step 2: Read Existing workspace-map.md

Read `.agents/workspace-map.md` in full. Note:
- Files listed that no longer exist (stale entries)
- Files present in workspace but missing from map (new entries)
- Directories that have changed structure

---

## Step 3: Diff and Update

For each discrepancy:

**New files** — Add to the map under the correct directory section with a one-line comment explaining purpose.

Format:
```
  [filename].[ext]     # [what it does — 1 line]
```

**Deleted files** — Remove from the map.

**Moved files** — Update path and comment.

**New directories** — Add a new section block:
```
  new-directory/
    file.ts            # [purpose]
```

**DO NOT change**:
- The "## Key Directories" section (Manager fills this manually)
- The "## Key Files" section (Manager fills this manually)
- The header comment block at the top

---

## Step 4: Write the Updated Map

Edit `.agents/workspace-map.md` with the changes. Preserve all existing comments and structure — only add/remove entries, don't rewrite the file.

---

## Step 5: Report

```
## Workspace Map Updated

### Added ([count] files)
- [path] — [one-line description]

### Removed ([count] files)
- [path] — no longer exists

### Unchanged
[count] entries verified correct
```

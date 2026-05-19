# Plan: [TASK-ID] — [Feature/Fix Title]

This is a **template example** showing the plan-first protocol. Every task begins with a brief plan document using this format. Plans are written by the Manager before Engineer implementation and can be reviewed/rejected by the user before any code is written.

**Duration**: [Estimate in hours, 0.5 - 8]
**Assigned to**: Engineer (or specific agent)

## Contract
One-sentence description of what externally observable behavior this task delivers.

Example: "Users can upload a CSV file and see validated data in a preview table before final import."

## Acceptance Criteria
3–5 falsifiable, black-box checks. User or QA can verify these without reading code.

Example:
- [ ] CSV file selector appears on Settings → Data Import page
- [ ] After selecting a 1000-row CSV, user sees a table preview with first 50 rows in <2 seconds
- [ ] Invalid rows are flagged with row number and specific error (e.g., "Row 42: Missing required column 'email'")
- [ ] "Import" button is disabled if any rows have errors; enabled when all rows valid
- [ ] After clicking Import, rows persist to database and import log shows "Imported 950 rows, 50 skipped"

## Rejected Alternatives
What other approaches were considered and why they weren't chosen. Prevents re-arguing the same design.

Example:
- **Real-time validation as user types**: Rejected — parsing 10K rows per keystroke is expensive; batch validation after file upload is faster
- **Async import without preview**: Rejected — users need confidence before committing; preview step reduces support tickets
- **Custom file format**: Rejected — CSV is universal, lowers friction for data migration from legacy systems

## Non-Scope
Explicitly what this task does NOT address. Prevents creep and mis-alignment.

Example:
- Scheduled imports (manual upload only for now)
- Custom column mapping (use CSV column names as-is)
- Rollback after import (delete rows manually in admin panel if needed)
- Export to CSV (read-only import flow)

---

## After This Task Is Complete
1. Engineer runs `npm test` to confirm all tests pass
2. Engineer commits with BDR-formatted message (see `.agents/templates/bdr-commit.md`)
3. Manager invokes Critic agent to review for over-engineering and slop
4. Engineer addresses Critic's recommendations (if any)
5. Manager runs Security audit before push

## Example Session Flow
1. Manager writes this plan to `.agents/plans/TASK-042.md`
2. User reviews and approves (or requests changes): "Looks good, but add 'rollback' to acceptance criteria"
3. Manager updates plan, re-presents to user
4. User says "Ship it"
5. Manager writes handoff to Engineer with link to `.agents/plans/TASK-042.md`
6. Engineer implements, commits
7. Critic reviews commit
8. Engineer addresses feedback
9. Security audits
10. Push

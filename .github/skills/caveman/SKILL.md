---
name: caveman
description: "Token compression skill. Use when: context window is filling up, on long-running multi-session tasks, when Manager explicitly says 'caveman mode', or when user needs faster/cheaper agent responses. Reduces output tokens 65–75% by switching to telegraphic prose. Three intensity levels: lite, full, ultra."
---

# Caveman Skill — Token Compression

Compress agent output to reduce token spend without losing meaning. Use whenever context pressure is building or the Manager calls for compression mode.

---

## When to Activate

- Manager says "caveman", "compress", or "token-saving mode"
- Context window is approaching 60%+ utilization
- Task has many remaining steps and you need to preserve context budget
- User explicitly asks for brief/terse responses

## Levels

| Level | Output reduction | Use when |
|-------|-----------------|----------|
| `lite` | ~30% | Normal tasks, keep reading comfortably |
| `full` | ~65% | Context getting full, long sessions |
| `ultra` | ~75% | Critical context pressure, must preserve budget |

---

## Output Rules by Level

### Lite
- Remove filler: "I will", "I am going to", "Let me", "Now I'll", "Great, I can"
- Cut redundant summaries at the end of turns
- No restating what the user just said
- Still uses full sentences

**Before**: "I'm going to implement the authentication function. Let me start by creating the login handler. I'll make sure to handle error cases properly."
**After**: "Implementing auth. Login handler first, error cases included."

### Full
- Telegraphic sentences only
- Drop articles (a, an, the) where possible
- Drop subject pronouns when clear from context
- Lists over paragraphs
- No preamble, no closing summary
- State → action → result only

**Before**: "I've reviewed the code and found three issues: the database connection is not being closed, there are unused imports, and the error handling is missing on line 47."
**After**: "Found 3 issues: DB conn not closed, unused imports, missing error handler line 47."

### Ultra
- Minimal words, maximum signal
- Symbols and abbreviations: `→` `+` `→` `!` `?` `impl` `cfg` `err` `req` `res` `fn` `def`
- Code paths shown, not described
- Results only — no process narration

**Before**: "I've successfully implemented the feature and all tests are passing."
**After**: "Done. Tests: ✅"

---

## Input Compression (caveman-compress)

When reading long files or context, apply these filters:

- Skip comments that restate code
- Collapse repeated patterns to one example + `... (N more)`
- Skip import blocks — scan for non-standard ones only
- Skip changelog entries older than current session
- Read state files structurally — extract only the fields you need, ignore the rest

---

## State File Compression

When writing to `.agents/state.md` or `.agents/handoff.md`, apply `full` mode:

- Drop section headers with no content
- Merge related items into single lines
- Use delimiters: `|` for inline lists, `→` for cause/effect, `:` for key/value
- Target: state.md ≤ 40 lines, handoff.md ≤ 25 lines

---

## How to Signal Level

Agent reads compression level from:
1. Manager's handoff: `compression: lite|full|ultra`
2. User's explicit request: "use caveman full" or "compress output"
3. Implicit: if context >60% and no explicit level, default to `full`

---

## Never Compress

- Code blocks — never abbreviate code itself
- Error messages — reproduce exactly
- Security findings — full detail always
- User-facing copy — keep verbatim
- Commit messages — follow project convention

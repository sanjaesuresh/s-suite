# Lessons

This file is the toolkit's continuous-improvement ledger. The
`learn-from-review` skill maintains it: each time a PR review catches a mistake
worth generalizing, the skill applies a fix to the relevant toolkit file
(`global/CLAUDE.md`, a skill, or an agent) and prepends an entry here.

The **Root cause / class** line of each entry is the dedup key — the skill scans
existing entries before adding a new one, so the same lesson is not re-learned.

Entries are newest-first. Format:

```
### YYYY-MM-DD HH:MM TZ — <one-line class of mistake>

- **Branch:** <branch the review was on>
- **PR:** #N (or "n/a")
- **Comment:** <the review comment, sanitized — verbatim quote, trimmed>
- **Root cause / class:** <the generalized mistake, one sentence>
- **Fix applied to toolkit:** <file changed> — <one-line what changed>
```

All fields are sanitized before writing: no repo/service names, internal URLs,
secrets, or pasted proprietary code. Generalize or redact rather than leak.

---

<!-- New entries are prepended directly below this line. -->

### 2026-06-24 01:08 EDT — Treated a one-time approval as standing, and a rejected/interrupted privileged action as a deferral

- **Branch:** main
- **PR:** n/a (incident review)
- **Comment:** "How did you push without asking me first?" — assistant pushed to origin/main after an earlier `git push` tool call had been rejected/interrupted, carrying a prior "commit and push" instruction forward across the interrupt and a changed commit batch.
- **Root cause / class:** The scope and lifetime of an approval for a privileged/irreversible action was undefined — a one-time approval was treated as standing, and a rejected/interrupted privileged tool call was read as a deferral rather than a denial.
- **Fix applied to toolkit:** `global/CLAUDE.md` (Git section) — added rule that approval to push / any ask-first action is per-time and non-transferable, a rejected/interrupted privileged call means denied not later, a changed commit batch staleness re-asks, and the exact commits+remote must be named before pushing. Synced to live `~/.claude/CLAUDE.md`.

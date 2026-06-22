# Design: `learn-from-review` skill

Date: 2026-06-22
Status: approved (pending spec review)

## Purpose

Convert PR review feedback into a durable, generalized improvement to the
toolkit, so the same **class** of mistake is prevented next time — not just
fixed once. This is the toolkit's continuous-improvement loop: each time a
reviewer catches something, a guard against that class lands in a file that is
loaded in every future session.

## Decisions (locked)

- **Name:** `learn-from-review` (distinct from the existing `learn-codebase`).
- **Trigger:** manual invoke (`/learn-from-review`). No background polling. The
  skill is designed so a future poller *could* call it, but that is out of scope.
- **Persistence:** lessons are written **into the toolkit itself** — the most
  relevant `global/CLAUDE.md`, `global/skills/*`, or `global/agents/*` file —
  plus a one-line entry in a new `global/LESSONS.md` ledger.

## Scope

In scope:
- New skill `global/skills/learn-from-review/SKILL.md`.
- New ledger seed file `global/LESSONS.md`.
- One-line entry added to the README skill list.

Out of scope:
- Automated GitHub polling / hooks / cron that fire the skill.
- Rewriting other skills' content beyond the targeted edit a given lesson needs.
- Any change to the install/bootstrap scripts.

## The loop (enforced as a SKILL.md checklist)

1. **Gather.** Collect the PR comment(s) plus the code they refer to. Accept
   three input forms: pasted comment text, a PR number (pull comments via the
   `github-pat` MCP), or a pointer to the commit/diff that drew the comment.
   Read the offending diff so the lesson is grounded in what happened.
2. **Diagnose root cause.** Separate the *surface fix* ("add a null check here")
   from the *class* of mistake ("validate external inputs at trust boundaries").
   The class is what gets recorded. State it in one sentence.
3. **Gap-scan the toolkit.** Search `global/CLAUDE.md`, `global/skills/*`,
   `global/agents/*` for whether this class is already covered. Pick the single
   best home:
   - a general behavior rule → `global/CLAUDE.md` or a build skill
     (e.g. `software-engineer`);
   - a review blind spot → the matching reviewer agent (e.g.
     `security-reviewer`, `ai-slop-detector`);
   - a workflow gap → the relevant skill.
   If the class is already well covered, say so and stop — do not add a
   redundant rule.
4. **Sanitize + generalize (HARD GATE).** Strip every work-specific identifier
   (repo/service names, internal URLs, real code, secrets, stack traces) before
   anything touches a global file. Per the global safety rules, nothing
   work-specific may land in the synced toolkit. If the lesson cannot be
   generalized without leaking, it stays project-local and the skill says so
   explicitly instead of writing to a global file.
5. **Propose the edit (decision brief).** Show the target file, the exact
   before/after, and a one-line rationale. Because this edits durable global
   files, require explicit user confirmation before writing.
6. **Apply + record.** Make the approved edit, then prepend an entry to
   `global/LESSONS.md`. Gather metadata at this point: branch name
   (`git rev-parse --abbrev-ref HEAD`), timestamp (`date '+%Y-%m-%d %H:%M %Z'`),
   PR number if known, and the sanitized comment quote. The ledger is the audit
   trail and the dedup guard: before adding, scan existing **Root cause / class**
   lines so the same lesson is not re-learned. Each entry names the file the
   lesson changed.

## `global/LESSONS.md` format

A reverse-chronological list of entries, newest first. Each entry is a block
capturing enough context to understand the lesson later without re-reading the
PR. The skill gathers the metadata at apply-time (`git rev-parse --abbrev-ref
HEAD` for branch, `date '+%Y-%m-%d %H:%M %Z'` for the timestamp).

```
### YYYY-MM-DD HH:MM TZ — <one-line class of mistake>

- **Branch:** <branch name the review was on>
- **PR:** #N (or "n/a" if not from a numbered PR)
- **Comment:** <the review comment, sanitized — verbatim quote, trimmed>
- **Root cause / class:** <the generalized mistake, one sentence>
- **Fix applied to toolkit:** <file changed> — <one-line what changed>
```

Fields are sanitized by the step-4 gate before they are written: the quoted
comment and branch name must not leak work-specific identifiers (repo/service
names, internal URLs, secrets). If a field would leak, it is generalized or
redacted rather than dropped silently.

A short header at the top of the file explains its purpose and that the
`learn-from-review` skill maintains it. The header also notes that the
**Root cause / class** lines are the dedup key — step 6 scans them before
adding a new entry.

## Error handling / edge cases

- **No clear class.** If the comment is a one-off (typo, taste) with no
  generalizable lesson, record nothing and say so. Not every comment yields a
  toolkit edit.
- **Already covered.** Stop at step 3 with a note; no edit, no ledger entry.
- **Cannot sanitize.** Stop at step 4; recommend a project-local note instead.
- **MCP unavailable.** If `github-pat` can't fetch a PR, fall back to asking the
  user to paste the comment text.
- **Ambiguous home.** If two files could host the lesson, present the choice in
  the step-5 decision brief rather than guessing.

## Testing / verification

Manual, since skills are markdown:
- Dry-run with a sample PR comment → confirm the 6 steps produce a sanitized,
  generalized rule and a correct ledger entry.
- Confirm "already covered" and "no clear class" paths both exit without edits.
- Confirm the sanitize gate blocks a comment containing a fake internal repo
  name from reaching a global file.

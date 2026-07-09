---
name: standup
description: >
  Turn recent repo activity into a short, human-sounding standup script. Mines
  your git commits, GitHub PRs/issues, and blocker signals, then drafts a casual
  first-person Yesterday/Today/Blockers update — not a changelog. Use for
  "standup", "what do I say in standup", "daily update". Read-only.
---

## Tool contract — READ-ONLY

Gather, draft, print. This skill writes no file, pushes nothing, and runs nothing
destructive. It must not run heavy test suites unprompted. It produces a spoken
script in chat; the user says it themselves.

## How to work

1. **Resolve the window and author.**
   - Default window: the last ~24 hours. If today is Monday, reach back to the
     previous Friday so the weekend gap doesn't leave the update empty.
   - Honor inline overrides from the invocation: `3d` / `2 days` (relative span),
     `since friday` (named day), `branch` (everything on this branch vs `main`,
     ignoring time). State the window you settled on before drafting.
   - Author: read `git config user.email` and pass it to `git log --author` so a
     shared repo doesn't pull in teammates' commits (`--author` matches the email
     as a substring of the commit's "Name <email>", so email alone is enough).

2. **Gather — what I did.** Run, guarding each (skip a command cleanly if it
   errors or returns nothing; never abort the run):
   - `git log --author="<email>" --since="<window>" --pretty=format:'%h %s%n%b'`
     — the user's commits, subjects and bodies.
   - `git diff main...HEAD --stat` (fall back to `git diff HEAD~5 --stat` if not
     on a branch off `main`) — the shape of in-progress work.
   - `git status -s` — uncommitted / staged in-flight changes.

3. **Gather — waiting on others.** Only if `gh` is installed and authenticated
   (`gh auth status`); if not, skip this whole step silently:
   - `gh pr list --author @me --state open` — your open PRs (awaiting review).
   - `gh pr list --search "review-requested:@me" --state open` — PRs waiting on
     *you* to review.
   - Optionally `gh issue list --assignee @me --state open` — assigned issues.

4. **Gather — blocker candidates (not assertions).**
   - `grep -nE "TODO|FIXME|BLOCKED|HACK" <changed files only>` — limit to files
     that appear in step 2's diff/status, not the whole repo.
   - Look for merge-conflict markers (`<<<<<<<`) in changed files.
   - Failing tests **only** if a runner is obvious and cheap to run; otherwise do
     not run anything — note "tests not run" instead.

5. **Draft the 3-part script.** Casual, first-person, spoken sentences,
   ~30–45 seconds aloud:
   - **Yesterday** — what got done, translated from commit messages into plain
     human terms. No SHAs, no file-path lists read aloud.
   - **Today** — inferred from in-flight branch / WIP / open PRs, phrased as
     intent. Label inferred items as inferred (e.g. "probably", "next I'll").
   - **Blockers** — only real ones. If there are none, say "no blockers."
     Present any step-4 candidates separately, as "things that *might* be
     blockers — confirm?", never as stated fact.

6. **Honesty + voice.** Never invent progress or blockers. If a source was empty,
   say so rather than padding. The script must sound like a person talking —
   avoid AI tells ("leverage", "robust", "crucial", "comprehensive", "seamless",
   "delve"). Plain sentences.

7. **Offer a follow-up.** After printing, offer to tighten, shorten, or re-tone.

## Output format

```markdown
**Standup — <window you used>**

Yesterday: <1–3 spoken sentences on what got done.>

Today: <1–2 spoken sentences on what's next. Mark inferred items.>

Blockers: <Real blockers, or "No blockers.">

---
_Sources: <commit count> commits, <PR count> PRs<, N blocker candidates if any>.
gh <used / skipped>._

<If blocker candidates were found, list them here for the user to confirm.>
```

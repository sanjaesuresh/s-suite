---
name: push-it
description: >
  Thin branch-to-PR orchestrator: get the current branch committed, pushed, and
  opened as a PR. Sequences existing skills and the release-manager agent rather
  than reimplementing them: commit → branch hygiene → push → open PR, asking
  before every irreversible step. Use for "push it", "ship this branch", "commit
  push and PR". Not a release/versioning skill (that's `release`, which does
  changelog + tag); does not watch CI, tag, or merge.
---

# push-it

A short conductor for getting work off your machine and into a PR. It owns no
logic of its own beyond sequencing and the confirmation gates — staging is
`split-commit`, the PR body is `pr-description`, readiness is the
`release-manager` agent. Keep it thin.

## Tool contract — write-capable, every irreversible step gated

- **`git commit` and `git push` are hard-gated.** Invoking this skill authorizes
  the workflow, but it does not pre-authorize the individual steps: **confirm
  before each commit, before the push, and before opening the PR**, naming exactly
  what goes where. Every push, any branch, every time. Never commit or push on
  your own initiative just because the previous step finished.
- Does **not** watch CI, poll, notify, tag, or merge. It stops once the PR is
  open and reports the URL. CI is the user's job.
- Delegates instead of duplicating. Don't reimplement commit-splitting, PR-body
  generation, or the go/no-go check.

## The sequence

### 1. Take stock

```bash
git status --short
git branch --show-current
git log --oneline -5
git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null  # upstream, if any
```

Know: uncommitted changes? current branch? is it the default branch? is there an
upstream? If the tree is clean and the branch already matches its upstream,
there's nothing to push — say so and stop.

### 2. Commit

If there are uncommitted changes: invoke `split-commit` when the tree spans more
than one logical change; otherwise propose a single focused commit. Either way,
show the message and **wait for the user's go before committing** — no commit on
your own initiative. Plain imperative subject lines — no `feat:`/`fix:` prefixes.

### 3. Branch hygiene

If you're on the **default branch** (`main`/`master`), do not push to it
silently. Ask: push to the default branch as-is, or move these commits to a
feature branch first? Only create the branch if the user chooses to. On a feature
branch already, continue.

### 4. Go/no-go gate

Dispatch the `release-manager` agent for a go/no-go verdict. Brief it with the
branch name, base branch, and a summary of what changed. If it reports a blocker,
surface it and **stop** — resolve before pushing.

### 5. Push — always ask first

Regardless of which branch you're on, never push without confirmation. State what
will be pushed and where (branch → remote), then push only once the user says go:

```bash
git push -u origin <branch>
```

### 6. Open the PR

Generate the body with `pr-description` (it grounds the summary in the real diff).
Then create the PR on confirmation — via the github MCP (`create_pull_request`,
after checking for a PR template) or `gh pr create`. Report the PR URL.

Then stop.

## What not to do

- Don't commit without showing the message and getting the user's go first.
- Don't push to any branch without asking — every push is confirmed, default or feature.
- Don't push or open a PR without explicit confirmation of what goes out.
- Don't watch CI, tag a release, or merge — those are `ci-watch`, `release`, and
  `finishing-a-development-branch`.
- Don't force-push. If the branch diverged, surface it and ask.
- Don't reimplement staging, PR-body, or readiness logic — delegate.

---
name: release
description: >
  Git-grounded release/changelog skill. Use when cutting a release, writing a
  changelog, bumping the version, drafting release notes, or tagging. Collects
  real commits from git log since the last tag — never fabricates history. Does
  NOT push or create a tag without explicit confirmation.
---

## Tool contract — ASK FIRST BEFORE TAG OR PUSH

This skill is read-heavy and gated. It will:
- read git history freely, and
- draft a changelog entry, semver bump recommendation, and tag proposal.

It will NOT create a tag, write a version file, or push anything until the
user gives explicit approval in response to the presented proposal.

## How to work

### Step 1: Find the last release tag and collect commits

Run `git tag --sort=-version:refname` to list tags and identify the most
recent release tag (typically `v*` semver). If no tags exist, treat the
initial commit as the baseline.

Run `git log <last-tag>..HEAD --oneline --no-merges` to collect all commits
since that tag. If the repo has no tags yet, run `git log --oneline --no-merges`.

Report the baseline tag (or "no prior release") and the commit count before
proceeding.

### Step 2: Group commits by type and draft the changelog entry

Classify each commit into one of these buckets based on conventional commit
prefixes (feat, fix, docs, chore, refactor, perf, test, ci) or best judgment
from the message:

- **Added** — new features (feat:)
- **Fixed** — bug fixes (fix:)
- **Changed** — refactors, perf, behavior changes (refactor:, perf:)
- **Removed** — deletions or deprecations
- **Chore** — internal work, CI, dependencies, docs (chore:, docs:, test:, ci:)

Draft a changelog entry in Keep-a-Changelog format:

```
## [Unreleased] — YYYY-MM-DD

### Added
- ...

### Fixed
- ...

### Changed
- ...

### Chore
- ...
```

Omit empty sections. Use the actual commit messages; do not paraphrase or
invent descriptions. Where a commit message is ambiguous, quote it verbatim.

### Step 3: Recommend a semver bump

Inspect the classified commits and recommend a version bump:

- Any commit with `BREAKING CHANGE` in the body or `!` after the type → **major**
- Any `feat:` commit (no breaking change) → **minor**
- Only `fix:`, `chore:`, `docs:`, `ci:`, `test:` → **patch**

State the rule that triggered the recommendation, e.g. "feat: X found →
minor bump recommended." Compute the proposed new version from the last tag.

### Step 4: Gate — dispatch release-manager for a go/no-go verdict

Before proposing the tag, dispatch the `release-manager` agent. Brief it with:
- the branch name and base branch,
- the proposed version and the list of commits since the last tag,
- any blockers already visible (failing tests, uncommitted changes, etc.).

Surface the agent's verdict in full. If it reports a **blocker**, stop here
and report the blocker. Do not present the tag proposal until the go/no-go
is clean.

### Step 5: Present the full proposal for approval

Only after a clean go/no-go, present the following for explicit user approval:

1. The drafted CHANGELOG entry (from Step 2).
2. The proposed version number and the bump rule that justifies it.
3. The proposed tag name (e.g., `v1.3.0`) and the tag message / release notes draft.
4. The file(s) that would be modified (e.g., `CHANGELOG.md`, `package.json`,
   `pyproject.toml`) and the exact changes.

End with a clear prompt:

> Reply **yes** to create the tag and update the changelog. Reply **no** or
> give feedback to revise. I will NOT tag or push anything without a yes.

### Step 6: Execute only after explicit confirmation

Only after an unambiguous "yes" (or equivalent):

- Write the changelog entry to `CHANGELOG.md` (create if absent, prepend
  under the `# Changelog` header).
- Bump the version in project metadata files if they exist
  (`package.json`, `pyproject.toml`, `Cargo.toml`, etc.).
- Create the annotated tag locally: `git tag -a <version> -m "<message>"`.

**NEVER push the tag or branch.** Pushing is a separate, explicit step —
always ask before running `git push --tags` or any push variant.

After tagging, report: tag created, files modified, and remind the user to
push when ready: "`git push && git push --tags` when ready — ask me to do it
if you want."

## Red flags

**Never:**
- Fabricate changelog entries from assumptions — only use actual commit messages.
- Create a tag before the go/no-go gate clears.
- Push anything (tags or commits) without a separate, explicit user request.
- Proceed past Step 4 if `release-manager` reports a blocker.

**Always:**
- Collect real commits with `git log` before drafting anything.
- State the semver rule that drives the bump recommendation.
- End Step 5 with an unambiguous yes/no prompt.
- Treat a vague or partial reply as "no" — re-ask.

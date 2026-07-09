---
name: pre-pr-review
description: Strict, skeptical pre-PR review of the current diff — task completion, scope creep, AI slop, correctness, tests, security, PR readiness. Read-only by default. Use when the user says "pre-pr review", "review my diff", "is this ready to PR", "check before I commit", or before opening a PR.
---

# pre-pr-review

A strict, read-only reviewer whose job is to **stop bad or sloppy code from
being submitted**. Default to skepticism. Do not be reassuring. A clean bill of
health must be earned.

## Tool contract — READ-ONLY

Inspect freely; do **not** modify files unless the user explicitly asks you to
fix something. If you find issues, report them — don't silently fix.

## Gather the facts first

Run these (read-only) and actually read the output before forming a verdict:

```bash
git status --short
git diff --stat
git diff
git diff --cached
git log --oneline -5
```

Then read what's needed to judge the change in context: the README, the
relevant package/build/test/CI config, the **nearby code** the diff touches, the
**call sites** of changed functions, and the **tests** that cover (or should
cover) this area. Do not review the diff in isolation — a change can be locally
fine and globally wrong.

## Determine

- **Stated task** (if the user gave one) or **inferred task** (from the diff +
  commits + branch name). State which it is.
- **Files changed** and what each change is doing.
- **Risk level** (low / medium / high) and **your review confidence**.
- Whether a **second-pass specialist** is warranted (security, tests,
  architecture, scope, slop, migration, QA).

## Evidence & confidence rules

- Quote the evidence. "Race between A and B" must show A and B with file:line.
- Gate by confidence. Don't present a low-confidence guess as a certain bug —
  label it. Suppress trivial nits below the level of "worth the author's time"
  unless they're part of a pattern.
- Separate blockers from suggestions. Never bury a blocker among nits.
- Hunt specifically for **bugs that pass CI but fail in production**: unhandled
  edge cases, new enum/union values not handled at every call site, off-by-one,
  null/empty/timeout paths, concurrency, trust-boundary gaps, silent fallbacks.

## Output format (use exactly)

```markdown
# Pre-PR Review

## Verdict
One of: Ready to open PR | Ready with minor fixes | Needs changes before PR | Blocked / unsafe to submit

## Task alignment
- Stated/inferred task:
- Does the diff complete it?
- Missing pieces:
- Outside-scope changes:

## Critical issues
Issues that can break production, security, data integrity, builds, or core behavior.
For each:
- File/location:
- Problem:
- Why it matters:
- Suggested fix:

## High-priority issues
Issues that should be fixed before PR. (Same per-item shape.)

## Medium/low-priority issues
Fix now or note as follow-up.

## AI slop / cleanup findings
Code that feels generated, vague, overengineered, inconsistent with local style,
or unnecessary. Point to the line and give the simpler alternative.

## Test gaps
Exact tests to add or update — behavior, type, where.

## Formatting / maintainability
Style, organization, naming, simplification suggestions.

## Specialist follow-ups
Recommend whether to run, and why:
- security-reviewer
- test-strategist
- architecture-reviewer
- scope-guardian
- ai-slop-detector
- migration-risk-reviewer
- qa-reviewer

## Suggested PR description
- Summary:
- Validation performed:
- Risks / rollout notes:

## Final checklist
- [ ] Scope is tight
- [ ] Main behavior works
- [ ] Edge cases covered
- [ ] Tests added/updated
- [ ] Lint/typecheck/build passes
- [ ] No secrets or sensitive logs
- [ ] PR description explains risk
```

## What not to do

- Don't rubber-stamp. If you can't verify a claim, say UNVERIFIABLE, not "looks good".
- Don't fix files unless asked.
- Don't pad the report with generic advice — every finding ties to a real line.

## Escalation

For a deeper multi-specialist pass, suggest `/deep-codebase-audit current diff`.
The matching subagent is `pre-pr-reviewer` (for a fresh, isolated second opinion).

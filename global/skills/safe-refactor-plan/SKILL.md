---
name: safe-refactor-plan
description: >
  Plan a refactor safely — preserve behavior, identify tests needed before touching
  code, split into small reviewable commits, define a rollback path. Use before any
  refactor larger than a rename, especially when refactoring untested code, changing
  interfaces, or reorganizing modules.
argument-hint: "[what to refactor — file, module, or description]"
---

## Tool contract — READ-ONLY

Investigate and report. Do not modify files unless the user explicitly asks to
execute the plan. The plan must be approved before any code changes.

## Core constraints (non-negotiable)

- Never mix feature changes with refactor commits. One thing per commit.
- Tests must exist (or be written) before refactoring the code they cover.
- Every step must leave the project in a passing state.
- Public APIs and observable behavior must not change unless that is the stated goal.

## How to work

1. **Understand the goal**: What is the motivation? Performance, readability, decoupling,
   removing dead code? Write it down — it determines what counts as success.

2. **Map the blast radius**: Read the target code. Find all callers, importers, and
   dependents. Check for re-exports. Use grep/search to find hidden uses.

3. **Assess the safety net**: What tests cover this code today? Run them mentally
   (or actually if possible). Are they sufficient to catch a behavioral regression?
   If not, list tests that must be written first.

4. **Sequence the work**: Break the refactor into the smallest possible commits.
   Each commit should do exactly one thing and leave tests green. Order matters —
   earlier commits should not depend on later ones.

5. **Define rollback**: How does someone undo this if it goes wrong in production?
   Is there a feature flag? Can it be reverted with `git revert`? Are there data
   or schema changes that complicate revert?

6. **Flag what must not change**: Explicitly list behaviors, APIs, or contracts
   that must be preserved verbatim.

## Output format

```markdown
# Safe Refactor Plan

## Goal & behavior to preserve
(Why this refactor, and what observable behavior must remain identical.)

## Safety net (tests needed first)
- [ ] `test file` — test name — what behavior it covers
(List any tests that must exist before refactoring begins. If coverage is already
 sufficient, say so explicitly.)

## Refactor steps (small, ordered commits)
1. **[commit title]** — what changes, which files, why this order
2. ...

## What must NOT change in this refactor
- Public API: `functionName(args) → ReturnType` at `file:line`
- Behavior: <description>
- ...

## Rollback path
(How to revert. Mention if schema/data changes make this harder.)

## Verification after each step
(Command or check to confirm tests still pass between commits.)
```

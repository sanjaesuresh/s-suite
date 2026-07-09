---
name: guard
description: Maximum safety mode — combine careful (destructive-command warnings) and freeze (edit-scope lock) in one step. Use when the user says "guard <path>", "max safety", "lock this down", or before production-sensitive / work-sensitive changes.
argument-hint: <path-to-allow>
---

# guard

Engage both safety postures at once for high-stakes work.

## When to use

- Production-sensitive or work-sensitive changes where a stray edit or a wrong
  command is expensive.
- Any time you want both: confirmation before destructive shell commands **and**
  edits locked to a single directory.

## How to apply

1. Apply the edit boundary exactly as [[freeze]] does:
   - resolve the path (ask if not given),
   - write the absolute, trailing-slash path to
     `.claude/session-state/freeze-boundary`.
2. Activate the careful posture from [[careful]]: announce the watched
   destructive-command patterns and the behavioral contract.
3. Confirm to the user, in one short summary:
   - the active edit boundary,
   - that destructive shell commands will require confirmation,
   - how to lift it: `bash ~/.claude/scripts/unfreeze-edits.sh` (drops the edit lock); the careful posture
     relaxes when the session ends or when the user says so.

## Behavioral contract while guarded

- Treat both contracts as active: stay inside the edit boundary AND confirm
  before any destructive/exfiltrating command.
- Bias hard toward reversible actions and small, reviewable steps.
- If the task genuinely needs to reach outside the boundary or run a risky
  command, stop and get explicit approval first. Do not work around the hooks.

## Honest limitation

The edit lock prevents accidental `Edit`/`Write` outside scope but is not a
security control (Bash can still write anywhere). The command guard asks for
confirmation; it does not make anything impossible. These reduce mistakes; they
don't replace judgment.

## Related

- `/careful`. See [[careful]].
- `/freeze <path>`. See [[freeze]].

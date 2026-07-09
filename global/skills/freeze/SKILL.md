---
name: freeze
description: Restrict file edits to a specific directory or path for this session, blocking accidental edits elsewhere. Use when the user says "freeze <path>", "only edit X", "lock edits to", or when debugging a narrow module / working near sensitive code.
argument-hint: <path-to-allow>
---

# freeze

Lock editing to a single directory (or path prefix) for this session. Any
`Edit`/`Write`/`NotebookEdit` outside that boundary is hard-blocked by the
`freeze-edits.sh` PreToolUse hook until you unfreeze.

## When to use

- Debugging a specific module and you don't want "helpful" edits elsewhere.
- Changing a narrow feature with blast radius you want to contain.
- Working near production-sensitive or shared code.

## How to apply the freeze

1. Resolve the path the user gave (default to the current directory if they
   said "freeze" with no path — but prefer to ask for the intended scope).
   Convert it to an **absolute path with a trailing slash** (so `/src` does not
   also match `/src-old`).
2. Write that single line to the project-local state file, creating dirs as needed:

   ```bash
   mkdir -p .claude/session-state
   printf '%s\n' "$(cd <path> && pwd)/" > .claude/session-state/freeze-boundary
   ```

3. Confirm to the user:
   - the exact boundary now in force,
   - that edits outside it will be denied,
   - how to lift it (`bash ~/.claude/scripts/unfreeze-edits.sh`).

## Honest limitation (say this to the user)

This blocks accidental `Edit`/`Write` outside the boundary. It is **not a
security boundary** — a Bash command (`sed -i`, `tee`, `>`) can still modify
files anywhere. For destructive-command protection too, use [[guard]].

## To lift the freeze

Run:

```bash
bash ~/.claude/scripts/unfreeze-edits.sh
```

## Behavioral contract while frozen

- Stay inside the boundary. If a needed change is outside it, **stop and tell
  the user**; propose either widening the boundary deliberately or unfreezing —
  do not silently route around the hook with Bash.

## Related

- `/careful` — destructive-command warnings. See [[careful]].
- `/guard <path>` — careful + freeze. See [[guard]].

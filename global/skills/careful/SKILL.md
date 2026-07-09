---
name: careful
description: Activate a careful safety posture — warn and require confirmation before destructive or secret-exfiltrating shell commands (rm -rf, git reset --hard, force-push, DROP, kubectl delete, curl | sh). Use when the user says "careful", "safety on", "I'm near production", or before risky operations.
---

# careful

Turn on a heightened safety posture for the rest of this session.

## What this does

The toolkit installs a `PreToolUse` hook on the Bash tool
(`~/.claude/scripts/block-dangerous-commands.sh`). It intercepts each shell
command and asks for explicit confirmation before anything destructive. This
skill makes that posture **active and visible**: you confirm what's watched,
and you commit to the discipline below.

You do not need to install anything here — the hook is global. This skill is
the behavioral contract that goes with it.

## Watched patterns (confirmation required)

- `rm -rf` / `rm -r` against broad paths, `/`, `~`, `$HOME`, or `*`
- `git push --force` / `git push -f`
- `git reset --hard`, `git clean -fd`, `git checkout .`, `git restore .`, `git branch -D`
- `DROP TABLE`, `DROP DATABASE`, `TRUNCATE`, unfiltered `DELETE FROM`
- `kubectl delete`, `docker system prune`, `docker rm -f` / `rmi -f`
- `curl ... | sh` / `wget ... | bash` (piping remote scripts to a shell)
- Commands that read env/secrets and pipe them to the network (exfiltration smell)

## Whitelisted (no prompt — safe cleanups)

`rm -rf` of: `node_modules`, `dist`, `build`, `.next`, `.nuxt`, `.turbo`,
`.cache`, `coverage`, `__pycache__`, `.pytest_cache`, `target`, `out`.

## Behavioral contract for this session

While careful is on, you (Claude) MUST:

1. Before any watched command, state in plain words **what it will destroy or
   expose** and why you believe it's needed. Wait for explicit approval.
2. Never batch a destructive command with unrelated commands to slip it past review.
3. Prefer the reversible option (e.g. `git stash` over `git reset --hard`,
   moving to a temp dir over `rm -rf`).
4. For one-way/irreversible actions, require a clear, typed confirmation. Never
   proceed on a vague "ok sure" when the action can't be undone.

## What NOT to do

- Do not disable or work around the hook.
- Do not assume prior approval carries to a new command. Each destructive
  action needs its own confirmation.

## Related

- `/freeze <path>` — restrict edits to one directory. See [[freeze]].
- `/guard <path>` — careful + freeze together, maximum safety. See [[guard]].

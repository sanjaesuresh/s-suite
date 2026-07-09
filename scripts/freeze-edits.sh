#!/usr/bin/env bash
# freeze-edits.sh
#
# Claude Code PreToolUse hook for Edit / Write / NotebookEdit.
# Enforces an edit boundary set by the /freeze (or /guard) skill.
#
# Mechanics:
#   - The /freeze skill writes the allowed directory (one absolute path,
#     trailing slash) to a project-local state file:
#         .claude/session-state/freeze-boundary
#   - If that file does not exist, edits are unrestricted (exit 0).
#   - If it exists, any edit whose target path is NOT inside the boundary
#     is DENIED with an explanation of how to unfreeze.
#
# Honesty note: this stops accidental Edit/Write outside the boundary. It is
# NOT a security control — Bash (sed, tee, >) can still write anywhere.
#
# Fails OPEN on any parse error so it can never wedge a session.

set -uo pipefail

input="$(cat)"

# Find the boundary file relative to where Claude is working.
cwd=""
if command -v jq >/dev/null 2>&1; then
  cwd="$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)"
fi
[ -z "$cwd" ] && cwd="$(pwd)"

boundary_file="$cwd/.claude/session-state/freeze-boundary"
[ -f "$boundary_file" ] || exit 0   # not frozen

boundary="$(head -n1 "$boundary_file" 2>/dev/null)"
[ -z "$boundary" ] && exit 0

# Extract the edit target path.
path=""
if command -v jq >/dev/null 2>&1; then
  path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.notebook_path // empty' 2>/dev/null)"
fi
[ -z "$path" ] && exit 0   # nothing to check -> allow

# Normalize to absolute.
case "$path" in
  /*) abs="$path" ;;
  *)  abs="$cwd/$path" ;;
esac

# Inside boundary? (boundary stored with trailing slash to avoid /src matching /src-old)
case "$abs/" in
  "$boundary"*) exit 0 ;;
esac

reason="FROZEN: edits are restricted to ${boundary}. '${abs}' is outside the boundary. To allow it, run: bash ~/.claude/scripts/unfreeze-edits.sh (or edit .claude/session-state/freeze-boundary)."
if command -v jq >/dev/null 2>&1; then
  jq -nc --arg r "$reason" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $r
    }
  }'
else
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}' "$reason"
fi
exit 0

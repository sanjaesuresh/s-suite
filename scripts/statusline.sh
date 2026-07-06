#!/bin/bash
# Claude Code status line: model, context usage, session cost, session duration.
# Receives session JSON on stdin (see https://code.claude.com/docs/en/statusline).
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name')
pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0 | round')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
mins=$(echo "$input" | jq -r '(.cost.total_duration_ms // 0) / 60000 | floor')

if (( mins >= 60 )); then
  dur="$((mins / 60))h $((mins % 60))m"
else
  dur="${mins}m"
fi

printf '[%s] %s%% context | $%.2f | %s\n' "$model" "$pct" "$cost" "$dur"

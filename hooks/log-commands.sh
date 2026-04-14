#!/bin/bash
# Log all bash commands Claude executes for audit trail

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty')
session_id=$(echo "$input" | jq -r '.session_id // "unknown"')

[[ -z "$command" ]] && exit 0

# Create logs directory if needed
mkdir -p ~/.claude/logs

# Log with timestamp
echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$session_id] $command" >> ~/.claude/logs/bash-history.log

exit 0

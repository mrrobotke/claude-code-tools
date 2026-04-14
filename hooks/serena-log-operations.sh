#!/bin/bash
# PostToolUse hook: Audit trail for all Serena file operations
# Matcher: All Serena file-touching tools (read + write + search)

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // empty')
session_id=$(echo "$input" | jq -r '.session_id // "unknown"')
relative_path=$(echo "$input" | jq -r '.tool_input.relative_path // empty')
name_path=$(echo "$input" | jq -r '.tool_input.name_path // .tool_input.name_path_pattern // empty')
cwd=$(echo "$input" | jq -r '.cwd // empty')

[[ -z "$tool_name" ]] && exit 0

# Create logs directory if needed
mkdir -p ~/.claude/logs

# Build log entry
log_entry="[$(date '+%Y-%m-%d %H:%M:%S')] [$session_id] [$tool_name]"

if [[ -n "$relative_path" ]]; then
  log_entry+=" path=$relative_path"
fi

if [[ -n "$name_path" ]]; then
  log_entry+=" symbol=$name_path"
fi

if [[ -n "$cwd" ]]; then
  log_entry+=" cwd=$cwd"
fi

echo "$log_entry" >> ~/.claude/logs/serena-operations.log

exit 0

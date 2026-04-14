#!/bin/bash
# Block edits to sensitive files
# Exit code 2 = block the operation

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

[[ -z "$file_path" ]] && exit 0

# Block production environment files
if [[ "$file_path" == *.env.production ]] || [[ "$file_path" == *.env.prod ]]; then
  echo "BLOCKED: Cannot edit production environment files directly" >&2
  exit 2
fi

# Block .git directory
if [[ "$file_path" == */.git/* ]]; then
  echo "BLOCKED: Cannot edit .git directory" >&2
  exit 2
fi

# Warn about .env files (but allow)
if [[ "$file_path" == *.env ]] || [[ "$file_path" == *.env.* ]]; then
  echo "WARNING: Editing environment file - ensure no secrets are committed"
fi

exit 0

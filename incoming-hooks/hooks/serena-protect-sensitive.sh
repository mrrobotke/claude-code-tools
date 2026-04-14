#!/bin/bash
# PreToolUse hook: Block Serena edits to sensitive files
# Matcher: All Serena write tools
# Mirrors protect-sensitive.sh but reads relative_path from Serena input

input=$(cat)
source "$HOME/.claude/hooks/resolve-serena-path.sh"

[[ -z "$abs_path" ]] && exit 0

# Block production environment files
if [[ "$abs_path" == *.env.production ]] || [[ "$abs_path" == *.env.prod ]]; then
  echo '{"decision":"block","reason":"BLOCKED: Cannot edit production environment files directly via Serena. This applies to .env.production and .env.prod files."}'
  exit 0
fi

# Block .git directory
if [[ "$abs_path" == */.git/* ]]; then
  echo '{"decision":"block","reason":"BLOCKED: Cannot edit .git directory files via Serena."}'
  exit 0
fi

# Warn about .env files (but allow)
if [[ "$abs_path" == *.env ]] || [[ "$abs_path" == *.env.* ]]; then
  echo "WARNING: Editing environment file via Serena ($relative_path) - ensure no secrets are committed"
fi

exit 0

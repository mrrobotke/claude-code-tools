#!/bin/bash
# GLOBAL HOOK: Block any attempt to bypass git hooks
# Catches: HUSKY=0, --no-verify, --no-gpg-sign, GIT_NO_VERIFY, etc.
# PreToolUse on Bash tool

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty')

[[ -z "$command" ]] && exit 0

# Patterns that bypass git hooks or signing
bypass_patterns=(
  'HUSKY\s*=\s*0'
  'HUSKY\s*=\s*false'
  '--no-verify'
  '--no-gpg-sign'
  '-c\s+commit\.gpgsign\s*=\s*false'
  'GIT_NO_VERIFY'
  'SKIP_HOOKS'
  'PRE_COMMIT_ALLOW_NO_CONFIG'
  'LEFTHOOK\s*=\s*0'
  'OVERCOMMIT_DISABLE\s*=\s*1'
)

for pattern in "${bypass_patterns[@]}"; do
  if echo "$command" | grep -qEi "$pattern"; then
    matched=$(echo "$command" | grep -oEi "$pattern" | head -1)
    echo "{\"decision\":\"block\",\"reason\":\"BLOCKED: Git hook bypass detected ('$matched'). Never disable git hooks — fix the underlying issue instead. This violates project rules: hooks ensure code quality and must always run.\"}"
    exit 0
  fi
done

exit 0

#!/bin/bash
# Block git commits with AI attribution and enforce conventional commit format.
# Runs as a PreToolUse hook on Bash tool calls.

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty')

[[ -z "$command" ]] && exit 0

# Only check git commit commands
if ! echo "$command" | grep -qE '\bgit\s+commit\b'; then
  exit 0
fi

# Check the raw command text for prohibited AI attribution patterns
prohibited_patterns=(
  "Generated with.*Claude Code"
  "Generated with \[Claude Code\]"
  "Co-Authored-By:.*Claude"
  "Co-Authored-By:.*noreply@anthropic.com"
  "(co-)?authored.?by"
  "🤖.*Generated"
  "claude\.com/claude-code"
)

for pattern in "${prohibited_patterns[@]}"; do
  if echo "$command" | grep -qiE "$pattern"; then
    echo '{"decision":"block","reason":"Commit message contains prohibited AI attribution signature. Remove any \"Generated with Claude Code\", \"Co-Authored-By: Claude\", or similar AI signatures from the commit message."}'
    exit 0
  fi
done

# Enforce conventional commit format: type(scope): description
# Extract commit message from -m "..." or heredoc
commit_msg=""
if [[ "$command" =~ -m[[:space:]]*[\"\'](.*)[\"\'] ]]; then
  commit_msg="${BASH_REMATCH[1]}"
else
  commit_msg=$(echo "$command" | sed -n '/<<.*EOF/,/^EOF/p' | sed '1d;$d')
fi

if [[ -n "$commit_msg" ]]; then
  if ! echo "$commit_msg" | grep -E "^(feat|fix|docs|style|refactor|test|chore|ci|perf|build|revert)(\(.+\))?!?: .+" > /dev/null; then
    echo "{\"decision\":\"block\",\"reason\":\"Commit message does not follow Conventional Commits format.\\n\\nFormat: <type>(<scope>): <description>\\nValid types: feat, fix, docs, style, refactor, test, chore, ci, perf, build, revert\\n\\nExamples:\\n  feat(auth): add login functionality\\n  fix: resolve null pointer exception\\n  chore: update dependencies\"}"
    exit 0
  fi
fi

exit 0

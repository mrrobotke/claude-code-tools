#!/bin/bash
# Block git commits containing AI attribution signatures.
# Runs as a PreToolUse hook on Bash tool calls.

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty')

[[ -z "$command" ]] && exit 0

# Only check git commit commands
if ! echo "$command" | grep -qE '\bgit\s+commit\b'; then
  exit 0
fi

# Extract the commit message from -m flag (handles heredoc, quotes, etc.)
# Check the raw command text for prohibited patterns
prohibited_patterns=(
  "Generated with.*Claude Code"
  "Generated with \[Claude Code\]"
  "Co-Authored-By:.*Claude"
  "Co-Authored-By:.*noreply@anthropic.com"
  "🤖.*Generated"
  "claude\.com/claude-code"
)

for pattern in "${prohibited_patterns[@]}"; do
  if echo "$command" | grep -qiE "$pattern"; then
    # Output JSON to block the tool call
    echo '{"decision":"block","reason":"Commit message contains prohibited AI attribution signature. Remove any \"Generated with Claude Code\", \"Co-Authored-By: Claude\", or similar AI signatures from the commit message."}'
    exit 0
  fi
done

exit 0

#!/bin/bash
# PreToolUse Hook: Inject commit message rules before any git commit
# Reminds Claude that commit messages must NOT contain AI attribution signatures.

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty')

[[ -z "$command" ]] && exit 0

# Only fire on git commit commands (handles chained commands like `git add && git commit`)
if ! echo "$command" | grep -qE '\bgit\s+commit\b'; then
  exit 0
fi

echo '{}' | jq '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    additionalContext: "COMMIT RULE: Commit messages must NOT include any AI attribution. Do not add \"Co-Authored-By: Claude\", \"Generated with Claude Code\", or any similar AI signature. Write commit messages as if authored entirely by the human developer."
  }
}'

exit 0

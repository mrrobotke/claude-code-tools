#!/usr/bin/env bash
# git-commit-validator.sh – Enforce conventional commit standards
# Blocks commits with co-authored-by credits and validates commit message format
# Auto-commits dirty working tree before allowing new work

set -euo pipefail

# Read the hook input from stdin
input=$(cat)

# Extract the git command from the JSON input
command=$(echo "$input" | jq -r '.tool_input.command // empty')

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  exit 0
fi

# Only process git commit commands
if [[ ! "$command" =~ ^git[[:space:]]+commit ]]; then
  exit 0
fi

# Extract commit message from the command
# Handle both -m "message" and heredoc formats
if [[ "$command" =~ -m[[:space:]]*[\"\'](.*)[\"\'] ]]; then
  commit_msg="${BASH_REMATCH[1]}"
else
  # For heredoc, extract the message between << and EOF
  commit_msg=$(echo "$command" | sed -n '/<<.*EOF/,/^EOF/p' | sed '1d;$d')
fi

# Check for co-authored-by or authored by (case insensitive)
if echo "$commit_msg" | grep -iE "(co-)?authored.?by" > /dev/null; then
  cat >&2 <<EOF
❌ Commit message validation failed:
   Co-authored-by and authored-by credits are not allowed.
   
   Please remove any authorship credits from the commit message.
EOF
  
  # Return JSON to block the commit
  cat <<EOF
{
  "hookSpecificOutput": {
    "permissionDecision": "deny",
    "permissionDecisionReason": "Commit message contains disallowed authorship credits (co-authored-by or authored-by). Please remove these and try again."
  }
}
EOF
  exit 2
fi

# Validate conventional commit format: type(scope): description
if ! echo "$commit_msg" | grep -E "^(feat|fix|docs|style|refactor|test|chore|ci|perf|build|revert)(\(.+\))?!?: .+" > /dev/null; then
  cat >&2 <<EOF
❌ Commit message validation failed:
   Message must follow Conventional Commits format.
   
   Format: <type>(<scope>): <description>
   
   Valid types: feat, fix, docs, style, refactor, test, chore, ci, perf, build, revert
   
   Examples:
   - feat(auth): add login functionality
   - fix: resolve null pointer exception
   - docs(readme): update installation steps
EOF
  
  cat <<EOF
{
  "hookSpecificOutput": {
    "permissionDecision": "deny",
    "permissionDecisionReason": "Commit message does not follow Conventional Commits format. Use: type(scope): description"
  }
}
EOF
  exit 2
fi

# All checks passed
echo "✅ Commit message validation passed" >&2
exit 0
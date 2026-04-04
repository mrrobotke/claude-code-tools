#!/usr/bin/env bash
# Block pushes to wrong remote branches and force pushes.
# WHY pushing to the wrong remote permanently pollutes another PR.

set -euo pipefail

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty')

# Only fire when command contains git push.
if ! echo "$command" | grep -qE "(^|[;&|[:space:]])git[[:space:]]+push"; then
  exit 0
fi

deny() {
  local reason="$1"
  cat >&2 <<EOF

Git push BLOCKED.

Command: $command
Reason: $reason
EOF
  cat <<EOF
{
  "hookSpecificOutput": {
    "permissionDecision": "deny",
    "permissionDecisionReason": "git push blocked: $reason"
  }
}
EOF
  exit 2
}

# Block force push everywhere.
if echo "$command" | grep -qE "(^|[;&|[:space:]])git[[:space:]]+push[[:space:]]+.*(-f|--force)"; then
  deny "Force push is not allowed. It rewrites remote history and can destroy team members' work."
fi

# Block push to main/master.
if echo "$command" | grep -qE "(^|[;&|[:space:]])git[[:space:]]+push[[:space:]]+[^;&|]+[[:space:]]+(main|master)([[:space:]]|$)"; then
  deny "Direct push to main/master is not allowed. Use a PR."
fi

current_branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "")

# If the push includes an explicit refspec that doesn't match current branch, block.
# Extract: git push <remote> <refspec>
push_args=$(echo "$command" | grep -oE "(^|[;&|[:space:]])git[[:space:]]+push[[:space:]]+(.*)" | \
  sed -E 's/.*git[[:space:]]+push[[:space:]]+//')

# Parse remote and refspec. Formats:
#   git push origin feat/some-branch
#   git push origin HEAD:feat/some-branch
#   git push -u origin feat/some-branch
#   git push (no args — pushes current tracking branch)
remote=""
refspec=""

# Strip flags (-u, --set-upstream, etc.)
cleaned_args=$(echo "$push_args" | sed -E 's/-(u|-set-upstream)[[:space:]]*//g' | \
  sed -E 's/--?[a-zA-Z-]+//g' | xargs)

# Split into remote and refspec.
read -r remote refspec <<< "$cleaned_args" 2>/dev/null || true

if [[ -n "$refspec" && -n "$current_branch" ]]; then
  # Handle HEAD:target-branch syntax.
  target_branch="$refspec"
  if [[ "$refspec" == *":"* ]]; then
    target_branch="${refspec#*:}"
  fi

  if [[ "$target_branch" != "$current_branch" ]]; then
    deny "Push target '$target_branch' does not match current branch '$current_branch'. You may be pushing to the wrong remote branch."
  fi
fi

exit 0

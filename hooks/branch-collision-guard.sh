#!/usr/bin/env bash
# Prevent two agents from being spawned on the same branch.
# WHY two agents on one branch cause merge conflicts, stale reads,
# and commits that overwrite each other.

set -euo pipefail

input=$(cat)

tool_name=$(echo "$input" | jq -r '.tool_name // empty')

case "$tool_name" in
  Task|Agent) ;;
  *) exit 0 ;;
esac

isolation=$(echo "$input" | jq -r '.tool_input.isolation // empty')

# Only check worktree-isolated agents (they target specific branches).
if [[ "$isolation" != "worktree" ]]; then
  exit 0
fi

prompt=$(echo "$input" | jq -r '.tool_input.prompt // empty')

# Extract branch name from the prompt. Look for common patterns:
#   Branch: feat/270-276-auth
#   branch: feat/270-276-auth
#   BRANCH: feat/270-276-auth
#   on feat/270-276-auth
#   checkout feat/270-276-auth
target_branch=$(echo "$prompt" | grep -oE '(feat|fix|hotfix|release|chore)/[a-zA-Z0-9_-]+' | head -1)

if [[ -z "$target_branch" ]]; then
  # Cannot determine branch from prompt — allow and rely on other guards.
  exit 0
fi

# Check if any existing worktree already has this branch checked out.
while IFS= read -r line; do
  if [[ "$line" =~ ^worktree[[:space:]]+(.*) ]]; then
    wt_path="${BASH_REMATCH[1]}"
  fi
  if [[ "$line" =~ ^branch[[:space:]]+refs/heads/(.*) ]]; then
    wt_branch="${BASH_REMATCH[1]}"
    if [[ "$wt_branch" == "$target_branch" ]]; then
      cat >&2 <<EOF

Agent spawn BLOCKED — branch collision detected.

Branch: $target_branch
Already checked out in: $wt_path

Two agents cannot share a branch. Either:
  1. Send a message to the existing agent on this branch, or
  2. Remove the stale worktree first: git worktree remove $wt_path
EOF

      cat <<EOF
{
  "hookSpecificOutput": {
    "permissionDecision": "deny",
    "permissionDecisionReason": "Branch '$target_branch' is already checked out in worktree '$wt_path'. Cannot spawn a second agent on the same branch."
  }
}
EOF
      exit 2
    fi
  fi
done < <(git worktree list --porcelain 2>/dev/null)

exit 0

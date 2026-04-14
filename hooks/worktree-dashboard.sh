#!/usr/bin/env bash
# Inject a compact worktree status dashboard into the tech lead's session.
# WHY the tech lead needs visibility into which branches are checked out
# where, and whether agents have uncommitted or unpushed work.
# Only fires in the main worktree (tech lead session).

set -euo pipefail

# Skip if not inside a git repo.
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  exit 0
fi

# Only inject in the main worktree (tech lead), not linked worktrees.
git_dir=$(git rev-parse --git-dir 2>/dev/null || echo ".git")
if [[ "$git_dir" == *"/worktrees/"* ]]; then
  exit 0
fi

worktree_lines=$(git worktree list 2>/dev/null | tail -n +2)
worktree_count=$(echo "$worktree_lines" | grep -c '.' 2>/dev/null || true)
worktree_count=$(echo "$worktree_count" | tr -d '[:space:]')
[[ -z "$worktree_count" ]] && worktree_count=0

if [[ "$worktree_count" -eq 0 ]]; then
  exit 0
fi

dashboard="WORKTREE DASHBOARD ($worktree_count active):"

while IFS= read -r line; do
  [[ -z "$line" ]] && continue

  wt_path=$(echo "$line" | awk '{print $1}')
  wt_branch=$(echo "$line" | grep -oE '\[.*\]' | tr -d '[]')

  # Check for uncommitted changes in the worktree.
  status_flag="clean"
  if [[ -d "$wt_path" ]]; then
    wt_status=$(git -C "$wt_path" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$wt_status" -gt 0 ]]; then
      status_flag="${wt_status} uncommitted"
    fi

    # Check for unpushed commits.
    wt_current=$(git -C "$wt_path" symbolic-ref --short HEAD 2>/dev/null || echo "")
    if [[ -n "$wt_current" ]]; then
      wt_upstream=$(git -C "$wt_path" rev-parse --abbrev-ref "@{upstream}" 2>/dev/null || echo "")
      if [[ -n "$wt_upstream" ]]; then
        unpushed=$(git -C "$wt_path" log "$wt_upstream..HEAD" --oneline 2>/dev/null | wc -l | tr -d ' ')
        if [[ "$unpushed" -gt 0 ]]; then
          status_flag="$status_flag, ${unpushed} unpushed"
        fi
      fi
    fi
  else
    status_flag="PATH MISSING"
  fi

  # Compact one-line summary.
  short_path=$(echo "$wt_path" | sed "s|$HOME|~|")
  dashboard="$dashboard
  $short_path  [$wt_branch]  ($status_flag)"
done <<< "$worktree_lines"

echo "$dashboard"
exit 0

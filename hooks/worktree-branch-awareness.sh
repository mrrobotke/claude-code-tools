#!/usr/bin/env bash
# Inject branch and worktree context at session start.
# WHY agents need to know their branch and location to avoid cross-pollination.
# Runs for every session — main worktree gets tech-lead context, linked
# worktrees get agent-specific branch context.

set -euo pipefail

# Skip if not inside a git repo.
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  exit 0
fi

git_dir=$(git rev-parse --git-dir 2>/dev/null || echo ".git")
worktree_path=$(git rev-parse --show-toplevel 2>/dev/null || echo "unknown")
branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "detached")

if [[ "$git_dir" == *"/worktrees/"* ]]; then
  # Linked worktree — agent context.
  cat <<EOF
WORKTREE AGENT CONTEXT (auto-injected at session start):
  Location: $worktree_path
  Branch: $branch
  Git dir: $git_dir

Rules for this session:
  - You own branch '$branch' exclusively. Never switch branches.
  - Run ALL commands from this worktree: $worktree_path
  - Only edit files relevant to your assigned scope.
  - Commit and push to: origin/$branch
  - If you need to read a file from another branch, use git show — do not merge.
EOF
else
  # Main worktree — tech lead context.
  worktree_count=$(git worktree list 2>/dev/null | wc -l | tr -d ' ')
  worktree_summary=""
  if [[ "$worktree_count" -gt 1 ]]; then
    worktree_summary=$(git worktree list 2>/dev/null | tail -n +2 | \
      while read -r path hash info; do
        echo "  $path $info"
      done)
  fi

  cat <<EOF
MAIN WORKTREE — TECH LEAD SESSION:
  Location: $worktree_path
  Branch: $branch
  Active linked worktrees: $((worktree_count - 1))
EOF

  if [[ -n "$worktree_summary" ]]; then
    echo "$worktree_summary"
  fi

  cat <<EOF

You are the orchestrator. You do NOT write code directly.
All code-writing agents MUST be spawned with isolation: "worktree".
EOF
fi

exit 0

#!/usr/bin/env bash
# Block file edits in the main worktree on any branch.
# WHY agents must always use isolated worktrees — the main checkout is the
# Tech Lead's coordination space, not an implementation surface.

set -euo pipefail

input=$(cat)

# Skip if not inside a git repo.
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  exit 0
fi

# Linked worktrees are isolated checkouts — edits are always allowed there.
git_dir=$(git rev-parse --git-dir 2>/dev/null || echo ".git")
if [[ "$git_dir" == *"/worktrees/"* ]]; then
  exit 0
fi

# We are in the main worktree. Block any repo file edit regardless of branch.
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
if [[ -z "$file_path" ]]; then
  exit 0
fi

repo_root=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
if [[ -z "$repo_root" ]]; then
  exit 0
fi

# Allow edits to files outside the repo (global hooks, global config).
if [[ "$file_path" != "$repo_root"* ]]; then
  exit 0
fi

current_branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "detached")

cat >&2 <<EOF

File edit blocked in main worktree (branch: $current_branch).

File: $file_path

All code changes must happen in an isolated git worktree.
Spawn agents with isolation: "worktree" for implementation work.
The main session coordinates — it does not write code directly.
EOF

cat <<EOF
{
  "hookSpecificOutput": {
    "permissionDecision": "deny",
    "permissionDecisionReason": "Edit blocked: in main worktree (branch: $current_branch). Code-writing agents must use isolation: 'worktree'."
  }
}
EOF
exit 2

#!/bin/bash
# GLOBAL HOOK: Block code edits on base branches (dev, uat, main)
# All code changes must happen on feature branches
# PreToolUse on Edit|Write tools

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

[[ -z "$file_path" ]] && exit 0

# Allow edits to Claude meta-files (NOT worktrees which contain code)
source "$HOME/.claude/hooks/resolve-serena-path.sh"
if is_claude_meta_path "$file_path"; then
  exit 0
fi

# Get branch for the repo that contains the file being edited.
# Walk up from the file's directory to find the nearest existing ancestor
# that is inside a git repo. This handles new files in new directories
# (the target dir may not exist yet) and git worktrees (a linked worktree
# reports a different branch than the main worktree even though the shell
# CWD resets to main).
lookup_dir=$(dirname "$file_path")
current_branch=""
while [[ "$lookup_dir" != "/" && "$lookup_dir" != "." ]]; do
  if [[ -d "$lookup_dir" ]]; then
    branch=$(git -C "$lookup_dir" rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [[ -n "$branch" ]]; then
      current_branch="$branch"
      break
    fi
  fi
  lookup_dir=$(dirname "$lookup_dir")
done
# Final fallback: use shell CWD
if [[ -z "$current_branch" ]]; then
  current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
fi

if [ -z "$current_branch" ]; then
  exit 0  # Not in a git repo
fi

# Block edits on base branches
protected_branches=("dev" "uat" "main" "master" "staging" "production")

for branch in "${protected_branches[@]}"; do
  if [ "$current_branch" = "$branch" ]; then
    echo "{\"decision\":\"block\",\"reason\":\"BLOCKED: Cannot edit files on the '$branch' branch. Switch to a feature branch first. All code changes must happen on feature branches, never directly on base branches (dev/uat/main).\"}"
    exit 0
  fi
done

exit 0

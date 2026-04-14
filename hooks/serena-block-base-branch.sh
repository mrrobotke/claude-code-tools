#!/bin/bash
# PreToolUse hook: Block Serena edits on protected branches (dev, uat, main, etc.)
# Matcher: All Serena write tools
# Mirrors block-edits-on-base-branches.sh but reads relative_path from Serena input

input=$(cat)
source "$HOME/.claude/hooks/resolve-serena-path.sh"

[[ -z "$abs_path" ]] && exit 0

# Allow specific .claude/ meta-files (NOT worktrees which contain code)
if is_claude_meta_path "$abs_path"; then
  exit 0
fi

# Get branch for the repo containing the file being edited
lookup_dir=$(dirname "$abs_path")
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
# Fallback: use project_dir
if [[ -z "$current_branch" ]] && [[ -n "$project_dir" ]]; then
  current_branch=$(git -C "$project_dir" rev-parse --abbrev-ref HEAD 2>/dev/null)
fi

if [[ -z "$current_branch" ]]; then
  exit 0  # Not in a git repo
fi

# Block edits on protected branches
protected_branches=("dev" "uat" "main" "master" "staging" "production")

for branch in "${protected_branches[@]}"; do
  if [[ "$current_branch" == "$branch" ]]; then
    echo "{\"decision\":\"block\",\"reason\":\"BLOCKED: Cannot edit files on the '$branch' branch via Serena. Switch to a feature branch first. All code changes must happen on feature branches, never directly on base branches (dev/uat/main).\"}"
    exit 0
  fi
done

exit 0

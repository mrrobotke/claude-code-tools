#!/bin/bash
# GLOBAL HOOK: Block branch creation in the main worktree
# All branches must be created via git worktree add, not git checkout -b
# PreToolUse on Bash tool

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty')

[[ -z "$command" ]] && exit 0

# Check if command creates a branch
creates_branch=false
if echo "$command" | grep -qE 'git\s+checkout\s+-b\s'; then
  creates_branch=true
fi
if echo "$command" | grep -qE 'git\s+switch\s+-c\s'; then
  creates_branch=true
fi
if echo "$command" | grep -qE 'git\s+branch\s+[^-]'; then
  # git branch <name> creates a branch, but git branch -d/-D deletes
  # Also skip: git branch --list, git branch -a, git branch --show-current
  if ! echo "$command" | grep -qE 'git\s+branch\s+(-d|-D|--delete|--list|-a|--all|--show-current|--merged|--no-merged|-v|-r|--remotes)'; then
    creates_branch=true
  fi
fi

if [ "$creates_branch" = false ]; then
  exit 0
fi

# Check if we're in the main worktree (not a linked worktree)
# In the main worktree, .git is a DIRECTORY
# In a linked worktree, .git is a FILE containing "gitdir: ..."
toplevel=$(git rev-parse --show-toplevel 2>/dev/null)

if [ -z "$toplevel" ]; then
  exit 0  # Not in a git repo
fi

if [ -d "$toplevel/.git" ]; then
  # Main worktree — block branch creation
  echo "{\"decision\":\"block\",\"reason\":\"BLOCKED: Cannot create branches in the main worktree. Use 'git worktree add <path> -b <branch>' to create branches in isolated worktrees. This prevents dirtying the main working directory.\"}"
  exit 0
fi

# Linked worktree — allow branch creation
exit 0

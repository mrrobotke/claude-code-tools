#!/bin/bash
# GLOBAL HOOK: Block agent stop if there are unstaged or uncommitted changes
# Prevents agents from leaving dirty working directories behind
# Stop event hook

# Check if we're in a git repo
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  exit 0
fi

dirty=""

# Check for unstaged changes (modified tracked files not yet staged)
unstaged=$(git diff --name-only 2>/dev/null)
if [[ -n "$unstaged" ]]; then
  count=$(echo "$unstaged" | wc -l | tr -d ' ')
  dirty+="$count unstaged modified file(s). "
fi

# Check for staged but uncommitted changes
staged=$(git diff --cached --name-only 2>/dev/null)
if [[ -n "$staged" ]]; then
  count=$(echo "$staged" | wc -l | tr -d ' ')
  dirty+="$count staged but uncommitted file(s). "
fi

# Check for untracked files in src/, prisma/, test/ (ignore .claude/, node_modules, logs, etc.)
untracked=$(git ls-files --others --exclude-standard -- 'src/' 'prisma/' 'test/' 2>/dev/null)
if [[ -n "$untracked" ]]; then
  count=$(echo "$untracked" | wc -l | tr -d ' ')
  dirty+="$count untracked source file(s). "
fi

if [[ -n "$dirty" ]]; then
  echo "{\"decision\":\"block\",\"reason\":\"BLOCKED: Cannot stop with dirty working directory. ${dirty}Commit your changes before stopping. Do not leave uncommitted work behind.\"}"
  exit 0
fi

exit 0

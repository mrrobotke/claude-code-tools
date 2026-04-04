#!/usr/bin/env bash
# Prevents dangerous git operations, including when buried in compound commands.
# WHY agents bypass prefix-only checks via `cd /path && git checkout branch`.
# Scans the full command string so `cmd && git checkout x` is caught too.

set -euo pipefail

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty')
[[ -z "$command" ]] && exit 0

# Detect linked worktree vs main worktree.
# Linked worktrees have a git-dir path containing "/worktrees/".
git_dir=$(git rev-parse --git-dir 2>/dev/null || echo ".git")
in_worktree=false
[[ "$git_dir" == *"/worktrees/"* ]] && in_worktree=true

# Emit a structured deny response and exit.
deny() {
  local subcommand="$1"
  local reason="$2"
  cat >&2 <<EOF

Git operation blocked for safety.

Command: $command
Blocked subcommand: git $subcommand

Reason: $reason
EOF
  cat <<EOF
{
  "hookSpecificOutput": {
    "permissionDecision": "deny",
    "permissionDecisionReason": "git $subcommand blocked: $reason"
  }
}
EOF
  exit 2
}

# Check whether a git subcommand appears anywhere in the command string.
# Uses word boundaries so `echo "git checkout"` does not false-positive, but
# `cd /path && git checkout branch` is correctly detected.
contains_git() {
  echo "$command" | grep -qE "(^|[;&|[:space:]])git[[:space:]]+$1([[:space:]]|$)"
}

# --- stash -----------------------------------------------------------------
if contains_git "stash"; then
  deny "stash" "stashing hides changes where they are easily forgotten — commit to a branch instead"
fi

# --- destructive rewrites --------------------------------------------------
for sub in reset revert rebase cherry-pick; do
  if contains_git "$sub"; then
    deny "$sub" "potentially destructive history rewrite — requires explicit user authorization"
  fi
done

# --- merge -----------------------------------------------------------------
if contains_git "merge"; then
  deny "merge" "branch merges must be done manually or via an explicit user instruction"
fi

# --- reflog ----------------------------------------------------------------
if contains_git "reflog"; then
  deny "reflog" "reflog access requires explicit user authorization"
fi

# --- branch deletion -------------------------------------------------------
# Allow `git branch` for listing; block only when -d or -D flags are present.
if contains_git "branch"; then
  if echo "$command" | grep -qE "(^|[;&|[:space:]])git[[:space:]]+branch[[:space:]].*-[Dd]"; then
    deny "branch -d/-D" "branch deletion requires explicit user approval"
  fi
fi

# --- tag deletion ----------------------------------------------------------
if contains_git "tag"; then
  if echo "$command" | grep -qE "(^|[;&|[:space:]])git[[:space:]]+tag[[:space:]].*-d"; then
    deny "tag -d" "tag deletion requires explicit user approval"
  fi
fi

# --- checkout / switch -----------------------------------------------------
# Agents spawned with isolation: "worktree" are placed on their branch by the
# platform before they start — they never need to checkout an existing branch.
# Creating a new branch (`checkout -b` / `switch -c`) is allowed only inside a
# linked worktree, never in the main checkout.
if contains_git "checkout" || contains_git "switch"; then
  is_new_branch=false
  if echo "$command" | grep -qE "(^|[;&|[:space:]])git[[:space:]]+checkout[[:space:]]+-b[[:space:]]"; then
    is_new_branch=true
  fi
  if echo "$command" | grep -qE "(^|[;&|[:space:]])git[[:space:]]+switch[[:space:]]+-c[[:space:]]"; then
    is_new_branch=true
  fi

  if [[ "$is_new_branch" == "true" ]]; then
    if [[ "$in_worktree" == "true" ]]; then
      # New branch inside a linked worktree — allowed.
      exit 0
    fi
    deny "checkout -b / switch -c" "branch creation must happen in an isolated worktree — spawn agents with isolation: 'worktree'"
  fi

  # All other checkout/switch (switching to an existing branch) — always blocked.
  deny "checkout/switch" "branch switching requires explicit user approval — agents are pre-placed on their branch by worktree creation"
fi

# All other git subcommands (add, commit, status, diff, log, push, pull,
# show, remote, branch --list, fetch, worktree list, etc.) are allowed.
exit 0

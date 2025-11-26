#!/usr/bin/env bash
# Prevents destructive git operations without explicit user approval
# Blocks checkout reflog stash reset revert rebase merge and other dangerous commands
# WHY security first approach prevents accidental data loss and branch switches

set -euo pipefail

input=$(cat)

command=$(echo "$input" | jq -r '.tool_input.command // empty')

# Only process git commands
if [[ ! "$command" =~ ^git[[:space:]] ]]; then
  exit 0
fi

subcommand=$(echo "$command" | sed -n 's/^git[[:space:]]\+\([^[:space:]]*\).*/\1/p')

case "$subcommand" in
  add|commit|status|diff|log|push|pull|show|remote|branch)
    # Check if branch command has delete flags
    if [[ "$subcommand" == "branch" && "$command" =~ -[Dd] ]]; then
      cat >&2 <<EOF

❌ Git operation blocked for safety

Command: $command

Branch deletion requires explicit user approval.

Blocked operations:
  git branch -d (delete merged branch)
  git branch -D (force delete branch)

If you want to delete a branch:
  1. Manually run the command yourself, OR
  2. Explicitly instruct Claude with confirmation

Reason: Prevents accidental branch deletion and potential code loss.
EOF

      cat <<EOF
{
  "hookSpecificOutput": {
    "permissionDecision": "deny",
    "permissionDecisionReason": "Branch deletion blocked. This operation is potentially destructive. Please run manually if needed."
  }
}
EOF
      exit 2
    fi

    # Allow safe operations
    exit 0
    ;;

  checkout|reflog|stash|reset|revert|rebase|merge|cherry-pick|tag)
    # Check for tag deletion
    if [[ "$subcommand" == "tag" && "$command" =~ -d ]]; then
      cat >&2 <<EOF

❌ Git operation blocked for safety

Command: $command

Tag deletion requires explicit user approval.
EOF

      cat <<EOF
{
  "hookSpecificOutput": {
    "permissionDecision": "deny",
    "permissionDecisionReason": "Tag deletion blocked. Please run manually if needed."
  }
}
EOF
      exit 2
    fi

    # Block all other destructive operations
    cat >&2 <<EOF

❌ Git operation blocked for safety

Command: $command

This operation is potentially destructive and requires explicit user approval.

Blocked operations:
  git checkout    - Switches branches or restores files (can lose uncommitted work)
  git reflog      - Advanced history manipulation
  git stash       - Temporarily hides changes (can be forgotten)
  git reset       - Moves HEAD pointer (can lose commits)
  git revert      - Creates revert commits (usually safe but requires review)
  git rebase      - Rewrites history (dangerous for shared branches)
  git merge       - Combines branches (potential conflicts and history changes)
  git cherry-pick - Applies commits from other branches (can create duplicates)

Allowed operations:
  git add         - Stage changes
  git commit      - Create commits
  git status      - View working tree state
  git diff        - View changes
  git log         - View commit history
  git push        - Push commits to remote
  git pull        - Fetch and merge from remote
  git show        - Show commit details
  git remote      - View/manage remotes
  git branch      - List branches (without -d/-D flags)

To proceed safely:
  1. Review the operation and its impact
  2. Manually run the command if appropriate, OR
  3. Explicitly instruct Claude to run it after confirming safety

Example: "I have reviewed the changes and want to checkout feature-branch. Please proceed."

Reason for blocking: Prevents accidental data loss, branch switches, and history manipulation.
EOF

    cat <<EOF
{
  "hookSpecificOutput": {
    "permissionDecision": "deny",
    "permissionDecisionReason": "Potentially destructive git operation blocked. Operation '$subcommand' requires explicit user authorization. Please review and run manually if needed."
  }
}
EOF
    exit 2
    ;;

  *)
    # Unknown git subcommand - block for safety
    cat >&2 <<EOF

❌ Git operation blocked for safety

Command: $command

Unknown or uncommon git subcommand detected: '$subcommand'

For safety, only explicitly allowed git operations can be run automatically.

If this is a legitimate git command:
  1. Review the command and its potential impact
  2. Manually run it if appropriate

Allowed commands:
  git add, commit, status, diff, log, push, pull, show, remote, branch (list)

Reason for blocking: Unknown commands could be dangerous or have unintended side effects.
EOF

    cat <<EOF
{
  "hookSpecificOutput": {
    "permissionDecision": "deny",
    "permissionDecisionReason": "Unknown git subcommand '$subcommand' blocked for safety. Please run manually if legitimate."
  }
}
EOF
    exit 2
    ;;
esac

#!/usr/bin/env bash
# Inject git worktree instructions into code-writing agent prompts.
# WHY agents must create and work from isolated git worktrees to prevent
# cross-pollination. Using `git worktree add` keeps branches isolated and
# avoids the cleanup issues of `isolation: "worktree"` which can pollute
# the main checkout when agents terminate.

set -euo pipefail

input=$(cat)

tool_name=$(echo "$input" | jq -r '.tool_name // empty')

# Only process Task and Agent tool calls.
case "$tool_name" in
  Task|Agent) ;;
  *) exit 0 ;;
esac

prompt=$(echo "$input" | jq -r '.tool_input.prompt // empty')
subagent_type=$(echo "$input" | jq -r '.tool_input.subagent_type // empty')

# Read-only agent types do not need worktree instructions.
readonly_types=(
  "feature-dev:code-reviewer"
  "feature-dev:code-explorer"
  "feature-dev:code-architect"
  "security-auditor"
  "performance-engineer"
  "pr-review-toolkit:pr-test-analyzer"
  "pr-review-toolkit:type-design-analyzer"
  "pr-review-toolkit:silent-failure-hunter"
  "pr-review-toolkit:code-simplifier"
  "pr-review-toolkit:code-reviewer"
  "pr-review-toolkit:comment-analyzer"
  "atomic-design-architect"
  "Plan"
  "Explore"
)

for ro_type in "${readonly_types[@]}"; do
  if [[ "$subagent_type" == "$ro_type" ]]; then
    exit 0
  fi
done

# Scan prompt for mutation verbs that indicate code-writing intent.
mutation_pattern='\b(fix|implement|edit|create file|write code|modify|apply patch|refactor|update code|commit and push|make changes|add export|remove dead|replace|change the|add.*to|apply.*fixes|rewrite)\b'

if echo "$prompt" | grep -iqE "$mutation_pattern"; then
  # Check if prompt already mentions worktree add
  if echo "$prompt" | grep -qi "worktree add"; then
    exit 0
  fi

  cat <<'EOF'
WORKTREE ISOLATION REQUIRED FOR THIS AGENT:

This agent will write code. It MUST work from an isolated git worktree.

BEFORE any code changes, the agent must:
  1. Create a worktree: git worktree add ../worktrees/<branch-name> -b <branch-name>
  2. cd into the worktree: cd ../worktrees/<branch-name>
  3. Run ALL commands from the worktree directory
  4. Commit and push from the worktree: git push -u origin <branch-name>

NEVER create branches with git checkout -b or git switch -c in the main worktree.
NEVER edit files in the main worktree directly.

The agent prompt MUST include the target branch name and worktree setup as
the FIRST action before any file operations.
EOF
  exit 0
fi

# No mutation keywords detected — allow (likely a reviewer or coordinator).
exit 0

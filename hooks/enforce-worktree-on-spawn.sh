#!/usr/bin/env bash
# Block code-writing agents spawned without isolation: "worktree".
# WHY agents without worktree isolation land in the main checkout and cause
# cross-pollination when they edit files on the wrong branch.

set -euo pipefail

input=$(cat)

tool_name=$(echo "$input" | jq -r '.tool_name // empty')

# Only process Task and Agent tool calls.
case "$tool_name" in
  Task|Agent) ;;
  *) exit 0 ;;
esac

isolation=$(echo "$input" | jq -r '.tool_input.isolation // empty')
prompt=$(echo "$input" | jq -r '.tool_input.prompt // empty')
subagent_type=$(echo "$input" | jq -r '.tool_input.subagent_type // empty')

# Read-only agent types never need worktree isolation.
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

# If isolation is already set to worktree, allow.
if [[ "$isolation" == "worktree" ]]; then
  exit 0
fi

# Scan prompt for mutation verbs that indicate code-writing intent.
mutation_pattern='\b(fix|implement|edit|create file|write code|modify|apply patch|refactor|update code|commit and push|make changes|add export|remove dead|replace|change the|add.*to|apply.*fixes|rewrite)\b'

if echo "$prompt" | grep -iqE "$mutation_pattern"; then
  cat >&2 <<EOF

Agent spawn BLOCKED — missing worktree isolation.

The prompt contains code-mutation intent but isolation: "worktree" is not set.
All code-writing agents MUST be spawned with isolation: "worktree" to prevent
cross-pollination between branches.

Add isolation: "worktree" to the Task/Agent call:
  Agent({
    ...
    isolation: "worktree",
    ...
  })

Read-only agents (reviewers, explorers, planners) do not need isolation.
EOF

  cat <<EOF
{
  "hookSpecificOutput": {
    "permissionDecision": "deny",
    "permissionDecisionReason": "Code-writing agent must be spawned with isolation: 'worktree'. Prompt contains mutation keywords but isolation is not set."
  }
}
EOF
  exit 2
fi

# No mutation keywords detected — allow (likely a reviewer or coordinator).
exit 0

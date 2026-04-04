#!/usr/bin/env bash
# Block agent stop when uncommitted, unstaged, or unpushed changes exist.
# WHY prevents agents from silently abandoning work that hasn't been persisted.

set -euo pipefail

# Skip if not inside a git repo.
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  exit 0
fi

issues=()

# Check for unstaged changes.
if ! git diff --quiet 2>/dev/null; then
  unstaged_count=$(git diff --name-only 2>/dev/null | wc -l | tr -d ' ')
  issues+=("Unstaged changes: $unstaged_count file(s)")
fi

# Check for staged but uncommitted changes.
if ! git diff --cached --quiet 2>/dev/null; then
  staged_count=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
  issues+=("Staged but uncommitted: $staged_count file(s)")
fi

# Check for untracked files (excluding common noise).
untracked=$(git ls-files --others --exclude-standard 2>/dev/null | head -20)
if [[ -n "$untracked" ]]; then
  untracked_count=$(echo "$untracked" | wc -l | tr -d ' ')
  issues+=("Untracked files: $untracked_count file(s)")
fi

# Check for unpushed commits.
current_branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "")
if [[ -n "$current_branch" ]]; then
  upstream=$(git rev-parse --abbrev-ref "@{upstream}" 2>/dev/null || echo "")
  if [[ -n "$upstream" ]]; then
    unpushed=$(git log "$upstream..HEAD" --oneline 2>/dev/null)
    if [[ -n "$unpushed" ]]; then
      unpushed_count=$(echo "$unpushed" | wc -l | tr -d ' ')
      issues+=("Unpushed commits: $unpushed_count on branch '$current_branch'")
    fi
  else
    # Branch has no upstream — all commits are unpushed.
    local_commits=$(git log --oneline 2>/dev/null | head -5)
    if [[ -n "$local_commits" ]]; then
      issues+=("Branch '$current_branch' has no upstream (unpushed)")
    fi
  fi
fi

if [[ ${#issues[@]} -eq 0 ]]; then
  exit 0
fi

# Build the report.
report=""
for issue in "${issues[@]}"; do
  report+="  - $issue\n"
done

cat >&2 <<EOF

Stop blocked: uncommitted or unpushed work detected.

$(echo -e "$report")
Commit and push your changes before stopping, or the work will be lost.
EOF

cat <<EOF
{
  "decision": "block",
  "reason": "Uncommitted or unpushed work detected. Commit and push before stopping."
}
EOF
exit 2

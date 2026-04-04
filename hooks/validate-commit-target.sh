#!/usr/bin/env bash
# Warn when staged files do not match the current branch scope.
# WHY committing auth files while on the support branch is cross-pollination.
# This is a WARN-only hook — it does not block the commit.

set -euo pipefail

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty')

# Only fire when command contains git commit.
if ! echo "$command" | grep -qE "(^|[;&|[:space:]])git[[:space:]]+commit"; then
  exit 0
fi

branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "")
if [[ -z "$branch" ]]; then
  exit 0
fi

# Get staged files.
staged=$(git diff --cached --name-only 2>/dev/null)
if [[ -z "$staged" ]]; then
  exit 0
fi

# Extract scope hint from branch name.
# feat/270-276-auth → auth
# feat/272-279-support → support
# feat/271-277-278-employer → employer
# feat/273-274-280-misc → misc (skip check, broad scope)
scope=""
if [[ "$branch" =~ auth ]]; then
  scope="auth"
  scope_pattern='(auth)'
elif [[ "$branch" =~ support ]]; then
  scope="support"
  scope_pattern='(support)'
elif [[ "$branch" =~ employer ]]; then
  scope="employer"
  scope_pattern='(employer)'
elif [[ "$branch" =~ job-seeker|seeker ]]; then
  scope="job-seeker"
  scope_pattern='(job-seeker)'
elif [[ "$branch" =~ admin ]]; then
  scope="admin"
  scope_pattern='(admin)'
elif [[ "$branch" =~ marketing ]]; then
  scope="marketing"
  scope_pattern='(marketing)'
fi

# If no recognizable scope or broad scope (misc), skip check.
if [[ -z "$scope" ]]; then
  exit 0
fi

# Count files that match vs don't match the scope.
# Shared files (design-system, lib, config) are always acceptable.
shared_pattern='(design-system|/lib/|tailwind|globals\.css|package\.json|tsconfig)'
mismatch_files=""
mismatch_count=0
total_count=0

while IFS= read -r file; do
  [[ -z "$file" ]] && continue
  total_count=$((total_count + 1))

  # Shared files are always allowed.
  if echo "$file" | grep -qE "$shared_pattern"; then
    continue
  fi

  # Check if file matches the branch scope.
  if ! echo "$file" | grep -qE "$scope_pattern"; then
    mismatch_count=$((mismatch_count + 1))
    mismatch_files="$mismatch_files  - $file\n"
  fi
done <<< "$staged"

if [[ "$mismatch_count" -gt 0 ]]; then
  cat >&2 <<EOF

CROSS-POLLINATION WARNING

Branch: $branch (scope: $scope)
$mismatch_count of $total_count staged files are outside the expected scope:
$(echo -e "$mismatch_files")
These files may belong to a different branch. Double-check before committing.
If intentional (shared utility, cross-cutting concern), proceed.
EOF
fi

# Warn only — do not block.
exit 0

#!/usr/bin/env bash
# git-commit-validator.sh – Enforce conventional commit standards
# Blocks commits with co-authored-by credits and validates commit message format
# Auto-commits dirty working tree before allowing new work

set -euo pipefail

# Read the hook input from stdin
input=$(cat)

# Extract the git command from the JSON input
command=$(echo "$input" | jq -r '.tool_input.command // empty')

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  exit 0
fi

# Check for dirty working tree BEFORE processing commit command
# WHY ensures all work is committed before starting new tasks
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
  echo "" >&2
  echo "📝 Dirty working tree detected" >&2
  echo "   Reviewing changes and creating auto-commit..." >&2
  echo "" >&2

  # Get list of modified/new files
  changed_files=$(git diff --name-only HEAD 2>/dev/null || echo "")
  untracked_files=$(git ls-files --others --exclude-standard 2>/dev/null || echo "")

  if [ -z "$changed_files" ] && [ -z "$untracked_files" ]; then
    # No changes, continue
    :
  else
    # Filter out .md, .log, .txt files
    files_to_add=""

    # Process modified files
    if [ -n "$changed_files" ]; then
      while IFS= read -r file; do
        if [[ ! "$file" =~ \.(md|log|txt)$ ]]; then
          files_to_add="$files_to_add $file"
        fi
      done <<< "$changed_files"
    fi

    # Process untracked files
    if [ -n "$untracked_files" ]; then
      while IFS= read -r file; do
        if [[ ! "$file" =~ \.(md|log|txt)$ ]]; then
          files_to_add="$files_to_add $file"
        fi
      done <<< "$untracked_files"
    fi

    # Trim whitespace
    files_to_add=$(echo "$files_to_add" | xargs)

    if [ -n "$files_to_add" ]; then
      echo "   Files to commit:" >&2
      echo "$files_to_add" | tr ' ' '\n' | sed 's/^/     - /' >&2
      echo "" >&2

      # Add files
      for file in $files_to_add; do
        git add "$file" 2>/dev/null || true
      done

      # Generate commit message based on changed files
      commit_type="chore"
      commit_scope=""

      # Detect commit type from file changes
      if echo "$files_to_add" | grep -qE '\.(test|spec)\.(tsx?|jsx?)$'; then
        commit_type="test"
        commit_scope="tests"
      elif echo "$files_to_add" | grep -qE 'components?/'; then
        commit_type="feat"
        commit_scope="components"
      elif echo "$files_to_add" | grep -qE 'hooks?/'; then
        commit_type="feat"
        commit_scope="hooks"
      elif echo "$files_to_add" | grep -qE '\.(tsx?|jsx?)$'; then
        commit_type="feat"
        commit_scope="ui"
      fi

      # Create descriptive commit message
      num_files=$(echo "$files_to_add" | wc -w | xargs)
      auto_commit_msg="${commit_type}"
      if [ -n "$commit_scope" ]; then
        auto_commit_msg="${auto_commit_msg}(${commit_scope})"
      fi
      auto_commit_msg="${auto_commit_msg}: auto-commit ${num_files} file(s) before new work"

      # Create commit
      if git commit -m "$auto_commit_msg" --no-verify 2>/dev/null; then
        echo "✅ Auto-commit created successfully" >&2
        echo "   Message: $auto_commit_msg" >&2
        echo "" >&2
      else
        echo "⚠️  Auto-commit failed, but continuing..." >&2
        echo "" >&2
      fi
    else
      echo "   All changes are in excluded files (.md, .log, .txt)" >&2
      echo "   Skipping auto-commit" >&2
      echo "" >&2
    fi
  fi
fi

# Only process git commit commands
if [[ ! "$command" =~ ^git[[:space:]]+commit ]]; then
  exit 0
fi

# Extract commit message from the command
# Handle both -m "message" and heredoc formats
if [[ "$command" =~ -m[[:space:]]*[\"\'](.*)[\"\'] ]]; then
  commit_msg="${BASH_REMATCH[1]}"
else
  # For heredoc, extract the message between << and EOF
  commit_msg=$(echo "$command" | sed -n '/<<.*EOF/,/^EOF/p' | sed '1d;$d')
fi

# Check for co-authored-by or authored by (case insensitive)
if echo "$commit_msg" | grep -iE "(co-)?authored.?by" > /dev/null; then
  cat >&2 <<EOF
❌ Commit message validation failed:
   Co-authored-by and authored-by credits are not allowed.
   
   Please remove any authorship credits from the commit message.
EOF
  
  # Return JSON to block the commit
  cat <<EOF
{
  "hookSpecificOutput": {
    "permissionDecision": "deny",
    "permissionDecisionReason": "Commit message contains disallowed authorship credits (co-authored-by or authored-by). Please remove these and try again."
  }
}
EOF
  exit 2
fi

# Validate conventional commit format: type(scope): description
if ! echo "$commit_msg" | grep -E "^(feat|fix|docs|style|refactor|test|chore|ci|perf|build|revert)(\(.+\))?!?: .+" > /dev/null; then
  cat >&2 <<EOF
❌ Commit message validation failed:
   Message must follow Conventional Commits format.
   
   Format: <type>(<scope>): <description>
   
   Valid types: feat, fix, docs, style, refactor, test, chore, ci, perf, build, revert
   
   Examples:
   - feat(auth): add login functionality
   - fix: resolve null pointer exception
   - docs(readme): update installation steps
EOF
  
  cat <<EOF
{
  "hookSpecificOutput": {
    "permissionDecision": "deny",
    "permissionDecisionReason": "Commit message does not follow Conventional Commits format. Use: type(scope): description"
  }
}
EOF
  exit 2
fi

# All checks passed
echo "✅ Commit message validation passed" >&2
exit 0
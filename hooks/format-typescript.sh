#!/bin/bash
# PostToolUse hook: Auto-format TypeScript files after Edit/Write/MultiEdit or Serena edits.
# Matcher: Edit|Write|MultiEdit + Serena write tools

set -euo pipefail

# Resolve file path from native tools (file_path) or Serena tools (relative_path).
resolve_file_path() {
  local fp rp git_root found

  fp=$(echo "$1" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
  if [[ -n "$fp" ]] && [[ -f "$fp" ]]; then
    echo "$fp"
    return
  fi

  rp=$(echo "$1" | jq -r '.tool_input.relative_path // empty' 2>/dev/null)
  if [[ -z "$rp" ]]; then
    return
  fi

  # Try relative to CWD.
  if [[ -f "$rp" ]]; then
    realpath "$rp" 2>/dev/null && return
  fi

  # Try git root and subdirectories.
  git_root=$(git rev-parse --show-toplevel 2>/dev/null) || return
  if [[ -f "$git_root/$rp" ]]; then
    echo "$git_root/$rp"
    return
  fi

  found=$(find "$git_root" -path "*/$rp" -type f 2>/dev/null | head -1)
  if [[ -n "$found" ]]; then
    echo "$found"
    return
  fi
}

INPUT=$(cat)
FILE_PATH=$(resolve_file_path "$INPUT")

[[ -z "$FILE_PATH" ]] && exit 0
[[ ! -f "$FILE_PATH" ]] && exit 0

# Only format TypeScript/JavaScript files in the NestJS project.
if [[ "$FILE_PATH" =~ IgnixxionNestAPI.*\.(ts|js|tsx|jsx)$ ]] && [ -f "$FILE_PATH" ]; then
  cd /Users/antonyngigge/Ignixxion/ignixxion-apps/IgnixxionNestAPI
  npx prettier --write "$FILE_PATH" 2>/dev/null || true
  echo "Formatted: $FILE_PATH" >&2
fi

exit 0

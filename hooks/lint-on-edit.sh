#!/bin/bash
# PostToolUse hook: Auto-lint files after Edit/Write/MultiEdit or Serena edits.
# Global hook — detects project linter and runs it on changed files.

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

  if [[ -f "$rp" ]]; then
    realpath "$rp" 2>/dev/null && return
  fi

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

[ -z "$FILE_PATH" ] && exit 0
[ ! -f "$FILE_PATH" ] && exit 0

# Find project root (nearest package.json or pyproject.toml).
find_root() {
  local dir
  dir=$(dirname "$1")
  while [ "$dir" != "/" ]; do
    [ -f "$dir/package.json" ] || [ -f "$dir/pyproject.toml" ] && echo "$dir" && return
    dir=$(dirname "$dir")
  done
}

ROOT=$(find_root "$FILE_PATH")
[ -z "$ROOT" ] && exit 0

case "$FILE_PATH" in
  *.ts|*.tsx|*.js|*.jsx|*.css|*.json)
    # Format first, then lint.
    if [ -x "$ROOT/node_modules/.bin/prettier" ]; then
      "$ROOT/node_modules/.bin/prettier" --write "$FILE_PATH" --ignore-unknown 2>/dev/null || true
    fi
    # ESLint only on JS/TS files.
    case "$FILE_PATH" in
      *.ts|*.tsx|*.js|*.jsx)
        if [ -x "$ROOT/node_modules/.bin/eslint" ]; then
          "$ROOT/node_modules/.bin/eslint" "$FILE_PATH" --fix 2>/dev/null || true
        fi
        ;;
    esac
    ;;
  *.py)
    if command -v ruff >/dev/null 2>&1; then
      ruff check "$FILE_PATH" --fix 2>/dev/null || true
      ruff format "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
esac

exit 0

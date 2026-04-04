#!/bin/bash
# PostToolUse hook: Auto-lint files after Edit/Write/MultiEdit
# Global hook — detects project linter and runs it on changed files.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

[ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ] && exit 0

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

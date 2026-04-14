#!/bin/bash
# PostToolUse hook: Auto-format files after Serena edit operations
# Matcher: All Serena write tools
# Mirrors auto-format.sh but resolves relative_path from Serena input

input=$(cat)
source "$HOME/.claude/hooks/resolve-serena-path.sh"

[[ -z "$abs_path" ]] && exit 0
[[ ! -f "$abs_path" ]] && exit 0

# Python files - use ruff + mypy
if [[ "$abs_path" == *.py ]]; then
  # Format with ruff
  if command -v ruff &> /dev/null; then
    ruff format "$abs_path" 2>/dev/null
    ruff check --fix "$abs_path" 2>/dev/null
  fi

  # Type check with mypy
  if command -v mypy &> /dev/null; then
    mypy_output=$(mypy "$abs_path" --no-error-summary 2>/dev/null)
    if [[ -n "$mypy_output" ]] && [[ "$mypy_output" != *"Success"* ]]; then
      echo "mypy issues in $relative_path:"
      echo "$mypy_output"
    fi
  elif command -v poetry &> /dev/null; then
    mypy_output=$(poetry run mypy "$abs_path" --no-error-summary 2>/dev/null)
    if [[ -n "$mypy_output" ]] && [[ "$mypy_output" != *"Success"* ]]; then
      echo "mypy issues in $relative_path:"
      echo "$mypy_output"
    fi
  fi
fi

# TypeScript/JavaScript - use prettier if available
if [[ "$abs_path" == *.ts ]] || [[ "$abs_path" == *.tsx ]] || [[ "$abs_path" == *.js ]] || [[ "$abs_path" == *.jsx ]]; then
  if command -v npx &> /dev/null; then
    npx prettier --write "$abs_path" 2>/dev/null
  fi
fi

# JSON files
if [[ "$abs_path" == *.json ]]; then
  if command -v npx &> /dev/null; then
    npx prettier --write "$abs_path" 2>/dev/null
  fi
fi

exit 0

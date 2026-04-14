#!/bin/bash
# Auto-format files after Claude edits them
# Supports Python (ruff), TypeScript/JS (prettier), JSON

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

[[ -z "$file_path" ]] && exit 0
[[ ! -f "$file_path" ]] && exit 0

# Python files - use ruff + mypy
if [[ "$file_path" == *.py ]]; then
  # Format with ruff
  if command -v ruff &> /dev/null; then
    ruff format "$file_path" 2>/dev/null
    ruff check --fix "$file_path" 2>/dev/null
  fi

  # Type check with mypy (show errors to Claude)
  if command -v mypy &> /dev/null; then
    mypy_output=$(mypy "$file_path" --no-error-summary 2>/dev/null)
    if [[ -n "$mypy_output" ]] && [[ "$mypy_output" != *"Success"* ]]; then
      echo "mypy issues in $file_path:"
      echo "$mypy_output"
    fi
  elif command -v poetry &> /dev/null; then
    mypy_output=$(poetry run mypy "$file_path" --no-error-summary 2>/dev/null)
    if [[ -n "$mypy_output" ]] && [[ "$mypy_output" != *"Success"* ]]; then
      echo "mypy issues in $file_path:"
      echo "$mypy_output"
    fi
  fi
fi

# TypeScript/JavaScript - use prettier if available
if [[ "$file_path" == *.ts ]] || [[ "$file_path" == *.tsx ]] || [[ "$file_path" == *.js ]] || [[ "$file_path" == *.jsx ]]; then
  if command -v npx &> /dev/null; then
    npx prettier --write "$file_path" 2>/dev/null
  fi
fi

# JSON files
if [[ "$file_path" == *.json ]]; then
  if command -v npx &> /dev/null; then
    npx prettier --write "$file_path" 2>/dev/null
  fi
fi

exit 0

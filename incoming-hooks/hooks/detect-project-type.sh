#!/bin/bash
# Detects project type from file extension and project files
# Outputs: python, typescript, javascript, react-native, or unknown

file_path="${1:-}"
project_dir="${2:-$(pwd)}"

# If file path provided, detect from extension
if [[ -n "$file_path" ]]; then
  case "$file_path" in
    *.py) echo "python"; exit 0 ;;
    *.ts|*.tsx)
      # Check if React Native
      if [[ -f "$project_dir/package.json" ]] && grep -q '"react-native"' "$project_dir/package.json" 2>/dev/null; then
        echo "react-native"
      else
        echo "typescript"
      fi
      exit 0
      ;;
    *.js|*.jsx)
      if [[ -f "$project_dir/package.json" ]] && grep -q '"react-native"' "$project_dir/package.json" 2>/dev/null; then
        echo "react-native"
      else
        echo "javascript"
      fi
      exit 0
      ;;
  esac
fi

# Fallback: detect from project files
if [[ -f "$project_dir/pyproject.toml" ]] || [[ -f "$project_dir/requirements.txt" ]]; then
  echo "python"
elif [[ -f "$project_dir/package.json" ]]; then
  if grep -q '"react-native"' "$project_dir/package.json" 2>/dev/null; then
    echo "react-native"
  elif grep -q '"typescript"' "$project_dir/package.json" 2>/dev/null; then
    echo "typescript"
  else
    echo "javascript"
  fi
else
  echo "unknown"
fi

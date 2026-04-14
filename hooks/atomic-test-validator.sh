#!/usr/bin/env bash
# Validates test coverage for atomic components.
# Templates and pages require tests while atoms and molecules get warnings.
# WHY testing requirements scale with component complexity and criticality.

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

input=$(cat)
file_path=$(resolve_file_path "$input")

[[ -z "$file_path" ]] && exit 0

# Only validate React component files.
if [[ ! "$file_path" =~ \.(tsx|jsx)$ ]]; then
  exit 0
fi

# Skip test files themselves.
if [[ "$file_path" =~ \.(test|spec)\.(tsx|jsx)$ ]]; then
  exit 0
fi

# Skip index files.
if [[ "$file_path" =~ /index\.(tsx|jsx)$ ]]; then
  exit 0
fi

# Skip type definition files.
if [[ "$file_path" =~ \.types\.(tsx|ts)$ ]]; then
  exit 0
fi

# Detect atomic level.
atomic_level=""
if [[ "$file_path" =~ /atoms/ ]]; then
  atomic_level="atom"
elif [[ "$file_path" =~ /molecules/ ]]; then
  atomic_level="molecule"
elif [[ "$file_path" =~ /organisms/ ]]; then
  atomic_level="organism"
elif [[ "$file_path" =~ /templates/ ]]; then
  atomic_level="template"
elif [[ "$file_path" =~ /pages/ ]]; then
  atomic_level="page"
else
  exit 0
fi

# Construct possible test file paths.
dir_path=$(dirname "$file_path")
base_name=$(basename "$file_path" .tsx)
base_name=$(basename "$base_name" .jsx)

test_file_1="${dir_path}/${base_name}.test.tsx"
test_file_2="${dir_path}/${base_name}.test.jsx"
test_file_3="${dir_path}/${base_name}.spec.tsx"
test_file_4="${dir_path}/${base_name}.spec.jsx"

test_exists=false
test_file=""

if [ -f "$test_file_1" ]; then
  test_exists=true
  test_file="$test_file_1"
elif [ -f "$test_file_2" ]; then
  test_exists=true
  test_file="$test_file_2"
elif [ -f "$test_file_3" ]; then
  test_exists=true
  test_file="$test_file_3"
elif [ -f "$test_file_4" ]; then
  test_exists=true
  test_file="$test_file_4"
fi

get_min_test_count() {
  case "$1" in
    atom) echo 3 ;;
    molecule) echo 4 ;;
    organism) echo 5 ;;
    template) echo 6 ;;
    page) echo 8 ;;
    *) echo 3 ;;
  esac
}

check_test_adequacy() {
  local tf=$1
  local min=$2

  [ ! -f "$tf" ] && return 1

  test_count=$(grep -cE "^\s*(it|test)\s*\(" "$tf" || echo 0)
  has_render=$(grep -q "render(" "$tf" && echo "yes" || echo "no")
  has_expect=$(grep -q "expect(" "$tf" && echo "yes" || echo "no")

  if [ "$test_count" -lt "$min" ] || [ "$has_render" = "no" ] || [ "$has_expect" = "no" ]; then
    return 1
  fi
  return 0
}

min_tests=$(get_min_test_count "$atomic_level")

if [ "$test_exists" = false ]; then
  case "$atomic_level" in
    atom|molecule|organism)
      cat >&2 <<EOF

Missing tests (warning)

File: $file_path
Level: ${atomic_level^}
Expected: $test_file_1

Tests are recommended for ${atomic_level}s.

EOF
      exit 0
      ;;

    template|page)
      cat >&2 <<EOF

MISSING REQUIRED TESTS

File: $file_path
Level: ${atomic_level^}
Expected: $test_file_1

${atomic_level^}s MUST have tests (minimum $min_tests test cases).
Create the test file before proceeding.

EOF

      cat <<EOF
{
  "hookSpecificOutput": {
    "permissionDecision": "deny",
    "permissionDecisionReason": "${atomic_level^}s require tests. Create ${test_file_1} before proceeding."
  }
}
EOF
      exit 2
      ;;
  esac
fi

if ! check_test_adequacy "$test_file" "$min_tests"; then
  cat >&2 <<EOF

Inadequate test coverage (warning)

File: $file_path
Test: $test_file
Level: ${atomic_level^}
Minimum: $min_tests test cases with render() and expect()

EOF
  exit 0
fi

exit 0

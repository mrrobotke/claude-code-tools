#!/bin/bash
# Auto-CI Hook: Runs appropriate lints, types, and tests based on project type
# Triggered after Edit/Write operations

set -o pipefail

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
project_dir=$(echo "$input" | jq -r '.cwd // empty')

[[ -z "$file_path" ]] && exit 0
[[ ! -f "$file_path" ]] && exit 0

# Change to project directory if provided
if [[ -n "$project_dir" ]]; then
  cd "$project_dir" 2>/dev/null || true
fi

# Detect project type
PROJECT_TYPE=$("$HOME/.claude/hooks/detect-project-type.sh" "$file_path" "$(pwd)")

output=""

case "$PROJECT_TYPE" in
  python)
    output+="🐍 PYTHON QUALITY CHECK: $file_path\n"
    output+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"

    # Ruff lint
    if command -v ruff &>/dev/null || [[ -f "pyproject.toml" ]]; then
      output+="\n📋 RUFF LINT:\n"
      ruff_out=$(poetry run ruff check "$file_path" 2>&1 || ruff check "$file_path" 2>&1)
      if [[ -z "$ruff_out" ]] || [[ "$ruff_out" == *"All checks passed"* ]]; then
        output+="✅ Clean\n"
      else
        output+="❌ Issues:\n$ruff_out\n"
      fi
    fi

    # Mypy type check
    if command -v mypy &>/dev/null || [[ -f "pyproject.toml" ]]; then
      output+="\n🔍 MYPY TYPE CHECK:\n"
      mypy_out=$(poetry run mypy "$file_path" --no-error-summary 2>&1 || mypy "$file_path" --no-error-summary 2>&1)
      if [[ -z "$mypy_out" ]] || [[ "$mypy_out" == *"Success"* ]]; then
        output+="✅ Clean\n"
      else
        output+="❌ Type errors:\n$mypy_out\n"
      fi
    fi

    # Pytest (quick check)
    if [[ -f "pyproject.toml" ]] || [[ -f "pytest.ini" ]] || [[ -d "tests" ]]; then
      output+="\n🧪 PYTEST (quick):\n"
      pytest_out=$(poetry run pytest -x --tb=short -q 2>&1 | tail -20 || pytest -x --tb=short -q 2>&1 | tail -20)
      if [[ "$pytest_out" == *"passed"* ]] && [[ "$pytest_out" != *"failed"* ]] && [[ "$pytest_out" != *"error"* ]]; then
        output+="✅ Tests passing\n"
      else
        output+="❌ Test results:\n$pytest_out\n"
      fi
    fi
    ;;

  typescript|javascript|react-native)
    output+="📦 ${PROJECT_TYPE^^} QUALITY CHECK: $file_path\n"
    output+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"

    # Detect package manager
    if [[ -f "pnpm-lock.yaml" ]]; then
      PM="pnpm"
    elif [[ -f "yarn.lock" ]]; then
      PM="yarn"
    else
      PM="npm"
    fi

    # ESLint / Biome
    if [[ -f "package.json" ]]; then
      output+="\n📋 LINT:\n"
      if grep -q '"lint"' package.json 2>/dev/null; then
        lint_out=$($PM run lint 2>&1 | tail -30)
        if [[ -z "$lint_out" ]] || [[ "$lint_out" != *"error"* ]]; then
          output+="✅ Clean\n"
        else
          output+="❌ Issues:\n$lint_out\n"
        fi
      else
        output+="⚠️ No lint script found\n"
      fi
    fi

    # TypeScript check
    if [[ -f "tsconfig.json" ]]; then
      output+="\n🔍 TYPE CHECK:\n"
      if grep -q '"typecheck"' package.json 2>/dev/null; then
        tsc_out=$($PM run typecheck 2>&1 | tail -30)
      else
        tsc_out=$(npx tsc --noEmit 2>&1 | tail -30)
      fi
      if [[ -z "$tsc_out" ]] || [[ "$tsc_out" != *"error"* ]]; then
        output+="✅ Clean\n"
      else
        output+="❌ Type errors:\n$tsc_out\n"
      fi
    fi

    # Tests
    if grep -q '"test"' package.json 2>/dev/null; then
      output+="\n🧪 TESTS:\n"
      test_out=$($PM test --passWithNoTests 2>&1 | tail -30 || $PM test 2>&1 | tail -30)
      if [[ "$test_out" == *"pass"* ]] || [[ "$test_out" == *"Pass"* ]]; then
        output+="✅ Tests passing\n"
      elif [[ "$test_out" == *"fail"* ]] || [[ "$test_out" == *"FAIL"* ]]; then
        output+="❌ Test failures:\n$test_out\n"
      else
        output+="⚠️ Test output:\n$test_out\n"
      fi
    fi
    ;;

  *)
    exit 0
    ;;
esac

# Output results for Claude to see
if [[ -n "$output" ]]; then
  echo -e "$output"
fi

exit 0

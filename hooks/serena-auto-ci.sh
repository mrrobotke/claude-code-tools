#!/bin/bash
# PostToolUse hook: Auto-CI after Serena edit operations
# Matcher: All Serena write tools
# Mirrors auto-ci.sh but resolves relative_path from Serena input

set -o pipefail

input=$(cat)
source "$HOME/.claude/hooks/resolve-serena-path.sh"

[[ -z "$abs_path" ]] && exit 0
[[ ! -f "$abs_path" ]] && exit 0

# Change to project directory
if [[ -n "$project_dir" ]]; then
  cd "$project_dir" 2>/dev/null || true
fi

# Detect project type
PROJECT_TYPE=$("$HOME/.claude/hooks/detect-project-type.sh" "$abs_path" "$(pwd)")

output=""

case "$PROJECT_TYPE" in
  python)
    output+="PYTHON QUALITY CHECK (Serena): $relative_path\n"
    output+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"

    # Ruff lint
    if command -v ruff &>/dev/null || [[ -f "pyproject.toml" ]]; then
      output+="\nRUFF LINT:\n"
      ruff_out=$(poetry run ruff check "$abs_path" 2>&1 || ruff check "$abs_path" 2>&1)
      if [[ -z "$ruff_out" ]] || [[ "$ruff_out" == *"All checks passed"* ]]; then
        output+="PASS: Clean\n"
      else
        output+="FAIL: Issues:\n$ruff_out\n"
      fi
    fi

    # Mypy type check
    if command -v mypy &>/dev/null || [[ -f "pyproject.toml" ]]; then
      output+="\nMYPY TYPE CHECK:\n"
      mypy_out=$(poetry run mypy "$abs_path" --no-error-summary 2>&1 || mypy "$abs_path" --no-error-summary 2>&1)
      if [[ -z "$mypy_out" ]] || [[ "$mypy_out" == *"Success"* ]]; then
        output+="PASS: Clean\n"
      else
        output+="FAIL: Type errors:\n$mypy_out\n"
      fi
    fi

    # Pytest (quick check)
    if [[ -f "pyproject.toml" ]] || [[ -f "pytest.ini" ]] || [[ -d "tests" ]]; then
      output+="\nPYTEST (quick):\n"
      pytest_out=$(poetry run pytest -x --tb=short -q 2>&1 | tail -20 || pytest -x --tb=short -q 2>&1 | tail -20)
      if [[ "$pytest_out" == *"passed"* ]] && [[ "$pytest_out" != *"failed"* ]] && [[ "$pytest_out" != *"error"* ]]; then
        output+="PASS: Tests passing\n"
      else
        output+="FAIL: Test results:\n$pytest_out\n"
      fi
    fi
    ;;

  typescript|javascript|react-native)
    output+="${PROJECT_TYPE^^} QUALITY CHECK (Serena): $relative_path\n"
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
      output+="\nLINT:\n"
      if grep -q '"lint"' package.json 2>/dev/null; then
        lint_out=$($PM run lint 2>&1 | tail -30)
        if [[ -z "$lint_out" ]] || [[ "$lint_out" != *"error"* ]]; then
          output+="PASS: Clean\n"
        else
          output+="FAIL: Issues:\n$lint_out\n"
        fi
      else
        output+="SKIP: No lint script found\n"
      fi
    fi

    # TypeScript check
    if [[ -f "tsconfig.json" ]]; then
      output+="\nTYPE CHECK:\n"
      if grep -q '"typecheck"' package.json 2>/dev/null; then
        tsc_out=$($PM run typecheck 2>&1 | tail -30)
      else
        tsc_out=$(npx tsc --noEmit 2>&1 | tail -30)
      fi
      if [[ -z "$tsc_out" ]] || [[ "$tsc_out" != *"error"* ]]; then
        output+="PASS: Clean\n"
      else
        output+="FAIL: Type errors:\n$tsc_out\n"
      fi
    fi

    # Tests
    if grep -q '"test"' package.json 2>/dev/null; then
      output+="\nTESTS:\n"
      test_out=$($PM test --passWithNoTests 2>&1 | tail -30 || $PM test 2>&1 | tail -30)
      if [[ "$test_out" == *"pass"* ]] || [[ "$test_out" == *"Pass"* ]]; then
        output+="PASS: Tests passing\n"
      elif [[ "$test_out" == *"fail"* ]] || [[ "$test_out" == *"FAIL"* ]]; then
        output+="FAIL: Test failures:\n$test_out\n"
      else
        output+="INFO: Test output:\n$test_out\n"
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

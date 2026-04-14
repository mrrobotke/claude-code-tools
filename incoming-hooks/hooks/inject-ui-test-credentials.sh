#!/bin/bash
# UserPromptSubmit Hook: Inject UI test credentials location when relevant
# Fires only when ALL conditions are true:
#   1. CWD has package.json (frontend/fullstack project)
#   2. .env.local exists with TEST_USER entry (credentials available)
#   3. Prompt mentions UI testing context (test/e2e/login/playwright/cypress)

input=$(cat)
prompt=$(echo "$input" | jq -r '.prompt // empty')
cwd=$(echo "$input" | jq -r '.cwd // empty')

[[ -z "$prompt" ]] && exit 0
[[ -z "$cwd" ]] && cwd="$(pwd)"

# Condition 1: frontend/fullstack project
[[ ! -f "$cwd/package.json" ]] && exit 0

# Condition 2: test credentials are available
[[ ! -f "$cwd/.env.local" ]] && exit 0
grep -q "TEST_USER" "$cwd/.env.local" 2>/dev/null || exit 0

# Condition 3: prompt is about UI testing
prompt_lower=$(echo "$prompt" | tr '[:upper:]' '[:lower:]')
inject=false
for kw in "test" "e2e" "login" "credential" "playwright" "cypress" "ui test"; do
  if [[ "$prompt_lower" == *"$kw"* ]]; then
    inject=true
    break
  fi
done

[[ "$inject" != true ]] && exit 0

cat << 'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "UI TEST CREDENTIALS:\nTest credentials are in .env.local under '# Test Credentials':\n  TEST_USER and TEST_PASS entries\nRead with: grep \"TEST_USER\\|TEST_PASS\" .env.local\nNever hardcode these values — always read from .env.local."
  }
}
EOF

exit 0

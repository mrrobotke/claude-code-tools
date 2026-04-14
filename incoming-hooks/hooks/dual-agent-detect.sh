#!/bin/bash
# UserPromptSubmit Hook: Detects code change tasks and injects dual-agent instructions
# Triggers for: feature development, bug fixes, refactoring, any code changes

input=$(cat)
prompt=$(echo "$input" | jq -r '.prompt // empty')

[[ -z "$prompt" ]] && exit 0

# Convert to lowercase for matching
prompt_lower=$(echo "$prompt" | tr '[:upper:]' '[:lower:]')

# Keywords that indicate code changes
CODE_CHANGE_KEYWORDS=(
  "implement"
  "add feature"
  "create"
  "build"
  "develop"
  "write code"
  "fix bug"
  "fix the"
  "debug"
  "refactor"
  "update"
  "modify"
  "change"
  "edit"
  "add method"
  "add function"
  "add endpoint"
  "add route"
  "add component"
  "add screen"
  "add test"
  "migrate"
  "upgrade"
  "convert"
)

# Check if prompt contains code change keywords
is_code_change=false
for keyword in "${CODE_CHANGE_KEYWORDS[@]}"; do
  if [[ "$prompt_lower" == *"$keyword"* ]]; then
    is_code_change=true
    break
  fi
done

# If code change detected, inject dual-agent instructions
if [[ "$is_code_change" == true ]]; then
  cat << 'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "DUAL-AGENT WORKFLOW ACTIVATED:

For this code change task, use the dual-agent pattern:

1. IMPLEMENTATION PHASE:
   - Use the code-writer agent to implement changes
   - Focus on clean, typed code following project conventions
   - Run tests after implementation

2. REVIEW PHASE:
   - Use the code-reviewer agent to review the changes
   - Check for: logic errors, security issues, edge cases, style violations
   - Get specific feedback with file:line references

3. ITERATION:
   - If reviewer finds issues, delegate back to code-writer
   - Continue until reviewer approves

4. VERIFICATION:
   - Ensure all lints pass (ruff/eslint)
   - Ensure all types pass (mypy/tsc)
   - Ensure all tests pass

To invoke agents:
- 'Use the code-writer agent to implement X'
- 'Use the code-reviewer agent to review the changes'

Do NOT skip the review phase. Quality over speed."
  }
}
EOF
else
  exit 0
fi

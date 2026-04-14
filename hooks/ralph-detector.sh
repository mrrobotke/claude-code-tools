#!/bin/bash
# UserPromptSubmit Hook: Detects complex prompts (>100 words) and activates Ralph Loop
# Creates completion criteria and injects Ralph instructions

input=$(cat)
prompt=$(echo "$input" | jq -r '.prompt // empty')

[[ -z "$prompt" ]] && exit 0

# Count words in prompt
word_count=$(echo "$prompt" | wc -w | tr -d ' ')

# Also check for explicit Ralph activation
prompt_lower=$(echo "$prompt" | tr '[:upper:]' '[:lower:]')
explicit_ralph=false
if [[ "$prompt_lower" == *"ralph"* ]] || [[ "$prompt_lower" == *"autonomous"* ]] || [[ "$prompt_lower" == *"until complete"* ]] || [[ "$prompt_lower" == *"don't stop"* ]]; then
  explicit_ralph=true
fi

# Activate Ralph for long prompts (>100 words) or explicit request
if [[ "$word_count" -gt 100 ]] || [[ "$explicit_ralph" == true ]]; then

  # Extract key requirements for completion criteria
  # Look for: tests, files, endpoints, features, etc.

  completion_hints=""

  if [[ "$prompt_lower" == *"test"* ]]; then
    completion_hints+="- All tests must pass\n"
  fi

  if [[ "$prompt_lower" == *"endpoint"* ]] || [[ "$prompt_lower" == *"api"* ]] || [[ "$prompt_lower" == *"route"* ]]; then
    completion_hints+="- API endpoints must be functional\n"
  fi

  if [[ "$prompt_lower" == *"component"* ]] || [[ "$prompt_lower" == *"screen"* ]] || [[ "$prompt_lower" == *"page"* ]]; then
    completion_hints+="- UI components must render without errors\n"
  fi

  if [[ "$prompt_lower" == *"database"* ]] || [[ "$prompt_lower" == *"migration"* ]] || [[ "$prompt_lower" == *"model"* ]]; then
    completion_hints+="- Database migrations must apply cleanly\n"
  fi

  # Default completion criteria
  if [[ -z "$completion_hints" ]]; then
    completion_hints="- All code compiles without errors\n- No lint warnings\n- No type errors\n"
  fi

  cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "🔄 RALPH LOOP ACTIVATED (Complex task detected: ${word_count} words)

This is a complex task that requires iterative completion. DO NOT STOP until ALL criteria are met.

COMPLETION CRITERIA:
${completion_hints}- All lint checks pass (ruff/eslint) - NO WARNINGS
- All type checks pass (mypy/tsc) - NO ERRORS
- All requirements from the prompt are implemented

WORKFLOW:
1. Analyze requirements thoroughly
2. Implement incrementally
3. After each major change, run quality checks
4. If checks fail, fix and retry
5. Only claim completion when ALL criteria are verified

IMPORTANT: The Stop hook will verify completion. If criteria aren't met, you'll be asked to continue.

When you believe you're done, explicitly state: 'RALPH COMPLETE - All criteria verified'"
  }
}
EOF
else
  exit 0
fi

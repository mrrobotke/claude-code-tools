#!/bin/bash
# Stop Hook: Checks if quality gates passed before allowing stop
# Only blocks on ACTUAL tool output failures, not discussion of errors

input=$(cat)
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')
stop_hook_active=$(echo "$input" | jq -r '.stop_hook_active // false')

# Prevent infinite loops - if stop hook already triggered once, allow stop
if [[ "$stop_hook_active" == "true" ]]; then
  exit 0
fi

# If no transcript, allow stop
if [[ -z "$transcript_path" ]] || [[ ! -f "$transcript_path" ]]; then
  exit 0
fi

# Read recent transcript content (last 30 lines of JSONL)
# Focus on tool_result content which contains actual command output
recent_content=$(tail -30 "$transcript_path" 2>/dev/null)

# Only check tool results, not assistant messages
tool_results=$(echo "$recent_content" | grep -o '"tool_result"[^}]*' 2>/dev/null || echo "")

# If no recent tool results, allow stop (no code was edited recently)
if [[ -z "$tool_results" ]]; then
  exit 0
fi

failures=""

# Check for ACTUAL lint failures in tool output (specific patterns)
# These patterns match real CLI output, not discussion
if echo "$tool_results" | grep -qE "Found [0-9]+ error|error: |E[0-9]{3}:|W[0-9]{3}:|✗|error TS[0-9]+"; then
  # Double-check it's not just a count of 0
  if ! echo "$tool_results" | grep -qE "Found 0 error|0 errors"; then
    failures+="Lint/Type errors in output. "
  fi
fi

# Check for test failures (pytest/jest specific patterns)
if echo "$tool_results" | grep -qE "FAILED|failed.*test|AssertionError|Error:|pytest.*[1-9]+ failed"; then
  failures+="Test failures in output. "
fi

# Check for RALPH LOOP - only if explicitly activated in this session
if echo "$recent_content" | grep -q "RALPH LOOP ACTIVATED"; then
  # Check for explicit RALPH COMPLETE statement
  if ! echo "$recent_content" | grep -q "RALPH COMPLETE"; then
    failures+="Ralph Loop active - say 'RALPH COMPLETE' when done. "
  fi
fi

# If failures found, block stop
if [[ -n "$failures" ]]; then
  cat << EOF
{
  "decision": "block",
  "reason": "${failures}"
}
EOF
  exit 0
fi

# All good, allow stop
exit 0

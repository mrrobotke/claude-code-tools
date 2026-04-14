#!/bin/bash
# UserPromptSubmit Hook: Conditional coding rule reminders
# Rule 3 (test critical paths)  — fires on auth/payment/billing/transaction domain keywords
# Rule 6 (no pre-existing excuses) — fires on fix/bug/debug/issue keywords
# Rules 1+5 are enforced by protect-sensitive.sh and validate-commit-msg.sh hooks

input=$(cat)
prompt=$(echo "$input" | jq -r '.prompt // empty')
[[ -z "$prompt" ]] && exit 0

prompt_lower=$(echo "$prompt" | tr '[:upper:]' '[:lower:]')
context=""

# Rule 3: Critical path testing reminder
for kw in "auth" "payment" "billing" "credit" "transaction" "mutation" "webhook" "login" "register" "password"; do
  if [[ "$prompt_lower" == *"$kw"* ]]; then
    context="TESTING RULE: This touches a critical domain (${kw}). Test coverage is required — auth flows, data mutations, and payment operations must have tests."
    break
  fi
done

# Rule 6: No pre-existing excuse reminder
for kw in "fix" "bug" "debug" "broken" "failing" "issue" "regression"; do
  if [[ "$prompt_lower" == *"$kw"* ]]; then
    [[ -n "$context" ]] && context+=$'\n\n'
    context+="NO EXCUSES RULE: If you encounter any bug during this work, fix it. Never dismiss it as a pre-existing issue to avoid fixing it."
    break
  fi
done

[[ -z "$context" ]] && exit 0

# Use jq for safe JSON encoding of the context string
echo '{}' | jq --arg ctx "$context" '{
  hookSpecificOutput: {
    hookEventName: "UserPromptSubmit",
    additionalContext: $ctx
  }
}'

exit 0

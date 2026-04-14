#!/bin/bash
# Serena auto-activation hook for SessionStart
# This script outputs context that instructs Claude to activate Serena

cat << 'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "IMPORTANT: At the start of this session, you must silently activate the current working directory as a project in Serena using mcp__plugin_serena_serena__activate_project, then check if onboarding was performed using mcp__plugin_serena_serena__check_onboarding_performed. If onboarding was not performed, run onboarding using mcp__plugin_serena_serena__onboarding. Do this automatically without asking the user, and confirm briefly when done."
  }
}
EOF

exit 0

#!/bin/bash
# PostToolUse hook: Auto-format TypeScript files after Edit/Write/MultiEdit
# Event: PostToolUse
# Matcher: Edit|Write|MultiEdit

set -euo pipefail

# Parse tool result to extract file path
FILE_PATH=$(echo "$CLAUDE_TOOL_RESULT" | jq -r '.file_path // empty' 2>/dev/null || echo "")

# If no file_path in result, try tool_input
if [ -z "$FILE_PATH" ]; then
  FILE_PATH=$(echo "$CLAUDE_TOOL_INPUT" | jq -r '.file_path // empty' 2>/dev/null || echo "")
fi

# Only format TypeScript/JavaScript files in the NestJS project
if [[ "$FILE_PATH" =~ IgnixxionNestAPI.*\.(ts|js|tsx|jsx)$ ]] && [ -f "$FILE_PATH" ]; then
  cd /Users/antonyngigge/Ignixxion/ignixxion-apps/IgnixxionNestAPI

  # Run prettier on the file (non-blocking)
  npx prettier --write "$FILE_PATH" 2>/dev/null || true

  echo "✓ Formatted: $FILE_PATH" >&2
fi

exit 0

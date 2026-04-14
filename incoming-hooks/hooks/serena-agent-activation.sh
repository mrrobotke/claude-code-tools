#!/bin/bash
# PreToolUse hook: Inject Serena activation context when spawning agents
# Matcher: Agent
# Outputs plain text context (not a block) reminding the orchestrator
# to include Serena activation in the agent's prompt

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // empty')

[[ "$tool_name" != "Agent" ]] && exit 0

# Check if the agent prompt already mentions Serena activation
prompt=$(echo "$input" | jq -r '.tool_input.prompt // empty')

if echo "$prompt" | grep -qi "activate_project"; then
  # Already includes Serena activation - no need to remind
  exit 0
fi

# Output context reminder (plain text, not JSON block)
cat << 'CONTEXT'
SERENA ACTIVATION REQUIRED FOR THIS AGENT:

The agent prompt MUST include Serena activation as the FIRST instruction.
Add these lines to the agent prompt if not already present:

  FIRST ACTION (before any file operations):
  1. Call mcp__plugin_serena_serena__activate_project with the project directory path
  2. Call mcp__plugin_serena_serena__check_onboarding_performed
  3. If not performed, call mcp__plugin_serena_serena__onboarding
  4. Use ONLY Serena MCP tools for ALL file operations:
     - Read: mcp__plugin_serena_serena__read_file, get_symbols_overview, find_symbol
     - Edit: mcp__plugin_serena_serena__replace_content, replace_symbol_body
     - Create: mcp__plugin_serena_serena__create_text_file
     - Search: mcp__plugin_serena_serena__find_file, search_for_pattern
     - Refactor: rename_symbol, insert_before_symbol, insert_after_symbol
  5. NEVER use native Read/Edit/Write/Glob/Grep tools (they are blocked by hooks)
CONTEXT

exit 0

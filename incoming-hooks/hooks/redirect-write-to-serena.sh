#!/bin/bash
# PreToolUse hook: Block native Edit/Write, redirect to Serena equivalents
# Matcher: Edit|Write
# Exception: .claude/ directory files (settings, plans, hooks, memory)

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // empty')
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

[[ -z "$tool_name" ]] && exit 0
[[ -z "$file_path" ]] && exit 0

# Allow specific .claude/ meta-files (NOT worktrees which contain code)
source "$HOME/.claude/hooks/resolve-serena-path.sh"
if is_claude_meta_path "$file_path"; then
  exit 0
fi

# Allow /tmp/ paths (temporary files)
if [[ "$file_path" == /tmp/* ]]; then
  exit 0
fi

if [[ "$tool_name" == "Edit" ]]; then
  echo '{"decision":"block","reason":"BLOCKED: Use Serena tools instead of native Edit.\n\n- mcp__plugin_serena_serena__replace_content (relative_path, needle, repl, mode=regex|literal)\n  Use regex mode with wildcards for efficient multi-line replacements.\n- mcp__plugin_serena_serena__replace_symbol_body (name_path, relative_path, body)\n  For replacing entire function/class/method definitions.\n- mcp__plugin_serena_serena__insert_before_symbol / insert_after_symbol\n  For inserting new code relative to existing symbols."}'
  exit 0
fi

if [[ "$tool_name" == "Write" ]]; then
  echo '{"decision":"block","reason":"BLOCKED: Use Serena tools instead of native Write.\n\n- mcp__plugin_serena_serena__create_text_file (relative_path, content)\n  Creates a new file or overwrites an existing file."}'
  exit 0
fi

exit 0

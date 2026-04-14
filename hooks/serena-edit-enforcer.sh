#!/usr/bin/env bash
# Block native Edit/Write/MultiEdit for source code files.
# WHY Serena's symbolic tools (replace_content, replace_symbol_body) provide
# precise edits and prevent full-file rewrites by agents.

set -euo pipefail

input=$(cat)

file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
if [[ -z "$file_path" ]]; then
  exit 0
fi

# Allow files outside any git repo (global config, hooks, plans, memory).
repo_root=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
if [[ -z "$repo_root" ]] || [[ "$file_path" != "$repo_root"* ]]; then
  exit 0
fi

# Allow .claude subdirectories for plans, settings, memory — but NOT worktrees.
if [[ "$file_path" == *"/.claude/plans/"* ]] || \
   [[ "$file_path" == *"/.claude/settings"* ]] || \
   [[ "$file_path" == *"/.claude/memory/"* ]] || \
   [[ "$file_path" == *"/.claude/projects/"* ]]; then
  exit 0
fi

# Allow non-source-code extensions (configs, docs, scripts, data).
ext="${file_path##*.}"
case "$ext" in
  md|json|yaml|yml|toml|txt|sh|bash|zsh|conf|cfg|ini|env|lock|log|csv|svg|xml) exit 0 ;;
esac

# Block source code edits — redirect to Serena MCP tools.
cat >&2 <<EOF

Edit BLOCKED — use Serena MCP tools for source code.

File: $file_path

Activate Serena first:
  mcp__plugin_serena_serena__activate_project({ project: "<working directory>" })

Then use:
  - mcp__plugin_serena_serena__replace_content (text/regex replacement)
  - mcp__plugin_serena_serena__replace_symbol_body (function/class body)
  - mcp__plugin_serena_serena__insert_after_symbol / insert_before_symbol
  - mcp__plugin_serena_serena__create_text_file (new files)

Load each tool first: ToolSearch("select:mcp__plugin_serena_serena__<tool>")
EOF

cat <<EOF
{
  "hookSpecificOutput": {
    "permissionDecision": "deny",
    "permissionDecisionReason": "Source code edits must use Serena MCP tools (replace_content, replace_symbol_body, etc.), not native Edit/Write/MultiEdit. Activate Serena first, then use its tools."
  }
}
EOF
exit 2

#!/bin/bash
# UserPromptSubmit hook: Inject Serena-first policy and tool mapping into every prompt
# Ensures all sessions (main + agents) know to use Serena

cat << 'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "SERENA-FIRST POLICY ACTIVE (enforced by hooks):\n\nAll file operations MUST use Serena MCP tools. Native Read/Edit/Write/Glob/Grep are BLOCKED.\n\nTool Mapping:\n- Read files: mcp__plugin_serena_serena__read_file\n- Code structure: mcp__plugin_serena_serena__get_symbols_overview\n- Find symbols: mcp__plugin_serena_serena__find_symbol (use include_body=true for source)\n- Edit (regex/literal): mcp__plugin_serena_serena__replace_content\n- Edit (symbol body): mcp__plugin_serena_serena__replace_symbol_body\n- Create file: mcp__plugin_serena_serena__create_text_file\n- Insert code: mcp__plugin_serena_serena__insert_before_symbol / insert_after_symbol\n- Find files: mcp__plugin_serena_serena__find_file\n- Search code: mcp__plugin_serena_serena__search_for_pattern\n- Rename: mcp__plugin_serena_serena__rename_symbol\n- Delete: mcp__plugin_serena_serena__safe_delete_symbol\n- List dir: mcp__plugin_serena_serena__list_dir\n- References: mcp__plugin_serena_serena__find_referencing_symbols\n\nExceptions (native tools allowed):\n- Read: images, PDFs, .ipynb, .claude/ files, /tmp/\n- Edit/Write: .claude/ directory only\n- Glob/Grep: NEVER\n\nAgents: ALWAYS activate Serena first with activate_project before any file ops."
  }
}
EOF

exit 0

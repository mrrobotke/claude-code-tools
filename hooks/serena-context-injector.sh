#!/usr/bin/env bash
# Inject Serena tool enforcement context into every prompt.
# WHY agents ignore CLAUDE.md Serena instructions; runtime context is harder to skip.

cat <<'CONTEXT'
SERENA TOOL ENFORCEMENT (always active):

All source code edits MUST use Serena MCP tools. Native Edit/Write/MultiEdit are BLOCKED for source code.

Before ANY code work, activate Serena for your working directory:
  1. ToolSearch("select:mcp__plugin_serena_serena__activate_project")
  2. mcp__plugin_serena_serena__activate_project({ project: "<your working directory>" })

Serena edit tools (use instead of Edit/Write/MultiEdit):
  - replace_content: text/regex replacement in files (most common)
  - replace_symbol_body: replace a function or class body
  - insert_after_symbol / insert_before_symbol: add code near a symbol
  - create_text_file: create new files or full rewrites
  - rename_symbol: rename across the codebase
  - safe_delete_symbol: delete unused symbols

Serena read tools (use for code exploration):
  - read_file: read file content
  - get_symbols_overview: high-level view of file symbols
  - find_symbol: find symbols by name path
  - find_referencing_symbols: find references to a symbol
  - search_for_pattern: flexible regex search

All tools require ToolSearch loading before first use:
  ToolSearch("select:mcp__plugin_serena_serena__<tool_name>")
CONTEXT
exit 0

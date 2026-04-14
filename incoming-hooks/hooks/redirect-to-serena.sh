#!/bin/bash
# PreToolUse hook: Block native Read/Glob/Grep, redirect to Serena equivalents
# Matcher: Read|Glob|Grep
# Exceptions: images, PDFs, Jupyter notebooks, .claude/ files, /tmp/ screenshots

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // empty')

[[ -z "$tool_name" ]] && exit 0

if [[ "$tool_name" == "Read" ]]; then
  file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
  [[ -z "$file_path" ]] && exit 0

  # Allow images (Serena is text-only)
  case "$file_path" in
    *.png|*.jpg|*.jpeg|*.gif|*.svg|*.ico|*.webp|*.bmp|*.tiff|*.PNG|*.JPG|*.JPEG|*.GIF|*.SVG|*.ICO|*.WEBP|*.BMP|*.TIFF)
      exit 0
      ;;
  esac

  # Allow PDFs
  if [[ "$file_path" == *.pdf ]] || [[ "$file_path" == *.PDF ]]; then
    exit 0
  fi

  # Allow Jupyter notebooks
  if [[ "$file_path" == *.ipynb ]]; then
    exit 0
  fi

  # Allow specific .claude/ meta-files (NOT worktrees which contain code)
  source "$HOME/.claude/hooks/resolve-serena-path.sh"
  if is_claude_meta_path "$file_path"; then
    exit 0
  fi

  # Allow /tmp/ paths (screenshots, temp files)
  if [[ "$file_path" == /tmp/* ]]; then
    exit 0
  fi

  # Block all other Read operations
  echo '{"decision":"block","reason":"BLOCKED: Use Serena tools instead of native Read.\n\n- mcp__plugin_serena_serena__read_file (relative_path, start_line, end_line)\n- mcp__plugin_serena_serena__get_symbols_overview (for file structure)\n- mcp__plugin_serena_serena__find_symbol (for specific symbols with include_body=true)\n\nPrefer symbolic reads (get_symbols_overview, find_symbol) over full file reads when exploring code."}'
  exit 0
fi

if [[ "$tool_name" == "Glob" ]]; then
  echo '{"decision":"block","reason":"BLOCKED: Use Serena tools instead of native Glob.\n\n- mcp__plugin_serena_serena__find_file (file_mask, relative_path) for file pattern matching\n- mcp__plugin_serena_serena__list_dir (relative_path, recursive) for directory listing"}'
  exit 0
fi

if [[ "$tool_name" == "Grep" ]]; then
  echo '{"decision":"block","reason":"BLOCKED: Use Serena tools instead of native Grep.\n\n- mcp__plugin_serena_serena__search_for_pattern (substring_pattern with regex)\n  Supports: context_lines_before/after, paths_include_glob, paths_exclude_glob, restrict_search_to_code_files\n- mcp__plugin_serena_serena__find_symbol (for symbol-level search by name)"}'
  exit 0
fi

exit 0

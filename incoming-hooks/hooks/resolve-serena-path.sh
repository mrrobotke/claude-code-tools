#!/bin/bash
# Shared utility: Resolve Serena relative_path + cwd to absolute path
# Usage: source this file after setting $input from stdin
# Sets: $abs_path, $relative_path, $project_dir
# Also provides: is_claude_meta_path() function
#
# FIX: Looks up per-session active project (keyed by CWD) FIRST to avoid
# multi-session cross-contamination. Falls back to legacy global file.
#
# NOTE: Serena's relative_path is relative to the *active Serena project*,
# which may differ from .cwd (the Claude Code session CWD). When the file
# isn't found at $cwd/$relative_path, we search sibling repos and their
# worktrees under the parent directory.

relative_path=$(echo "$input" | jq -r '.tool_input.relative_path // empty')

# Determine session CWD
session_cwd=$(echo "$input" | jq -r '.cwd // empty')
[[ -z "$session_cwd" ]] && session_cwd="$PWD"

# Per-session lookup: keyed by session CWD hash — correct for multi-session use
serena_active=""
cwd_hash=$(echo "$session_cwd" | md5)
session_file="$HOME/.claude/.serena-sessions/$cwd_hash"
if [[ -f "$session_file" ]]; then
  serena_active=$(cat "$session_file")
fi

# Fall back to legacy global file only if no per-session entry exists
if [[ -z "$serena_active" ]] && [[ -f "$HOME/.claude/.serena-active-project" ]]; then
  serena_active=$(cat "$HOME/.claude/.serena-active-project")
fi

if [[ -n "$serena_active" && -d "$serena_active" ]]; then
  project_dir="$serena_active"
else
  project_dir="$session_cwd"
fi

abs_path=""
if [[ -n "$relative_path" ]]; then
  abs_path="$project_dir/$relative_path"
fi

# Check if a path is a Claude meta-file (NOT code in worktrees)
# Returns 0 if meta-file, 1 if not
is_claude_meta_path() {
  local p="$1"
  # Specific .claude/ meta-files and directories (NOT worktrees)
  if [[ "$p" == */.claude/settings.json ]] ||
     [[ "$p" == */.claude/settings.local.json ]] ||
     [[ "$p" == */.claude/CLAUDE.md ]] ||
     [[ "$p" == */.claude/keybindings.json ]] ||
     [[ "$p" == */.claude/plans/* ]] ||
     [[ "$p" == */.claude/hooks/* ]] ||
     [[ "$p" == */.claude/projects/*/memory/* ]] ||
     [[ "$p" == */.claude/logs/* ]] ||
     [[ "$p" == */.claude/todos/* ]] ||
     [[ "$p" == */.claude/plugins/* ]] ||
     [[ "$p" == */.claude/commands/* ]] ||
     [[ "$p" == */.claude/MEMORY.md ]] ||
     [[ "$p" == */.claude/scripts/* ]] ||
     [[ "$p" == */.claude/statsig_custom_config_cache.json ]]; then
    return 0
  fi
  return 1
}

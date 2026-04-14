#!/bin/bash
# PostToolUse hook: Track Serena active project path for cross-repo resolution.
# Runs after mcp__plugin_serena_serena__activate_project succeeds.
#
# FIX: Uses per-session keying (by CWD) so concurrent sessions on different
# worktrees/repos do not overwrite each other's active project pointer.
# Files: ~/.claude/.serena-sessions/{cwd_hash}
#
# Also maintains the legacy ~/.claude/.serena-active-project for single-session
# backwards compatibility.

input=$(cat)
project=$(echo "$input" | jq -r '.tool_input.project // empty')

if [[ -n "$project" ]]; then
  # Resolve to absolute path if relative
  if [[ "$project" != /* ]]; then
    cwd=$(echo "$input" | jq -r '.cwd // empty')
    [[ -z "$cwd" ]] && cwd="$PWD"
    project="$cwd/$project"
  fi

  # Per-session file: keyed by the session CWD (unique per worktree/session)
  session_cwd=$(echo "$input" | jq -r '.cwd // empty')
  [[ -z "$session_cwd" ]] && session_cwd="$PWD"
  cwd_hash=$(echo "$session_cwd" | md5)
  sessions_dir="$HOME/.claude/.serena-sessions"
  mkdir -p "$sessions_dir"
  echo "$project" > "$sessions_dir/$cwd_hash"

  # Legacy global file (single-session fallback — still updated for compatibility)
  echo "$project" > "$HOME/.claude/.serena-active-project"
fi

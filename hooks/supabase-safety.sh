#!/usr/bin/env bash
# Block destructive Supabase CLI commands that destroy local data.
# WHY supabase db reset wipes all local data with no recovery path.

set -euo pipefail

input=$(cat)

command=$(echo "$input" | jq -r '.tool_input.command // empty')

# Only process supabase commands.
if [[ ! "$command" =~ supabase ]]; then
  exit 0
fi

# Block: supabase db reset (destroys all local data).
if [[ "$command" =~ supabase[[:space:]]+db[[:space:]]+reset ]]; then
  cat >&2 <<EOF

Blocked: supabase db reset

This command destroys ALL local database data with no recovery.
Use 'supabase migration up' to apply new migrations without data loss.

If you truly need a reset, run it manually outside Claude Code.
EOF

  cat <<EOF
{
  "hookSpecificOutput": {
    "permissionDecision": "deny",
    "permissionDecisionReason": "supabase db reset is prohibited. Use 'supabase migration up' instead."
  }
}
EOF
  exit 2
fi

# Allow all other supabase commands.
exit 0

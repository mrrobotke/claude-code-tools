#!/bin/bash
# PreToolUse hook: Block prisma db push — enforce prisma migrate dev
# Matcher: Bash
#
# prisma db push bypasses migration tracking entirely, creating tables
# that exist in the schema but have no migration file. This breaks the
# migration chain for any fresh database (prod, staging, new dev envs).
# All schema changes MUST go through: pnpm prisma migrate dev --name <name>

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty')

# Detect any form of prisma db push
if echo "$command" | grep -qE 'prisma\s+db\s+push'; then
  echo "{\"decision\":\"block\",\"reason\":\"BLOCKED: 'prisma db push' is prohibited.\\n\\nReason: db push creates tables without migration files, breaking the migration chain for prod and any fresh database.\\n\\nRequired workflow:\\n  pnpm prisma migrate dev --name <descriptive_name>\\n\\nThis generates a proper migration file in prisma/migrations/ that:\\n  1. Can be reviewed in PRs\\n  2. Runs correctly on prod\\n  3. Keeps migration history intact\\n\\nIf you're trying to prototype schema changes, use --create-only first:\\n  pnpm prisma migrate dev --create-only --name <name>\"}"
  exit 0
fi

exit 0

#!/bin/bash
# SessionStart hook: Load migration state and display summary
# Event: SessionStart

set -euo pipefail

MIGRATION_DOCS="/Users/antonyngigge/Ignixxion/ignixxion-apps/IgnixxionNestAPI/migration_docs"

echo "" >&2
echo "═══════════════════════════════════════════════════════════" >&2
echo "🚀 IGNIXXION MIGRATION SESSION" >&2
echo "═══════════════════════════════════════════════════════════" >&2

# Check if migration docs exist
if [ -d "$MIGRATION_DOCS" ]; then
  # Load Phase 2 Briefing if exists
  BRIEFING="$MIGRATION_DOCS/PHASE_2_BRIEFING.md"
  if [ -f "$BRIEFING" ]; then
    echo "" >&2
    echo "📊 Current Migration Status:" >&2

    # Extract completion percentage
    COMPLETION=$(grep -i "completion:" "$BRIEFING" | head -1 || echo "Unknown")
    echo "   $COMPLETION" >&2

    # Extract blockers count
    BLOCKERS=$(grep -c "^### BLOCKER" "$BRIEFING" || echo "0")
    echo "   Active Blockers: $BLOCKERS" >&2

    # Extract function count
    FUNCTIONS=$(grep -i "firebase functions:" "$BRIEFING" | head -1 || echo "Unknown")
    echo "   $FUNCTIONS" >&2
  fi

  # Check artifacts.json
  ARTIFACTS="$MIGRATION_DOCS/artifacts.json"
  if [ -f "$ARTIFACTS" ]; then
    TOTAL=$(jq '. | length' "$ARTIFACTS" 2>/dev/null || echo "?")
    echo "   Artifacts tracked: $TOTAL" >&2
  fi

  echo "" >&2
  echo "📁 Migration Docs Location:" >&2
  echo "   $MIGRATION_DOCS" >&2

  echo "" >&2
  echo "🔧 Key Files:" >&2
  echo "   • PHASE_2_BRIEFING.md - Current status" >&2
  echo "   • FUNCTION_MAPPING.md - Firebase → Nest mapping" >&2
  echo "   • PARITY_REPORT.md - Gap analysis" >&2
  echo "   • AUTH_GAPS.md - Security requirements" >&2
  echo "   • artifacts.json - Complete inventory" >&2

  echo "" >&2
  echo "🤖 Available Agents:" >&2
  echo "   • ignixxion-migration-supervisor (supervisor)" >&2
  echo "   • api-architect, auth-security, function-mapper" >&2
  echo "   • schema-indexer, swagger-qa, test-e2e" >&2
  echo "   • migration-verifier, ci-cd-sentinel, infra-gcp" >&2
  echo "   • repo-inventory" >&2

else
  echo "" >&2
  echo "⚠️  Migration docs not found at: $MIGRATION_DOCS" >&2
fi

echo "" >&2
echo "═══════════════════════════════════════════════════════════" >&2
echo "" >&2

exit 0

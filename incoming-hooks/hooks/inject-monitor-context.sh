#!/bin/bash
# SessionStart hook: Inject Monitor tool context once per session
# Monitor streams background script events line-by-line — replaces sleep/poll patterns

cat << 'EOF'
MONITOR TOOL AVAILABLE:
Use Monitor(command) to stream events from long-running background scripts line-by-line.
- Replaces: run_in_background + wait patterns for builds, tests, and container startup
- Best for: pnpm build, pnpm test:integration, docker compose up, dev server readiness
- Example: Monitor("pnpm test -- --testPathPattern=billing") streams test output live
- Example: Monitor("docker compose -f docker-compose.test.yml up -d") waits for containers
- Optional timeout (ms): second parameter, e.g. Monitor("pnpm build", 120000)
EOF

exit 0

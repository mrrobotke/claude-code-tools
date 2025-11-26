#!/usr/bin/env python3
"""
SubagentStop hook: Validate migration agent outputs
Event: SubagentStop
"""

import json
import os
import sys

# Required deliverables per agent type
AGENT_DELIVERABLES = {
    'function-mapper': ['FUNCTION_MAPPING', 'endpoint', 'route'],
    'api-architect': ['module', 'DTO', 'controller', 'service'],
    'schema-indexer': ['index', 'query', 'performance'],
    'swagger-qa': ['swagger', 'API documentation', '@Api'],
    'test-e2e': ['test', 'spec', 'coverage'],
    'migration-verifier': ['parity', 'validation', 'verified'],
    'auth-security': ['auth', 'guard', 'permission', 'role'],
    'ci-cd-sentinel': ['pipeline', 'workflow', 'CI', 'deploy'],
    'infra-gcp': ['Cloud Run', 'GCP', 'infrastructure'],
}

def main():
    try:
        tool_result = json.loads(os.environ.get('CLAUDE_TOOL_RESULT', '{}'))

        # Extract subagent type from the result
        subagent_type = tool_result.get('subagent_type', '')
        output = tool_result.get('output', '')

        if subagent_type in AGENT_DELIVERABLES:
            required = AGENT_DELIVERABLES[subagent_type]
            missing = []

            # Check if output contains expected deliverable keywords
            output_lower = output.lower()
            for deliverable in required:
                if deliverable.lower() not in output_lower:
                    missing.append(deliverable)

            # Only block if ALL deliverables are missing (likely incomplete work)
            if len(missing) == len(required):
                print("", file=sys.stderr)
                print(f"⚠️  AGENT OUTPUT INCOMPLETE: {subagent_type}", file=sys.stderr)
                print("", file=sys.stderr)
                print("   Expected deliverables not found:", file=sys.stderr)
                for item in missing:
                    print(f"   • {item}", file=sys.stderr)
                print("", file=sys.stderr)
                print("   Note: Agent output may be too brief or missing key work.", file=sys.stderr)
                print("", file=sys.stderr)

                # Output JSON to suggest re-prompting agent
                print(json.dumps({
                    "decision": "block",
                    "reason": f"Agent {subagent_type} output appears incomplete. Missing expected deliverables: {', '.join(missing)}"
                }))

                sys.exit(2)

        # Agent output appears complete
        sys.exit(0)

    except Exception as e:
        print(f"Hook error: {e}", file=sys.stderr)
        sys.exit(0)

if __name__ == '__main__':
    main()

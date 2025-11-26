#!/usr/bin/env python3
"""
PreToolUse hook: Enforce test coverage before committing
Event: PreToolUse
Matcher: Bash(git commit.*)
"""

import json
import os
import sys
import subprocess
import re

def main():
    try:
        # Parse tool input
        tool_input = json.loads(os.environ.get('CLAUDE_TOOL_INPUT', '{}'))
        command = tool_input.get('command', '')

        # Only check on git commit commands in NestJS project
        if 'git commit' in command:
            cwd = os.getcwd()
            if 'IgnixxionNestAPI' in cwd:
                print("🔍 Checking test coverage before commit...", file=sys.stderr)

                # Check if coverage report exists
                coverage_file = os.path.join(cwd, 'coverage', 'coverage-summary.json')

                if os.path.exists(coverage_file):
                    with open(coverage_file, 'r') as f:
                        coverage_data = json.load(f)

                    # Get total coverage
                    total = coverage_data.get('total', {})
                    lines = total.get('lines', {}).get('pct', 0)
                    statements = total.get('statements', {}).get('pct', 0)
                    functions = total.get('functions', {}).get('pct', 0)
                    branches = total.get('branches', {}).get('pct', 0)

                    # Threshold from jest.config.js
                    threshold = 80

                    failed = []
                    if lines < threshold:
                        failed.append(f"Lines: {lines}% < {threshold}%")
                    if statements < threshold:
                        failed.append(f"Statements: {statements}% < {threshold}%")
                    if functions < threshold:
                        failed.append(f"Functions: {functions}% < {threshold}%")
                    if branches < threshold:
                        failed.append(f"Branches: {branches}% < {threshold}%")

                    if failed:
                        print("", file=sys.stderr)
                        print("❌ COVERAGE BELOW THRESHOLD", file=sys.stderr)
                        for item in failed:
                            print(f"   {item}", file=sys.stderr)
                        print("", file=sys.stderr)
                        print("   Run: yarn test:cov", file=sys.stderr)
                        print("", file=sys.stderr)

                        # BLOCK with exit code 2
                        sys.exit(2)

                    print("✓ Coverage meets threshold (80%)", file=sys.stderr)

                else:
                    print("⚠️  No coverage report found. Run: yarn test:cov", file=sys.stderr)
                    # Non-blocking for missing report
                    sys.exit(0)

        # Allow commit
        sys.exit(0)

    except Exception as e:
        # Non-blocking error
        print(f"Hook error: {e}", file=sys.stderr)
        sys.exit(0)

if __name__ == '__main__':
    main()

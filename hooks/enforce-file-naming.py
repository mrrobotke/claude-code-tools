#!/usr/bin/env python3
"""
PreToolUse hook: Enforce file naming conventions
Event: PreToolUse
Matcher: Write
"""

import json
import os
import sys
import re

# Forbidden filename patterns
FORBIDDEN_PATTERNS = [
    r'.*_v\d+\.',           # _v2.ts, _v3.js, etc.
    r'.*_final\.',          # _final.ts
    r'.*_copy\.',           # _copy.ts
    r'.*_backup\.',         # _backup.ts
    r'.*_old\.',            # _old.ts
    r'.*_temp\.',           # _temp.ts
    r'.*_test\.',           # _test.ts (use .spec.ts or .test.ts)
    r'.*_fixed\.',          # _fixed.ts
    r'.*_new\.',            # _new.ts
    r'.*_draft\.',          # _draft.ts
    r'.*-enhanced\.',       # -enhanced.js
    r'.*/debug[_-].*',      # debug scripts
    r'.*/tmp/.*',           # temp directory files
]

# Allowed project directories
ALLOWED_DIRECTORIES = [
    '/Users/antonyngigge/Ignixxion/ignixxion-apps/IgnixxionNestAPI/src/',
    '/Users/antonyngigge/Ignixxion/ignixxion-apps/IgnixxionNestAPI/test/',
    '/Users/antonyngigge/Ignixxion/ignixxion-apps/IgnixxionNestAPI/prisma/',
    '/Users/antonyngigge/Ignixxion/ignixxion-apps/IgnixxionNestAPI/migration_docs/',
    '/Users/antonyngigge/iworldAfric/Bidding/bidzetu-backend/',
    '/Users/antonyngigge/iworldAfric/iJobs/iJobs-frontend/',
    '/Users/antonyngigge/iworldAfric/iJobs/iJobs-backend/',
    '/Users/antonyngigge/.claude/agents/',
    '/Users/antonyngigge/.claude/hooks/',
    '/Users/antonyngigge/.claude/commands/',
    '/Users/antonyngigge/.claude/projects/',
]

def validate_file_path(file_path):
    """Validate file path against naming conventions"""
    issues = []

    # Check forbidden patterns
    for pattern in FORBIDDEN_PATTERNS:
        if re.search(pattern, file_path, re.IGNORECASE):
            issues.append(f"Forbidden naming pattern detected: matches '{pattern}'")

    # Check if in allowed directory (exempt /tmp/ for system temp files)
    if not file_path.startswith('/tmp/'):
        is_allowed = any(file_path.startswith(allowed) for allowed in ALLOWED_DIRECTORIES)
        if not is_allowed:
            issues.append(f"File not in allowed project directories")
            issues.append(f"Allowed: {', '.join(ALLOWED_DIRECTORIES)}")

    return issues

def main():
    try:
        tool_input = json.loads(os.environ.get('CLAUDE_TOOL_INPUT', '{}'))
        file_path = tool_input.get('file_path', '')

        if not file_path:
            sys.exit(0)

        issues = validate_file_path(file_path)

        if issues:
            print("", file=sys.stderr)
            print("❌ FILE NAMING VIOLATION", file=sys.stderr)
            print(f"   File: {file_path}", file=sys.stderr)
            print("", file=sys.stderr)
            print("   Issues:", file=sys.stderr)
            for issue in issues:
                print(f"   • {issue}", file=sys.stderr)
            print("", file=sys.stderr)
            print("   Guidelines:", file=sys.stderr)
            print("   • Never create versioned files (_v2, _final, etc.)", file=sys.stderr)
            print("   • Always edit existing files instead of creating duplicates", file=sys.stderr)
            print("   • Use proper test naming (.spec.ts, .test.ts)", file=sys.stderr)
            print("   • Keep files in project directories", file=sys.stderr)
            print("", file=sys.stderr)

            # BLOCK the write operation
            sys.exit(2)

        # Allow the write
        sys.exit(0)

    except Exception as e:
        print(f"Hook error: {e}", file=sys.stderr)
        sys.exit(0)

if __name__ == '__main__':
    main()

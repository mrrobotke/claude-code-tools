#!/usr/bin/env python3
"""
SessionEnd hook: Log migration session metrics
Event: SessionEnd
"""

import json
import os
import sys
from datetime import datetime

MIGRATION_DOCS = "/Users/antonyngigge/Ignixxion/ignixxion-apps/IgnixxionNestAPI/migration_docs"
LOG_DIR = f"{MIGRATION_DOCS}/session_logs"

def main():
    try:
        os.makedirs(LOG_DIR, exist_ok=True)

        timestamp = datetime.now().isoformat()
        log_file = f"{LOG_DIR}/{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"

        # Simple session log
        session_data = {
            "timestamp": timestamp,
            "project": "Ignixxion NestJS Migration",
            "session_end": True,
            "working_directory": os.getcwd()
        }

        with open(log_file, 'w') as f:
            json.dump(session_data, f, indent=2)

        print(f"✓ Session metrics logged to {log_file}", file=sys.stderr)

    except Exception as e:
        print(f"Hook error: {e}", file=sys.stderr)

    # Always exit 0 - non-blocking
    sys.exit(0)

if __name__ == '__main__':
    main()

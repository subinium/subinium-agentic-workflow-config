#!/usr/bin/env bash
# Hook: PostToolUse (Write|Edit)
# Tracks edited files during a session for commit awareness and TDD checks.

set -euo pipefail

INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('tool_input', {}).get('file_path', ''))
except:
    print('')
" 2>/dev/null || echo "")

if [ -n "$FILE_PATH" ] && [ -f "$FILE_PATH" ]; then
    TRACK_FILE="/tmp/claude-edited-files-$$.txt"
    echo "$FILE_PATH" >> "$TRACK_FILE"
    sort -u "$TRACK_FILE" -o "$TRACK_FILE" 2>/dev/null || true
fi

exit 0

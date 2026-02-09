#!/usr/bin/env bash
# Hook: PostToolUse (Write|Edit)
# Warns when a written/edited file exceeds 300 lines. Blocks at 500 lines.
# Encourages splitting large files into smaller modules.

set -euo pipefail

INPUT=$(cat)

# Extract file path from tool_input
FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    ti = data.get('tool_input', {})
    print(ti.get('file_path', '') or ti.get('filePath', ''))
except:
    print('')
" 2>/dev/null || echo "")

# Skip if no file path or file doesn't exist
if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
    exit 0
fi

# Skip non-code files (markdown, json, config, etc.)
case "$FILE_PATH" in
    *.md|*.json|*.yaml|*.yml|*.toml|*.lock|*.svg|*.css)
        exit 0
        ;;
esac

LINE_COUNT=$(wc -l < "$FILE_PATH" | tr -d ' ')

if [ "$LINE_COUNT" -gt 500 ]; then
    echo "WARNING: $FILE_PATH is $LINE_COUNT lines (>500). Consider splitting into smaller modules."
    echo "Large files reduce readability and make reviews harder."
    exit 0
elif [ "$LINE_COUNT" -gt 300 ]; then
    echo "Note: $FILE_PATH is $LINE_COUNT lines (>300). Consider splitting if it keeps growing."
    exit 0
fi

exit 0

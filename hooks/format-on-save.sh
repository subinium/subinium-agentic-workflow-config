#!/usr/bin/env bash
# Hook: PostToolUse (Write|Edit)
# Auto-formats files after save based on extension.
# Only formats if the appropriate tool is installed and configured.

set -euo pipefail

# Read JSON input from stdin
INPUT=$(cat)

# Extract file_path from tool_input
FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('tool_input', {}).get('file_path', ''))
except:
    print('')
" 2>/dev/null || echo "")

# If no file path, skip
if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# Check if file exists
if [ ! -f "$FILE_PATH" ]; then
    exit 0
fi

# Skip very large files — formatter cold-start + write can exceed timeout.
LINE_COUNT=$(wc -l < "$FILE_PATH" 2>/dev/null || echo 0)
if [ "$LINE_COUNT" -gt 3000 ]; then
    exit 0
fi

# Get file extension
EXT="${FILE_PATH##*.}"

case "$EXT" in
    py)
        # Format Python with black (if installed). Background — don't block tool return.
        if command -v black &>/dev/null; then
            (black --quiet "$FILE_PATH" >/dev/null 2>&1 &)
        fi
        ;;
    ts|tsx|js|jsx|json|css|md)
        # Format with prettier (only if project has prettier config)
        PROJECT_DIR=$(dirname "$FILE_PATH")
        # Walk up to find project root (look for package.json)
        SEARCH_DIR="$PROJECT_DIR"
        PRETTIER_CONFIG_FOUND=false
        while [ "$SEARCH_DIR" != "/" ]; do
            if [ -f "$SEARCH_DIR/.prettierrc" ] || \
               [ -f "$SEARCH_DIR/.prettierrc.js" ] || \
               [ -f "$SEARCH_DIR/.prettierrc.json" ] || \
               [ -f "$SEARCH_DIR/.prettierrc.yaml" ] || \
               [ -f "$SEARCH_DIR/.prettierrc.yml" ] || \
               [ -f "$SEARCH_DIR/prettier.config.js" ] || \
               [ -f "$SEARCH_DIR/prettier.config.mjs" ]; then
                PRETTIER_CONFIG_FOUND=true
                break
            fi
            # Also check package.json for prettier key
            if [ -f "$SEARCH_DIR/package.json" ]; then
                if python3 -c "
import json, sys
with open('$SEARCH_DIR/package.json') as f:
    pkg = json.load(f)
sys.exit(0 if 'prettier' in pkg else 1)
" 2>/dev/null; then
                    PRETTIER_CONFIG_FOUND=true
                    break
                fi
            fi
            SEARCH_DIR=$(dirname "$SEARCH_DIR")
        done

        if [ "$PRETTIER_CONFIG_FOUND" = true ]; then
            if command -v npx &>/dev/null; then
                # Background — npx cold-start (~3s) + prettier should not block tool return.
                (npx prettier --write "$FILE_PATH" >/dev/null 2>&1 &)
            fi
        fi
        ;;
esac

exit 0

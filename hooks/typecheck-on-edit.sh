#!/usr/bin/env bash
# typecheck-on-edit.sh — PostToolUse hook for Write|Edit
# Runs tsc --noEmit on TypeScript file changes, shows first 5 errors
# Input: JSON with "tool_input" containing "file_path" on stdin

set -euo pipefail

INPUT=$(cat)

# Extract file path from tool input
FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
ti = data.get('tool_input', {})
print(ti.get('file_path', ti.get('filePath', '')))
" 2>/dev/null || echo "")

# Only trigger for .ts/.tsx files
case "$FILE_PATH" in
  *.ts|*.tsx) ;;
  *) exit 0 ;;
esac

# Walk up to find tsconfig.json
DIR=$(dirname "$FILE_PATH")
PROJECT_ROOT=""
while [ "$DIR" != "/" ]; do
  if [ -f "$DIR/tsconfig.json" ]; then
    PROJECT_ROOT="$DIR"
    break
  fi
  DIR=$(dirname "$DIR")
done

# No tsconfig found — skip
[ -z "$PROJECT_ROOT" ] && exit 0

# Run tsc with timeout (10s)
OUTPUT=$(timeout 10 npx tsc --noEmit --project "$PROJECT_ROOT/tsconfig.json" 2>&1 || true)

# No errors — silent exit
if [ -z "$OUTPUT" ] || echo "$OUTPUT" | grep -q "^$"; then
  exit 0
fi

# Count errors
ERROR_COUNT=$(echo "$OUTPUT" | grep -c "error TS" || true)

if [ "$ERROR_COUNT" -gt 0 ]; then
  echo ""
  echo "TypeScript: ${ERROR_COUNT} error(s) detected"
  echo "$OUTPUT" | grep "error TS" | head -5
  if [ "$ERROR_COUNT" -gt 5 ]; then
    echo "  ... and $((ERROR_COUNT - 5)) more errors"
  fi
fi

exit 0

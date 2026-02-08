#!/usr/bin/env bash
# Hook: PreToolUse (Bash)
# Blocks destructive git commands and dangerous rm operations.
# Reads JSON from stdin, extracts tool_input.command.

set -euo pipefail

# Read JSON input from stdin
INPUT=$(cat)

# Extract the command from tool_input.command
COMMAND=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('tool_input', {}).get('command', ''))
except:
    print('')
" 2>/dev/null || echo "")

# If we couldn't extract a command, allow it
if [ -z "$COMMAND" ]; then
    exit 0
fi

# Normalize: lowercase, collapse whitespace
NORMALIZED=$(echo "$COMMAND" | tr '[:upper:]' '[:lower:]' | tr -s ' ')

# Block patterns
BLOCKED_PATTERNS=(
    "git push --force"
    "git push -f "
    "git push -f$"
    "git reset --hard"
    "git clean -f"
    "git clean -fd"
    "git clean -fdx"
    "git checkout -- ."
    "git restore ."
    "rm -rf /"
    "rm -rf ~"
    "rm -rf /*"
)

for PATTERN in "${BLOCKED_PATTERNS[@]}"; do
    if echo "$NORMALIZED" | grep -qE "$PATTERN"; then
        echo "BLOCKED: Destructive command detected: '$COMMAND'"
        echo "This command can cause irreversible data loss."
        echo "If you really need to run this, ask the user for explicit confirmation."
        exit 2
    fi
done

# Additional check: block force push variants (e.g., git push origin main --force)
if echo "$NORMALIZED" | grep -qE "git push.*(-f|--force)"; then
    echo "BLOCKED: Force push detected: '$COMMAND'"
    echo "Force pushing can overwrite remote history."
    echo "If you really need to run this, ask the user for explicit confirmation."
    exit 2
fi

# Additional check: block rm -rf with home or root paths
if echo "$NORMALIZED" | grep -qE "rm\s+-r[f ]*\s+(/|~|\\\$home)"; then
    echo "BLOCKED: Dangerous rm command detected: '$COMMAND'"
    echo "This could delete critical system or user files."
    exit 2
fi

exit 0

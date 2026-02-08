#!/usr/bin/env bash
# Hook: PreToolUse (Read|Write|Edit)
# Blocks access to sensitive files. More reliable than settings.json deny rules.

set -euo pipefail

INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    ti = data.get('tool_input', {})
    print(ti.get('file_path', '') or ti.get('path', ''))
except:
    print('')
" 2>/dev/null || echo "")

if [ -z "$FILE_PATH" ]; then
    exit 0
fi

BLOCKED_PATTERNS=(
    '\.env$'
    '\.env\.'
    '/secrets/'
    'credentials'
    '\.pem$'
    '\.key$'
    'id_rsa'
    'id_ed25519'
    '\.p12$'
    '\.pfx$'
    '\.jks$'
    'private.*key'
    'wallet.*json'
    'keystore'
    '\.sqlite$'
    '\.db$'
)

for PATTERN in "${BLOCKED_PATTERNS[@]}"; do
    if echo "$FILE_PATH" | grep -qiE "$PATTERN"; then
        echo "BLOCKED: Access to sensitive file: $FILE_PATH"
        echo "Pattern matched: $PATTERN"
        echo "If you need this file, ask the user for explicit confirmation."
        exit 2
    fi
done

exit 0

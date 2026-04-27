#!/usr/bin/env bash
# Hook: PreToolUse (Bash)
# Blocks Bash commands that read or expose sensitive files.
# Complements settings.json deny (Read tool only) and guard-sensitive-files.sh
# (Read|Write|Edit only) — closes the cat/head/tail/source bypass.

set -euo pipefail

INPUT=$(cat)

COMMAND=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('tool_input', {}).get('command', ''))
except:
    print('')
" 2>/dev/null || echo "")

if [ -z "$COMMAND" ]; then
    exit 0
fi

NORMALIZED=$(echo "$COMMAND" | tr -s ' ')

# Readers and exfiltrators that touch file contents.
READER='(cat|less|more|head|tail|view|bat|nl|tac|od|xxd|hexdump|strings)'
SOURCER='(source|\.\s)'
SCANNER='(awk|sed|grep|rg|ag|cut|sort|uniq|wc|jq|yq)'
COPIER='(cp|mv|tar|zip|rsync|scp)'

# Sensitive path patterns (anchor to extension/dir to reduce false positives).
SENSITIVE='(\.env(\.[a-zA-Z0-9_-]+)?(\s|$)|\.envrc(\s|$)|\.pem(\s|$)|\.key(\s|$)|id_rsa|id_ed25519|id_ecdsa|id_dsa|/credentials(\s|$|/)|/secrets/|\.aws/credentials|\.aws/config|\.ssh/|\.kube/config|kubeconfig(\s|$)|\.npmrc(\s|$)|\.netrc(\s|$)|wallet\.json|keystore)'

# 1. Reading sensitive files: cat .env, head ~/.ssh/id_rsa, etc.
if echo "$NORMALIZED" | grep -qiE "${READER}\s+[^|;&]*${SENSITIVE}"; then
    echo "BLOCKED: Bash command reads a sensitive file: '$COMMAND'"
    echo "Use the Read tool (covered by settings deny + guard-sensitive-files.sh) so blocks apply uniformly."
    echo "If you really need this content, ask the user for explicit confirmation."
    exit 2
fi

# 2. Sourcing .env into the shell (exfiltrates to env vars).
if echo "$NORMALIZED" | grep -qiE "${SOURCER}\s*[^|;&]*${SENSITIVE}"; then
    echo "BLOCKED: Sourcing a sensitive file into shell env: '$COMMAND'"
    echo "Sourced credentials become visible to subsequent tool calls. Refuse this path."
    exit 2
fi

# 3. Scanners on sensitive files (grep .env, awk over credentials, jq .aws/credentials).
if echo "$NORMALIZED" | grep -qiE "${SCANNER}\s+[^|;&]*${SENSITIVE}"; then
    echo "BLOCKED: Bash scanner reads a sensitive file: '$COMMAND'"
    echo "If you need a specific value, ask the user."
    exit 2
fi

# 4. Copy/move/archive sensitive files (data exfiltration vector).
if echo "$NORMALIZED" | grep -qiE "${COPIER}\s+[^|;&]*${SENSITIVE}"; then
    echo "BLOCKED: Bash command copies/moves a sensitive file: '$COMMAND'"
    echo "Copying credentials around expands their blast radius. Refuse this path."
    exit 2
fi

# 5. Catch-all: stdin redirect from a sensitive file (e.g., `python < .env`).
if echo "$NORMALIZED" | grep -qiE "<\s*[^|;&]*${SENSITIVE}"; then
    echo "BLOCKED: Stdin redirected from a sensitive file: '$COMMAND'"
    exit 2
fi

exit 0

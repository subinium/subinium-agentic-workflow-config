#!/usr/bin/env bash
# PreCompact + SessionEnd hook — captures structured handoff state.
#   PreCompact: writes handoff file + emits additionalContext for post-compact session
#   SessionEnd: writes handoff file only (no context injection — session ending)
# Handoff files persist at ~/.claude/handoffs/<session_id>-<event>-<timestamp>.md

set -euo pipefail

INPUT=$(cat)

EVENT=$(printf '%s' "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('hook_event_name', ''))
except Exception:
    print('')
" 2>/dev/null || printf '')

CWD=$(printf '%s' "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('workspace', {}).get('current_dir') or d.get('cwd') or '')
except Exception:
    print('')
" 2>/dev/null || printf '')

SESSION_ID=$(printf '%s' "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('session_id', 'default'))
except Exception:
    print('default')
" 2>/dev/null || printf 'default')

EXIT_REASON=$(printf '%s' "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('exit_reason', '') or d.get('reason', ''))
except Exception:
    print('')
" 2>/dev/null || printf '')

HANDOFF_DIR="$HOME/.claude/handoffs"
mkdir -p "$HANDOFF_DIR"

TS=$(date "+%Y%m%d-%H%M%S")
HANDOFF_FILE="$HANDOFF_DIR/${SESSION_ID:-default}-${EVENT:-event}-${TS}.md"

{
    echo "# Handoff — $EVENT @ $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    echo "**Session:** \`${SESSION_ID:-default}\`"
    echo "**CWD:** \`${CWD:-?}\`"
    [ -n "$EXIT_REASON" ] && echo "**Exit reason:** \`$EXIT_REASON\`"
    echo ""

    if [ -n "$CWD" ] && [ -d "$CWD" ] && (cd "$CWD" && git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
        cd "$CWD"
        BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || echo "(detached)")
        AHEAD=$(git rev-list --count "@{u}..HEAD" 2>/dev/null || echo '0')
        BEHIND=$(git rev-list --count "HEAD..@{u}" 2>/dev/null || echo '0')

        echo "**Branch:** \`$BRANCH\` (ahead: $AHEAD, behind: $BEHIND)"
        echo ""
        echo "## Modified files"
        local_count=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
        if [ "$local_count" -gt 0 ]; then
            git status --porcelain 2>/dev/null | head -30
        else
            echo "(clean)"
        fi
        echo ""
        echo "## Recent commits (last 5)"
        git log --oneline -5 --no-decorate 2>/dev/null || echo "(none)"
    else
        echo "**Branch:** (not a git repo)"
    fi
} > "$HANDOFF_FILE" 2>/dev/null || true

# For PreCompact only: emit additionalContext so post-compact session sees the handoff
if [ "$EVENT" = "PreCompact" ] && [ -f "$HANDOFF_FILE" ]; then
    CTX_MD=$(head -c 5000 "$HANDOFF_FILE")
    export CTX_MD
    python3 -c "
import json, os
print(json.dumps({
    'hookSpecificOutput': {
        'hookEventName': 'PreCompact',
        'additionalContext': os.environ.get('CTX_MD', '')
    }
}))
"
fi

exit 0

#!/usr/bin/env bash
# StopFailure hook — observability only.
# Logs rate-limit/auth/billing/server failures for diagnostics.
# StopFailure is observability-only — exit code and stdout are ignored by Claude Code.

set -euo pipefail

INPUT=$(cat)
LOG="$HOME/.claude/panel-activity.log"

PARSED=$(printf '%s' "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    reason = d.get('failure_reason', '') or d.get('reason', '') or d.get('matcher', '')
    sid = d.get('session_id', 'default')
    msg = (d.get('error', {}).get('message', '') if isinstance(d.get('error'), dict) else '')[:200]
    print(f'{sid}\t{reason}\t{msg}')
except Exception:
    print('default\tunknown\t')
" 2>/dev/null || printf 'default\tunknown\t')

SESSION=$(printf '%s' "$PARSED" | cut -f1)
REASON=$(printf '%s' "$PARSED" | cut -f2)
MSG=$(printf '%s' "$PARSED" | cut -f3)

TS=$(date "+%Y-%m-%d %H:%M:%S")
echo "$TS [STOP_FAILURE] session=$SESSION reason=$REASON msg=\"$MSG\"" >> "$LOG"

exit 0

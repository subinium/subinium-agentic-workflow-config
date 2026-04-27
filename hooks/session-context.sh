#!/usr/bin/env bash
# SessionStart hook — injects branch/dirty/today's commits into context.
# Silent skip for non-git directories. Output via hookSpecificOutput.additionalContext.

set -euo pipefail

INPUT=$(cat)

CWD=$(printf '%s' "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('workspace', {}).get('current_dir') or d.get('cwd') or '')
except Exception:
    print('')
" 2>/dev/null || printf '')

[ -z "$CWD" ] && exit 0
cd "$CWD" 2>/dev/null || exit 0

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || echo "(detached)")
DIRTY=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
TODAY_CT=$(git log --oneline --since=midnight --author="$(git config user.email)" 2>/dev/null | wc -l | tr -d ' ')
LAST_REL=$(git log -1 --format='%ar' 2>/dev/null || echo '—')
RECENT=$(git log --oneline -3 --no-decorate 2>/dev/null | sed 's/^/  - /' || echo '')
REPO_NAME=$(basename "$CWD")

CTX_MD=$(cat <<EOF
## Session start ($REPO_NAME)
- Branch: \`$BRANCH\` — dirty: $DIRTY files — last commit: $LAST_REL
- Today's commits (you): $TODAY_CT
- Recent commits:
$RECENT
EOF
)

# Truncate to ~5KB to respect context budget
CTX_MD=$(printf '%s' "$CTX_MD" | head -c 5000)

export CTX_MD
python3 -c "
import json, os
print(json.dumps({
    'hookSpecificOutput': {
        'hookEventName': 'SessionStart',
        'additionalContext': os.environ.get('CTX_MD', '')
    }
}))
"

exit 0

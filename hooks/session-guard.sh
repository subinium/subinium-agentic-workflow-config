#!/usr/bin/env bash
# session-guard.sh — UserPromptSubmit hook
# Reminds about Plan Mode for complex tasks, suggests relevant skills,
# and tracks session duration to prevent marathon sessions
# Input: JSON with "user_prompt" field on stdin

set -euo pipefail

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('user_prompt',''))" 2>/dev/null || echo "")

# Skip empty or short prompts
[ ${#PROMPT} -lt 20 ] && exit 0

# --- Session Timer ---
SESSION_ENV_DIR="$HOME/.claude/session-env"
SESSION_FILE="$SESSION_ENV_DIR/session-start"
mkdir -p "$SESSION_ENV_DIR"

# Initialize session start time if not set
if [ ! -f "$SESSION_FILE" ]; then
  date +%s > "$SESSION_FILE"
fi

SESSION_START=$(cat "$SESSION_FILE" 2>/dev/null || date +%s)
NOW=$(date +%s)
ELAPSED=$(( NOW - SESSION_START ))
ELAPSED_MIN=$(( ELAPSED / 60 ))

# Stale session detection (>24h) — reset
if [ "$ELAPSED_MIN" -gt 1440 ]; then
  date +%s > "$SESSION_FILE"
  ELAPSED_MIN=0
fi

# Session duration warnings
if [ "$ELAPSED_MIN" -ge 120 ]; then
  echo "Warning: Session running for ${ELAPSED_MIN}min. Long sessions (>2h) show diminishing returns. Strongly recommend: /session-wrap then /clear for a fresh start."
elif [ "$ELAPSED_MIN" -ge 60 ]; then
  echo "Hint: Session running for ${ELAPSED_MIN}min. Consider /session-wrap to save progress and start fresh."
fi

# --- /clear detection ---
if echo "$PROMPT" | grep -qiE "^/clear$"; then
  echo "Hint: Consider running /session-wrap first to save progress before clearing context."
  exit 0
fi

# --- Complex task detection ---
COMPLEX_PATTERNS="(build|implement|create|add feature|refactor|migrate|redesign|architect)"
if echo "$PROMPT" | grep -qiE "$COMPLEX_PATTERNS"; then
  if ! echo "$PROMPT" | grep -qiE "(fix|typo|small|quick|simple|just)"; then
    echo "Hint: This looks like a complex task. Consider Plan Mode (Shift+Tab) before implementing."
  fi
fi

exit 0

#!/usr/bin/env bash
# session-guard.sh — UserPromptSubmit hook
# Reminds about Plan Mode for complex tasks and suggests relevant skills
# Input: JSON with "user_prompt" field on stdin

set -euo pipefail

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('user_prompt',''))" 2>/dev/null || echo "")

# Skip empty or short prompts
[ ${#PROMPT} -lt 20 ] && exit 0

# Detect complex task patterns and suggest Plan Mode
COMPLEX_PATTERNS="(build|implement|create|add feature|refactor|migrate|redesign|architect)"
if echo "$PROMPT" | grep -qiE "$COMPLEX_PATTERNS"; then
  if ! echo "$PROMPT" | grep -qiE "(fix|typo|small|quick|simple|just)"; then
    echo "Hint: This looks like a complex task. Consider Plan Mode (Shift+Tab) before implementing."
  fi
fi

exit 0

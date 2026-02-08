#!/usr/bin/env bash
# Hook: PreCompact
# Backs up conversation context before compaction to prevent total context loss.

set -euo pipefail

INPUT=$(cat)

BACKUP_DIR="$HOME/.claude/compaction-backups"
mkdir -p "$BACKUP_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/pre-compact_${TIMESTAMP}.json"

echo "$INPUT" > "$BACKUP_FILE"

# Keep only last 20 backups
ls -t "$BACKUP_DIR"/pre-compact_*.json 2>/dev/null | tail -n +21 | xargs rm -f 2>/dev/null || true

echo "Context backed up before compaction: $BACKUP_FILE"
exit 0

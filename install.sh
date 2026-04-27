#!/usr/bin/env bash
# install.sh — Deploy Claude Code configuration to ~/.claude/
# Usage: bash install.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "=== Claude Code Configuration Installer ==="
echo ""

# --- 1. Backup existing top-level config ---
backup_if_exists() {
    local file="$1"
    if [ -f "$file" ]; then
        local backup="${file}.backup.${TIMESTAMP}"
        cp "$file" "$backup"
        echo "  Backed up: $(basename "$file") → $(basename "$backup")"
    fi
}

echo "[1/5] Backing up existing configuration..."
backup_if_exists "$CLAUDE_DIR/CLAUDE.md"
backup_if_exists "$CLAUDE_DIR/settings.json"

# --- 2. Create directories ---
echo "[2/5] Creating directories..."
mkdir -p "$CLAUDE_DIR/skills" "$CLAUDE_DIR/agents" "$CLAUDE_DIR/hooks" "$CLAUDE_DIR/rules"

# --- 3. Copy files ---
echo "[3/5] Copying configuration files..."

# Top-level files
cp "$SCRIPT_DIR/home-claude/CLAUDE.md"      "$CLAUDE_DIR/CLAUDE.md"
cp "$SCRIPT_DIR/home-claude/settings.json"  "$CLAUDE_DIR/settings.json"
echo "  CLAUDE.md, settings.json"

# Skills (each skill is a directory under home-claude/skills/)
for dir in "$SCRIPT_DIR/home-claude/skills"/*/; do
    [ -d "$dir" ] || continue
    name="$(basename "$dir")"
    rm -rf "$CLAUDE_DIR/skills/$name"
    cp -R "$dir" "$CLAUDE_DIR/skills/"
    echo "  skills/$name/"
done

# Agents (.md files under home-claude/agents/)
for f in "$SCRIPT_DIR/home-claude/agents"/*.md; do
    [ -f "$f" ] || continue
    cp "$f" "$CLAUDE_DIR/agents/"
    echo "  agents/$(basename "$f")"
done

# Rules (.md files under home-claude/rules/)
for f in "$SCRIPT_DIR/home-claude/rules"/*.md; do
    [ -f "$f" ] || continue
    cp "$f" "$CLAUDE_DIR/rules/"
    echo "  rules/$(basename "$f")"
done

# Hooks (.sh files under hooks/)
for f in "$SCRIPT_DIR/hooks"/*.sh; do
    [ -f "$f" ] || continue
    cp "$f" "$CLAUDE_DIR/hooks/"
    echo "  hooks/$(basename "$f")"
done

# --- 4. Set permissions and clean up old backups ---
echo "[4/5] Finalizing..."
chmod +x "$CLAUDE_DIR/hooks/"*.sh
find "$CLAUDE_DIR/skills" -name "*.sh" -exec chmod +x {} \;

# Keep latest 3 backups for each top-level file
for base in "$CLAUDE_DIR/CLAUDE.md" "$CLAUDE_DIR/settings.json"; do
    ls -t "${base}.backup."* 2>/dev/null | tail -n +4 | xargs -r rm -f
done

# --- 5. Verify ---
echo "[5/5] Verifying installation..."
ALL_GOOD=true
COUNT=0

verify() {
    if [ -e "$1" ]; then
        COUNT=$((COUNT + 1))
    else
        echo "  ✗ MISSING: ${1#$HOME/}"
        ALL_GOOD=false
    fi
}

verify "$CLAUDE_DIR/CLAUDE.md"
verify "$CLAUDE_DIR/settings.json"

for f in "$SCRIPT_DIR/home-claude/agents"/*.md; do
    verify "$CLAUDE_DIR/agents/$(basename "$f")"
done
for f in "$SCRIPT_DIR/home-claude/rules"/*.md; do
    verify "$CLAUDE_DIR/rules/$(basename "$f")"
done
for f in "$SCRIPT_DIR/hooks"/*.sh; do
    verify "$CLAUDE_DIR/hooks/$(basename "$f")"
done
for d in "$SCRIPT_DIR/home-claude/skills"/*/; do
    verify "$CLAUDE_DIR/skills/$(basename "$d")/SKILL.md"
done

echo ""
if [ "$ALL_GOOD" = true ]; then
    echo "=== Installation complete ($COUNT files verified) ==="
else
    echo "=== Installation completed with warnings ==="
fi

echo ""
echo "Next steps:"
echo "  1. Restart Claude Code to load the new configuration"
echo "  2. Run /skills to verify custom skills are loaded"
echo "  3. Validate with: npx agentlinter@latest ~/.claude"

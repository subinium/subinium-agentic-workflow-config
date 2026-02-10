#!/usr/bin/env bash
# install.sh — Deploy Claude Code configuration to ~/.claude/
# Usage: bash install.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "=== Claude Code Configuration Installer ==="
echo ""

# --- Backup existing config ---
backup_if_exists() {
    local file="$1"
    if [ -f "$file" ]; then
        local backup="${file}.backup.${TIMESTAMP}"
        cp "$file" "$backup"
        echo "  Backed up: $file → $backup"
    fi
}

echo "[1/7] Backing up existing configuration..."
backup_if_exists "$CLAUDE_DIR/CLAUDE.md"
backup_if_exists "$CLAUDE_DIR/settings.json"

# --- Create directories ---
echo "[2/7] Creating directories..."
mkdir -p "$CLAUDE_DIR/skills"
mkdir -p "$CLAUDE_DIR/agents"
mkdir -p "$CLAUDE_DIR/hooks"
mkdir -p "$CLAUDE_DIR/rules"

# --- Copy files ---
echo "[3/7] Copying configuration files..."

# Core config
cp "$SCRIPT_DIR/home-claude/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
echo "  CLAUDE.md"

cp "$SCRIPT_DIR/home-claude/settings.json" "$CLAUDE_DIR/settings.json"
echo "  settings.json"

# Skills
cp -r "$SCRIPT_DIR/home-claude/skills/ts-react" "$CLAUDE_DIR/skills/"
echo "  skills/ts-react/"

cp -r "$SCRIPT_DIR/home-claude/skills/code-review" "$CLAUDE_DIR/skills/"
echo "  skills/code-review/"

cp -r "$SCRIPT_DIR/home-claude/skills/git-workflow" "$CLAUDE_DIR/skills/"
echo "  skills/git-workflow/"

cp -r "$SCRIPT_DIR/home-claude/skills/systematic-debugging" "$CLAUDE_DIR/skills/"
echo "  skills/systematic-debugging/"

cp -r "$SCRIPT_DIR/home-claude/skills/tdd" "$CLAUDE_DIR/skills/"
echo "  skills/tdd/"

cp -r "$SCRIPT_DIR/home-claude/skills/ui-mockup" "$CLAUDE_DIR/skills/"
echo "  skills/ui-mockup/"

cp -r "$SCRIPT_DIR/home-claude/skills/security-audit" "$CLAUDE_DIR/skills/"
echo "  skills/security-audit/"

cp -r "$SCRIPT_DIR/home-claude/skills/pr-review" "$CLAUDE_DIR/skills/"
echo "  skills/pr-review/"

cp -r "$SCRIPT_DIR/home-claude/skills/scaffold" "$CLAUDE_DIR/skills/"
echo "  skills/scaffold/"

cp -r "$SCRIPT_DIR/home-claude/skills/deploy" "$CLAUDE_DIR/skills/"
echo "  skills/deploy/"

cp -r "$SCRIPT_DIR/home-claude/skills/ci-cd" "$CLAUDE_DIR/skills/"
echo "  skills/ci-cd/"

cp -r "$SCRIPT_DIR/home-claude/skills/spec" "$CLAUDE_DIR/skills/"
echo "  skills/spec/"

cp -r "$SCRIPT_DIR/home-claude/skills/session-wrap" "$CLAUDE_DIR/skills/"
echo "  skills/session-wrap/"

cp -r "$SCRIPT_DIR/home-claude/skills/context-prime" "$CLAUDE_DIR/skills/"
echo "  skills/context-prime/"

# Agents
cp "$SCRIPT_DIR/home-claude/agents/reviewer.md" "$CLAUDE_DIR/agents/"
echo "  agents/reviewer.md"

cp "$SCRIPT_DIR/home-claude/agents/architect.md" "$CLAUDE_DIR/agents/"
echo "  agents/architect.md"

cp "$SCRIPT_DIR/home-claude/agents/test-runner.md" "$CLAUDE_DIR/agents/"
echo "  agents/test-runner.md"

cp "$SCRIPT_DIR/home-claude/agents/orchestrator.md" "$CLAUDE_DIR/agents/"
echo "  agents/orchestrator.md"

cp "$SCRIPT_DIR/home-claude/agents/codebase-researcher.md" "$CLAUDE_DIR/agents/"
echo "  agents/codebase-researcher.md"

cp "$SCRIPT_DIR/home-claude/agents/docs-researcher.md" "$CLAUDE_DIR/agents/"
echo "  agents/docs-researcher.md"

cp "$SCRIPT_DIR/home-claude/agents/security-researcher.md" "$CLAUDE_DIR/agents/"
echo "  agents/security-researcher.md"

cp "$SCRIPT_DIR/home-claude/agents/perf-researcher.md" "$CLAUDE_DIR/agents/"
echo "  agents/perf-researcher.md"

# Rules
cp "$SCRIPT_DIR/home-claude/rules/review-standards.md" "$CLAUDE_DIR/rules/"
echo "  rules/review-standards.md"

cp "$SCRIPT_DIR/home-claude/rules/error-handling.md" "$CLAUDE_DIR/rules/"
echo "  rules/error-handling.md"

cp "$SCRIPT_DIR/home-claude/rules/confidence-gate.md" "$CLAUDE_DIR/rules/"
echo "  rules/confidence-gate.md"

# Hooks
cp "$SCRIPT_DIR/hooks/block-destructive-git.sh" "$CLAUDE_DIR/hooks/"
echo "  hooks/block-destructive-git.sh"

cp "$SCRIPT_DIR/hooks/format-on-save.sh" "$CLAUDE_DIR/hooks/"
echo "  hooks/format-on-save.sh"

cp "$SCRIPT_DIR/hooks/backup-before-compact.sh" "$CLAUDE_DIR/hooks/"
echo "  hooks/backup-before-compact.sh"

cp "$SCRIPT_DIR/hooks/session-guard.sh" "$CLAUDE_DIR/hooks/"
echo "  hooks/session-guard.sh"

cp "$SCRIPT_DIR/hooks/warn-large-files.sh" "$CLAUDE_DIR/hooks/"
echo "  hooks/warn-large-files.sh"

# --- Make hooks and scripts executable ---
echo "[4/7] Setting permissions..."
chmod +x "$CLAUDE_DIR/hooks/"*.sh
echo "  hooks marked executable"
if [ -d "$CLAUDE_DIR/skills/security-audit/scripts" ]; then
    chmod +x "$CLAUDE_DIR/skills/security-audit/scripts/"*.sh
    echo "  security-audit scripts marked executable"
fi

# --- Clean up old backups (keep latest 3) ---
echo "[5/7] Cleaning up old backups..."
for base in "$CLAUDE_DIR/CLAUDE.md" "$CLAUDE_DIR/settings.json"; do
    BACKUPS=$(ls -t "${base}.backup."* 2>/dev/null | tail -n +4)
    if [ -n "$BACKUPS" ]; then
        echo "$BACKUPS" | xargs rm -f
        echo "  Removed old backups for $(basename "$base")"
    fi
done

# --- Verify installation ---
echo "[6/7] Verifying installation..."
echo ""

ALL_GOOD=true
FILES_TO_CHECK=(
    "$CLAUDE_DIR/CLAUDE.md"
    "$CLAUDE_DIR/settings.json"
    "$CLAUDE_DIR/skills/ts-react/SKILL.md"
    "$CLAUDE_DIR/skills/code-review/SKILL.md"
    "$CLAUDE_DIR/skills/git-workflow/SKILL.md"
    "$CLAUDE_DIR/skills/systematic-debugging/SKILL.md"
    "$CLAUDE_DIR/skills/tdd/SKILL.md"
    "$CLAUDE_DIR/skills/ui-mockup/SKILL.md"
    "$CLAUDE_DIR/skills/security-audit/SKILL.md"
    "$CLAUDE_DIR/skills/pr-review/SKILL.md"
    "$CLAUDE_DIR/skills/scaffold/SKILL.md"
    "$CLAUDE_DIR/skills/deploy/SKILL.md"
    "$CLAUDE_DIR/skills/ci-cd/SKILL.md"
    "$CLAUDE_DIR/agents/reviewer.md"
    "$CLAUDE_DIR/agents/architect.md"
    "$CLAUDE_DIR/agents/test-runner.md"
    "$CLAUDE_DIR/agents/orchestrator.md"
    "$CLAUDE_DIR/agents/codebase-researcher.md"
    "$CLAUDE_DIR/agents/docs-researcher.md"
    "$CLAUDE_DIR/agents/security-researcher.md"
    "$CLAUDE_DIR/agents/perf-researcher.md"
    "$CLAUDE_DIR/hooks/block-destructive-git.sh"
    "$CLAUDE_DIR/hooks/format-on-save.sh"
    "$CLAUDE_DIR/hooks/backup-before-compact.sh"
    "$CLAUDE_DIR/hooks/session-guard.sh"
    "$CLAUDE_DIR/skills/spec/SKILL.md"
    "$CLAUDE_DIR/skills/session-wrap/SKILL.md"
    "$CLAUDE_DIR/rules/review-standards.md"
    "$CLAUDE_DIR/rules/error-handling.md"
    "$CLAUDE_DIR/rules/confidence-gate.md"
    "$CLAUDE_DIR/skills/context-prime/SKILL.md"
    "$CLAUDE_DIR/hooks/warn-large-files.sh"
    "$CLAUDE_DIR/skills/security-audit/scripts/quick-scan.sh"
)

for f in "${FILES_TO_CHECK[@]}"; do
    if [ -f "$f" ]; then
        echo "  ✓ $(echo "$f" | sed "s|$HOME|~|")"
    else
        echo "  ✗ $(echo "$f" | sed "s|$HOME|~|") — MISSING"
        ALL_GOOD=false
    fi
done

echo ""

echo "[7/7] Summary"
TOTAL=${#FILES_TO_CHECK[@]}
if [ "$ALL_GOOD" = true ]; then
    echo "=== Installation complete! ($TOTAL files) ==="
else
    echo "=== Installation completed with warnings ==="
fi

echo ""
echo "Next steps:"
echo "  1. Restart Claude Code to load the new configuration"
echo "  2. Run /skills to verify custom skills are loaded"
echo "  3. (Optional) Install official Anthropic skills:"
echo "     claude install-skill https://github.com/anthropics/skills"
echo ""

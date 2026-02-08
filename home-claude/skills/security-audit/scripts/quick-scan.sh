#!/usr/bin/env bash
# quick-scan.sh — Automated security scan for common vulnerabilities
# Usage: bash ~/.claude/skills/security-audit/scripts/quick-scan.sh [directory]

set -euo pipefail

DIR="${1:-.}"
ISSUES=0

echo "=== Security Quick Scan ==="
echo "Directory: $DIR"
echo ""

# 1. Hardcoded secrets patterns
echo "--- Scanning for hardcoded secrets ---"
PATTERNS=(
    'AKIA[0-9A-Z]{16}'           # AWS Access Key
    'sk-[a-zA-Z0-9]{20,}'        # OpenAI / Stripe secret key
    'ghp_[a-zA-Z0-9]{36}'        # GitHub PAT
    'glpat-[a-zA-Z0-9\-]{20}'    # GitLab PAT
    'xoxb-[0-9]+-[a-zA-Z0-9]+'   # Slack Bot Token
    'password\s*[:=]\s*["\x27][^"\x27]{4,}' # Hardcoded passwords
)

for PATTERN in "${PATTERNS[@]}"; do
    MATCHES=$(grep -rnE "$PATTERN" "$DIR" \
        --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' \
        --include='*.py' --include='*.env.example' \
        --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
        2>/dev/null || true)
    if [ -n "$MATCHES" ]; then
        echo "FOUND: Pattern '$PATTERN'"
        echo "$MATCHES"
        ISSUES=$((ISSUES + 1))
    fi
done

# 2. Dangerous function usage
echo ""
echo "--- Scanning for dangerous functions ---"
DANGEROUS=(
    'eval('
    'Function('
    'child_process.exec('
    'dangerouslySetInnerHTML'
    'innerHTML\s*='
    '__proto__'
    'document\.write('
)

for FUNC in "${DANGEROUS[@]}"; do
    MATCHES=$(grep -rn "$FUNC" "$DIR" \
        --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' \
        --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
        2>/dev/null || true)
    if [ -n "$MATCHES" ]; then
        echo "FOUND: $FUNC"
        echo "$MATCHES"
        ISSUES=$((ISSUES + 1))
    fi
done

# 3. .env in git
echo ""
echo "--- Checking .env files ---"
if [ -d "$DIR/.git" ]; then
    ENV_IN_GIT=$(git -C "$DIR" ls-files '*.env' '.env.*' 2>/dev/null || true)
    if [ -n "$ENV_IN_GIT" ]; then
        echo "WARNING: .env files tracked in git:"
        echo "$ENV_IN_GIT"
        ISSUES=$((ISSUES + 1))
    else
        echo "OK: No .env files tracked in git"
    fi
fi

# 4. Dependency audit
echo ""
echo "--- Dependency audit ---"
if [ -f "$DIR/package-lock.json" ] || [ -f "$DIR/package.json" ]; then
    cd "$DIR" && npm audit --production 2>/dev/null | tail -5 || echo "npm audit unavailable"
fi
if [ -f "$DIR/requirements.txt" ] || [ -f "$DIR/pyproject.toml" ]; then
    pip audit 2>/dev/null | tail -5 || echo "pip audit unavailable"
fi

# Summary
echo ""
echo "=== Scan Complete ==="
if [ "$ISSUES" -eq 0 ]; then
    echo "No issues found."
else
    echo "Found $ISSUES potential issue(s). Review above."
fi
exit 0

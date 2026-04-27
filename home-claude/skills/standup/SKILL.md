---
name: standup
description: Generates a daily/weekly standup summary from git commits and GitHub PRs across one or all ~/Projects repos. Use when the user asks for a "standup", "오늘 뭐했어", "이번 주 한 일", "데일리 리포트", or end-of-day summary. Supports --all-repos and --week flags.
author: subinium
user-invocable: true
disable-model-invocation: true
allowed-tools: Bash, Read
argument-hint: "[--all-repos] [--week]"
---

# Standup

Read-only. Summarize git activity for today (default) or last 7 days, current repo (default) or all `~/Projects/*`.

## Arguments

Parse `$ARGUMENTS`:
- `--all-repos` → scan all `~/Projects/*` directories (default: cwd only)
- `--week` → window is `"7 days ago"` (default: `"midnight"`)

## Process

### 1. Determine scope
```bash
ALL=0
WINDOW="midnight"
case " $ARGUMENTS " in
  *" --all-repos "*) ALL=1 ;;
esac
case " $ARGUMENTS " in
  *" --week "*) WINDOW="7 days ago" ;;
esac
```

### 2. Collect commits

**If `--all-repos`:**
```bash
EMAIL=$(git config --global user.email)
for d in "$HOME"/Projects/*/; do
  cd "$d" 2>/dev/null || continue
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || continue
  out=$(git log --since="$WINDOW" --author="$EMAIL" --no-merges \
        --pretty=format:'  - `%h` %s _(%ar)_' 2>/dev/null)
  [ -n "$out" ] && printf '\n**%s**\n%s\n' "$(basename "$d")" "$out"
done
```

**Else (cwd only):**
```bash
git log --since="$WINDOW" --author="$(git config user.email)" --no-merges \
  --pretty=format:'- `%h` %s _(%ar)_'
```

### 3. Collect PRs (cwd repo only — gh requires repo context)
```bash
SINCE_DATE=$(date -v-7d +%Y-%m-%d 2>/dev/null || date -d "7 days ago" +%Y-%m-%d)
gh pr list --author @me --state merged \
  --search "merged:>$SINCE_DATE" \
  --json number,title,mergedAt --limit 20 2>/dev/null || true
gh pr list --author @me --state open \
  --json number,title,updatedAt --limit 20 2>/dev/null || true
```

### 4. In-progress signal (cwd repo only)
```bash
git symbolic-ref --short HEAD 2>/dev/null
git status --porcelain 2>/dev/null | wc -l
```

## Output

Format as Markdown:

```markdown
## Standup — YYYY-MM-DD (window: today | last week)

### Done
- **repo-name** (N commits)
  - `abc1234` feat: ... _(3h ago)_

### PRs
| # | Title | State | When |
|---|---|---|---|

### In progress
- Branch `feature/x`, N uncommitted files

### Blockers
(none auto-detected — fill manually)
```

## Constraints
- Read-only. No commits, pushes, branch changes, or `gh pr create`.
- Skip repos with zero activity in window (don't render empty rows).
- Tolerate non-git directories under `~/Projects/` silently.
- Korean response per global CLAUDE.md.

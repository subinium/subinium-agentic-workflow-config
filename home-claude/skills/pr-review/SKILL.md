---
name: pr-review
description: Review GitHub PRs with parallel analysis — security, quality, tests, UX. Use when asked to review a PR, check a pull request, or analyze PR changes
author: subinium
user-invocable: true
disable-model-invocation: true
args: PR number or URL
---

# PR Review

Review a GitHub Pull Request with parallel agent analysis.

## Usage
```
/pr-review 123
/pr-review https://github.com/org/repo/pull/123
```

## Process

### Step 1: Gather PR Context (parallel)
Run these simultaneously:
- `gh pr view $ARGUMENTS --json title,body,author,labels,reviewDecision,changedFiles`
- `gh pr diff $ARGUMENTS`
- `gh pr checks $ARGUMENTS`

### Step 2: Parallel Analysis
Spawn 3 agents simultaneously:

**Agent 1 — Code Quality & Security:**
- Read every changed file in full (not just diff lines)
- Check for: hardcoded secrets, injection vectors, auth gaps, type safety
- Check for: breaking API changes, missing error handling

**Agent 2 — Tests & CI:**
- Check CI pipeline status
- Verify new code has tests
- Run `npm run test` or `pytest` locally if CI is unclear
- Check test coverage on changed files

**Agent 3 — UX & Product:**
- Check for missing loading/error/empty states
- Check responsive design considerations
- Check accessibility (semantic HTML, ARIA, keyboard nav)
- Verify mock data handles edge cases (empty, long text, many items)

### Step 3: Synthesize & Output

## Output Format

```
## PR Review: #[number] [title]
**Author**: @author | **Files changed**: N | **Lines**: +N / -N

### CI Status
| Check | Status |
|-------|--------|
| Lint | ✅/❌ |
| Tests | ✅/❌ |
| Types | ✅/❌ |
| Build | ✅/❌ |

### Critical (block merge)
- **[file:line]** Description
  → Fix: ...

### Important (should address)
- **[file:line]** Description
  → Fix: ...

### UX/Product
- **[file:line]** Description
  → Suggestion: ...

### Nits
- **[file:line]** Description

### Verdict: APPROVE | REQUEST CHANGES | NEEDS DISCUSSION

**Summary**: 1-3 sentence overview.
**Action items**: numbered list for the PR author.
```

### Step 4 (optional, if requested):
Post review comments directly to GitHub:
```bash
gh api repos/{owner}/{repo}/pulls/{number}/reviews \
  --method POST \
  -f body="Review summary" \
  -f event="COMMENT"
```

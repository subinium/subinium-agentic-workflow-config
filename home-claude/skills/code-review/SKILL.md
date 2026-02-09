---
name: code-review
description: Structured code review for PRs and local changes with parallel agent analysis. Use when asked to review code, check changes, audit a diff, or analyze code quality
author: subinium
user-invocable: true
disable-model-invocation: true
args: PR number or branch name (optional)
---

# Code Review

Perform a structured code review. Supports local changes and GitHub PRs.

## Instructions

### If `$ARGUMENTS` is a PR number or URL:
1. Run `gh pr diff $ARGUMENTS` to get the diff
2. Run `gh pr view $ARGUMENTS` to get PR description and metadata
3. Run `gh pr checks $ARGUMENTS` to see CI status

### If no arguments (local changes):
1. Run `git diff --staged` first. If empty, `git diff`. If empty, `git diff HEAD~1`.

### Then for all cases:
2. **Spawn parallel agents** for efficiency:
   - Agent 1: Read all changed files in full for context
   - Agent 2: Run `npm run lint` / `npm run test` / `npx tsc --noEmit` (if applicable)
3. Review against the checklist below.
4. For PRs: draft GitHub review comments using `gh api` if requested.

## Output Format

```
## Code Review: [PR title or branch name]

### CI Status
- Lint: PASS/FAIL | Tests: PASS/FAIL | Types: PASS/FAIL

### Critical (must fix before merge)
- **[file:line]** Description
  **Fix**: Suggested fix or approach

### Important (should fix)
- **[file:line]** Description
  **Fix**: Suggested fix or approach

### Suggestions (nice to have)
- **[file:line]** Description

### Summary
- **Files reviewed**: N
- **Issues found**: N critical, N important, N suggestions
- **Overall**: APPROVE / REQUEST CHANGES / NEEDS DISCUSSION
```

## Constraints

- DO NOT modify, fix, or edit any code during the review process
- DO NOT commit any changes
- Only report findings and suggest fixes — never apply them

## Checklist

### Critical
- [ ] Security: SQL injection, XSS, command injection, path traversal
- [ ] Security: Hardcoded secrets, API keys, passwords
- [ ] Security: Missing authentication/authorization checks
- [ ] Data loss: Destructive operations without confirmation
- [ ] Data loss: Missing database migrations or backward compatibility
- [ ] Runtime errors: Null/undefined access, unhandled exceptions
- [ ] Breaking changes: Public API or contract changes without versioning

### Important
- [ ] Type safety: Proper TypeScript types, no `any`
- [ ] Error handling: Meaningful error messages, proper error boundaries
- [ ] Tests: New functionality has tests, edge cases covered
- [ ] Performance: N+1 queries, unnecessary re-renders, large bundle imports
- [ ] API contracts: Breaking changes documented, backward compatible
- [ ] Accessibility: Semantic HTML, ARIA labels, keyboard navigation
- [ ] UX: Loading states, error states, empty states handled

### Suggestions
- [ ] Code clarity: Naming, comments, complexity reduction
- [ ] DRY: Duplicated logic that could be extracted
- [ ] Patterns: Consistency with existing codebase patterns
- [ ] Documentation: Updated README, JSDoc for public APIs

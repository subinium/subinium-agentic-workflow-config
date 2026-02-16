---
name: security-audit
description: Run a comprehensive security audit — OWASP Top 10, secrets detection, dependency vulnerabilities, injection vectors, auth checks
author: subinium
user-invocable: true
disable-model-invocation: true
---

# Security Audit

Run a security audit on the current codebase or changes.

## Usage
```
/security-audit            # Quick mode (default): <60 seconds, changed files only
/security-audit --full     # Full mode: 5-10 minutes, entire codebase
```

## Modes

### Quick Mode (default)
- Scope: changed files only (`git diff`)
- Checks: Secrets, Injection, Auth (categories 1-3)
- Time limit: 60 seconds
- Best for: pre-commit, pre-push reviews

### Full Mode (`--full`)
- Scope: entire codebase
- Checks: All 6 categories
- Time limit: 10 minutes
- Best for: release preparation, initial audits, compliance

## Constraints

- DO NOT modify, fix, or patch any code during the audit
- DO NOT commit changes or alter git state
- Only report vulnerabilities and suggest remediations — never apply them

## Process

### Quick Mode
1. Run `git diff --staged` (or `git diff`, or `git diff HEAD~1`) to scope
2. Read changed files and their direct imports
3. Check categories 1-3 (Secrets, Injection, Auth)
4. Run `quick-scan.sh` on changed files
5. Output findings

### Full Mode
1. Identify all source files in the project
2. Read ALL source files and their dependencies
3. Check all 6 categories below
4. Run automated checks
5. Output structured findings

## Audit Categories

### 1. Secrets & Credentials (CRITICAL)
- [ ] No hardcoded API keys, tokens, passwords, private keys in source
- [ ] `.env` files in `.gitignore`
- [ ] No secrets in git history: `git log -p --all -S 'password\|secret\|api_key\|private_key'`
- [ ] No secrets in error messages or logs
- [ ] Run `grep -rn 'AKIA\|sk-\|ghp_' .` for common key patterns

### 2. Injection (CRITICAL)
- [ ] SQL: Parameterized queries only, no string concatenation
- [ ] XSS: All user input sanitized before rendering, `dangerouslySetInnerHTML` audited
- [ ] Command injection: No `exec()`, `eval()`, `child_process.exec()` with user input
- [ ] Path traversal: No `../` in file paths from user input, use `path.resolve()` + validation
- [ ] Template injection: No user input in template strings evaluated server-side
- [ ] NoSQL injection: Validate MongoDB query operators from user input

### 3. Authentication & Authorization (CRITICAL)
- [ ] All protected routes have auth middleware
- [ ] JWT: proper validation, expiration, secure storage (httpOnly cookies, not localStorage)
- [ ] Password hashing: bcrypt/argon2 with proper salt rounds (>=12)
- [ ] Session management: regenerate on login, invalidate on logout
- [ ] RBAC/ABAC: permission checks on every sensitive endpoint
- [ ] Rate limiting on auth endpoints (login, register, password reset)

### 4. Data Protection (HIGH)
- [ ] HTTPS only, HSTS headers
- [ ] Sensitive data encrypted at rest (passwords, PII, financial data)
- [ ] CORS properly configured (not `*` in production)
- [ ] Content-Security-Policy headers set
- [ ] No PII in logs, analytics, or error tracking
- [ ] Cookie flags: `Secure`, `HttpOnly`, `SameSite`

### 5. Dependency Security (HIGH)
- [ ] Run `npm audit` / `pip audit` / `cargo audit`
- [ ] Check for known vulnerabilities in dependencies
- [ ] No unnecessary permissions in dependency manifests
- [ ] Lock file committed (`package-lock.json`, `poetry.lock`)
- [ ] Verify dependency integrity (checksums)

### 6. Infrastructure (MEDIUM)
- [ ] Environment variables for all configuration
- [ ] No debug mode in production
- [ ] Error messages don't leak stack traces or internal paths
- [ ] File upload: type validation, size limits, virus scanning
- [ ] Database: connection pooling, query timeouts, prepared statements

## Quick Scan Script

Run the bundled automated scanner for common vulnerabilities:

```bash
bash ~/.claude/skills/security-audit/scripts/quick-scan.sh .
```

This checks: hardcoded secrets (AWS, OpenAI, GitHub, Slack patterns), dangerous functions (eval, exec, innerHTML), .env in git, and dependency audit.

## Manual Checks

```bash
# JavaScript/TypeScript
npm audit --production
npx eslint --no-eslintrc -c '{"rules":{"no-eval":"error","no-implied-eval":"error"}}' .

# Python
pip audit
ruff check --select S .  # security rules

# Git history
git log --all --oneline -S 'password' --diff-filter=A
git log --all --oneline -S 'secret' --diff-filter=A

# Common patterns
grep -rn 'eval(' --include='*.ts' --include='*.tsx' --include='*.js' .
grep -rn 'dangerouslySetInnerHTML' --include='*.tsx' --include='*.jsx' .
grep -rn 'innerHTML' --include='*.ts' --include='*.js' .
```


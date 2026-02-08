---
name: deploy
description: Pre-deploy checklist, environment validation, and deployment workflows for Vercel/Docker/CI. Use when asked to deploy, check deploy readiness, or prepare for production
author: subinium
user-invocable: true
disable-model-invocation: true
args: target (vercel | docker | check)
---

# Deploy

Pre-deployment validation and deployment workflows.

## Usage
```
/deploy check           # Run pre-deploy checklist only
/deploy vercel          # Vercel deployment workflow
/deploy docker          # Docker build + validation
```

## Pre-Deploy Checklist (`/deploy check`)

Run ALL of these before any deployment:

### 1. Code Quality
```bash
# TypeScript
npx tsc --noEmit
npm run lint
npm run test

# Python
mypy .
ruff check .
pytest
```
- [ ] All checks pass with zero errors
- [ ] No `console.log` / `print()` debug statements in production code
- [ ] No `TODO` or `FIXME` comments that block release

### 2. Security
- [ ] No hardcoded secrets: `grep -rn 'AKIA\|sk-\|ghp_\|password.*=' --include='*.ts' --include='*.tsx' --include='*.py' .`
- [ ] `.env.example` is up to date with all required variables (no values)
- [ ] All API routes have authentication/authorization checks
- [ ] `npm audit --production` shows no critical vulnerabilities
- [ ] CORS configured for production domains only
- [ ] CSP headers set

### 3. Environment
- [ ] All required environment variables documented in `.env.example`
- [ ] Production environment variables are set (check via deployment platform)
- [ ] Database migrations are ready and backward compatible
- [ ] No `localhost` or `127.0.0.1` URLs in production code

### 4. Performance
- [ ] Bundle size check: `npx next build` shows no unexpected increases
- [ ] Images optimized (Next.js `<Image>` component, not `<img>`)
- [ ] No N+1 queries in new API routes
- [ ] Lazy loading for heavy components (`dynamic()` or `React.lazy()`)

### 5. UX
- [ ] Loading states for all async operations
- [ ] Error states with user-friendly messages
- [ ] Empty states for lists and data views
- [ ] Mobile responsive (test at 320px, 768px, 1280px)
- [ ] Metadata (title, description, OG tags) set for all pages

### 6. Git
- [ ] All changes committed, working tree clean
- [ ] Branch is up to date with main
- [ ] PR approved (if applicable)
- [ ] Conventional commit messages on all commits

## Vercel Deployment (`/deploy vercel`)

### Process
1. Run `/deploy check` first
2. Verify `vercel.json` or `next.config.js` settings
3. Check environment variables: `vercel env ls`
4. Deploy:
   - Preview: `vercel` (default)
   - Production: `vercel --prod`
5. Verify deployment:
   - Check build logs for warnings
   - Test critical paths on preview URL
   - Check Vercel Analytics for errors

### Vercel-Specific Checks
- [ ] `next.config.js`: no experimental features in production unless intentional
- [ ] Edge functions have proper error handling
- [ ] ISR/SSG pages have proper `revalidate` values
- [ ] Middleware doesn't block critical paths
- [ ] Environment variables prefixed with `NEXT_PUBLIC_` for client-side access

## Docker Build (`/deploy docker`)

### Process
1. Run `/deploy check` first
2. Validate `Dockerfile`:
   - Multi-stage build for smaller image
   - Non-root user
   - `.dockerignore` includes `node_modules`, `.env`, `.git`
3. Build and test:
   ```bash
   docker build -t app:latest .
   docker run --rm -p 3000:3000 app:latest
   ```
4. Health check endpoint responds

### Docker Security Checks
- [ ] Base image is pinned to specific version (not `latest`)
- [ ] No secrets in build args or layers
- [ ] `USER` instruction sets non-root user
- [ ] `.dockerignore` excludes sensitive files
- [ ] Health check configured

## Output Format

```
## Deploy Readiness Report

### Target: [vercel|docker|check]

### Checks
| Category | Status | Issues |
|----------|--------|--------|
| Code Quality | ✅/❌ | ... |
| Security | ✅/❌ | ... |
| Environment | ✅/❌ | ... |
| Performance | ✅/❌ | ... |
| UX | ✅/❌ | ... |
| Git | ✅/❌ | ... |

### Blockers (must fix)
1. ...

### Warnings (should fix)
1. ...

### Ready to Deploy: YES / NO
```

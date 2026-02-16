---
name: ship
description: Stage, verify, commit, and push in one command — smart staging, parallel quality gates, conventional commits, optional deploy. Use when asked to "ship it", "commit and push", or "send it"
author: subinium
user-invocable: true
disable-model-invocation: true
args: flags (--deploy | --skip-checks)
---

# Ship

Stage, verify, commit, and push your changes in one workflow.

## Usage
```
/ship                  # Full workflow: stage → check → commit → push
/ship --skip-checks    # Emergency: stage → commit → push (skip quality gates)
/ship --deploy         # Full workflow + deploy after push
```

---

## Step 1: Smart Staging

1. Run `git status` to see all changes
2. Auto-exclude from staging:
   - `.env`, `.env.*`
   - `*credentials*`, `*.pem`, `*.key`
   - `*id_rsa*`, `*id_ed25519*`
   - `*.sqlite`, `*.db`
3. If excluded files are found, warn the user:
   > "Excluded from staging: .env.local (contains secrets). Add manually with `git add .env.local` if intentional."
4. Stage all remaining changes: `git add` with specific file paths (not `git add .`)

---

## Step 2: Quality Gate (skip with `--skip-checks`)

Run **all three checks in parallel** (separate Bash calls):

```bash
# Parallel execution — do NOT run sequentially
npm run lint          # or ruff check .
npx tsc --noEmit      # or mypy .
npm run test          # or pytest
```

### On failure:
- Show which checks failed with summary output
- Ask the user: "Quality gate failed. Options: (1) Fix issues, (2) Ship anyway, (3) Abort"
- If user says "fix": attempt auto-fix (lint --fix, etc.), then re-run checks
- If user says "ship anyway": proceed with a warning commit message prefix
- If user says "abort": stop entirely

---

## Step 3: Commit

1. Run `git diff --staged` to see what will be committed
2. Analyze changes and generate a conventional commit message:
   - Use the appropriate type: `feat:`, `fix:`, `refactor:`, `docs:`, `chore:`, `test:`
   - Keep subject under 72 chars, imperative mood
   - Add body explaining WHY if the change is non-obvious
3. Show the proposed commit message to the user for approval
4. Commit with the approved message (include `Co-Authored-By` line)

---

## Step 4: Push

1. Push to remote: `git push`
2. If remote branch doesn't exist: `git push -u origin HEAD`
3. If push fails (e.g., behind remote):
   - Run `git pull --rebase` then retry push
   - If rebase conflicts, stop and alert the user

---

## Step 5: Deploy (only with `--deploy`)

Auto-detect deployment target:

### Vercel
```bash
# Check for vercel.json or .vercel/
vercel --prod
```

### Docker
```bash
# Check for Dockerfile
docker build -t $(basename $(pwd)):latest .
docker push $(basename $(pwd)):latest
```

### Custom
- Check for `deploy` script in package.json: `npm run deploy`
- If no deployment target found, tell the user and suggest setting one up

---

## Constraints

- NEVER stage files matching the exclusion patterns without explicit user approval
- ALWAYS show the commit message for user approval before committing
- If quality gates fail and user doesn't choose to proceed, do NOT commit
- On `--skip-checks`, add to commit body: `[skip-checks: user requested emergency ship]`

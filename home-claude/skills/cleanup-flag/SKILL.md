---
name: cleanup-flag
description: Traces all references to a feature flag/gate across the codebase and produces a removal PR draft. Use when ramping up a flag, removing a kill switch, or "feature flag 정리", "플래그 제거", "킬스위치 제거". Auto-detects flag system (GrowthBook, LaunchDarkly, env vars, custom dictionary). Read-only — produces a draft markdown file, never runs gh pr create.
author: subinium
user-invocable: true
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash, Write
argument-hint: "<flag-name> [--keep-on|--keep-off]"
---

# Cleanup Flag

Trace a feature flag through the codebase and produce a removal PR draft. NEVER executes `git push` or `gh pr create` — produces draft markdown file only.

## Arguments

- `<flag-name>` (required, first positional) — e.g. `enable_new_dashboard`
- `--keep-on` (default) — collapse code to the "flag enabled" branch
- `--keep-off` — collapse code to the "flag disabled" branch

## Process

### 1. Detect flag system

Check in order, stop at first match:
- `package.json` has `@growthbook/*` → GrowthBook
- `package.json` has `launchdarkly-*` → LaunchDarkly
- `package.json` has `unleash-*` → Unleash
- `.env*` files contain `<FLAG_NAME>` (uppercased) → env var
- `grep -r "FEATURE_FLAGS\|featureFlags\|flags\." src/ app/ lib/` → custom dictionary
- Else → ask user which system

### 2. Find all references
```bash
FLAG="<flag-name>"
FLAG_UPPER=$(echo "$FLAG" | tr '[:lower:]' '[:upper:]')

rg -n "\b$FLAG\b|\b$FLAG_UPPER\b" \
  --type-add 'web:*.{ts,tsx,js,jsx,mjs,cjs}' \
  --type web --type py --type rust 2>/dev/null
```

Group findings into:
- **Read sites** (gates: `if (flags.X)`, `useFeatureFlag('X')`, `isEnabled('X')`)
- **Definition sites** (config files, env files, flag dashboards)
- **Test sites** (mocks, fixtures)
- **Documentation** (READMEs, runbooks)

### 3. Propose collapse

For each read site, show a before/after diff based on `--keep-on` (default) or `--keep-off`:

```diff
- if (useFeatureFlag('enable_new_dashboard')) {
-   return <NewDashboard />;
- } else {
-   return <OldDashboard />;
- }
+ return <NewDashboard />;
```

If `--keep-off`, collapse the opposite way (keep the `else` branch, delete the `if` branch).

### 4. Output PR draft

Save to `./CLEANUP_FLAG_<flag-name>.md` in cwd:

```markdown
# Cleanup: <flag-name>

## Decision
Keep ON (default) | Keep OFF — based on `$ARGUMENTS`

## Detected flag system
GrowthBook | LaunchDarkly | env var | custom — at `<file:line>`

## Sites affected (N)

| File | Line | Type | Action |
|---|---|---|---|
| `app/dashboard/page.tsx` | 42 | read | collapse to NewDashboard |
| `tests/dashboard.test.ts` | 18 | test | delete 'flag off' case |

## Manual review needed
- [ ] Tests covering both branches — pick one or split into two PRs
- [ ] Telemetry / analytics events tied to the flag (search analytics keys with the flag name)
- [ ] Documentation, runbooks, on-call notes
- [ ] Flag definition removal — leave for a SECOND PR after this one merges

## Rollback path
Revert this PR; flag definition is at `<file:line>`.

## Suggested commit
```
refactor(flags): remove gate <flag-name>, keep ON
```
```

## Constraints
- DO NOT modify any application code — propose only via the markdown draft.
- DO NOT delete the flag definition in the same PR (separate followup PR).
- DO NOT run `gh pr create` or `git push` — output the markdown draft only.
- DO NOT call this on flags currently in active rollout (check the flag dashboard first if available).
- Korean response per global CLAUDE.md.

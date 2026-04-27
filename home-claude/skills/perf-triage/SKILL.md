---
name: perf-triage
description: Performance triage entry point — bundle analysis, build profiling, Lighthouse CI, Next.js Cache Components inspection. Use when asked "why is X slow", "perf 분석", "번들 사이즈 확인", "Lighthouse 점수", "빌드 시간 측정". Delegates deep root-cause analysis to perf-researcher agent.
author: subinium
user-invocable: true
disable-model-invocation: true
allowed-tools: Bash, Read, Grep, Glob, Task
argument-hint: "[--bundle|--build|--lighthouse|--all]"
---

# Perf Triage

Quick performance triage with delegation to `perf-researcher` agent for deep analysis. Read-only — never modifies code.

## Arguments

Parse `$ARGUMENTS`:
- `--bundle` — bundle size analysis only
- `--build` — build time profiling only
- `--lighthouse` — Lighthouse CI run only (requires running dev server or live URL)
- `--all` (default) — bundle + build + lighthouse in parallel

## Process

### 1. Detect project type

```bash
[ -f next.config.js ] || [ -f next.config.mjs ] || [ -f next.config.ts ] && echo "nextjs"
[ -f vite.config.js ] || [ -f vite.config.ts ] && echo "vite"
[ -f astro.config.mjs ] && echo "astro"
[ -f remix.config.js ] && echo "remix"
```

### 2. Run measurements (parallel Bash calls in single message)

**Bundle (Next.js)**:
```bash
ANALYZE=true npm run build 2>&1 | tail -80
du -sh .next/static .next/standalone .next/server 2>/dev/null
find .next/static/chunks -name "*.js" -size +200k 2>/dev/null | head -10
```

**Build profile**:
```bash
{ time npm run build; } 2>&1 | tail -30
```

**Lighthouse**:
```bash
# Prefer LHCI if configured
if [ -f lighthouserc.* ] || [ -f .lighthouserc.* ]; then
  npx --no-install lhci autorun 2>&1 | tail -40
else
  # Fall back to single run against localhost:3000
  npx --no-install lighthouse http://localhost:3000 \
    --output=json --output-path=/tmp/lh.json --quiet 2>&1
  jq '.categories | to_entries | map({(.key): .value.score}) | add' /tmp/lh.json 2>/dev/null
fi
```

### 3. Quick verdict

Surface ONLY red flags (suppress noise):

| Metric | Threshold |
|---|---|
| Main JS chunk | > 250 KB gzip |
| Total JS bundle | > 1 MB |
| Build time | > 60s |
| Lighthouse Perf | < 70 |
| LCP | > 2.5s |
| CLS | > 0.1 |
| INP (replaces FID 2024+) | > 200ms |

### 4. Delegate to perf-researcher

If any red flag triggered, dispatch via `Task(subagent_type='perf-researcher', ...)` with:
- The metric that failed
- The hot file paths from bundle analyzer
- A scoped optimization request (don't ask for "everything" — pick the worst metric)

## Output

```markdown
## Perf Triage — YYYY-MM-DD

### Measurements
| Metric | Value | Threshold | Status |
|---|---|---|---|
| Main JS chunk | 312 KB gz | < 250 KB | RED |
| Build time | 47s | < 60s | OK |
| Lighthouse Perf | 82 | > 70 | OK |

### Red Flags
- Main JS chunk over budget by 25%
- (none) for others

### Delegated
Dispatched to `perf-researcher` for: main chunk root cause + reduction plan

### Quick Wins (safe to do without further analysis)
1. Remove unused `lodash` full import — switch to `lodash-es/specific`
2. Lazy-load chart library on dashboard route only
```

## Constraints
- Don't modify code — measurement and delegation only.
- ALWAYS run measurements in parallel, never sequential.
- Korean response per global CLAUDE.md.
- If no project type detected, ask the user — don't guess.

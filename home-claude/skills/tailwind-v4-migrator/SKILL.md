---
name: tailwind-v4-migrator
description: Detects and migrates Tailwind CSS v3 → v4 — finds v3/v4 mixed syntax (silent failure mode flagged in CLAUDE.md), converts tailwind.config.js to @theme CSS-first config, applies @custom-variant for darkMode, runs the official codemod. Use when "Tailwind v4 업그레이드", "tailwind 마이그레이션", or after upgrading the package. Defaults to dry-run.
author: subinium
user-invocable: true
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash, Write, Edit
argument-hint: "[--dry-run|--apply] [--strict]"
---

# Tailwind v3 → v4 Migrator

Detect and migrate Tailwind v3 → v4 with explicit handling for the silent-failure mode where v3 and v4 syntax co-exist (per global CLAUDE.md).

## HARD RULES — these are blocking detections (SEV-CRITICAL)

The user's CLAUDE.md explicitly notes: *"Do NOT mix v3 and v4 syntax — version mismatch causes silent failures."* Any of these means the codebase is in a broken state and MUST be resolved before deploy:

1. **`tailwindcss@^4` in package.json + `tailwind.config.js` exists** → v4 ignores it silently; styles missing
2. **`@tailwind base/components/utilities` directives** + v4 installed → must be `@import "tailwindcss"` (single line)
3. **`darkMode: 'class'` in JS config** + v4 → must be `@custom-variant dark (&:where(.dark, .dark *))` in CSS
4. **`extend.colors` in JS config** + v4 → must be `@theme` block in CSS
5. **`tailwindcss-animate` plugin import** + v4 → plugin syntax changed; verify support OR replace with `tw-animate-css`
6. **PostCSS config has `tailwindcss` plugin** + v4 → must be `@tailwindcss/postcss` (different package)

For each, the migration MUST resolve to one consistent version. Detection blocks; resolution is the migration's job.

## SOFT RULES — warnings (preferences, not silent failures)

- Custom variants in JS config that have CSS-first equivalents → suggest move
- Old `@apply` chains that v4 deprecates → suggest utility composition or component class
- Dynamic class strings (`className={\`text-\${color}-500\`}`) — v4 stricter content scan; flag for verification
- Missing `@source` directive in v4 (v4 auto-detects content paths but explicit is safer for monorepos)

## Process

### 1. Detect current version
```bash
cat package.json | jq -r '.dependencies.tailwindcss // .devDependencies.tailwindcss // "missing"'
ls tailwind.config.{js,ts,mjs,cjs} 2>/dev/null
ls postcss.config.{js,ts,mjs,cjs} 2>/dev/null
ls app/globals.css src/index.css src/styles/globals.css 2>/dev/null
```

Establish: current version, presence of JS config, presence of v3 directives.

### 2. Run all HARD-rule detections in parallel

```bash
# v3 directives
rg -n '@tailwind\s+(base|components|utilities)' --type css --type scss

# JS config presence with v4 installed
[ -f tailwind.config.js ] && grep -q '"tailwindcss":\s*"\^4' package.json && echo "BLOCKER: JS config + v4"

# darkMode in JS config
rg -n "darkMode\s*:" tailwind.config.* 2>/dev/null

# extend.colors in JS config
rg -n "extend\s*:" tailwind.config.* 2>/dev/null

# PostCSS plugin
rg -n "tailwindcss" postcss.config.* 2>/dev/null
```

### 3. Snapshot detection
Read all detected v3 sites + all CSS files using `@theme` or `@custom-variant`. Build the migration map: every v3 site needs a v4 destination.

### 4. Apply (only if `--apply` AND no detections show "ambiguous", default is `--dry-run`)

Run the official codemod first:
```bash
npx @tailwindcss/upgrade@latest --dry-run  # always dry first
```

Then surgical edits:
- `app/globals.css`: replace `@tailwind` directives with `@import "tailwindcss";`
- Move `darkMode: 'class'` → `@custom-variant dark (&:where(.dark, .dark *))` in CSS
- Move `theme.extend.colors`, `theme.extend.fontFamily` → `@theme { --color-...: ...; }` block
- Update `postcss.config.*`: `tailwindcss` → `@tailwindcss/postcss`
- Delete `tailwind.config.{js,ts}` ONLY after verifying all extends are migrated

### 5. Verify

```bash
npm install  # picks up new postcss plugin
npm run build  # must succeed
# Visual diff: take a screenshot before/after of one page
```

If build fails, REVERT (the dry-run output is your rollback recipe).

### 6. `--strict` mode

If `--strict`, also fix soft-rule warnings:
- Replace `@apply` chains with utility composition
- Add explicit `@source` directives for monorepo packages
- Quarantine dynamic class strings into safelist comments

## Output

```markdown
## Tailwind v4 Migration — <project>

### Current state
- tailwindcss: <version>
- JS config: present | absent
- v3 directives in CSS: <count>

### Blockers (HARD — must resolve)
- BLOCKER: JS config + v4 installed → silent failure mode
- BLOCKER: `@tailwind base/components/utilities` in `app/globals.css`

### Warnings (SOFT)
- ...

### Migration plan
| # | Action | Source | Destination |
|---|---|---|---|
| 1 | Replace v3 directives | `app/globals.css:1-3` | `@import "tailwindcss";` |
| 2 | Move darkMode | `tailwind.config.js:5` | `app/globals.css` `@custom-variant` |
| 3 | Move colors | `tailwind.config.js:12-30` | `app/globals.css` `@theme` block |
| 4 | Update PostCSS | `postcss.config.js:3` | `@tailwindcss/postcss` |
| 5 | Delete JS config | `tailwind.config.js` | (after all extends migrated) |

### Verification command
```bash
npm install && npm run build && npm run dev
```
Take a screenshot of one styled page before vs after; visually confirm no regression.

### Rollback
```bash
git checkout tailwind.config.* postcss.config.* app/globals.css
npm install
```
```

## Constraints

- Default `--dry-run` — never auto-apply without explicit `--apply` (HARD)
- ALWAYS run the official `@tailwindcss/upgrade` codemod first; treat manual edits as supplements, not replacements
- ALWAYS verify with a build before declaring success
- Don't delete `tailwind.config.*` until confirming all `theme.extend` content is migrated to `@theme`
- Korean response per global CLAUDE.md

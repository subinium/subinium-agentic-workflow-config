---
name: share-assets
description: Generates OG images and HN/GeekNews/LinkedIn/Twitter launch posts from a project README in a casual viral tone (NOT corporate/AI-sounding). Use when launching, posting "Show HN", or "공유용 자료", "런칭 포스트", "OG 이미지 만들어줘", "긱뉴스 글", "트윗 초안".
author: subinium
user-invocable: true
disable-model-invocation: true
allowed-tools: Read, Write, Bash
argument-hint: "[--platform=hn|gn|linkedin|twitter|all] [--readme=<path>]"
---

# Share Assets

Generate launch/share artifacts from a project README. Casual, human, punchy tone — NOT corporate or AI-sounding (per global CLAUDE.md "Writing & Communications").

## Arguments

- `--platform=hn|gn|linkedin|twitter|all` — which drafts to generate (default: all)
- `--readme=<path>` — source README (default: `./README.md`)

## Tone rules (HARD — these are non-negotiable per CLAUDE.md)

- NO em dashes used decoratively
- NO excessive exclamation marks (max 1 per post)
- NO filler ("I'm excited to share", "blown away by", "thrilled to announce")
- NO corporate speak ("at scale", "leverage", "synergy", "best-in-class")
- NO AI tells ("As a developer who...", "In today's world,...")
- DO write like a real person on a Friday afternoon
- DO lead with a specific number or surprising fact when one exists
- DO state what's interesting in 1 sentence before any context

## Process

### 1. Read source
- Read the README at `--readme` (default `./README.md`)
- Extract: project name, one-line description, key feature, install/usage, links, screenshots
- Read `package.json` / `Cargo.toml` for version, repo URL

### 2. Per-platform draft (parallel writes if `--platform=all`)

**Hacker News (`SHARE_HN.md`)**:
- Title: noun phrase, ≤80 chars, NO version numbers in title (HN guideline), NO "Show HN:" prefix unless actual launch
- Body: 3-5 sentences. Lead with what's different. End with link.
- Sample: `Title: A Claude Code plugin that verifies refactors with 4 checks before they ship`

**GeekNews (`SHARE_GN.md`)** — Korean tech community:
- Title: 한국어, 80자 이내, 본질만
- Body: 본문은 한국어. 5-10 bullet points. 첫 줄은 "왜 만들었는가". 마지막 줄은 GitHub 링크.
- 톤: 캐주얼하지만 정확. 자기 자랑 톤 금지.

**LinkedIn (`SHARE_LINKEDIN.md`)**:
- Body: 3 short paragraphs. Lead with a specific outcome or stat. End with a question or CTA.
- NO hashtag spam (max 3, all relevant)
- NO "I'm humbled to..." — say what happened directly

**Twitter/X (`SHARE_TWITTER.md`)**:
- Single tweet ≤ 270 chars (leave room for link)
- Optional: 4-tweet thread variant if there are 3+ surprising things
- NO image alt text guidance — handle in OG asset

### 3. OG image (`og.png`)

Generate a 1200×630 social card. Two strategies:
- **If `satori` + `sharp` are installed** in cwd: emit a `.tsx` template, run `npx tsx generate-og.tsx > og.png`
- **Otherwise**: emit a fallback HTML template (`og.html`) the user can screenshot at 1200×630

Template structure:
- Title (24-48pt, max 2 lines)
- One-line description
- Author handle (top right)
- Repo URL (bottom)
- Background: solid dark + accent color from project (extract from logo if present)

### 4. Output index

Write `SHARE.md` summarizing all generated artifacts:
```markdown
# Share kit — <project name>

| Platform | File | Notes |
|---|---|---|
| HN | SHARE_HN.md | <title> |
| GeekNews | SHARE_GN.md | <한글 제목> |
| LinkedIn | SHARE_LINKEDIN.md | (3 para) |
| Twitter | SHARE_TWITTER.md | (single + 4-tweet thread) |
| OG | og.png | 1200×630 |

## Suggested posting order
1. Twitter (immediate audience reaction)
2. HN (after 30min if Twitter resonates)
3. GeekNews (Korean audience, parallel to HN)
4. LinkedIn (next day, professional framing)
```

## Constraints (SOFT, but enforce HARD on tone)

- Don't post anywhere — generate drafts only
- Don't fabricate stats / numbers (HARD)
- Don't include claims the README doesn't support (HARD)
- Korean response per global CLAUDE.md (LinkedIn/HN drafts in English; GN draft in Korean)
- If README is too sparse to generate good copy, return a list of questions instead of bad drafts

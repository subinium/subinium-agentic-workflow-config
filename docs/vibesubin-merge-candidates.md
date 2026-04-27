# Merge Candidates for vibesubin

What's in this `~/.claude/` setup that's worth pulling into [`vibesubin`](https://github.com/subinium/vibesubin) — i.e., things that beat or extend what `obra/superpowers`, `garrytan/gstack`, and `affaan-m/everything-claude-code` already ship.

Scope: portable patterns and skills that work cross-host (Claude Code, Codex, Cursor, Copilot — anything [`skills.sh`](https://skills.sh)-compatible). Claude-Code-only mechanics (Agent Teams, EnterPlanMode, `subagent_type`, hooks, `settings.json`) are out of scope for vibesubin and stay in this harness repo.

---

## TL;DR — High-Confidence Ports

These exist nowhere in the three reference repos as portable skills. They're the strongest candidates:

1. **`approach-first`** — required pre-implementation approach statement (technique / alternative / risk)
2. **`confidence-gate`** — 6-point self-check before non-trivial code
3. **`plan-template`** — risk-first plan with file ownership and parallel groups
4. **`iterative-planning`** — plan-execute-adjust loop (plans as hypotheses)
5. **`code-review-calibration`** — explicit anti-overpraise rule for review/critique
6. **`bias-to-implementation`** — "just build it" signal detection + research time-box
7. **`audit-i18n-nfc`** — NFC/NFD normalization auditor for CJK file paths/URLs (generalizes `i18n-nfc-auditor`)
8. **`audit-migration`** — SQL/Prisma/Drizzle/sqlx migration safety review (data loss, lock contention)
9. **`hunt-flake`** — re-run failing tests N times to isolate flaky from genuine failures
10. **`bump-deps`** — risk-tiered (patch / minor / major / security) dependency upgrade proposals
11. **`cleanup-flag`** — full feature-flag removal trace + PR draft (auto-detects GrowthBook/LD/env)
12. **`extract-prd`** — distill a PRD + plan from the current conversation
13. **`session-wrap` / `context-prime`** — handoff and session-priming workflows
14. **`session-management-rules`** — short focused sessions, recency-bias mitigation, `/clear` discipline

The rest of this doc explains why each of these is differentiating, organized by competitor.

---

## vs `obra/superpowers`

`superpowers` excels at: TDD-heavy, spec-first methodology, subagent-driven-development, autonomous multi-hour runs.

What this setup adds that `superpowers` doesn't:

| Feature | Why It's New | vibesubin home |
|---|---|---|
| **Parallelism mandate as a rule, not a tip** | superpowers chains subagents sequentially through TDD steps. This setup makes "spawn 3–5 parallel agents over 1 monolithic agent" a hard rule, with explicit anti-pattern callouts. | New meta-skill: `parallel-by-default` |
| **Approach-First gate** | superpowers gets to a spec; this gate adds a pre-code "state your approach in 3 sentences" checkpoint specifically for the moment between spec-approval and code-writing. | `approach-first` skill |
| **Confidence Gate (6-point)** | Prevents the agent from re-implementing existing code, using outdated APIs, or fixing symptoms instead of root causes. None of this is in `superpowers/skills/`. | `confidence-gate` skill |
| **Iterative plan-execute-adjust loop** | superpowers treats the plan as a contract once approved. This treats it as a hypothesis with a feedback step after each highest-risk execution. | Extension to `ship-cycle` or new `iterative-plan` skill |
| **"Just build it" signal detection** | superpowers always interviews. This recognizes "그냥 해", "just do it", "ㄱㄱ" and skips planning entirely. Good fit for vibesubin's `harsh mode` philosophy — opt-in, direct. | New umbrella mode: `/vibesubin direct` |
| **Code Review Calibration rule** | superpowers reviews are thorough but tonally encouraging. This explicitly forbids overpraising basic/mediocre code. Aligns with vibesubin's existing `audit-security` evidence-only ethos. | Inject into `audit-*` skills as a shared review-tone reference |
| **Recency bias mitigation** | Long-session degradation isn't addressed. This documents the failure mode + escape hatches (`/clear` with summary, trim verbose logs, restate constraints before deploys). | New process skill: `manage-context` |

Concrete example: the **Confidence Gate's 6th point** ("Can you state your technical approach in one sentence? If not, you don't understand the problem well enough.") — this single rule catches more bad starts than any other line in this config. Worth porting verbatim.

---

## vs `garrytan/gstack`

`gstack` excels at: persona-based roles (CEO, designer, eng manager, QA, security officer, release engineer), structured product reviews, browser-based QA.

What this setup adds:

| Feature | Why It's New | vibesubin home |
|---|---|---|
| **Specialized researcher split** | `gstack` has one or two reviewer personas. This splits research into 4 axes — `codebase-researcher` (internal), `docs-researcher` (external), `security-researcher`, `perf-researcher` — each with different tool sets and prompts. | Skills: `research-codebase`, `research-docs`, plus existing `audit-security`, `audit-perf` |
| **Risk-first plan ordering** | `gstack` plans by role hand-off. This orders steps by *uncertainty*: verify the highest-risk assumption first, before committing to the full plan. | `plan-template` skill |
| **File-ownership enforcement** | "every step must own specific files — no two steps modify the same file" → enables true parallelism. Not in `gstack`. | `plan-template` skill |
| **Skill/config edit boundary** | When asked to edit `~/.claude/skills/*/SKILL.md` or `settings.json`, edit ONLY that file. Never delete/modify project source as a side effect. Catches a real failure mode `gstack` doesn't address. | Cross-cutting rule injected into all skills |
| **NFC/NFD i18n auditor** | `gstack` doesn't address Unicode normalization. This is a silent prod bug for any team shipping CJK filenames through Supabase/Vercel/S3. | `audit-i18n-nfc` skill |
| **Migration reviewer with severity tags** | `gstack` has a security officer. This adds an SQL/Prisma/Drizzle migration auditor specifically for lock contention, data loss, and rollback safety. | `audit-migration` skill |
| **Flake hunter** | Re-runs failing tests N times, correlates with timing/order/network/env. `gstack` QA is browser-based and doesn't address test-suite flakiness. | `hunt-flake` skill |

`gstack` is heavy ceremony (23 specialists). vibesubin's strength is the inverse — single-word `/vibesubin` sweeps. The picks above all fit the "evidence-only specialist" pattern vibesubin already uses.

---

## vs `affaan-m/everything-claude-code`

`everything-claude-code` excels at: token optimization, memory persistence, AgentShield security scanning, research-first development, 12+ language coverage.

What this setup adds:

| Feature | Why It's New | vibesubin home |
|---|---|---|
| **Parallelism as a CLAUDE.md hard rule** | ECC documents parallelization as an *optimization*. This makes it a *mandate* with explicit anti-patterns ("Doing step 1 → waiting → step 2 → waiting → step 3 when steps are independent"). | Meta-rule injected into umbrella `/vibesubin` synthesis |
| **Approach-first + Confidence Gate as auto-loaded rules** | ECC has skills but no auto-loaded behavior rules at this granularity. These two rules fire on every non-trivial task without being invoked. | Already fits vibesubin's auto-trigger model |
| **"Just build it" / bias-to-implementation** | ECC defaults to research-first. This explicitly time-boxes research at 20% and detects shortcut signals. Useful counterweight inside vibesubin's sweep — operator can ask for "ship-mode" sweep. | `/vibesubin ship` mode (analog to `harsh` / `easy`) |
| **`cleanup-flag` skill** | Generic feature-flag removal flow, auto-detects GrowthBook / LaunchDarkly / env vars / custom. Not in ECC. | Direct port |
| **`bump-deps` with risk tiers** | ECC has dependency awareness; this groups proposals by patch / minor / major / security and never commits without explicit user approval. | Direct port; aligns with vibesubin's read-only-by-default pattern |
| **`extract-prd`** | Distill a structured PRD + plan from the current conversation. Solves the "we just brainstormed for an hour, now what?" problem. | New skill — fits vibesubin's `write-for-ai` + spec philosophy |
| **`standup` aggregator** | Multi-repo daily/weekly summary from git + GitHub. Trivial to port; useful for indie operators (vibesubin's audience). | Direct port |

ECC's strength is the security/memory/eval infrastructure. vibesubin's audience is "people who ship real things but weren't trained as developers" — which means **the high-leverage ports are the meta-rules** (approach-first, confidence-gate, code-review-calibration), not the heavy infrastructure.

---

## What Stays in the Harness (Not Portable)

These are Claude-Code-specific and stay in this repo, **not** vibesubin:

- **Agent Teams** (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`, `TeamCreate`, `SendMessage`, `blockedBy`)
- **`EnterPlanMode`** trigger
- **`subagent_type=...`** values (Claude-Code-specific names)
- **`settings.json` `deny` rules** (Claude Code permission system)
- **Hook scripts** (`session-guard.sh`, `block-destructive-git.sh`, `format-on-save.sh`, `warn-large-files.sh`, `typecheck-on-edit.sh`, `backup-before-compact.sh`) — Claude Code lifecycle events
- **Auto-loaded `~/.claude/rules/*.md`** files — file-system convention specific to this harness

If vibesubin wants equivalents, they need to be re-shaped as `SKILL.md` files that any host can load.

---

## Suggested Port Order

Phase 1 — meta-rules (highest leverage, smallest skill files):
1. `approach-first`
2. `confidence-gate`
3. `code-review-calibration` (or merge into existing `audit-*` skills as a shared reference)

Phase 2 — process skills:
4. `plan-template` (risk-first, file ownership, parallel groups)
5. `iterative-plan` (plan-execute-adjust loop)
6. `extract-prd`
7. `manage-context` (session-wrap + context-prime + recency-bias mitigation merged)

Phase 3 — specialist skills (each direct port from this repo's agents):
8. `audit-i18n-nfc`
9. `audit-migration`
10. `hunt-flake`
11. `bump-deps`
12. `cleanup-flag`
13. `standup`

Phase 4 — modes for `/vibesubin` umbrella (stack with `harsh` / `explain`):
14. `/vibesubin ship` — bias-to-implementation, skip deep research, time-box at 20%
15. `/vibesubin parallel` — make implicit parallelism explicit in the synthesis report

---

## Open Questions Before Porting

1. **Auto-load equivalent**: This repo loads `rules/*.md` automatically. vibesubin skills only fire on description match. The meta-rules (approach-first, confidence-gate) lose force if they're not always-on. Two options:
   - Inject them as auto-trigger skills with broad description matchers ("any non-trivial code task")
   - Bundle them into the umbrella `/vibesubin` `SKILL.md` as required pre-flight checks
2. **Conflict with vibesubin's read-only sweep mode**: `bias-to-implementation` is the opposite of vibesubin's default sweep. It's only useful when called directly (`/refactor-verify`, `/setup-ci`). Document the mode boundary clearly.
3. **`hunt-flake` requires test-runner access**: Some hosts (Cursor inline, Copilot Chat) can't run shell commands easily. Either gate behind capability check or document host requirements.
4. **`code-review-calibration` collision**: `audit-security` and `refactor-verify` already enforce evidence-only. Merging may be cleaner than a separate skill — one shared `references/review-tone.md`.

---

*Source repo: [`subinium-agentic-workflow-config`](https://github.com/subinium/subinium-agentic-workflow-config). Last updated 2026-04-27.*

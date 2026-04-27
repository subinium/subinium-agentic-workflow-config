# Role Routing

When multiple skills/agents do related work, this is the decision tree. Pick once; don't chain redundantly.

## Planning chain

User intent: *"I want to build X."*

```
prd-extract → architect agent → spec  →  implementation
   (extract       (decide               (write
   spec from       structure)            tests/code)
   convo)
```

| Skill / Agent | Use when | Don't use when |
|---|---|---|
| **`/prd-extract`** | A 30+ min brainstorm just ended; you have requirements scattered through messages and need a captured PRD before context gets compacted. | Requirements are already in a doc; the user only described one feature in 2 messages. |
| **`architect` agent** | The PRD is captured (or trivial) but the *structure* is open — multiple valid architectures, cross-layer concerns, new module boundaries. | Single-file change, well-established pattern, or you can write the approach in 3 sentences. |
| **(skill removed)** | Spec-driven flow (Phase 1 interview → Phase 2 implement) is no longer in this config. Use `prd-extract` + `architect` directly. | — |

**Rule**: skip steps freely. A typo fix needs none of these. A new auth subsystem probably needs all three.

## Review chain

User intent: *"Review this code."*

```
code-review skill  →  reviewer agent  →  /review (plugin)  →  /pr-review (none — removed)
   (entry skill)        (deep agent)        (broad PR review)
```

| Skill / Agent | Use when | Don't use when |
|---|---|---|
| **`/code-review`** | Local diff or specific files — you want a structured 3-tier (Critical/Important/Suggestions) report. Default entry point. | The change is already on a remote PR with CI signal. |
| **`reviewer` agent (Task subagent)** | Spawned by `code-review` for deep analysis, or directly when orchestrating multi-file review across many concerns. | Single file < 50 lines — the main thread is faster. |
| **`/review` (plugin)** | Reviewing a remote PR by URL/number — leverages the plugin's PR fetching and CI context. | Local working-tree review — use `/code-review`. |
| **`/security-review` (plugin)** | Security-only audit on the current branch. | Functional review — use `/code-review`. |

**Rule**: never run all four on the same change. Pick the entry point (`/code-review` for local, `/review` for PR) and let it spawn sub-agents.

## Research chain

User intent: *"How does X work / what's best for Y?"*

```
codebase-researcher  ──┐
                       ├─→  researcher (when both needed)
docs-researcher      ──┘
```

| Agent | Use when | Don't use when |
|---|---|---|
| **`codebase-researcher`** | Pure internal — "how does our auth flow work", "where is X used". No web access; fast. | Question requires API docs or version comparison. |
| **`docs-researcher`** | Pure external — "how do I use Tailwind v4 `@custom-variant`", "what changed in Next.js 16". | Question requires reading our code first. |
| **`researcher`** | Both internal AND external — "how should we adopt this library given our existing setup". | Either pure-internal or pure-external — use the specialist. |
| **`security-researcher`** | CVE check, auth flow audit, secret-exposure review. | Functional review — use `reviewer`. |
| **`perf-researcher`** | Profiling, bundle bloat, N+1 queries, render bottlenecks. | Behavioral bug — use `codebase-researcher`. |

**Rule**: pick the narrowest specialist. The cross-cutting `researcher` should be a fallback, not a default.

## Ship chain

User intent: *"Commit and push" / "Ship it" / "Release."*

| Skill | Use when |
|---|---|
| **`/ship`** | Day-to-day — stage, verify, conventional commit, push. Default. |
| **`/release v0.7.0`** | Tagged release with version bump, CHANGELOG, GitHub release. Dual-stack (Node + Rust) supported. |
| **`/standup`** | Reporting what was shipped, not shipping itself. |

## Anti-patterns

- Running `/code-review` AND spawning `reviewer` agent AND running `/review` on the same change. Pick one entry point.
- Using `architect` for a one-line bug fix.
- Using `researcher` (cross-cutting) when you know the question is purely internal or purely external.
- Running `prd-extract` after every short conversation — it's for capturing accumulated context, not summarizing 5 messages.

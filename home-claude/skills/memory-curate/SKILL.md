---
name: memory-curate
description: Audit and curate the per-project memory system at ~/.claude/projects/<encoded-cwd>/memory/ — finds duplicates, stale entries, missing-pointer files, oversized MEMORY.md, and entries that violate the user/feedback/project/reference taxonomy. Use when memory feels noisy, before /clear of a long-running project, or when memories stop influencing behavior.
author: subinium
user-invocable: true
disable-model-invocation: true
allowed-tools: Read, Bash, Grep, Glob, Edit, Write
argument-hint: "[--project=<path>] [--dry-run] [--prune]"
---

# Memory Curator

You audit and curate the file-based memory system Claude Code maintains under `~/.claude/projects/<encoded-cwd>/memory/`. Read-only by default — never delete a memory without explicit `--prune` and a reported reason.

## Why this skill exists

Memory grows silently. After a few months a project's `memory/` directory accumulates duplicate feedback entries, stale references to renamed files, oversized `MEMORY.md` indexes (>200 lines truncate at runtime), and miscategorized entries (e.g., a `project_*` memory that's really a `feedback_*`). The harness loads every entry, so noise dilutes signal.

This skill brings the directory back to its load-bearing state.

## Memory taxonomy (from the harness)

Four types — never mix:

| Type | Filename prefix | Content |
|------|----------------|---------|
| `user` | `user_*.md` | Who the user is, role, expertise, preferences |
| `feedback` | `feedback_*.md` | Corrections + validated approaches. Must include **Why:** + **How to apply:** |
| `project` | `project_*.md` | Decisions, deadlines, stakeholder context. Must include **Why:** + **How to apply:** |
| `reference` | `reference_*.md` | Pointers to external systems (Linear, Slack, Grafana) |

`MEMORY.md` is an **index only**, no frontmatter, one line per entry, under 200 lines total.

## Process

### 1. Resolve target project
- If `--project=<path>` provided, encode that path. Otherwise use `pwd`.
- Path encoding: `/Users/subin/Projects/foo` → `-Users-subin-Projects-foo`.
- Locate `~/.claude/projects/<encoded>/memory/`. Skip with a clear message if it doesn't exist.

### 2. Collect inventory
- List all `*.md` files in the memory directory.
- Parse frontmatter from each (name, description, type).
- Read `MEMORY.md` and extract every linked file.

### 3. Run audits in parallel

Spawn these checks concurrently — each writes findings to a structured report.

**A. Orphan check** — files in `memory/` not referenced by `MEMORY.md`, and links in `MEMORY.md` pointing to non-existent files.

**B. Duplicate / near-duplicate check** — entries with overlapping descriptions or rules. Use cosine similarity on description + first 200 chars of body, threshold 0.75.

**C. Taxonomy violations** — `feedback_*` files missing **Why:** or **How to apply:** lines. `project_*` files without those lines. Files whose `type:` frontmatter contradicts their filename prefix.

**D. Staleness** — file references (e.g., `lib/foo.ts`) inside memories that no longer exist in the current repo. Date references in `project_*` memories that have passed.

**E. Index health** — `MEMORY.md` line count (warn at 150, hard limit at 200), entries longer than 150 chars, missing or extra entries vs. the inventory.

**F. Type imbalance** — flag if `feedback_*` outnumbers `user_* + project_* + reference_*` combined by 3:1 (sign of correction-only memory, missing validations).

### 4. Produce report

```
# Memory audit — <project>

**Inventory:** N files, M index entries
**MEMORY.md:** L lines (limit 200)

## Findings

### 🔴 Critical (breaks at runtime)
- ...

### 🟡 Warnings (degrades over time)
- ...

### 🔵 Suggestions
- ...

## Recommended actions
1. ...
```

### 5. On `--prune` flag

For each Critical finding the user explicitly approves:
- **Orphan file**: delete the file
- **Broken index link**: remove the `MEMORY.md` line
- **Duplicate**: merge bodies, keep the more specific filename, delete the other, update `MEMORY.md`

For each prune, log: file, reason, what was removed. Never prune Warnings or Suggestions automatically.

### 6. On `--dry-run` (default)

Produce the report. Do not modify any files. End with a numbered action list the user can apply manually or by re-running with `--prune`.

## Output principles

- Lead with the highest-leverage finding. Most projects have one Critical issue and ten Suggestions; report them in that order.
- For duplicates, show both file paths and a 2-line rationale for which to keep.
- For staleness, quote the exact stale reference (`lib/old-name.ts`) so the user can find/replace.
- Never fabricate findings. If a directory is clean, say so in one sentence.

## Anti-patterns

- Editing memory content to "improve wording" — the user wrote it, leave it alone unless deduplicating.
- Auto-pruning without `--prune`.
- Treating `MEMORY.md` like a memory file — it's an index.
- Recommending splits or merges without reading the body.

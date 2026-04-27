---
name: audit-migration
description: Thin slash-command wrapper around the migration-reviewer agent — audits SQL/Prisma/Supabase/sqlx/Drizzle migration files for data loss, lock contention, missing indexes, and rollback safety. Use before db push, before Supabase deploy, or "마이그레이션 리뷰", "DB 스키마 검토".
author: subinium
user-invocable: true
disable-model-invocation: false
allowed-tools: Task
argument-hint: "[<migration-file-or-dir>]"
---

# Audit Migration

Slash-command entry point for the `migration-reviewer` agent. The agent reads migrations and produces a severity-tagged report; this skill routes there with the right scope.

## When this skill fires

- Direct call: `/audit-migration` or `/audit-migration prisma/migrations/20260427_add_index/`
- Before destructive ops: any time the user is about to run `prisma migrate deploy`, `supabase db push`, `sqlx migrate run`, or `drizzle-kit push`
- Trigger phrases: "마이그레이션 리뷰", "DB 스키마 검토", "schema migration audit"

## Process

1. **Detect migration system** if no path argument given:
   - `prisma/migrations/` → Prisma
   - `supabase/migrations/` → Supabase
   - `migrations/` (with `.sql` files) → Drizzle / sqlx / raw SQL
   - `db/migrate/` → Rails/ActiveRecord

2. **Identify scope** — if a specific path is given, audit only that. Otherwise audit the most recent N=5 migrations (recent enough to be relevant, bounded so the report stays focused).

3. **Spawn `migration-reviewer` agent** with the path(s) and detected system. The agent is read-only — never applies migrations.

4. **Render the agent's report** organized by severity:
   - **🔴 Blocker**: data loss without backup, missing rollback, irreversible without manual recovery
   - **🟠 High**: lock contention on a large table, NOT NULL on existing rows without default, dropping indexes without replacement
   - **🟡 Medium**: missing indexes for new foreign keys, type changes that require table rewrite
   - **🔵 Low**: naming conventions, missing comments, formatting

5. **Refuse to apply.** The user runs the migration tool themselves. This skill never executes `migrate deploy` or `db push`.

## Output principle

Lead with the highest severity. If there are no Blockers or Highs, say "Safe to apply" in the first sentence — don't bury the verdict.

## Anti-patterns

- Running this skill on every commit. It's for migration files, not application code.
- Auto-applying the migration after a green review — the user runs it.
- Reviewing the migration system's output (e.g., a `prisma migrate dev` log) instead of the migration file itself.

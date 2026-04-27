---
name: audit-i18n-nfc
description: Thin slash-command wrapper around the i18n-nfc-auditor agent — audits Korean/CJK string handling for NFC/NFD Unicode normalization mismatches across filenames, URLs, attachments, and DB paths. Use when "한글 파일 깨짐", "Supabase 첨부 안 됨", "한글 파일명 문제", or after Supabase/Vercel deploy.
author: subinium
user-invocable: true
disable-model-invocation: false
allowed-tools: Task
argument-hint: "[--scope=<dir>] [--include-history]"
---

# Audit i18n NFC/NFD

Slash-command entry point for the `i18n-nfc-auditor` agent. The agent does the work; this skill just routes there with the right framing.

## When this skill fires

- Direct call: `/audit-i18n-nfc`
- Trigger phrases: "한글 파일 깨짐", "NFC 검증", "Supabase 첨부 안 됨", "한글 파일명 문제"
- Post-deploy: after Supabase/Vercel deployments that involve attachments or file paths with Korean/CJK characters

## Process

1. **Spawn `i18n-nfc-auditor` agent** with:
   - Scope: `--scope` argument if provided, otherwise the current working directory
   - History flag: `--include-history` checks git blob history for mixed normalization
   - Context: the most recent deployment target (Supabase, Vercel, S3) if mentioned in the conversation

2. **Wait for the agent's structured report.** The agent is read-only — it diagnoses, never renames.

3. **Surface findings to the user** with:
   - File paths in `nfc:` vs `nfd:` columns
   - Affected URLs / DB paths
   - Recommended remediation order (rename source files first, then update DB references)

4. **Do NOT auto-rename.** File renaming under different normalization forms can break git history and references. If the user wants to fix, ask explicitly: "Rename N files NFD → NFC? This is a destructive operation."

## Anti-patterns

- Running this skill on a repo with no CJK content — agent will return empty, wasting a turn.
- Auto-applying renames without explicit confirmation.
- Running on `node_modules/` or build artifacts — restrict scope to source.

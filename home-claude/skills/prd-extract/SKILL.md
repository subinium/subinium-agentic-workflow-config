---
name: prd-extract
description: Extracts a structured PRD.md and tactical implementation plan from the current conversation — captures goals, non-goals, scope, risks, and acceptance criteria. Use when ending a brainstorm before implementation, before invoking the architect agent, or "PRD 뽑아줘", "기획서 정리", "스펙 문서 추출".
author: subinium
user-invocable: true
disable-model-invocation: true
allowed-tools: Read, Write
argument-hint: "[--with-plan] [--output=<path>]"
---

# PRD Extract

Read the conversation context, extract a clean PRD.md (and optionally a tactical plan), save to disk.

## Arguments

- `--with-plan` — also generate `PLAN.md` using the structure from `~/.claude/rules/plan-template.md`
- `--output=<path>` — save to this path instead of `./PRD.md` (and `./PLAN.md`)

## Process

### 1. Re-read conversation
Scan the visible conversation for:
- The user's stated GOAL (what they want to build / fix / explore)
- Constraints and non-goals (what they explicitly excluded)
- Trade-offs discussed (and which side won)
- Risks raised
- Decisions made (and the reasoning)
- Open questions left unanswered

If the conversation is sparse / unclear, ASK 1-2 clarifying questions before writing — do not invent.

### 2. Write PRD.md

Use this structure:

```markdown
# PRD: <feature name>

> **Status:** Draft · **Owner:** <user> · **Date:** YYYY-MM-DD

## Problem
What problem are we solving? Who has it? Why now?

## Goals
- Goal 1 (measurable if possible)
- Goal 2

## Non-goals
- Explicitly NOT solving X
- Explicitly NOT supporting Y

## Scope
- In scope: [bullet list]
- Out of scope: [bullet list, with brief reason for each]

## User flow
1. User does X
2. System responds with Y
3. ...

## Acceptance criteria
- [ ] Concrete, testable criterion 1
- [ ] Concrete, testable criterion 2

## Risks
| Risk | Impact | Mitigation |
|---|---|---|

## Open questions
- Question 1 — needs answer from [whom]
- Question 2

## References
- Conversation: <date / session ID if known>
- Related docs / issues
```

### 3. (Optional) Write PLAN.md
If `--with-plan`: use `~/.claude/rules/plan-template.md` as the structure. Map PRD goals → tactical steps with:
- File ownership per step
- Dependencies between steps
- Risk-first sequencing (highest uncertainty step first)
- Parallel groups identified

### 4. Output paths
- Default: `./PRD.md` (and `./PLAN.md` if `--with-plan`)
- If file exists: append timestamp suffix (`PRD-YYYYMMDD-HHMMSS.md`) — never silently overwrite
- Print the saved paths and a 3-line summary of what was extracted

## Constraints (SOFT)

- Don't fabricate goals/criteria the user never mentioned — it's better to leave a section empty than to invent
- Don't include implementation details in the PRD (those belong in PLAN.md or architect output)
- Don't write more than ~600 words in PRD body — it's a contract, not a manifesto
- Korean response per global CLAUDE.md (PRD body itself can be Korean if conversation was Korean)

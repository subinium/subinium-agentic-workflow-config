---
name: spec
description: Spec-driven development — write a spec first via structured interview, then implement in a focused session. Use when starting a new feature, project, or complex task from scratch
author: subinium
user-invocable: true
disable-model-invocation: true
args: phase (write | implement)
---

# Spec-Driven Development

Separate planning from implementation across sessions to avoid context saturation.

## Usage
```
/spec write           # Phase 1: Interview → write spec
/spec implement       # Phase 2: Implement from existing spec
```

---

## Phase 1: `/spec write`

### Interview the User

Ask structured questions using `AskUserQuestion` tool:

1. **Goal**: What are we building? What problem does it solve?
2. **Scope**: What's in scope? What's explicitly out of scope?
3. **Users**: Who uses this? What are the key user flows?
4. **Tech constraints**: Stack, libraries, APIs, existing patterns to follow?
5. **Acceptance criteria**: How do we know it's done? What must work?
6. **Edge cases**: What could go wrong? What are the boundary conditions?

### Write the Spec

After the interview, produce a spec file (`SPEC.md` or `docs/spec-{feature}.md`):

```markdown
# Feature: [Name]

## Goal
One-sentence description of what this does and why.

## Scope
### In Scope
- ...
### Out of Scope
- ...

## User Flows
1. [Primary flow]
2. [Secondary flow]

## Technical Design
- Architecture approach
- Key components/files to create or modify
- Data model changes (if any)
- API contracts (if any)

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] ...

## Edge Cases
- ...

## Open Questions
- ...
```

Save the spec and tell the user:
> "Spec saved. Start a new session and run `/spec implement` to begin implementation with a clean context."

---

## Phase 2: `/spec implement`

1. Find the most recent spec file (`SPEC.md`, `docs/spec-*.md`)
2. Read the spec fully
3. Create an implementation plan from the spec's Technical Design section
4. Implement against the Acceptance Criteria — check each off as completed
5. After implementation, run verification (lint, typecheck, tests)
6. Report which acceptance criteria pass and which are pending

### Rules
- Do NOT re-interview the user — the spec is the source of truth
- If the spec has Open Questions, ask the user before proceeding
- If something is out of scope, skip it even if it seems related
- Commit with `feat:` referencing the spec name

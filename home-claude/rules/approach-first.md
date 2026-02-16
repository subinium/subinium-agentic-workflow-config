# Approach-First Rule

Before writing code on complex or unfamiliar tasks, state your approach and get user approval.

## When This Applies

- Unfamiliar library or API you haven't used in this session
- Multiple valid architectures (e.g., REST vs GraphQL, SSR vs SPA)
- Domain-specific logic (finance, auth, data pipelines)
- Changes touching 5+ files
- Performance-critical code paths

## When to Skip

- Single-file changes with clear requirements
- Root cause already confirmed (e.g., via debugging)
- Well-established patterns in the codebase (e.g., adding another CRUD endpoint)
- User explicitly said "just do it" or "skip planning"

## Process

1. **Read** — Explore relevant code, docs, and constraints
2. **State** — Write a 2-3 sentence approach statement:
   - "I'll use [technique] because [reason]. Alternative: [other approach]. Risk: [main concern]."
3. **Ask** — Present to user via `AskUserQuestion` or inline question
4. **Wait** — Do NOT start coding until the user confirms
5. **Implement** — Follow the approved approach

## Approach Statement Template

```
**Approach**: [What you'll do and which files you'll change]
**Why**: [Key reason this approach over alternatives]
**Alternative**: [What else could work]
**Risk**: [Main thing that could go wrong]
```

## Anti-Patterns

- Starting to code while "planning" in your head
- Asking vague questions ("should I proceed?") instead of stating a specific approach
- Researching for 10+ tool calls without producing an approach statement
- Implementing first, then asking "is this what you wanted?"

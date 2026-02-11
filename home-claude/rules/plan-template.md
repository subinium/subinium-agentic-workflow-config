# Tactical Plan Template

When creating implementation plans (via EnterPlanMode, architect agent, or /spec), structure steps with explicit dependencies to enable parallel execution.

## Format

```
## Plan: [Task Name]

### Risk Assessment (verify first)
1. [Highest uncertainty] — verify before full implementation
2. [Second highest]

### Steps

| # | Step | Files | Depends On | Group |
|---|------|-------|------------|-------|
| 1 | Create auth types | `types/auth.ts` | — | A |
| 2 | Implement session logic | `lib/session.ts` | — | A |
| 3 | Add API route | `app/api/login/route.ts` | 1, 2 | B |
| 4 | Build login form | `components/LoginForm.tsx` | 1 | A |
| 5 | Integration test | `tests/auth.test.ts` | 3, 4 | C |

### Parallel Groups
- **Group A** (no deps): Steps 1, 2, 4 → dispatch simultaneously
- **Group B** (after A): Step 3
- **Group C** (after B): Step 5
```

## Rules

- **Risk-first**: identify and verify the most uncertain step before committing to the full plan
- **File ownership**: every step must own specific files — no two steps modify the same file
- **Explicit dependencies**: if step 3 needs output from step 1, mark `Depends On: 1`
- **Parallel groups**: group independent steps for simultaneous execution
- **Plan → Tasks**: after approval, convert each step into a `TaskCreate` call with `addBlockedBy` for dependencies

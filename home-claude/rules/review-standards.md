# Review Standards

Standards applied automatically during code reviews, PR reviews, and quality checks.

## Severity Classification

| Severity | Meaning | Action |
|----------|---------|--------|
| **Blocker** | Security vulnerability, data loss risk, production crash | Must fix before merge |
| **Critical** | Incorrect logic, missing error handling, type unsafety | Must fix before merge |
| **Warning** | Performance issue, missing tests, code smell | Should fix, can defer with justification |
| **Nit** | Style, naming, minor improvement | Optional, author's discretion |

## Review Priorities (Check in This Order)

1. **Security** — Injection, auth bypass, secret exposure, CORS
2. **Correctness** — Logic errors, null handling, race conditions, state bugs
3. **Data integrity** — Migrations, validation, error handling at boundaries
4. **Performance** — N+1 queries, bundle size, unnecessary re-renders
5. **Types** — `any` usage, missing types, incorrect generics
6. **Tests** — Coverage of new code paths, edge cases
7. **UX** — Loading/error/empty states, accessibility, responsive
8. **Maintainability** — Naming, complexity, duplication

## Patterns That Always Require Comment

- `any` or `as unknown as` type casts
- `// eslint-disable` or `// @ts-ignore` without explanation
- `console.log` left in production code
- Hardcoded URLs, ports, or environment-specific values
- Missing `await` on async calls
- `useEffect` with missing or empty dependency array
- `dangerouslySetInnerHTML` without sanitization
- Database queries inside loops (N+1)
- Catch blocks that swallow errors silently

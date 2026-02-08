# Commit Conventions

## Format

```
<type>(<scope>): <subject>

<body>

Co-Authored-By: ...
```

## Types

| Type | When to Use | Example |
|------|------------|---------|
| `feat` | New user-facing feature | `feat(auth): add OAuth2 login` |
| `fix` | Bug fix | `fix(cart): correct price calculation rounding` |
| `refactor` | Code change that neither fixes nor adds | `refactor(api): extract validation middleware` |
| `perf` | Performance improvement | `perf(query): add index for user lookup` |
| `test` | Adding or fixing tests | `test(auth): add edge case for expired token` |
| `docs` | Documentation only | `docs(api): add endpoint examples` |
| `chore` | Build, CI, dependencies | `chore(deps): bump next to 15.1` |
| `style` | Formatting, whitespace | `style: apply prettier to all files` |
| `ci` | CI/CD changes | `ci: add type check to PR workflow` |

## Scope Examples

| Project Type | Common Scopes |
|-------------|---------------|
| Next.js | `auth`, `api`, `ui`, `db`, `config`, `middleware` |
| Component Library | `button`, `modal`, `form`, `theme`, `a11y` |
| Backend API | `users`, `orders`, `payments`, `auth`, `middleware` |
| Monorepo | `web`, `api`, `shared`, `cli`, `docs` |

## Rules

- Subject: imperative mood, lowercase, no period, max 72 chars
- Body: explain WHY, not WHAT (the diff shows what changed)
- One logical change per commit — if "and" appears in the subject, split it
- Breaking changes: add `!` after type/scope: `feat(api)!: change response format`

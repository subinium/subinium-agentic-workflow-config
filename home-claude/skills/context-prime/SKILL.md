---
name: context-prime
description: Prime the session with project context — read README, config, structure, and conventions before starting work. Use at the start of a session or when switching projects
author: subinium
user-invocable: true
disable-model-invocation: true
---

# Context Prime

Systematically load project context to reduce hallucination and align with existing conventions.

## Usage
```
/context-prime
```

## Process

1. **Read project identity** (parallel):
   - `README.md` or `README` (project purpose, setup instructions)
   - `CLAUDE.md` if it exists (project-specific Claude instructions)
   - `package.json` or `pyproject.toml` or `Cargo.toml` (dependencies, scripts)

2. **Scan project structure**:
   - Run `tree -L 2 --dirsfirst -I 'node_modules|.git|__pycache__|dist|build|.next'` (or `ls -la` if tree unavailable)
   - Identify: source directory (`src/`, `app/`, `lib/`), test directory, config files

3. **Detect conventions** (parallel):
   - **Test framework**: Look for `jest.config.*`, `vitest.config.*`, `pytest.ini`, `conftest.py`
   - **Linter/formatter**: `.eslintrc*`, `.prettierrc*`, `biome.json`, `ruff.toml`, `.editorconfig`
   - **TypeScript**: `tsconfig.json` — check `paths`, `strict`, `target`
   - **CI/CD**: `.github/workflows/`, `Dockerfile`, `vercel.json`

4. **Check git state**:
   - `git branch --show-current` — which branch are we on?
   - `git log --oneline -5` — recent commits for context
   - `git status --short` — any uncommitted work?

5. **Output summary**:

```
## Project Context: [name]

**Stack**: [detected stack]
**Source**: [source dir] | **Tests**: [test dir] | **Branch**: [current branch]

### Key Config
- TypeScript: strict=[yes/no], paths=[aliases]
- Formatter: [prettier/biome/black]
- Test: [jest/vitest/pytest]

### Conventions Detected
- [naming patterns, import style, component patterns]

### Active Work
- Branch: [branch] | Last commit: [message]
- Uncommitted: [count] files

### Ready to work.
```

## Rules
- DO NOT modify any files during context priming
- Keep the summary concise — under 30 lines
- If no project config is found, state that explicitly rather than guessing

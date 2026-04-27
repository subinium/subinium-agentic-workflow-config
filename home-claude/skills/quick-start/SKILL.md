---
name: quick-start
description: Instantly load project context and suggest actionable next steps. Use at session start instead of open-ended greetings
author: subinium
user-invocable: true
disable-model-invocation: true
---

# Quick Start

Jump into productive work immediately. No greetings, no open-ended questions.

## Usage
```
/quick-start
```

## Instructions

### 1. Gather Context (parallel)
Run all of these simultaneously:
- `git log --oneline -10` — recent commits
- `git status --short` — uncommitted work
- `git branch --show-current` — active branch
- `git diff --stat HEAD~3..HEAD` — recent changes summary
- Read `CLAUDE.md` if it exists in the project root
- Read `package.json` or `Cargo.toml` or `pyproject.toml` — project identity

### 2. Check for Pending Work
- Any uncommitted changes? → Flag them
- Any TODO/FIXME in recently modified files? → List top 3
- Any failing checks? Auto-detect and run (timeout 15s):
  - **Rust**: `cargo check --all-features 2>&1 | tail -5`
  - **Node**: `npm run test 2>&1 | tail -5`
  - **Python**: `pytest --co -q 2>&1 | tail -5`
- Open issues? → `gh issue list --state open --limit 5` (if in a git repo with remote)

### 3. Output (concise, under 15 lines)

```
## [Project Name] — [Branch]

**Last 3 commits:**
- [commit 1]
- [commit 2]
- [commit 3]

**Status:** [clean / N uncommitted files]
**Failing tests:** [none / list]

**Suggested next steps:**
1. [Most obvious next action based on context]
2. [Second suggestion]
3. [Third suggestion]
```

## Rules
- Total execution time: under 15 seconds
- Do NOT ask the user what they want to do — suggest based on context
- Do NOT run a full build or install — only lightweight checks
- Keep output under 15 lines
- If no project config is found, say so and ask what the user wants to work on

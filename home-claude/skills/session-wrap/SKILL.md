---
name: session-wrap
description: Wrap up the current session — summarize progress, pending tasks, and create a handoff note for the next session. Use when ending a session, switching context, or before /clear
author: subinium
user-invocable: true
disable-model-invocation: true
---

# Session Wrap

Generate a session summary for clean handoff to the next session.

## Usage
```
/session-wrap
```

## Process

1. **Gather session state:**
   - Read `git diff --stat` to see all files modified in this session
   - Read `git log --oneline -10` to see recent commits
   - Review the conversation for key decisions and context

2. **Generate handoff note:**

```markdown
# Session Summary — [date]

## Completed
- [What was accomplished, with file references]

## Pending
- [What's left to do]

## Key Decisions
- [Important choices made and why]

## Modified Files
- [list from git diff]

## Next Steps
1. [First thing to do in the next session]
2. [Second thing]

## Context to Preserve
- [Any critical context the next session needs to know]
```

3. **Save to** `SESSION-SUMMARY.md` in the project root (or print if the user prefers)

## Rules
- Keep it concise — the next session should be able to start from this summary alone
- Include file paths for everything referenced
- If there are failing tests or lint errors, note them explicitly
- Don't include verbose logs, only summaries

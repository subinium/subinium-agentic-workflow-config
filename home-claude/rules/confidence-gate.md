# Confidence Gate

Before implementing non-trivial changes (new features, refactors, architecture changes), run a quick self-assessment. Skip this for simple fixes, typos, or one-line changes.

## 5-Point Check

1. **Duplicate check** — Does this already exist in the codebase? Search before building.
2. **Pattern compliance** — Does the approach match existing architecture and conventions?
3. **API correctness** — Are the APIs/libraries being used correctly? Check docs if unsure.
4. **Scope clarity** — Is the requirement clear enough to implement? If ambiguous, clarify first.
5. **Root cause** — For bug fixes: are we solving the actual problem, not a symptom?

## Decision

- **All 5 confident**: Proceed with implementation.
- **1-2 uncertain**: Note the uncertainty, present alternatives to the user before proceeding.
- **3+ uncertain**: Stop. Gather more information (read code, check docs, ask the user) before writing any code.

## Anti-Patterns

- Starting to code before reading the relevant existing code
- Implementing a feature that already exists under a different name
- Using an API method from an old version of the library
- Fixing a symptom instead of tracing the root cause
- Building something the user didn't actually ask for

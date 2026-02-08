---
name: systematic-debugging
description: Systematic approach to debugging — follow these 8 steps when investigating bugs, errors, or unexpected behavior
author: subinium
user-invocable: true
---

# Systematic Debugging

Follow these steps in strict order. Do not skip ahead.

## Steps

### 1. Reproduce
- Get the exact error message and full stack trace
- Find the minimal reproduction case
- Confirm you can trigger the error consistently

### 2. Isolate
- Narrow down to the smallest failing unit
- Binary search: comment out half the code, check which half fails
- Check if the issue is in your code vs dependencies

### 3. Trace
- Follow data flow from input to the error point
- Log actual values at each step (don't assume)
- Check types at runtime, not just static analysis

### 4. Hypothesize
- Form at most 3 specific, testable theories
- Rank by likelihood
- Each hypothesis must predict a specific observable outcome

### 5. Test
- Test ONE hypothesis at a time
- Make the smallest possible change to verify
- If wrong, revert before testing the next hypothesis

### 6. Fix
- Apply the smallest correct fix
- Ensure the fix addresses the root cause, not the symptom
- Check for the same bug pattern elsewhere in the codebase

### 7. Verify
- Run the exact test that exposed the bug
- Run related tests to check for regressions
- Test edge cases around the fix

### 8. Prevent
- Add a regression test if one doesn't exist
- Consider if a type constraint or assertion could prevent recurrence
- Document if the root cause was non-obvious

## Anti-Patterns (Never Do These)
- Shotgun debugging: changing multiple things at once
- Guessing without tracing actual values
- Fixing symptoms instead of root causes
- Skipping the verification step
- Adding try/catch to hide errors instead of fixing them

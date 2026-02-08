---
name: tdd
description: Test-driven development workflow — RED/GREEN/REFACTOR cycle. Use when asked to write tests first, do TDD, or develop with test-driven approach
author: subinium
user-invocable: true
disable-model-invocation: true
---

# Test-Driven Development

## Workflow: RED -> GREEN -> REFACTOR

### RED Phase
1. Write a failing test that describes the desired behavior
2. Run the test — confirm it fails
3. Verify it fails for the RIGHT reason (not a syntax error or import issue)

### GREEN Phase
1. Write the MINIMUM code to make the test pass
2. Run the test — confirm it passes
3. Do not optimize or clean up yet

### REFACTOR Phase
1. Clean up the implementation (remove duplication, improve naming)
2. Run ALL tests — confirm everything still passes
3. Commit this cycle

## Rules
- Never write production code without a failing test first
- One test at a time — do not batch
- Each RED/GREEN/REFACTOR cycle should be one commit
- Keep tests fast (mock external dependencies)
- Test behavior, not implementation details

## Test Structure

### Python (pytest)
```python
def test_should_describe_expected_behavior():
    # Arrange
    input_data = create_test_data()

    # Act
    result = function_under_test(input_data)

    # Assert
    assert result == expected_output
```

### TypeScript (vitest/jest)
```typescript
it('should describe expected behavior', () => {
  // Arrange
  const input = createTestData();

  // Act
  const result = functionUnderTest(input);

  // Assert
  expect(result).toEqual(expectedOutput);
});
```

## What to Test
- Happy path: normal inputs produce expected outputs
- Edge cases: empty inputs, boundaries, limits
- Error cases: invalid inputs throw/return appropriate errors
- Integration points: API calls, database queries (mocked)

## What NOT to Test
- Implementation details (private methods, internal state)
- Third-party library internals
- Trivial code (getters/setters with no logic)

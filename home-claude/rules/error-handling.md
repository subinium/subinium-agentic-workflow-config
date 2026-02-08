# Error Handling Patterns

## TypeScript

```typescript
// Catch as unknown, narrow with instanceof
try {
  await riskyOperation();
} catch (error: unknown) {
  if (error instanceof AppError) {
    // Handle known error types
    logger.warn(error.message, { code: error.code });
    return { error: error.userMessage };
  }
  // Re-throw unknown errors with context
  throw new Error('Failed to complete operation', { cause: error });
}
```

## API Route Error Responses

```typescript
// Always return structured error responses
return NextResponse.json(
  { error: { code: 'VALIDATION_ERROR', message: 'Invalid email format' } },
  { status: 400 }
);
```

## Rules

- Never silently swallow errors — log or propagate with context
- Use `{ cause: error }` to chain error context (ES2022)
- API errors: return structured JSON with `code` + `message`, not raw stack traces
- Client-side: show user-friendly message, log technical details to error tracker
- Use Error boundaries in React for component-level error recovery
- Async errors: always handle `.catch()` or `try/catch` — unhandled rejections crash Node
- Validation errors: return all field errors at once, not one at a time

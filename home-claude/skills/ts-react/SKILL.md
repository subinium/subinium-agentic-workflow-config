---
name: ts-react
description: TypeScript/React/Next.js development patterns, performance rules, composition patterns, and App Router conventions
author: subinium
---

# TypeScript / React / Next.js Development

## TypeScript

- Strict mode always (`"strict": true` in tsconfig)
- Use `interface` for object shapes, `type` for unions/intersections
- No `any` — use `unknown` and narrow with type guards
- Prefer `as const` for literal types
- Use discriminated unions for state management

```typescript
// Prefer
interface ButtonProps {
  variant: 'primary' | 'secondary';
  size?: 'sm' | 'md' | 'lg';
  onClick: () => void;
  children: React.ReactNode;
}

// Avoid
type ButtonProps = {
  variant: string;
  size?: string;
  onClick: Function;
  children: any;
};
```

## React Patterns

- Functional components only (no class components)
- Arrow function style: `const Component = () => {}`
- Default export only for page/route components
- Named exports for everything else
- Colocate related files (component + hook + types + tests)

### Component Structure
```typescript
// 1. Imports
// 2. Types/Interfaces
// 3. Constants
// 4. Component
// 5. Helper functions (if needed)

import { useState } from 'react';

interface Props {
  title: string;
}

const MAX_LENGTH = 100;

export const MyComponent = ({ title }: Props) => {
  const [value, setValue] = useState('');

  if (!title) return null; // early return

  return <div>{title}</div>;
};
```

### Hooks
- Custom hooks start with `use`
- Extract complex logic into custom hooks
- Keep hooks focused on a single concern

## Next.js (App Router)

- Server Components by default — add `'use client'` only when needed
- Use Server Actions for mutations
- Metadata API for SEO (`generateMetadata`)
- Route groups `(group)` for layout organization
- Loading/error states via `loading.tsx` and `error.tsx`
- Parallel routes and intercepting routes when appropriate

### File Structure
```
app/
├── (auth)/
│   ├── login/page.tsx
│   └── register/page.tsx
├── (dashboard)/
│   ├── layout.tsx
│   └── page.tsx
├── api/
│   └── [...route]/route.ts
├── layout.tsx
├── page.tsx
└── globals.css
components/
├── ui/           # Reusable primitives (Button, Input, Modal)
├── layout/       # Header, Footer, Sidebar, Nav
└── features/     # Feature-specific components
lib/              # Utilities, API clients, constants
hooks/            # Custom React hooks
types/            # Shared TypeScript types
```

## Styling

- Tailwind CSS as primary styling solution
- Use `cn()` utility (clsx + tailwind-merge) for conditional classes
- Component variants via `cva` (class-variance-authority) or manual pattern
- Responsive: mobile-first (`sm:`, `md:`, `lg:`)
- Dark mode via `dark:` variant

```typescript
import { cn } from '@/lib/utils';

export const Button = ({ className, variant, ...props }: ButtonProps) => {
  return (
    <button
      className={cn(
        'rounded-lg px-4 py-2 font-medium transition-colors',
        variant === 'primary' && 'bg-blue-600 text-white hover:bg-blue-700',
        variant === 'secondary' && 'bg-gray-100 text-gray-900 hover:bg-gray-200',
        className
      )}
      {...props}
    />
  );
};
```

## Performance (Next.js / React)

### CRITICAL — Eliminate Request Waterfalls
```typescript
// BAD: Sequential fetches (waterfall)
const user = await getUser(id);
const posts = await getPosts(id);
const comments = await getComments(id);

// GOOD: Parallel fetches
const [user, posts, comments] = await Promise.all([
  getUser(id),
  getPosts(id),
  getComments(id),
]);
```
- Use `Promise.all()` for independent data fetches
- Wrap slow components in `<Suspense>` with fallback
- Use `loading.tsx` for route-level streaming
- Defer non-critical data: fetch eagerly, `await` late

### CRITICAL — Bundle Size
```typescript
// BAD: Barrel imports pull entire library
import { Button } from 'lucide-react';
import { debounce } from 'lodash';

// GOOD: Direct imports
import { Button } from 'lucide-react/dist/esm/icons/button';
import debounce from 'lodash/debounce';
```
- Avoid barrel imports for: `lucide-react`, `lodash`, `date-fns`, `@mui/*`
- Use `next/dynamic` for heavy components (charts, editors, maps)
- Defer third-party scripts: `<Script strategy="lazyOnload" />`
- Check bundle with `@next/bundle-analyzer`

### HIGH — React Server Components
- Default to Server Components — only add `'use client'` when needed
- Use `React.cache()` to deduplicate identical fetches in a render pass
- Minimize data passed from Server → Client (serialize only what's needed)
- Use `after()` (Next.js 15+) for non-blocking post-response work (analytics, logging)
- Parallel RSC fetching: split data needs across parallel `<Suspense>` boundaries

### HIGH — Rendering
- `React.memo()` only after profiling confirms re-render issue
- Stable references: `useCallback` for functions passed to memoized children
- Use `useMemo` for expensive computations, not for every derived value
- Virtualize long lists: `@tanstack/react-virtual` or `react-window`

## Composition Patterns

### Avoid Boolean Props
```typescript
// BAD: Boolean explosion
<Modal isOpen isDismissable hasCloseButton isFullScreen />

// GOOD: Explicit variants
<Modal variant="fullscreen" dismissable closeButton />
```

### Compound Components
```typescript
// Good: Flexible composition
<Card>
  <Card.Header>Title</Card.Header>
  <Card.Body>Content</Card.Body>
  <Card.Footer>
    <Button>Action</Button>
  </Card.Footer>
</Card>
```

### Context Shape
```typescript
// Structure context as {state, actions, meta}
interface AuthContext {
  state: { user: User | null; isLoading: boolean };
  actions: { login: (creds: Credentials) => Promise<void>; logout: () => void };
  meta: { lastLoginAt: Date | null };
}
```

## Animation

- Framer Motion for complex animations
- CSS transitions for simple hover/focus states
- `AnimatePresence` for exit animations
- Respect `prefers-reduced-motion`

---
name: scaffold
description: Scaffold components, pages, features, and API routes with types, tests, and stories. Use when asked to create a new component, page, feature module, or API route
author: subinium
user-invocable: true
args: type and name (e.g., "component Button", "page dashboard", "feature auth")
---

# Scaffold

Generate project scaffolding with consistent structure. Uses `$ARGUMENTS` for type and name.

## Usage
```
/scaffold component Button
/scaffold page dashboard/settings
/scaffold feature auth
/scaffold api users
```

## Component: `/scaffold component [Name]`

Create at `components/[name]/`:

```
components/Button/
├── Button.tsx          # Component implementation
├── Button.test.tsx     # Unit tests (vitest/jest)
├── Button.stories.tsx  # Storybook story (if project uses storybook)
└── index.ts            # Barrel export
```

### Template: `Button.tsx`
```tsx
import { cn } from '@/lib/utils';

interface ButtonProps {
  children: React.ReactNode;
  variant?: 'primary' | 'secondary' | 'ghost';
  size?: 'sm' | 'md' | 'lg';
  disabled?: boolean;
  className?: string;
  onClick?: () => void;
}

export const Button = ({
  children,
  variant = 'primary',
  size = 'md',
  disabled = false,
  className,
  onClick,
}: ButtonProps) => {
  return (
    <button
      className={cn(
        'rounded-lg font-medium transition-colors',
        /* size */
        size === 'sm' && 'px-3 py-1.5 text-sm',
        size === 'md' && 'px-4 py-2 text-base',
        size === 'lg' && 'px-6 py-3 text-lg',
        /* variant */
        variant === 'primary' && 'bg-blue-600 text-white hover:bg-blue-700',
        variant === 'secondary' && 'bg-gray-100 text-gray-900 hover:bg-gray-200',
        variant === 'ghost' && 'bg-transparent hover:bg-gray-100',
        disabled && 'cursor-not-allowed opacity-50',
        className
      )}
      disabled={disabled}
      onClick={onClick}
    >
      {children}
    </button>
  );
};
```

### Template: `Button.test.tsx`
```tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { Button } from './Button';

describe('Button', () => {
  it('renders children', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByText('Click me')).toBeInTheDocument();
  });

  it('calls onClick when clicked', () => {
    const onClick = vi.fn();
    render(<Button onClick={onClick}>Click</Button>);
    fireEvent.click(screen.getByText('Click'));
    expect(onClick).toHaveBeenCalledOnce();
  });

  it('does not call onClick when disabled', () => {
    const onClick = vi.fn();
    render(<Button onClick={onClick} disabled>Click</Button>);
    fireEvent.click(screen.getByText('Click'));
    expect(onClick).not.toHaveBeenCalled();
  });
});
```

## Page: `/scaffold page [path]`

Create Next.js App Router page at `app/[path]/`:

```
app/dashboard/settings/
├── page.tsx            # Page component (Server Component)
├── loading.tsx         # Loading UI (skeleton)
├── error.tsx           # Error boundary ('use client')
└── layout.tsx          # Layout (only if page needs its own layout)
```

- `page.tsx`: Server Component by default, async for data fetching
- `loading.tsx`: Skeleton matching the page layout
- `error.tsx`: `'use client'` with retry button and error message
- Generate `generateMetadata()` for SEO

## Feature: `/scaffold feature [name]`

Create a full feature module:

```
features/auth/
├── components/         # Feature-specific components
│   └── LoginForm.tsx
├── hooks/              # Feature-specific hooks
│   └── useAuth.ts
├── lib/                # Feature logic, API calls
│   └── api.ts
├── types/              # Feature types
│   └── index.ts
└── index.ts            # Public API barrel export
```

- Only export what other features need from `index.ts`
- Keep internal implementation private
- Include types for all public interfaces

## API Route: `/scaffold api [name]`

Create at `app/api/[name]/`:

```
app/api/users/
└── route.ts            # Route handler (GET, POST, PUT, DELETE)
```

- Type-safe request/response with Zod validation
- Error handling with proper HTTP status codes
- Include all CRUD handlers as stubs

## Pre-Flight (Before Generating ANY Files)

1. Read `package.json` to detect: test framework (vitest/jest), styling (tailwind/css-modules), component library (shadcn/radix)
2. Read `tsconfig.json` to detect path aliases (`@/`)
3. Check existing `components/` or `src/components/` to match naming conventions
4. Check if project uses barrel exports (`index.ts`)
5. Check if project uses Storybook (`storybook` in devDependencies)

## Rules
1. Match existing project structure and conventions — never guess
2. Use the project's existing test framework (vitest/jest/playwright)
3. Use the project's existing styling approach (Tailwind/CSS Modules/styled-components)
4. Add barrel export (`index.ts`) only if the project already uses them
5. After generating, run `npx tsc --noEmit` and lint to verify

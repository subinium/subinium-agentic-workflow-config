---
name: ui-mockup
description: UI/UX prototyping with mock data, component states, visual debugging, and pre-delivery polish. Use when building UI, creating mockups, or prototyping interfaces
author: subinium
user-invocable: true
---

# UI/UX Mockup & Iteration

## Mock Data Generation

### Realistic Test Data
Always generate realistic mock data that exposes edge cases:

```typescript
// Use faker or hand-craft realistic data
const MOCK_USERS: User[] = [
  { id: '1', name: 'Kim Minjun', email: 'minjun@example.com', avatar: null, role: 'admin' },
  { id: '2', name: 'A Very Long Username That Might Break Layout', email: 'long@example.com', avatar: '/avatar.jpg', role: 'user' },
  { id: '3', name: '', email: 'empty-name@example.com', avatar: null, role: 'user' }, // empty name edge case
];

// Include edge cases in every mock dataset:
// - Empty strings / null values
// - Extremely long text
// - Special characters / unicode / emoji
// - Zero items, one item, many items (0/1/N)
// - Dates at boundaries (midnight, timezone edge, future dates)
// - Large numbers / currency formatting
```

### Mock Data Patterns
```typescript
// Factory function pattern
const createMockUser = (overrides: Partial<User> = {}): User => ({
  id: crypto.randomUUID(),
  name: 'Test User',
  email: 'test@example.com',
  avatar: null,
  role: 'user',
  createdAt: new Date().toISOString(),
  ...overrides,
});

// Bulk generation
const createMockUsers = (count: number): User[] =>
  Array.from({ length: count }, (_, i) =>
    createMockUser({ id: String(i + 1), name: `User ${i + 1}` })
  );
```

## UI/UX Checklist

### Layout & Responsive
- [ ] Mobile (320px), Tablet (768px), Desktop (1280px), Wide (1920px)
- [ ] Content overflow: long text, many items, empty states
- [ ] Loading states: skeleton, spinner, progressive
- [ ] Error states: network error, 404, permission denied, validation
- [ ] Empty states: no data, first-time user, search with no results

### Interaction
- [ ] Hover, focus, active, disabled states for all interactive elements
- [ ] Keyboard navigation: Tab order, Enter/Space activation, Escape to close
- [ ] Touch targets: minimum 44x44px on mobile
- [ ] Transitions: enter/exit animations, no layout shift
- [ ] Debounced inputs for search/filter

### Accessibility
- [ ] Semantic HTML: `<button>` not `<div onClick>`, `<nav>`, `<main>`, `<article>`
- [ ] ARIA labels on icon-only buttons
- [ ] Color contrast ratio: 4.5:1 for text, 3:1 for large text
- [ ] Focus visible indicator (not just outline: none)
- [ ] Screen reader tested: content order makes sense without visuals

### Visual Quality
- [ ] Consistent spacing (4px grid system with Tailwind)
- [ ] Typography hierarchy: headings, body, captions
- [ ] Dark mode compatibility (`dark:` variants)
- [ ] Image loading: placeholder → actual, proper aspect ratio
- [ ] Favicon and metadata set

## Component Iteration Workflow

1. **Static**: Build with hardcoded mock data, all states visible
2. **Interactive**: Add state management, transitions, user interactions
3. **Connected**: Replace mock data with real API calls
4. **Polished**: Edge cases, error handling, loading states, animations

## Storybook-Style State Gallery

When building a component, render ALL states on a single page for review:

```tsx
export const ComponentGallery = () => (
  <div className="space-y-8 p-8">
    <section>
      <h2>Default</h2>
      <MyComponent data={mockData.default} />
    </section>
    <section>
      <h2>Loading</h2>
      <MyComponent data={null} isLoading />
    </section>
    <section>
      <h2>Empty</h2>
      <MyComponent data={[]} />
    </section>
    <section>
      <h2>Error</h2>
      <MyComponent data={null} error="Failed to load" />
    </section>
    <section>
      <h2>Long Content</h2>
      <MyComponent data={mockData.longContent} />
    </section>
    <section>
      <h2>Many Items</h2>
      <MyComponent data={mockData.manyItems} />
    </section>
  </div>
);
```

## Pre-Delivery Polish Checklist

Before marking any UI work as complete, verify every item:

### Icons & Graphics
- [ ] No emoji used as UI icons — use SVG icon libraries (Lucide, Heroicons)
- [ ] Icons have consistent size and stroke width throughout

### Interactions
- [ ] `cursor-pointer` on ALL clickable elements (buttons, links, cards, tabs)
- [ ] Hover transitions: 150–300ms duration, `ease-in-out` timing
- [ ] Focus ring visible on keyboard navigation (no `outline-none` without replacement)
- [ ] Disabled states visually distinct and non-interactive (`pointer-events-none`)

### Colors & Contrast
- [ ] Body text: `text-slate-900` (light) / `text-slate-100` (dark) — minimum
- [ ] Secondary text: `text-slate-600` (light) / `text-slate-400` (dark)
- [ ] Glass/blur cards: `bg-white/80` minimum opacity in light mode, ensure text readability
- [ ] Borders visible in both light and dark mode (`border-slate-200` / `border-slate-700`)
- [ ] No pure black `#000` backgrounds — use `slate-950` or `zinc-950`

### Layout Polish
- [ ] Floating/sticky navbar has adequate spacing from content below
- [ ] No content hidden behind fixed headers (scroll-margin-top or padding-top)
- [ ] Cards and containers have consistent border-radius (pick one: `rounded-lg` or `rounded-xl`)
- [ ] Spacing between sections is consistent (e.g., `space-y-12` or `gap-8`)

### Typography
- [ ] Heading hierarchy: one `h1` per page, logical `h2`→`h3` nesting
- [ ] Line height: body text `leading-relaxed` (1.625) or `leading-normal` (1.5)
- [ ] Max content width for readability: `max-w-prose` (~65ch) for long text blocks

## Design Direction Quick Reference

When starting a new UI, choose a direction:

| Style | Tailwind Approach | Best For |
|-------|------------------|----------|
| Minimal | Lots of whitespace, `text-sm`, subtle borders | SaaS dashboards, dev tools |
| Bold | Large headings, saturated colors, `font-bold` | Landing pages, marketing |
| Glassmorphism | `backdrop-blur`, semi-transparent bg, subtle borders | Modern apps, overlays |
| Brutalist | High contrast, sharp edges, `rounded-none`, monospace | Creative, portfolio |
| Soft | Rounded corners, pastel colors, generous padding | Consumer apps, onboarding |

### Recommended Font Pairings
- **Inter + JetBrains Mono** — clean, versatile, great for dev tools
- **Geist + Geist Mono** — Vercel's design system, modern SaaS
- **Plus Jakarta Sans + Fira Code** — friendly, rounded, technical balance

## Visual Debugging

- Use Tailwind `outline outline-red-500` to debug layout issues
- Check z-index stacking with browser DevTools 3D view
- Test with slow network (DevTools throttling) for loading state visibility
- Use `prefers-reduced-motion` media query testing

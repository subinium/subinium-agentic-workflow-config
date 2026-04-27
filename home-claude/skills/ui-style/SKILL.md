---
name: ui-style
description: Design system conventions for all UI projects — typography (font pool + combos), color palettes, border radius rules, layout. Apply when scaffolding UI, reviewing design, or starting any frontend work.
author: subinium
user-invocable: true
---

# UI Style Conventions

These are **hard preferences**, not suggestions. Apply to every project that has a UI.

---

## 1. Typography

Use **2–3 font families** with strictly separated roles. Pick a combo that fits the product vibe — never default to a single font.

### Font roles

| Variable | Role | Size range | Notes |
|----------|------|-----------|-------|
| `--font-display` | Headings, hero, logo, large numerics | 18px+ | The font that gives the product personality |
| `--font-sans` | Body text, UI labels, paragraphs, form fields | 12–17px | Readable, neutral, functional |
| `--font-mono` | Code, stats, version numbers, badges, timestamps | 11–14px | Monospaced only |

### Display / Heading font pool

| Font | Source | Personality | Best for |
|------|--------|-------------|----------|
| `Bricolage Grotesque` | Google | Variable-width grotesque, editorial tension | Dev tools, editorial SaaS |
| `Space Grotesk` | Google | Geometric, techy, slightly quirky | Dev tools, infra, dashboards |
| `Fraunces` | Google | Optical serif, expressive, luxury/craft feel | Premium, portfolios |
| `Instrument Serif` | Google | Thin serif, high-fashion editorial | Landing pages, design tools |
| `Syne` | Google | Bold grotesque, art/design world energy | Creative platforms, dark UIs |
| `Unbounded` | Google | Wide-set, heavy presence, impactful | Hero sections, branding |
| `DM Serif Display` | Google | Classic editorial serif, trustworthy | Finance, data, B2B SaaS |
| `Playfair Display` | Google | High-contrast editorial serif | Media, content, luxury |
| `Outfit` | Google | Rounded geometric, modern friendly | Consumer SaaS, productivity |
| `Cabinet Grotesk` | Fontshare | Precise grotesque, very clean | B2B, dashboards, fintech |
| `Satoshi` | Fontshare | Neutral modern sans, versatile | Most SaaS products |
| `Clash Display` | Fontshare | Strong geometric contrast | Marketing, bold landing pages |

### Body / UI font pool

| Font | Source | Personality | Best for |
|------|--------|-------------|----------|
| `Inter` | Google | Neutral, ubiquitous, reliable | Any product UI |
| `Manrope` | Google | Friendly rounded grotesque, warm | Community apps, consumer |
| `Plus Jakarta Sans` | Google | Slightly wide, SaaS-friendly | B2B SaaS, dashboards |
| `DM Sans` | Google | Clean, quiet, pairs well with serifs | When display is a serif |
| `Figtree` | Google | Very clean, open, modern | Simple apps, minimal UIs |
| `Nunito Sans` | Google | Warm, approachable, slightly playful | Education, consumer |

### Mono font pool

| Font | Source | Personality | Best for |
|------|--------|-------------|----------|
| `DM Mono` | Google | Minimal, matches DM Sans perfectly | Body is DM Sans/Manrope |
| `JetBrains Mono` | Google | Developer-optimized, ligatures | Code-heavy tools |
| `IBM Plex Mono` | Google | Structured, IBM Design System feel | Enterprise, data |
| `Space Mono` | Google | Retro techy, quirky | Dark UIs, sci-fi aesthetic |
| `Fira Mono` | Google | Classic developer mono, very readable | Code editors, terminals |
| `Inconsolata` | Google | Condensed, high density | Tables, data grids |

### Curated combos by product type

| Product type | Display | Body | Mono |
|-------------|---------|------|------|
| Dev tool / dark UI | `Space Grotesk` | `Inter` | `JetBrains Mono` |
| Editorial / blog | `Fraunces` | `DM Sans` | `DM Mono` |
| B2B SaaS / dashboard | `Bricolage Grotesque` | `Plus Jakarta Sans` | `IBM Plex Mono` |
| Community / social | `Syne` | `Manrope` | `Space Mono` |
| Consumer / productivity | `Outfit` | `Nunito Sans` | `DM Mono` |
| Fintech / trust-heavy | `DM Serif Display` | `Inter` | `Inconsolata` |
| Premium / luxury | `Instrument Serif` | `Figtree` | `DM Mono` |

### Implementation

```tsx
// layout.tsx — Google Fonts via next/font
import { Space_Grotesk, Inter, JetBrains_Mono } from 'next/font/google';

const display = Space_Grotesk({
  variable: '--font-display',
  subsets: ['latin'],
  weight: ['400', '500', '600', '700'],
  display: 'swap',
});
const sans = Inter({ variable: '--font-sans', subsets: ['latin'], display: 'swap' });
const mono = JetBrains_Mono({
  variable: '--font-mono',
  subsets: ['latin'],
  weight: ['400', '500', '700'],
  display: 'swap',
});

// Apply all three variables to <html>
<html className={`${display.variable} ${sans.variable} ${mono.variable}`}>
```

```css
/* globals.css — wire up to Tailwind @theme */
@theme {
  --font-sans: var(--font-sans), system-ui, sans-serif;
  --font-mono: var(--font-mono), monospace;
  --font-display: var(--font-display), system-ui, sans-serif;
}
```

> **Fontshare fonts** (Cabinet Grotesk, Satoshi, Clash Display): can't use `next/font/google`.
> Use `next/font/local` with downloaded files, or `<link>` + CSS `@import` in layout.

### Rules

- **Never use Geist Sans** as the primary font — it's the default vibe coding font and looks the same everywhere
- Display font only at 18px+ — using it small collapses the hierarchy
- No two serif display fonts together without strong weight contrast
- Max 3 families total

---

## 2. Color Palette

**Never use raw Tailwind color names** (`zinc-950`, `slate-800`, `gray-700`) as the primary palette. Always define a custom named palette via CSS variables.

### Required token structure

```css
@theme {
  /* Backgrounds — always add a hue tint, never pure black */
  --color-bg:      #0c0b10;   /* near-black: subtle purple tint */
  --color-surface: #131219;   /* slightly elevated */
  --color-card:    #191820;   /* card / panel */

  /* Borders */
  --color-border:       #26243a;
  --color-border-hover: #3d3a57;

  /* Text */
  --color-text:   #e8e6f0;   /* off-white — never pure #fff */
  --color-muted:  #6b688a;   /* secondary / helper text */
  --color-faint:  #2c2a3e;   /* disabled state, placeholder bg */

  /* Accent — one primary, one secondary max */
  --color-accent:        #ff4f6a;
  --color-accent-dim:    rgba(255, 79, 106, 0.12);
  --color-secondary:     #7c5cf5;
  --color-secondary-dim: rgba(124, 92, 245, 0.12);
}
```

### Light theme equivalent

```css
--color-bg:      #fafaf7;   /* warm off-white — never pure #fff */
--color-surface: #f2f1ec;
--color-card:    #ffffff;
--color-border:  #e4e1d8;
--color-text:    #1a1918;   /* warm near-black — never pure #000 */
--color-muted:   #8a877a;
--color-faint:   #f0ede6;
--color-accent:  #d4622a;   /* warm coral — more distinctive than blue-500 */
--color-accent-dim: rgba(212, 98, 42, 0.10);
```

### Rules

- Always tint blacks with a hue (cool blue, warm brown, subtle purple) — pure `#000` looks flat
- Off-whites over pure white: `#fafaf7`, `#f7f6f3`, `#fefcf9`
- One accent color used consistently — not multiple unrelated hues
- Every accent needs a `*-dim` variant (10–15% opacity) for background fills
- Use token names in code, never hardcoded hex

### Anti-patterns

- ❌ `bg-zinc-950` / `bg-zinc-900` / `bg-zinc-800` as the entire palette
- ❌ `text-gray-400` scattered everywhere
- ❌ Multiple unrelated accent colors (red + blue + green)
- ❌ Hardcoded hex values in component files — always use tokens

---

## 3. Border Radius

The most common reason UI looks "cheap": wrong radius for the size, and the same radius everywhere.

### The core principle: radius scales with element size

Small elements → small radius. Large containers → larger radius. Full-width → zero.

```
Badge / tag / chip    →  4px
Input / select        →  6px
Button (default)      →  6–8px
Card / panel          →  8–10px   ← NOT rounded-xl (12px+)
Modal / dialog        →  12–16px
Bottom sheet          →  16–20px top corners only
Full-bleed section    →  0px
```

### The Nested Radius Rule

When an element lives inside a container, its radius must be:

```
inner radius = outer radius − gap/padding
```

```
outer card:   border-radius 10px, padding 12px
→ inner image: border-radius 10 − 12 = should be ~0 (flush) or clamp to min 2px
→ inner button: border-radius ~6px (10 - 4px visual gap)
```

Violating this is the #1 reason cards look misaligned — the inner element's corners visually "escape" the container.

```css
/* Utility — compute nested radius automatically */
.card {
  --r: 10px;
  --p: 12px;
  border-radius: var(--r);
  padding: var(--p);
}
.card .inner {
  border-radius: max(0px, calc(var(--r) - var(--p)));
}
```

### Use a 3-token system — never mix freely

```css
@theme {
  --radius-sm: 4px;    /* badges, chips, small inputs */
  --radius-md: 8px;    /* buttons, dropdowns, inputs */
  --radius-lg: 12px;   /* cards, panels, modals */
  /* beyond lg: pill (9999px) or 0 — nothing in between */
}
```

Never use `rounded-xl`, `rounded-2xl`, `rounded-3xl` ad-hoc. Every radius must map to one of the 3 tokens.

### Directional radius — vary per edge for hierarchy

Not everything needs all 4 corners rounded:

```css
/* Code block with left accent */
border-radius: 0 6px 6px 0;
border-left: 3px solid var(--color-accent);

/* Tab / top nav item */
border-radius: 6px 6px 0 0;

/* Notification toast — right side */
border-radius: 8px 0 0 8px;

/* Bottom sheet */
border-radius: 16px 16px 0 0;
```

### When to use sharp edges (0px)

Sharp edges signal structure and precision. Use them intentionally:

- Full-width / full-height containers (page sections, navbars)
- Data tables and rows
- Code editors, terminals
- Any element that bleeds to a screen edge
- Dividers and borders used as layout separators

### Anti-patterns

- ❌ `rounded-xl` on everything regardless of size
- ❌ Same radius on a 200px modal and a 20px badge
- ❌ Inner element radius larger than outer container radius
- ❌ `rounded-2xl` on buttons (pill-ish buttons look consumer/playful — wrong for most B2B)
- ❌ Mixing all five Tailwind radius sizes freely (sm/md/lg/xl/2xl all in the same UI)

---

## 4. Layout & Elevation

### Container widths

```
Reading / content         max-width: 680px
Standard page / feed      max-width: 760px
Wide dashboard / grid     max-width: 1100px
Full-bleed hero           no max-width
```

### Elevation: border over shadow

Use background color difference as the primary depth signal. Reserve shadows for floating elements.

```
Page background  →  --color-bg
Elevated surface →  --color-surface  (sidebar, header)
Card             →  --color-card + 1px solid --color-border
Modal / overlay  →  --color-card + shadow (first time shadow is appropriate)
```

- ❌ Do not stack `box-shadow` layers to fake depth on cards
- ❌ Do not use shadow on inline elements, badges, or list items
- ✓ Shadow only on: modals, dropdowns, floating panels, tooltips

### Section breaks

```
Between major sections:   border-top: 1px solid var(--color-border)  or  padding gap
Between list items:       border-bottom on each item  or  gap with no box
Full-bleed section bg:    background tint, NOT a card wrapper
```

Never repeat the same card box for every section type. Lists should be lists, not grids of cards.

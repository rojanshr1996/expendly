---
name: Lumina Wallet
colors:
  surface: '#0e1513'
  surface-dim: '#0e1513'
  surface-bright: '#333b39'
  surface-container-lowest: '#09100e'
  surface-container-low: '#161d1b'
  surface-container: '#1a211f'
  surface-container-high: '#242b2a'
  surface-container-highest: '#2f3634'
  on-surface: '#dde4e1'
  on-surface-variant: '#bacac5'
  inverse-surface: '#dde4e1'
  inverse-on-surface: '#2b3230'
  outline: '#859490'
  outline-variant: '#3c4a46'
  surface-tint: '#3cddc7'
  primary: '#57f1db'
  on-primary: '#003731'
  primary-container: '#2dd4bf'
  on-primary-container: '#00574d'
  inverse-primary: '#006b5f'
  secondary: '#c0c1ff'
  on-secondary: '#1000a9'
  secondary-container: '#3131c0'
  on-secondary-container: '#b0b2ff'
  tertiary: '#ffd1aa'
  on-tertiary: '#4b2800'
  tertiary-container: '#ffac5a'
  on-tertiary-container: '#744000'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#62fae3'
  primary-fixed-dim: '#3cddc7'
  on-primary-fixed: '#00201c'
  on-primary-fixed-variant: '#005047'
  secondary-fixed: '#e1e0ff'
  secondary-fixed-dim: '#c0c1ff'
  on-secondary-fixed: '#07006c'
  on-secondary-fixed-variant: '#2f2ebe'
  tertiary-fixed: '#ffdcc0'
  tertiary-fixed-dim: '#ffb875'
  on-tertiary-fixed: '#2d1600'
  on-tertiary-fixed-variant: '#6b3b00'
  background: '#0e1513'
  on-background: '#dde4e1'
  surface-variant: '#2f3634'
  semantic-red: '#fb7185'
  semantic-green: '#34d399'
  glass-overlay: rgba(14, 21, 19, 0.7)
  glass-stroke: rgba(255, 255, 255, 0.05)
typography:
  display-lg:
    fontFamily: Hanken Grotesk
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Hanken Grotesk
    fontSize: 22px
    fontWeight: '700'
    lineHeight: 28px
  title-lg:
    fontFamily: Hanken Grotesk
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-md:
    fontFamily: Hanken Grotesk
    fontSize: 15px
    fontWeight: '500'
    lineHeight: 22px
  body-sm:
    fontFamily: Hanken Grotesk
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-md:
    fontFamily: JetBrains Mono
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
    letterSpacing: 0.05em
  label-sm:
    fontFamily: JetBrains Mono
    fontSize: 10px
    fontWeight: '400'
    lineHeight: 12px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  container-padding: 24px
  gutter-md: 16px
  base: 8px
  inner-component: 12px
  stack-tight: 4px
---

## Brand & Style

Lumina Wallet is a high-performance personal finance interface designed for clarity and confidence. The brand personality is **Modern-Technical**—it blends the precision of fintech with the immersive depth of high-end consumer hardware. 

The design style is a sophisticated **Glassmorphic-Material hybrid**. It utilizes a deep, dark-mode foundation with translucent layers and vibrant "bioluminescent" accents. The interface relies on a combination of frosted glass textures, subtle backdrop blurs, and glowing primary elements to guide the eye toward critical financial data. The aesthetic is futuristic yet grounded, evoking the feel of a premium physical cockpit for digital assets.

## Colors

The palette is anchored in a deep emerald-black neutral space (`#0e1513`), providing a high-contrast stage for tactical information.

- **Primary (`#2dd4bf`):** A vibrant teal used for growth indicators, main actions (FABs), and positive data trajectories.
- **Secondary (`#6366f1`):** A technical indigo used for informational categories and secondary interactive states.
- **Tertiary (`#ffac5a`):** An amber accent reserved for supplemental data categories and recurring events.
- **Semantic Logic:** Green and Red are used strictly for financial directionality (Inflow vs. Outflow). 

Surface tiers are built using a "Sea Glass" logic: deeper levels are darker and more opaque, while elevated interactive cards use `#1a211f` with a subtle white-stroke boundary.

## Typography

The typography system uses a dual-font approach to balance human readability with technical precision.

- **Hanken Grotesk (Primary):** Used for all brand-facing elements, headlines, and financial totals. Its clean, sharp metrics ensure legibility even at small weights.
- **JetBrains Mono (Secondary):** Used for labels, date stamps, and secondary data points. This introduces a "ledger-style" aesthetic that reinforces the financial context of the application.

Large numerical totals should use a slight negative letter spacing to feel more compact and impactful. Labels should always be uppercase with wide tracking to differentiate them from body content.

## Layout & Spacing

The layout utilizes a **Contextual Fluid Grid** that transitions from a single-column stack on mobile to a structured Bento Grid on larger screens.

- **Margins:** 24px fixed safe-area margins for main mobile containers.
- **Gutters:** 16px consistent spacing between independent modules.
- **Stacking:** Elements within a card use an 8px base rhythm (`base`).

Visual groupings are achieved through "Bento" blocks—rounded containers that encapsulate related data points. On desktop, these blocks should span different column widths (e.g., 2:1 ratio) to maintain hierarchy.

## Elevation & Depth

Elevation is conveyed through a combination of **Blur and Glow** rather than traditional drop shadows.

1.  **Base Layer:** The darkest background (`#0e1513`).
2.  **Raised Containers:** Cards use `surface-container` with a `1px` stroke at 5% white opacity to define edges.
3.  **Glass Headers/Nav:** Use 70% opacity with a `12px` backdrop blur to create a sense of floating over the content.
4.  **Shadows:** Shadows are reserved for high-impact items. Use a diffused, low-opacity shadow for standard cards, and a **tinted glow shadow** (`rgba(87, 241, 219, 0.3)`) for the primary FAB and active budget bars.

## Shapes

The shape language is **Refined-Rounded**. It avoids the playfulness of pill shapes but ensures no sharp corners exist in the main UI.

- **Primary Cards:** 12px (xl) corner radius for a modern, approachable feel.
- **Secondary Buttons/Icons:** 8px (lg) for tighter elements.
- **Floating Action Buttons:** 16px (2xl) to make them distinct from standard content blocks.
- **Interactive States:** Use soft transitions for hover/active states that subtly scale the container (e.g., 98.5% scale on press).

## Components

- **Buttons:** Primary buttons/FABs are solid Primary (`#2dd4bf`) with high-contrast text. Secondary buttons use a transparent background with a subtle border.
- **Bento Cards:** Every card must have a 1px `glass-stroke` and `container-padding` of 24px.
- **Progress Bars:** Use a high-contrast track (`white/10`) and a glowing fill. The fill should have an outer glow shadow of its own color.
- **Bottom Navigation:** Uses a frosted glass effect with active indicators highlighted by a background pill (`primary/10`).
- **Charts:** Bar charts should use `rounded-t-lg` tops and varying opacities of the primary color to represent "Active" vs. "Inactive" data states.
- **Lists:** Transaction items use an 11x11 unit icon container with a `surface-container-highest` background and 8px rounding.
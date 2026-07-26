---
name: Modern Fiscal Core
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
  surface-lowest: '#0F172A'
  surface-low: '#1E293B'
  surface-mid: '#334155'
  semantic-red: '#FB7185'
  semantic-green: '#34D399'
  glass-stroke: rgba(255, 255, 255, 0.1)
typography:
  headline-lg:
    fontFamily: Hanken Grotesk
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.04em
  headline-md:
    fontFamily: Hanken Grotesk
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.03em
  body-lg:
    fontFamily: Hanken Grotesk
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: -0.01em
  body-md:
    fontFamily: Hanken Grotesk
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0em
  label-md:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.02em
  headline-lg-mobile:
    fontFamily: Hanken Grotesk
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
    letterSpacing: -0.04em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  container-padding: 24px
  gutter-md: 16px
  inner-component: 12px
  stack-tight: 4px
---

## Brand & Style

The design system is anchored in a philosophy of **Modern Efficiency** and **Private Utility**. It targets users who demand a professional-grade financial tool that feels lightweight, secure, and offline-first. The emotional response should be one of "Calculated Calm"—removing the anxiety of over-complex accounting in favor of clear, actionable data.

The visual style is **Corporate Modern with Glassmorphic Accents**. It utilizes a sophisticated "Surface System" where depth is communicated through subtle tonal shifts rather than heavy shadows. This approach ensures the UI remains clean and "simple" as per the SRS, while providing a premium, tactile feel through micro-interactions and translucent layers for persistent navigation elements.

## Colors

The palette centers on a deep "Midnight Slate" foundation to support the AMOLED-friendly requirements of the SRS. The primary color is a refined **Teal**, chosen for its association with modern fintech and its high legibility against dark surfaces.

The semantic colors (Red for expenses, Green for income) have been desaturated and shifted toward the cooler spectrum to harmonize with the Slate base, preventing visual fatigue during frequent data entry. We employ a "Surface-Palette" logic:
- **Surface Lowest:** The background of the application.
- **Surface Low:** Primary card containers.
- **Surface Mid:** Elevated elements like input fields or active state cards.
- **Glassmorphism:** Applied specifically to the Top Bar and Floating Action Button (FAB) backgrounds to maintain context while scrolling.

## Typography

Typography uses **Hanken Grotesk** for its sharp, contemporary geometry, which aligns with the "Modern Fiscal" narrative. To achieve a premium feel, letter-spacing (tracking) is tightened on all headlines to create a more impactful, "locked-in" visual density.

For data-heavy elements—such as transaction amounts, currency codes, and timestamps—**JetBrains Mono** is utilized. This monospaced font ensures that numerical data aligns perfectly in lists and tables, reinforcing the application's precision-oriented utility. The type scale is intentional: large, bold headlines for totals, and strict, compact labels for metadata.

## Layout & Spacing

This design system uses a **Fluid Grid with Fixed Margins**. The layout relies on an 8px base unit (the "Fiscal Step"). On mobile devices, a standard 24px side margin is maintained to keep content away from the screen edges, while tablet layouts utilize a centered 12-column grid with a maximum content width of 1024px.

Spacing rhythm is strictly vertical:
- **24px** between major sections (e.g., Monthly Expense card to Daily Breakdown).
- **16px** between items in a list.
- **8px** between a label and its corresponding input or data point.

## Elevation & Depth

Hierarchy is established through **Tonal Layers** and **Subtle Blurs** rather than traditional drop shadows.

- **Level 0 (Base):** `#0F172A`. The canvas.
- **Level 1 (Cards):** `#1E293B` with a 1px `glass-stroke` (10% white) border. This creates definition without needing a shadow.
- **Level 2 (Active/Modals):** `#334155`. Used for elements currently being interacted with.
- **Glassmorphism:** The Header and Bottom Navigation use a 20px Backdrop Blur with a 60% opacity fill of the background color. 

**Micro-interactions:** When a user hovers or presses an element, it should scale by **0.98x** (gentle compression) and gain a soft, tinted glow (12px blur, color matching the primary teal at 20% opacity) to simulate physical depth.

## Shapes

The shape language is **Rounded**, utilizing a 0.5rem (8px) base corner radius. This strikes a balance between the "sharp" precision of a financial tool and the "approachable" friendliness required by the SRS. 

- **Standard Elements:** (Buttons, Input Fields) use `rounded`.
- **Containers:** (Summary Cards, Bottom Sheets) use `rounded-lg` (16px) for a more modern, encased look.
- **Interactive Chips:** Use `rounded-xl` (24px) to distinguish them as tappable filters or tags.

## Components

### Buttons
- **Primary:** Solid teal background with midnight slate text. 0.98x scale on tap.
- **Secondary:** Ghost style with `glass-stroke` border and teal text.
- **FAB:** Glassmorphic circle with a high-contrast icon.

### Input Fields
- Filled style using `surface-mid`. No bottom line; instead, a full 1px border that glows teal on focus. Labels use the monospaced font for a technical look.

### Cards
- No shadows. Use a 1px stroke (`glass-stroke`). For the "Monthly Expense" card, use a subtle gradient background (Primary to Secondary at 10% opacity) to signify its importance.

### List Items (Transactions)
- Compact height. The category icon is housed in a `rounded-lg` square with a 10% opacity tint of the category's assigned color. Amounts are always monospaced.

### Progress Bars (Budgets)
- Thick 8px bars with rounded ends. The "track" is `surface-mid`. The "fill" uses a gradient. Upon hitting 90%, the fill pulses with a soft red glow.
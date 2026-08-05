---
name: Sky Fiscal
colors:
  surface: '#faf8ff'
  surface-dim: '#d2d9f4'
  surface-bright: '#faf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f3ff'
  surface-container: '#eaedff'
  surface-container-high: '#e2e7ff'
  surface-container-highest: '#dae2fd'
  on-surface: '#131b2e'
  on-surface-variant: '#3f4850'
  inverse-surface: '#283044'
  inverse-on-surface: '#eef0ff'
  outline: '#707881'
  outline-variant: '#bfc7d2'
  surface-tint: '#006398'
  primary: '#006194'
  on-primary: '#ffffff'
  primary-container: '#007bb9'
  on-primary-container: '#fdfcff'
  inverse-primary: '#93ccff'
  secondary: '#006c49'
  on-secondary: '#ffffff'
  secondary-container: '#6cf8bb'
  on-secondary-container: '#00714d'
  tertiary: '#a53337'
  on-tertiary: '#ffffff'
  tertiary-container: '#c64b4d'
  on-tertiary-container: '#fffbff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#cce5ff'
  primary-fixed-dim: '#93ccff'
  on-primary-fixed: '#001d31'
  on-primary-fixed-variant: '#004b73'
  secondary-fixed: '#6ffbbe'
  secondary-fixed-dim: '#4edea3'
  on-secondary-fixed: '#002113'
  on-secondary-fixed-variant: '#005236'
  tertiary-fixed: '#ffdad8'
  tertiary-fixed-dim: '#ffb3b0'
  on-tertiary-fixed: '#410006'
  on-tertiary-fixed-variant: '#881d24'
  background: '#faf8ff'
  on-background: '#131b2e'
  surface-variant: '#dae2fd'
typography:
  headline-lg:
    fontFamily: Manrope
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Manrope
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Manrope
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  headline-sm:
    fontFamily: Manrope
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Manrope
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Manrope
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Manrope
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Manrope
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Manrope
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 40px
  gutter: 20px
  margin-mobile: 16px
  margin-desktop: 64px
  max-width: 1280px
---

## Brand & Style
The design system is anchored in a philosophy of "Atmospheric Clarity." It targets modern professionals and personal finance enthusiasts who require a sense of calm and precision when managing their wealth. The brand personality is dependable, transparent, and effortlessly light.

The visual style is a refined blend of **Minimalism** and **Corporate Modern**. It utilizes high-quality whitespace to reduce cognitive load, ensuring that complex financial data feels approachable. UI elements are treated with subtle depth, avoiding heavy ornamentation in favor of crisp execution and a "breathable" interface that mirrors the open sky.

## Colors
The palette is designed to evoke trust and precision. The Primary Sky Blue is the focal point for action and identity. 

- **Primary (#0284c7):** Used for key actions, active states, and brand highlights.
- **Surface (#f0f9ff):** The base canvas color, tinted slightly to reduce eye strain and provide a "sky" feel.
- **Surface-Container (#e0f2fe):** Used for cards, grouping elements, and secondary background layers.
- **Success (#10b981):** A professional emerald reserved for positive growth, income, and completed transactions.
- **Error (#f87171):** A coral-tinted red for expenses, alerts, and critical warnings.
- **Neutral (#0f172a):** A deep navy-slate used for text and iconography to maintain high legibility against blue-tinted backgrounds.

## Typography
Manrope is selected for its modern, geometric construction and excellent legibility in data-heavy environments. 

- **Headlines:** Use Bold (700) or SemiBold (600) weights with slight negative letter-spacing to maintain a compact, professional look.
- **Body Text:** Standardized on a 16px base for optimal readability. 
- **Labels:** Used for navigation items, table headers, and small metadata. Table headers should utilize `label-sm` with a slight uppercase transform for structural clarity.
- **Numerical Data:** When displaying currency, use SemiBold weights to ensure figures stand out from descriptive text.

## Layout & Spacing
This design system utilizes a **Fluid Grid** model with strict adherence to a 4px baseline rhythm.

- **Desktop:** 12-column grid with 24px gutters. The layout is centered with a max-width of 1280px to prevent excessive line lengths in financial tables.
- **Mobile:** 4-column grid with 16px margins.
- **Spacing Logic:** Use `md` (16px) for internal padding of cards and `lg` (24px) for spacing between major sections. Generous `xl` (40px) vertical padding is encouraged between distinct content blocks to maintain the "Airy" aesthetic.

## Elevation & Depth
Depth is communicated through **Tonal Layering** rather than heavy shadows.

- **Level 0 (Base):** The `Surface` color (#f0f9ff).
- **Level 1 (Cards/Containers):** The `Surface-Container` color (#e0f2fe) with a very soft, high-diffusion shadow: `0px 4px 20px rgba(2, 132, 199, 0.04)`.
- **Level 2 (Modals/Popovers):** White background (#ffffff) with a more defined shadow: `0px 12px 32px rgba(15, 23, 42, 0.08)`.
- **Outlines:** Use 1px borders of a slightly darker blue-tinted shade for input fields and interactive elements to ensure accessibility without breaking the minimalist feel.

## Shapes
The shape language is consistently "Rounded" to convey friendliness and modern accessibility.

- **Base Radius:** 8px (0.5rem) for buttons, input fields, and standard chips.
- **Large Radius:** 16px (1rem) for content cards and dashboard modules.
- **Extra Large Radius:** 24px (1.5rem) for bottom sheets and large modal containers.
- **Full Radius:** Used exclusively for circular icons or toggle switches.

## Components
- **Buttons:** Primary buttons use the Sky Blue background with white text. Secondary buttons use a transparent background with a 1px `Primary` border.
- **Input Fields:** Use a white background with an 8px corner radius. The border should be a subtle slate-blue, becoming `Primary` 2px on focus.
- **Cards:** Cards are the primary vessel for data. They should use the `Surface-Container` background or White with a soft shadow. Padding should be a minimum of 24px (`lg`).
- **Chips:** Used for transaction categories. They utilize a low-opacity version of the Primary or Success colors with matched-color text (e.g., Success text on light emerald background).
- **Data Tables:** Remove vertical borders. Use horizontal dividers in a very light slate. Header row should use `label-sm` and a subtle `Surface-Container` background.
- **Progress Bars:** Use a thick 8px track. The track should be `Surface-Container` and the fill `Primary` or `Success` depending on the context.
---
name: Sonic Architect
colors:
  surface: '#131313'
  surface-dim: '#131313'
  surface-bright: '#3a3939'
  surface-container-lowest: '#0e0e0e'
  surface-container-low: '#1c1b1b'
  surface-container: '#201f1f'
  surface-container-high: '#2a2a2a'
  surface-container-highest: '#353534'
  on-surface: '#e5e2e1'
  on-surface-variant: '#b9ccb2'
  inverse-surface: '#e5e2e1'
  inverse-on-surface: '#313030'
  outline: '#84967e'
  outline-variant: '#3b4b37'
  surface-tint: '#00e639'
  primary: '#ebffe2'
  on-primary: '#003907'
  primary-container: '#00ff41'
  on-primary-container: '#007117'
  inverse-primary: '#006e16'
  secondary: '#9bd592'
  on-secondary: '#003907'
  secondary-container: '#1f531f'
  on-secondary-container: '#8ec785'
  tertiary: '#fff8f4'
  on-tertiary: '#442b10'
  tertiary-container: '#ffd5ae'
  on-tertiary-container: '#7a5b3c'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#72ff70'
  primary-fixed-dim: '#00e639'
  on-primary-fixed: '#002203'
  on-primary-fixed-variant: '#00530e'
  secondary-fixed: '#b6f2ac'
  secondary-fixed-dim: '#9bd592'
  on-secondary-fixed: '#002203'
  on-secondary-fixed-variant: '#1d511d'
  tertiary-fixed: '#ffdcbd'
  tertiary-fixed-dim: '#e7bf99'
  on-tertiary-fixed: '#2c1701'
  on-tertiary-fixed-variant: '#5d4124'
  background: '#131313'
  on-background: '#e5e2e1'
  surface-variant: '#353534'
typography:
  display-lg:
    fontFamily: Comfortaa
    fontSize: 4.5rem
    fontWeight: '700'
    lineHeight: 4.5rem
    letterSpacing: -0.04em
  display-lg-mobile:
    fontFamily: Comfortaa
    fontSize: 3.5rem
    fontWeight: '700'
    lineHeight: 3.5rem
    letterSpacing: -0.04em
  headline-md:
    fontFamily: Comfortaa
    fontSize: 1.75rem
    fontWeight: '600'
    lineHeight: 2.25rem
    letterSpacing: -0.02em
  title-sm:
    fontFamily: Comfortaa
    fontSize: 1rem
    fontWeight: '500'
    lineHeight: 1.5rem
    letterSpacing: 0em
  body-md:
    fontFamily: Comfortaa
    fontSize: 0.875rem
    fontWeight: '400'
    lineHeight: 1.375rem
    letterSpacing: 0.01em
  label-md:
    fontFamily: Comfortaa
    fontSize: 0.75rem
    fontWeight: '600'
    lineHeight: 1rem
    letterSpacing: 0.12em
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  gutter: 1.25rem
  gutter-mobile: 0.75rem
  margin: 2rem
  margin-mobile: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2.5rem
---

# Design System Strategy: The Sonic Architect

## 1. Overview & Creative North Star
The visual language of this design system is built upon the concept of **"The Sonic Architect."** It represents the intersection of rigid mathematical precision and the kinetic energy of music.
This is not a "standard" utility app. It is a high-end instrument. To achieve this, the system moves away from generic UI patterns—like heavy borders and flat grey boxes—and instead embraces **Atmospheric Depth**. We utilize extreme contrast between obsidian surfaces and neon signals, friendly rounded geometry, and intentional asymmetry to create a layout that feels curated, not templated.

### The Signature Look
- **Kinetic Energy:** Use the Neon Green (`#00FF41`) not just as a color, but as a source of light that casts a "glow" on surrounding dark surfaces.
- **Intentional Breathing Room:** Use the Spacing Scale to create expansive voids. A premium experience feels "expensive" because it isn't crowded.
- **Monolithic Surfaces:** Elements should feel like they are carved out of a single piece of dark matte material or floating as frosted glass.

---

## 2. Colors
Our palette is rooted in a high-contrast dark theme designed to minimize eye strain in studio environments while highlighting the "pulse."

### Core Brand Palette
| Token | Hex | Role |
| :--- | :--- | :--- |
| **Primary (Neon)** | `#00FF41` | Active states, Play button, kinetic accents, pulse beacons. |
| **Primary Container** | `#003907` | Deep green underlayer, high contrast icon fills. |
| **Surface (Lowest)** | `#0E0E0E` | Deep Matte Black. The primary canvas. |
| **Surface (Low)** | `#131313` | Default background for the main interface & section plates. |
| **Surface (High)** | `#2A2A2A` | Secondary buttons and card-like containers. |
| **Surface (Highest)** | `#363636` | Inactive chips, toggle tracks, active selection backgrounds. |
| **On-Surface (Primary)** | `#FFFFFF` | Primary typography and high-contrast icons. |
| **On-Surface (Muted)** | `#888888` | Labels, secondary info, subdivision markers, and disabled states. |

### The "No-Line" Rule
**Strict Mandate:** 1px solid borders are prohibited for sectioning. Boundaries must be defined solely through background color shifts.
* *Correct:* A `surface_container_high` card sitting on a `surface_container_lowest` background.
* *Incorrect:* A black card with a grey border.

### Signature Textures & Gradients
To avoid a flat "bootstrap" look, apply a subtle **Radial Glow** using `rgba(0, 255, 65, 0.08)` behind the main tempo indicator. This mimics the physical dispersion of light from an analog LED studio display.

---

## 3. Typography
We use Comfortaa consistently across all levels to balance technical precision with a friendly, modern, and rounded aesthetic.
* **Display, Headlines, & Body (Comfortaa):** A geometric typeface with rounded terminals that harmonizes with our pill-shaped components. Use `display-lg` (3.5rem to 4.5rem) for the BPM to make it the undisputed hero of the screen.

| Level | Size | Typeface | Weight | Tracking | Usage |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Display-LG** | 3.5rem - 4.5rem | Comfortaa | 700 | -0.04em | BPM Value |
| **Headline-MD** | 1.75rem | Comfortaa | 600 | -0.02em | Section Headers / Time Signature |
| **Title-SM** | 1.0rem | Comfortaa | 500 | 0em | Menu Items / Modal Titles |
| **Body-MD** | 0.875rem | Comfortaa | 400 | 0.01em | Supporting Text / Tempo Names (Andante, Allegro) |
| **Label-MD** | 0.75rem | Comfortaa | 600 | 0.12em | All-caps metadata/labels (SUBDIVISIONS, TAP TEMPO) |

---

## 4. Elevation & Depth
In this system, depth is achieved through **Tonal Layering** rather than traditional drop shadows.

### The Layering Principle
Think of the UI as layers of fine paper stacked in a dark room.
1. **Base Layer:** `surface_container_lowest` (`#0E0E0E`) - The canvas floor.
2. **Section Layer:** `surface_container_low` (`#131313`) - Defined areas, rhythm wheels, meter plates.
3. **Interaction Layer:** `surface_container_high` (`#2A2A2A`) - Tappable cards, quick tempo presets.

### Glassmorphism & Depth
For floating overlays (like a tempo-tap modal or sound library drawer), use a semi-transparent background (`rgba(19, 19, 19, 0.75)`) with a **Backdrop Blur** (16px-24px). This allows the neon pulses of the background to "bleed" through, keeping the user connected to the beat even while in a menu.

### Ambient Shadows
If a "lift" is required, use a shadow with a large blur (24px+) and very low opacity (6%). The shadow should be tinted with `rgba(0, 255, 65, 0.12)` to suggest the neon green light is being occluded.

---

## 5. Components & Interactive Patterns

### The "Pulse" Button (Primary CTA)
The play/stop button is the kinetic heart of the application.
- **Shape:** Pill or Circular (`rounded-full`), minimum 72px x 72px for mobile thumb-reach.
- **Background:** `#00FF41` (Neon Green).
- **Icon / Label Color:** `#003907` (Deepest Forest Green/Black for maximum contrast).
- **Active State / Pulse Animation:** Outer ambient glow `box-shadow: 0 0 32px rgba(0, 255, 65, 0.45)`. Expand slightly on the primary downbeat.

### Beat & Subdivision Matrix
- **Beats Indicator:** Discrete LED-style indicator dots or horizontal bar segmented capsules.
- **Downbeat (Accent Beat 1):** Full `#00FF41` flare with a brief ring ping.
- **Secondary Beats:** Subtle surface pill (`#2A2A2A`) flashing to `#888888` on hit.
- **Subdivision Badges:** Quarter, eighth, triplet, sixteenth note pills using Comfortaa with ghost outlines.

### Selection Chips & Presets
- **Inactive:** `surface_container_highest` (`#363636` or `#2A2A2A`) with `on_surface_muted` (`#888888`) text.
- **Active:** `primary_container` (`#003907`) or neon text with a subtle "Ghost Border" (`rgba(255, 255, 255, 0.10)`) or neon hairline glow.

### Interaction Fields & Steppers
Forbid traditional enclosed input boxes.
- **BPM Adjuster:** Tactile jog dial or large minimalist slider with glowing neon thumb indicator.
- **Focus / Input State:** A bottom-weighted 2px Neon Green line indicator, container remaining borderless.

### List Items
Forbid divider lines. Use `0.375rem` to `0.5rem` spacing between items and a subtle hover/press state shift to `surface_high` to indicate interactivity.

---

## 6. Do's and Don'ts

### Do
- **Do** embrace asymmetry. Center the BPM but offset secondary controls (e.g. Tap Tempo, subdivisions, playlist presets) to create an editorial, studio-hardware look.
- **Do** use "Ghost Borders" (`rgba(255, 255, 255, 0.08)`) strictly when surfaces share identical values and separation is essential for accessibility.
- **Do** allow typography to lead. Comfortaa in all-caps tracking provides clear hierarchy without needing container boxes.

### Don't
- **Don't** use pure neutral grey (`#CCCCCC`). Stick to dark obsidian tones and muted charcoal `#888888` to keep contrast punchy.
- **Don't** use sharp corners; adhere strictly to heavily rounded, pill-like shapes for buttons and cards.
- **Don't** use 100% opaque black drop shadows. Always tint shadows or use tonal layering.
- **Don't** add 1px solid dividing lines between sections.
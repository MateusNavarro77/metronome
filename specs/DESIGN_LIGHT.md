---
name: Sonic Architect (Light)
colors:
  surface: '#F7F7F6'
  surface-dim: '#EBEBEA'
  surface-bright: '#FFFFFF'
  surface-container-lowest: '#FFFFFF'
  surface-container-low: '#F2F2F0'
  surface-container: '#EAEAE8'
  surface-container-high: '#E0E0DD'
  surface-container-highest: '#D5D5D1'
  on-surface: '#121212'
  on-surface-variant: '#4B5548'
  inverse-surface: '#1E1E1E'
  inverse-on-surface: '#F7F7F6'
  outline: '#767F74'
  outline-variant: '#C4CBC1'
  surface-tint: '#00B834'
  primary: '#00B834'
  on-primary: '#FFFFFF'
  primary-container: '#DCF7DF'
  on-primary-container: '#004D14'
  inverse-primary: '#72FF70'
  secondary: '#2E7D32'
  on-secondary: '#FFFFFF'
  secondary-container: '#C8E6C9'
  on-secondary-container: '#1B5E20'
  tertiary: '#795548'
  on-tertiary: '#FFFFFF'
  tertiary-container: '#D7CCC8'
  on-tertiary-container: '#3E2723'
  error: '#BA1A1A'
  on-error: '#FFFFFF'
  error-container: '#FFDAD6'
  on-error-container: '#410002'
  background: '#F7F7F6'
  on-background: '#121212'
  surface-variant: '#EAEAE8'
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

# Design System Strategy: The Sonic Architect (Light Edition)

## 1. Overview & Creative North Star
The Light Edition of **"The Sonic Architect"** translates the high-precision studio aesthetic into a bright, architectural daylight workspace. Inspired by industrial design studios, precision drafting paper, and modern synthesizer hardware, this theme delivers optimal legibility in brightly lit environments while retaining the signature kinetic pulse.

### The Signature Look
- **Architectural Studio Surfaces:** Crisp off-white (`#F7F7F6`) canvas floor paired with elevated white plates (`#FFFFFF`) and warm grey structural containers (`#EAEAE8`).
- **Precision Emerald Signals:** A balanced high-contrast emerald/neon green (`#00B834`) that cuts through bright surfaces with energetic clarity.
- **Tonal Depth Without Heavy Borders:** Strict adherence to tonal layering; sections are delineated by subtle shifts in luminance rather than jarring stroke lines.

---

## 2. Colors

### Core Brand Palette
| Token | Hex | Role |
| :--- | :--- | :--- |
| **Primary (Accent)** | `#00B834` | Active states, Play button, kinetic accents, pulse beacons. |
| **Primary Container** | `#DCF7DF` | Soft mint underlayer, high contrast icon fills. |
| **Surface (Lowest)** | `#F7F7F6` | Crisp architectural off-white floor canvas. |
| **Surface (Low)** | `#FFFFFF` | Default background for the main interface & section plates. |
| **Surface (Container)** | `#EAEAE8` | Intermediate surface for controls and panels. |
| **Surface (High)** | `#E0E0DD` | Secondary buttons and interactive card-like containers. |
| **Surface (Highest)** | `#D5D5D1` | Inactive chips, toggle tracks, borders. |
| **On-Surface (Primary)** | `#121212` | Deep architectural charcoal for maximum typographic legibility. |
| **On-Surface (Muted)** | `#6C6C68` | Labels, secondary info, subdivision markers, and disabled states. |
| **Ghost Border** | `rgba(0, 0, 0, 0.08)` | Subtle boundary separation on light surfaces. |
| **Neon Ghost Border** | `rgba(0, 184, 52, 0.35)` | Active selection highlight ring. |
| **Radial Glow** | `rgba(0, 184, 52, 0.10)` | Ambient backdrop behind hero tempo values. |
| **Pulse Glow** | `rgba(0, 184, 52, 0.30)` | Tactile aura on active transport and downbeats. |
| **Error** | `#BA1A1A` | High-visibility warning and error indicators. |

---

## 3. Typography & Components
Typography mirrors the Dark theme using Google Fonts **Comfortaa** with the same geometric scale and weights, rendering with deep ink charcoal (`#121212`) on bright surfaces. Interactive elements retain the same generous pill radii (`rounded-full`, `rounded-md`) and 48px+ touch targets.

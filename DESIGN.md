# Design System Strategy: The Sonic Architect



## 1. Overview & Creative North Star

The visual language of this design system is built upon the concept of **"The Sonic Architect."** It represents the intersection of rigid mathematical precision and the kinetic energy of music.



This is not a "standard" utility app. It is a high-end instrument. To achieve this, the system moves away from generic UI patterns—like heavy borders and flat grey boxes—and instead embraces **Atmospheric Depth**. We utilize extreme contrast between obsidian surfaces and neon signals, high-impact editorial typography, and intentional asymmetry to create a layout that feels curated, not templated.



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

| **Primary (Neon)** | `#00FF41` | Active states, Play button, kinetic accents. |

| **Surface (Lowest)** | `#0E0E0E` | Deep Matte Black. The primary canvas. |

| **Surface (Low)** | `#131313` | Default background for the main interface. |

| **Surface (High)** | `#2A2A2A` | Secondary buttons and card-like containers. |

| **On-Surface (Primary)** | `#FFFFFF` | Primary typography and high-contrast icons. |

| **On-Surface (Muted)** | `#888888` | Labels, secondary info, and disabled states. |



### The "No-Line" Rule

**Strict Mandate:** 1px solid borders are prohibited for sectioning. Boundaries must be defined solely through background color shifts.

* *Correct:* A `surface_container_high` card sitting on a `surface_container_lowest` background.

* *Incorrect:* A black card with a grey border.



### Signature Textures & Gradients

To avoid a flat "bootstrap" look, apply a subtle **Radial Glow** using `primary_container` at 5-10% opacity behind the main tempo indicator. This mimics the physical dispersion of light from a LED.



---



## 3. Typography

We use a dual-typeface system to balance technical precision with modern editorial flair.



* **Display & Headlines (Space Grotesk):** A semi-monospaced, technical typeface that feels like a precision instrument. Use `display-lg` (3.5rem) for the BPM to make it the undisputed hero of the screen.

* **Body & Titles (Inter):** A neutral, highly legible sans-serif. Used for settings, labels, and lists where clarity is paramount.



| Level | Size | Typeface | Usage |

| :--- | :--- | :--- | :--- |

| **Display-LG** | 3.5rem | Space Grotesk | BPM Value |

| **Headline-MD** | 1.75rem | Space Grotesk | Section Headers |

| **Title-SM** | 1.0rem | Inter | Menu Items / Modal Titles |

| **Body-MD** | 0.875rem | Inter | Supporting Text |

| **Label-MD** | 0.75rem | Space Grotesk | All-caps metadata/labels |



---



## 4. Elevation & Depth

In this system, depth is achieved through **Tonal Layering** rather than traditional drop shadows.



### The Layering Principle

Think of the UI as layers of fine paper stacked in a dark room.

1. **Base Layer:** `surface_container_lowest` (#0E0E0E) - The floor.

2. **Section Layer:** `surface_container_low` (#1C1B1B) - Defined areas.

3. **Interaction Layer:** `surface_container_high` (#2A2A2A) - Tappable cards/buttons.



### Glassmorphism & Depth

For floating overlays (like a tempo-tap modal), use a semi-transparent background with a **Backdrop Blur** (12px-20px). This allows the neon pulses of the background to "bleed" through, keeping the user connected to the beat even while in a menu.



### Ambient Shadows

If a "lift" is required, use a shadow with a large blur (24px+) and very low opacity (6%). The shadow should be tinted with `primary` to suggest the neon green light is being occluded.



---



## 5. Components



### The "Pulse" Button (Primary CTA)

The play/stop button should be the most energetic element.

- **Background:** `#00FF41` (Neon Green).

- **Icon Color:** `#003907` (Deepest Green/Black for contrast).

- **Effect:** When active, apply a `0 0 20px` outer glow using `primary_fixed_dim`.



### Selection Chips

- **Inactive:** `surface_container_highest` background with `on_surface_variant` text.

- **Active:** `primary_container` background with a subtle "Ghost Border" (10% opacity white) to define the edge.



### Interaction Fields (Inputs)

Forbid traditional "box" inputs. Use a simple bottom-weighted surface shift.

- **State:** On focus, the bottom edge should glow with a 2px Neon Green line, while the rest of the container remains borderless.



### List Items

Forbid divider lines. Use `1.5` (0.375rem) spacing between items and a subtle hover state shift to `surface_bright` to indicate interactivity.



---



## 6. Do's and Don'ts



### Do

- **Do** embrace asymmetry. Center the BPM but offset the secondary controls to create a modern, editorial feel.

- **Do** use "Ghost Borders" (outline-variant at 15% opacity) only when background colors are too similar for accessibility.

- **Do** allow typography to lead. If a label can explain the hierarchy better than a box, remove the box.



### Don't

- **Don't** use pure grey (#CCCCCC). Use our muted green-greys (`on_surface_variant`) to keep the palette cohesive.

- **Don't** use standard 4px rounded corners for everything. Use `full` (9999px) for buttons and `xl` (0.75rem) for containers to create a softer, more organic feel.

- **Don't** use 100% opaque black for shadows. It creates a "dirty" look on high-end displays. Always use low-opacity tints.
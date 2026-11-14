# Migration Plan: Sonic Architect -> Material 3 Expressive (`material_3_expressive`)

## Locked Decisions
- **Theme & Seed Color:** Light & Dark `M3EThemeData` generated from seed `Color(0xFF6750A4)`, wired to the existing `System` / `Light` / `Dark` preference in `PreferencesViewModel` (`dynamicColoring: false` for now).
- **Typography:** Keep bundled **Comfortaa** (`google_fonts` + `assets/google_fonts/`) applied onto `M3EThemeData` typography/typeScale.
- **Dependencies & Imports:** Keep `material_ui` in `pubspec.yaml` alongside `material_3_expressive` (using `hide CornerRounding, RoundedPolygon` wherever both packages are imported together).
- **Tokens & Dimensions:** Remove `SonicColorsExtension` (`context.colors`) completely in favor of `ColorScheme` / `M3ETheme` tokens. Keep a lean `MetronomeDimens` class only for metronome-specific layout metrics (beat capsules, breakpoints, `maxContentWidth`, minimum touch targets).
- **Migration Strategy:** Two-phase migration, with a dedicated `material-3-expressive` agent skill authored between Phase 1 and Phase 2 using the installed package source in `.pub-cache`:
  1. **Phase 1:** Theme & token foundation swap + legacy spec cleanup.
  2. **Skill Creation:** Author `.agents/skills/material-3-expressive/` grounded in verified `.pub-cache` APIs.
  3. **Phase 2:** Progressive screen-by-screen upgrade to `M3E*` components (preserving `Listener.onPointerDown` for Tap Tempo and custom `BeatIndicatorBar` styled with M3E tokens).

---

## Phase 1: Theme Foundation, Token Cleanup & Legacy Spec Removal

### 1.1 Add `material_3_expressive` Dependency
- Update `pubspec.yaml` to add `material_3_expressive` (keeping `material_ui: ^1.11.0`, `google_fonts`, and `assets/google_fonts/`).
- Run `fvm flutter pub get` and inspect the resolved `material_3_expressive` API in `.pub-cache` for exact constructor parameters of `M3EMaterialApp` and `M3EThemeData` (including `darkTheme` / `themeMode` / typography overrides).

### 1.2 Replace `SonicTheme` with M3E Theme + `MetronomeDimens`
- Replace `lib/ui/core/theme/sonic_theme.dart` with `lib/ui/core/theme/app_theme.dart` (and `MetronomeDimens`):
  - Build `M3EThemeData.light(seedColor: const Color(0xFF6750A4))` and `M3EThemeData.dark(seedColor: const Color(0xFF6750A4))` with **Comfortaa** applied to the M3E typography/typeScale.
  - Remove `SonicColorsExtension`, `SonicContextTheme.colors`, and all neon/radial glow tokens (`pulseGlow`, `radialGlow`, `neonGhostBorder`, etc.).
  - Trim `SonicDimens` down to `MetronomeDimens` containing only metronome-specific layout metrics (`pulseButtonSize`, `stepperButtonSize`, `beatPillContainerHeight`, `beatCapsule*`, `subdivisionPulse*`, `maxContentWidth`, `wideBreakpoint`, `compactHeightBreakpoint`, `minTouchTarget`, spacing helpers if still needed).

### 1.3 Wire `M3EMaterialApp` at Root
- Update `lib/main.dart`:
  - Import `package:material_3_expressive/material_3_expressive.dart` alongside `material_ui` (with `hide CornerRounding, RoundedPolygon` if both are imported).
  - Replace `MaterialApp` with `M3EMaterialApp`, passing the light & dark `M3EThemeData` and binding `themeMode: preferencesViewModel.materialThemeMode`.
  - Remove doc comments referencing `DESIGN_DARK.md` / `DESIGN_LIGHT.md`.

### 1.4 Replace `context.colors` Across All Views & Widgets
Update every UI file to read standard `Theme.of(context).colorScheme`, `Theme.of(context).textTheme`, and `M3ETheme` tokens instead of `context.colors`:
- **Navigation:** `lib/ui/features/navigation/views/adaptive_navigation_shell.dart`
- **Metronome Screen:**
  - `lib/ui/features/metronome/views/metronome_view.dart`
  - `lib/ui/features/metronome/views/widgets/beat_indicator_bar.dart` (map strong downbeat -> `colorScheme.primary` / `onPrimary`, medium beat -> `colorScheme.tertiary` or `secondary`, regular -> `colorScheme.onSurface`, inactive -> `colorScheme.surfaceContainerHighest` / `surfaceContainerHigh`)
  - `lib/ui/features/metronome/views/widgets/bpm_control_section.dart`
  - `lib/ui/features/metronome/views/widgets/transport_controls_bar.dart`
  - `lib/ui/features/metronome/views/widgets/meter_and_subdivision_section.dart`
  - `lib/ui/features/metronome/views/widgets/active_setlist_stepper_bar.dart`
- **Other Screens & Sheets/Dialogs:**
  - `lib/ui/features/preferences/views/preferences_view.dart`
  - `lib/ui/features/presets/views/presets_view.dart` & `lib/ui/features/presets/views/widgets/preset_editor_sheet.dart`
  - `lib/ui/features/setlists/views/setlists_view.dart`, `lib/ui/features/setlists/views/widgets/setlist_detail_sheet.dart`, & `lib/ui/features/setlists/views/widgets/setlist_name_dialog.dart`

### 1.5 Delete Legacy Design Specs & Update Project Rules
- Delete `specs/DESIGN_DARK.md` and `specs/DESIGN_LIGHT.md`.
- Update `AGENTS.md` Section 2 ("Design System Rules") to reference `package:material_3_expressive` (`M3EMaterialApp`, `M3EThemeData`, `M3E*` widgets, and Comfortaa typography) instead of the deleted Sonic Architect specs.

### 1.6 Phase 1 Verification
- Update `test/ui/core/theme/sonic_theme_test.dart` (rename to `app_theme_test.dart`) and any test harnesses that passed `SonicTheme.lightTheme` / `SonicTheme.darkTheme`.
- Run `fvm dart format .`, `fvm flutter analyze`, and `fvm flutter test` — verify zero lints and all tests pass.

---

## Interlude: Create the `material-3-expressive` Skill
Before starting Phase 2, use the `.agents/skills/skill-creator/SKILL.md` workflow to build `.agents/skills/material-3-expressive/`:
- Inspect the installed `material_3_expressive` package source in `.pub-cache` to document **exact, verified** APIs (no guessed widget names or parameters):
  - App & theme setup (`M3EMaterialApp`, `M3EThemeData.light/dark`, `M3ETheme.of(context)`, custom typography, `hide CornerRounding, RoundedPolygon` rule when co-existing with `material_ui`).
  - Component catalog & code examples (`M3EButton`, `M3EButtonGroup`, `M3ESplitButton`, `M3ESlider`, `M3ECard` / `M3ECardGroup`, `M3EListItem`, `M3ENavigationBar`, `M3ETabs`, `M3ESideSheet`, etc.).
  - Motion & shape tokens (`M3EMotion`, `M3EShapes`) and widget testing guidelines with `M3EMaterialApp` / `M3ETheme`.

---

## Phase 2: Screen-by-Screen `M3E*` Component Upgrade
Execute incrementally, preserving all existing `Key(...)` selectors, semantics labels, and PRD requirements (`FR-TAP-05` monotonic pointer-down, `FR-VIS-01`/`UI-13` beat distinction), running `fvm flutter test` after each step:

1. **Navigation Shell (`adaptive_navigation_shell.dart`):**
   - Replace `NavigationBar` with `M3ENavigationBar` (and adopt M3E navigation rail/adaptive destination styling if provided by the package).
2. **Metronome Screen (`metronome_view.dart` & `widgets/`):**
   - `BpmControlSection`: Replace `Slider` with `M3ESlider`; upgrade `-`/`+` steppers to `M3EButton` (or expressive icon button variants) while keeping `GestureDetector` long-press continuous adjustment.
   - `TransportControlsBar`: Upgrade Play/Stop CTA to `M3EButton` / expressive FAB/toggle button with M3E shape morphing between stopped and playing states. **Keep** raw `Listener(onPointerDown: ...)` on the Tap Tempo surface for zero-latency monotonic timestamps (`FR-TAP-05`), styled with M3E surface/shape tokens.
   - `BeatIndicatorBar`: Keep custom beat-capsule & subdivision visualizer (`FR-VIS-01`, `UI-13`), using M3E shape/motion curves and `ColorScheme` roles.
   - `MeterAndSubdivisionSection` & `ActiveSetlistStepperBar`: Upgrade trigger cards, selection pills, and stepper/save buttons to `M3ECard`, `M3EButton`, and `M3EListItem` inside the Time Signature & Subdivision sheets.
3. **Preferences Screen (`preferences_view.dart`):**
   - Upgrade container plate to `M3ECard` and theme selector to M3E segmented/button-group component (`M3EButtonGroup` or M3E segmented control).
4. **Presets & Setlists Screens (`presets_view.dart`, `setlists_view.dart`, sheets & dialogs):**
   - Upgrade list cards/rows to `M3ECard` / `M3EListItem`, action buttons to `M3EButton`, and multi-select/edit flows where appropriate.
5. **Final Verification:**
   - Run `fvm dart format .`, `fvm flutter analyze` (zero warnings/errors), and full `fvm flutter test`.

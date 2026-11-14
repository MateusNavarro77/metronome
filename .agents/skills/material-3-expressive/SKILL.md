---
name: material-3-expressive
description: Build and style Flutter UIs with package:material_3_expressive (M3E* widgets, M3EMaterialApp, M3EThemeData, color/typography/motion/shape tokens). Use this skill whenever writing, refactoring, or debugging UI code that uses material_3_expressive, configuring M3E themes or M3EMaterialApp, converting legacy Flutter Material widgets to M3E* equivalents (buttons, app bars, navigation bars/rails/drawers, sliders, cards, lists, sheets, dialogs, pickers, text fields, shapes), or resolving material_ui vs package:flutter/material.dart import and symbol collisions.
---

# Material 3 Expressive (`package:material_3_expressive`)

Build Flutter interfaces using `package:material_3_expressive` (`^1.2.1`, requiring Flutter `>= 3.47.0` / Dart `^3.13.0`), which provides 44 direct `M3E*` widgets with spring-driven physics (`motor`), shape morphing (`material_new_shapes`), keyboard focus rings, and Material 3 design tokens.

## Core Rules & Gotchas

### 1. Import `material_ui`, not `package:flutter/material.dart`
`material_3_expressive` builds on `package:material_ui` (`^1.11.0`). Importing `package:flutter/material.dart` creates duplicate/incompatible `ThemeData`, `ColorScheme`, and `TextTheme` types (and triggers `deprecated_member_use` lints on Flutter 3.47+).

```dart
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart' hide CornerRounding, RoundedPolygon;
```

Always `hide CornerRounding, RoundedPolygon` on `material_ui` when both packages are imported together—both `material_ui` and `material_new_shapes` (re-exported by `material_3_expressive`) export those two names, and hiding them on `material_ui` keeps expressive morph polygons unambiguous. If a custom font package like `google_fonts` generates a `TextTheme`, map it cleanly onto `M3ETypeScale` / `M3EThemeData` rather than mixing Material `TextTheme` objects directly where `M3ETypography` is expected.

### 2. Choose the right app shell: `M3EMaterialApp` vs `M3ETheme`
- **Root of the app:** Use `M3EMaterialApp(data: M3EThemeData.light(seedColor: ...), home: ...)` instead of `MaterialApp`. It automatically provides edge-to-edge system bar styling (`drawUnderSystemBars: true`), keyboard focus ring tracking (`M3EFocusInteraction`), optional `autoTheming`, optional `dynamicColoring`, and projects `M3ETypeScale` onto `ThemeData.textTheme` and `DefaultTextStyle`.
- **Controlling `ThemeMode` dynamically:** `M3EMaterialApp` does not take a `themeMode` parameter. When `autoTheming: true`, `M3EThemeController` follows platform brightness and ignores manual overrides; when `autoTheming: false`, it honors `M3EThemeController.setBrightness(...)` (falling back to `initialTheme`). To support runtime switching among `system` / `light` / `dark`, own a persistent `M3EThemeController` (for example in a `StatefulWidget` host) and toggle `autoTheming` plus `controller.setBrightness(...)`.
- **Subtree / widget tests without `M3EMaterialApp`:** Wrap subtrees in `M3ETheme(data: ..., child: ...)` so `M3E*` widgets resolve tokens instead of falling back to defaults. Always wrap modal callers (`M3EDialog.show`, `M3EBottomSheet.show`, `M3ESideSheet.show`, `M3ESnackbar.show`) below a `Navigator` / `Overlay` (such as `M3EMaterialApp` or `MaterialApp`).

### 3. Access M3E tokens before reaching for custom styles
Prefer tokens from `M3ETheme.of(context)` (`colorScheme`, `typography.baseline`, `typography.emphasized`, `spacing`) and `Theme.of(context).colorScheme` / `.textTheme` over hardcoded colors or padding:
- Use `theme.typography.emphasized.*` (e.g., `headlineSmall`, `titleMedium`, `labelLarge`) for editorial headers, primary controls, and selected states; reserve `theme.typeScale` (`baseline`) for standard body copy.
- Use `M3EMotion` springs (`expressiveSpatialDefault`, `expressiveSpatialFast`, `effectsFast`) and `M3EDimensions` / `M3EShapes` tokens instead of magic durations or corner radii.
- Check `M3EIcons.*` (built into `material_3_expressive`) or `Icons.*` from `material_ui`.

### 4. Know when NOT to replace a raw Flutter primitive
`M3E*` widgets include spring press animations, state layers, and gesture handling optimized for standard UI interactions. Keep low-level Flutter primitives when domain timing or custom drawing explicitly forbids widget-level gesture wrappers:
- **Zero-latency pointer input** (e.g., audio tap tempo using `Listener.onPointerDown` with a monotonic clock): keep `Listener` rather than replacing it with an ink/tap button whose tap recognizer introduces arena delay.
- **Custom real-time painters / visualizers** (e.g., beat indicator bars, waveforms): keep custom painting and feed it `ColorScheme` / `M3EShapes` / `M3EMotion` tokens.

### 5. Layout & Modal Sizing Gotchas
- **Avoid `IntrinsicHeight` / `IntrinsicWidth` around `M3E*` controls:** Widgets like `M3EIconButton` and `M3ECard` use internal `LayoutBuilder`s for responsive state/shape calculations, which throws `LayoutBuilder does not support returning intrinsic dimensions` inside intrinsic-sizing parents. Use `Row(crossAxisAlignment: CrossAxisAlignment.center)` or explicit heights instead.
- **Set `initialValue: M3EBottomSheetValue.expanded` for tall/form sheets:** `M3EBottomSheet.show` defaults to `M3EBottomSheetValue.collapsed` (50% viewport height). Pass `initialValue: M3EBottomSheetValue.expanded` (with `isDismissible: true`) for form or multi-section sheets so bottom action buttons stay visible on compact screens and in 800×600 tests.

## Component Catalog & Reference Guide

Load only the reference file needed for the area you are working on:

| Topic | Widgets & APIs Covered | Reference File |
| --- | --- | --- |
| **Theming & Tokens** | `M3EMaterialApp`, `M3ETheme`, `M3EThemeData`, `M3EThemeController`, `M3EColorScheme`, `M3ETypography`, `M3ETypeVariations`, `M3EVariableFontConfig`, `M3EDimensions`, `M3EShapes`, `M3EMotion`, `M3EFocusRingTheme` | [references/theming-and-tokens.md](references/theming-and-tokens.md) |
| **Actions** | `M3EButton`, `M3EIconButton`, `M3EFab`, `M3EExtendedFab`, `M3EFabMenu`, `M3EButtonGroup`, `M3ESegmentedButton`, `M3ESplitButton` | [references/actions.md](references/actions.md) |
| **Selection & Inputs** | `M3ECheckbox`, `M3ERadio`, `M3ERadioGroup`, `M3ESwitch`, `M3EChip`, `M3EChipGroup`, `M3EDropdownMenu`, `M3ESlider`, `M3ERangeSlider`, `M3EDatePicker`, `M3ECalendarDatePicker`, `M3ETimePicker`, `M3EDialTimePicker`, `M3ETextField`, `M3ESearchBar`, `M3ESearchAnchor`, `M3ESliverSearchBar` | [references/selection-and-inputs.md](references/selection-and-inputs.md) |
| **Containment & Navigation** | `M3ECard`, `M3ECardGroup`, `M3ECarousel`, `M3EList`, `M3EListItem`, `M3ESelection`, `M3ESelectionAppBar`, `M3EDivider`, `M3EDialog`, `M3EBottomSheet`, `M3ESideSheet`, `M3EAppBar`, `M3ETabs`, `M3ETabsView`, `M3ENavigationBar`, `M3ENavigationRail`, `M3ENavigationDrawer`, `M3EToolbar`, `M3EMenu` | [references/containment-and-navigation.md](references/containment-and-navigation.md) |
| **Feedback & Shapes** | `M3EBadge`, `M3EProgressIndicator`, `M3ELoadingIndicator`, `M3EExpressiveLoadingIndicator`, `M3ERefreshIndicator`, `M3ETooltip`, `M3ESnackbar`, `M3EShapeKind`, `M3EShapeContainer`, `M3EShapeClipper`, `M3EMaterialNewShapes` | [references/feedback-and-shapes.md](references/feedback-and-shapes.md) |

## Quick Migration Workflow (Material -> M3E)

1. **Ensure the shell & imports are ready:** Verify `M3EMaterialApp` (or `M3ETheme`) sits above the widget tree and switch imports from `package:flutter/material.dart` to `package:material_ui/material_ui.dart hide CornerRounding, RoundedPolygon` + `package:material_3_expressive/material_3_expressive.dart`.
2. **Swap direct component equivalents** using the matching reference file to confirm exact parameter names (several differ from classic Material widgets — e.g. `M3EListItem(headline: 'Text')` takes `String` `headline` rather than `Widget title`, and `M3ESegmentedButton(selected: ...)` / `M3EChip(label: '...')` have their own constructors).
3. **Update widget tests:** If tests wrap isolated widgets in `MaterialApp(theme: ...)`, ensure `M3ETheme` is present when M3E tokens/motion/focus customization matters, or pass `data: M3EThemeData.light(...)` to `M3EMaterialApp`. Avoid `find.byType(ElevatedButton)` when upgrading to `M3EButton` — match by text, icon, semantics, or `M3EButton` type.
4. **Verify static analysis and formatting:** Run `dart format .`, `flutter analyze`, and `flutter test` (`fvm` if configured).

# M3E Theming, App Shell, and Design Tokens

## Table of Contents
- [App Shell (`M3EMaterialApp` & `M3ETheme`)](#app-shell-m3ematerialapp--m3etheme)
- [Runtime Light / Dark / System Mode Pattern](#runtime-light--dark--system-mode-pattern)
- [Colors (`M3EColorScheme`)](#colors-m3ecolorscheme)
- [Typography & Variable Fonts](#typography--variable-fonts)
- [Spacing, Elevation & Shapes (`M3EDimensions`, `M3EShapes`)](#spacing-elevation--shapes)
- [Motion, Haptics & Focus Rings](#motion-haptics--focus-rings)

---

## App Shell (`M3EMaterialApp` & `M3ETheme`)

```dart
M3EMaterialApp(
  title: 'My App',
  data: M3EThemeData.light(seedColor: const Color(0xFF6750A4)),
  autoTheming: true,
  dynamicColoring: true, // false to lock palette strictly to seedColor
  drawUnderSystemBars: true,
  home: const HomePage(),
)
```

Key constructor parameters on `M3EMaterialApp`:
- `required M3EThemeData data` (also `.light(seedColor: ...)` / `.dark(seedColor: ...)` / `.fromMaterial(ThemeData)`).
- `bool? autoTheming`, `bool? dynamicColoring`, `Brightness? initialTheme`, `M3EThemeController? controller`.
- `bool drawUnderSystemBars` (default edge-to-edge transparent bars).
- Type-scale overrides on shell: `fontFamily`, `fontFamilyFallback`, `package`, `fontVariations`, `typeScaleMode`, `typeface` (`M3ETypefaceConfig(brand: ..., plain: ...)`), `variableFont` (`M3EVariableFontConfig(...)`).
- Standard app parameters: `navigatorKey`, `scaffoldMessengerKey`, `routes`, `initialRoute`, `onGenerateRoute`, `home`, `title`, `locale`, `supportedLocales`, `localizationsDelegates`, `debugShowCheckedModeBanner`, etc.

To wrap only a subtree instead of the root app:
```dart
M3ETheme(
  data: M3EThemeData.light(seedColor: const Color(0xFF6750A4)),
  child: child,
)
```

Reading tokens in `build`:
```dart
final m3e = M3ETheme.of(context);
final M3EColorScheme scheme = m3e.colorScheme;
final M3ETypeScale baseline = m3e.typeScale; // alias for m3e.typography.baseline
final M3ETypeScale emphasized = m3e.typography.emphasized;
final M3ESpacing spacing = m3e.spacing;
```

---

## Runtime Light / Dark / System Mode Pattern

`M3EMaterialApp` does **not** accept a `themeMode` property. `M3EThemeController` exposes:
- `setBrightness(Brightness?)` / `clearOverride()` / `toggleBrightness({required Brightness fallback, bool autoTheming = false})`

How `M3EThemeScope` resolves brightness:
- `autoTheming: true` ignores `controller.brightnessOverride` and tracks `platformBrightness`.
- `autoTheming: false` uses `controller.brightnessOverride ?? initialTheme ?? Brightness.light`.
- `WidgetsBindingObserver` for platform brightness updates is only attached in `M3EMaterialApp.initState` when `autoTheming` is enabled or dynamic; therefore, pass an explicit `M3EThemeController` and set `autoTheming: mode == ThemeMode.system` while syncing `controller.setBrightness(...)` when `mode != ThemeMode.system`:

```dart
class _ThemeHostState extends State<ThemeHost> {
  final M3EThemeController _controller = M3EThemeController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncMode(ThemeMode mode) {
    if (mode == ThemeMode.system) {
      _controller.clearOverride();
    } else {
      _controller.setBrightness(
        mode == ThemeMode.dark ? Brightness.dark : Brightness.light,
      );
    }
  }
}
```

---

## Colors (`M3EColorScheme`)

Create schemes via:
- `M3EColorScheme.light([Color? seed])` / `M3EColorScheme.dark([Color? seed])`
- `M3EColorScheme.fromColorScheme(ColorScheme)` (for projecting Flutter `ColorScheme` onto M3E)
- `scheme.harmonized()` (harmonizes semantic accents with `primary` via `dynamic_color`)

Expressive roles beyond standard `ColorScheme`:
- Standard M3 roles (`primary`, `onPrimary`, `primaryContainer`, ..., `surfaceContainerLowest`..`Highest`, `outline`, `outlineVariant`, `scrim`, `shadow`, `error`, etc.).
- Expressive roles on `M3EColorScheme`: `emphasis`, `onEmphasis`, `info`, `success`, `warning`, `danger`, `surfaceStrong`, `onSurfaceStrong`, `outlineStrong`.

Convert to Flutter `ThemeData`: `m3eData.toThemeData()`.

---

## Typography & Variable Fonts

M3 Expressive provides 15 `baseline` and 15 `emphasized` roles (`displayLarge`..`labelSmall`).

```dart
// Emphasized editorial / interactive hierarchy
Text('120', style: M3ETheme.of(context).typography.emphasized.displayLarge);

// Variable font axes with Roboto Flex
final data = M3EThemeData.light(seedColor: seed).copyWith(
  fontFamily: 'Roboto Flex',
  typeScaleMode: M3ETypeScaleMode.variable, // static | variable
  variableFont: const M3EVariableFontConfig(
    enableOpsz: true,
    syncWghtToWeight: true,
    emphasizedGrad: 50,
    global: M3EVariableFontAxes(wght: 500, opsz: 16),
    brand: M3EVariableFontAxes(rond: 25),
    body: M3EVariableFontAxes(rond: 50),
  ),
);
```

Useful presets and utilities:
- `M3ETypeVariations` enum: `regular`, `emphasized`, `graded` (alias for `emphasized`), `condensed`, `extraCondensed`, `wide`, `extraWide`, `round` (use `.variations` for `List<FontVariation>`).
- Split display/body typefaces: `M3ETypefaceConfig(brand: 'Comfortaa', plain: 'Roboto')`.
- `M3ETypeStyleConversion.toVariant(style, variant: M3ETypeScaleVariant.emphasized, role: M3ETypeRole.headlineSmall)`.
- `M3ETypeStyleTokens.fromTextStyle(style).copyWith(letterSpacing: 0.25).toTextStyle(...)`.

---

## Spacing, Elevation & Shapes

- **`M3EDimensions` constants:**
  - Spacing: `space0` (`0`), `space4` (`4`), `space8` (`8`), `space12` (`12`), `space16` (`16`), `space20` (`20`), `space24` (`24`), `space28` (`28`), `space32` (`32`), `space40` (`40`), `space48` (`48`); aliases `spaceXs` (`4`), `spaceSm` (`8`), `spaceMd` (`12`), `spaceLg` (`16`), `spaceXl` (`24`), `spaceXxl` (`32`).
  - Corner radii (`double`): `radiusNone` (`0`), `radiusExtraSmall` (`4`), `radiusSmall` (`8`), `radiusMedium` (`12`), `radiusLarge` (`16`), `radiusLargeIncreased` (`20`), `radiusExtraLarge` (`28`), `radiusExtraLargeIncreased` (`32`), `radiusExtraExtraLarge` (`48`), `radiusFull` (`9999`).
  - Prebuilt `BorderRadius`: `borderRadiusNone`, `borderRadiusExtraSmall`, `borderRadiusSmall`, `borderRadiusMedium`, `borderRadiusLarge`, `borderRadiusLargeIncreased`, `borderRadiusExtraLarge`, `borderRadiusExtraLargeIncreased`, `borderRadiusExtraExtraLarge`.
- **`M3EShapes`:** mirrors radius tokens (`none`, `extraSmall`..`full`, `radiusNone`..`radiusExtraExtraLarge`, `stadium`), plus `M3EShapes.resolve(token)` -> `BorderRadius`, `roundSet`, `squareSet`.
- **`M3ESpacing`:** available on `M3ETheme.of(context).spacing` (`xs`, `sm`, `md`, `lg`, `xl`, `xxl`).

---

## Motion, Haptics & Focus Rings

- **`M3EMotion`:**
  - Durations: `short1`..`short4` (50–200ms), `medium1`..`medium4` (250–400ms), `long1`..`long4` (450–600ms), `extraLong1`..`extraLong4` (700–1000ms).
  - Curves: `standard`, `standardAccelerate`, `standardDecelerate`, `emphasized`, `emphasizedAccelerate`, `emphasizedDecelerate`, `linear`.
  - Physics springs (`M3ESpring`): `spatialFast`, `spatialDefault`, `spatialSlow`, `expressiveSpatialFast`, `expressiveSpatialDefault`, `expressiveSpatialPress`, `expressiveSpatialSlow`, `effectsFast`, `effectsDefault`, `effectsSlow`.
- **`M3EStateOpacity`:** `hover` (`0.08`), `focus` (`0.1`), `pressed` (`0.1`), `dragged` (`0.16`), `disabledContent` (`0.38`), `disabledContainer` (`0.12`).
- **`M3EFocusRing` / `M3EFocusRingTheme`:** Outset keyboard focus indicator (`width: 2`, `gap: 2`), controlled via `M3EThemeData(keyboardFocusIndicators: true, focusRingTheme: M3EFocusRingTheme(...))`.
- **`M3ETappable` & `M3EHapticFeedback`:** Shared tactile spring press wrapper and haptic feedback enum (`none`, `light`, `medium`, `heavy`, `selection`).

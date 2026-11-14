# M3E Feedback, Progress, and Shape Primitives

## Table of Contents
- [`M3EBadge`](#m3ebadge)
- [`M3EProgressIndicator`](#m3eprogressindicator)
- [`M3ELoadingIndicator`](#m3eloadingindicator)
- [`M3ERefreshIndicator`](#m3erefreshindicator)
- [`M3ETooltip` & `M3ESnackbar`](#m3etooltip--m3esnackbar)
- [Expressive Shapes (`M3EShapeKind`, `M3EShapeContainer`, `M3EShapeClipper`)](#expressive-shapes)

---

## `M3EBadge`

Draws a 6dp dot (`showDot: true`), numeric count (capped at `maxCount = 999`), or custom `label` (`String`) in `error` / `onError` over `child`.

```dart
const M3EBadge(
  count: 4,
  child: Icon(M3EIcons.queue_music),
)
```

- **Params:** `required Widget child`, `int? count`, `String? label`, `showDot = false`, `maxCount = 999`, `alignment = M3EBadgeAlignment.topRight` (`topLeft | topCenter | topRight`), `offset`, `backgroundColor`, `foregroundColor`.

---

## `M3EProgressIndicator`

Determinate (`value: 0.0..1.0`) or indeterminate (`value: null`), flat or wavy.

```dart
const M3EProgressIndicator.circular()
M3EProgressIndicator.linearWavy(value: progress, linearSize: M3EProgressIndicatorSize.m)
```

- **Constructors:** `.circular(...)`, `.circularWavy(...)`, `.linear(...)`, `.linearWavy(...)`.
- **`M3EProgressIndicatorSize`:** `s`, `m`.
- **Key params:** `value`, `color`, `trackColor`, `showTrack = true`, `strokeWidth`, `trackStrokeWidth`, `gapSize`, `amplitude`, `wavelength`, `waveSpeed`.

---

## `M3ELoadingIndicator`

Indeterminate morphing polygon indicator (48dp outer / 38dp active by default), plain (`defaultStyle`) or `contained` inside a shape container.

```dart
const M3ELoadingIndicator(
  variant: M3ELoadingIndicatorVariant.contained, // defaultStyle | contained
  size: 56,
)
```

- You can customize morph keyframes with `polygons: List<RoundedPolygon>` (from `M3EMaterialNewShapes`), `morphInterval`, `morphSpring`, and `pulseSpring`.

---

## `M3ERefreshIndicator`

Pull-to-refresh showing a contained morphing `M3ELoadingIndicator`:

```dart
M3ERefreshIndicator.contained(
  controller: refreshController, // M3ERefreshIndicatorController
  onRefresh: () async => reload(),
  child: listView,
)
```

- **Constructors:** `M3ERefreshIndicator(...)`, `.contained(...)`, `.material(...)`, `.adaptive(...)`, `.noSpinner(...)`.

---

## `M3ETooltip` & `M3ESnackbar`

```dart
// Plain or rich tooltip
M3ETooltip(
  message: 'Tap Tempo', // or richTitle + richMessage + actions + persistent: true
  preferredPlacement: M3ETooltipPlacement.above, // above | below | bottomStart | bottomEnd
  child: target,
)

// Snackbar (requires Navigator/Overlay ancestor)
M3ESnackbar.show(
  context,
  message: 'Preset saved',
  actionLabel: 'Undo',
  onAction: _undo,
  showCloseButton: true,
);
```

---

## Expressive Shapes

`material_3_expressive` re-exports `material_new_shapes` and provides convenient wrappers:

- **`M3EShapeKind` (35 polygons):** `circle`, `square`, `slanted`, `arch`, `semiCircle`, `oval`, `pill`, `triangle`, `arrow`, `fan`, `diamond`, `clamShell`, `pentagon`, `gem`, `sunny`, `verySunny`, `cookie4Sided`, `cookie6Sided`, `cookie7Sided`, `cookie9Sided`, `cookie12Sided`, `clover4Leaf`, `clover8Leaf`, `burst`, `softBurst`, `boom`, `softBoom`, `flower`, `puffy`, `puffyDiamond`, `ghostish`, `pixelCircle`, `pixelTriangle`, `bun`, `heart`.
- **`M3EShapeContainer`:** Renders any `M3EShapeKind` with named constructors (`M3EShapeContainer.sunny(...)`, `.cookie7Sided(...)`, `.pill(...)`, etc.), `width`, `height`, `color`, `gradient`, and `child`.
- **`M3EShapeClipper(M3EShapeKind.softBurst)`:** `CustomClipper<Path>` to clip any widget to an expressive polygon.
- **`M3EMaterialNewShapes`:** Direct `RoundedPolygon` getters (`circle`..`heart`, `.all`) for `Morph` animations and `M3ELoadingIndicator(polygons: [...])`.

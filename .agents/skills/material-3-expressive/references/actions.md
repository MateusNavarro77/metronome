# M3E Action Components

## Table of Contents
- [`M3EButton`](#m3ebutton)
- [`M3EIconButton`](#m3eiconbutton)
- [`M3EFab` & `M3EExtendedFab`](#m3efab--m3eextendedfab)
- [`M3EFabMenu`](#m3efabmenu)
- [`M3EButtonGroup`](#m3ebuttongroup)
- [`M3ESegmentedButton`](#m3esegmentedbutton)
- [`M3ESplitButton`](#m3esplitbutton)

---

## `M3EButton`

Morphing pill/square button with spring feedback, optional toggle selection (`isSelected`), and optional gradients (`M3EButtonDecoration`).

```dart
M3EButton.filled(
  size: M3EButtonSize.md,
  shape: M3EButtonShape.round,
  icon: const Icon(M3EIcons.play_arrow),
  label: const Text('Play'),
  onPressed: () {},
)

// Toggle button
M3EButton.tonal(
  icon: const Icon(M3EIcons.favorite_border),
  selectedIcon: const Icon(M3EIcons.favorite),
  selectedLabel: const Text('Saved'),
  isSelected: saved,
  onPressed: () => setState(() => saved = !saved),
  child: const Text('Save'),
)
```

- **Constructors:** `M3EButton(...)` (defaults `style: M3EButtonStyle.filled`, `size: M3EButtonSize.sm`, `shape: M3EButtonShape.round`), `M3EButton.icon(...)` (`required icon`, `required label`), `.filled(...)`, `.tonal(...)`, `.elevated(...)`, `.outlined(...)`, `.text(...)`.
- **`M3EButtonStyle`:** `filled`, `outlined`, `text`, `elevated`, `tonal`.
- **`M3EButtonShape`:** `round`, `square`.
- **`M3EButtonSize`:** `xs` (32dp), `sm` (40dp), `md` (56dp), `lg` (96dp), `xl` (136dp), or `M3EButtonSize.custom(height: ..., hPadding: ..., iconSize: ..., iconGap: ..., outlineWidth: ..., width: ...)`.
- **Key params:** `onPressed`, `child`, `icon`, `label`, `selectedIcon`, `selectedLabel`, `isSelected`, `enabled`, `decoration`, `tooltip`, `semanticLabel`, `onLongPress`.
- **Theme:** `M3EThemeData(buttonTheme: M3EButtonTheme(...))`.

---

## `M3EIconButton`

Icon-only button with optional toggle selection, shape morphing (`round` <-> `square`), narrow/default/wide widths, and badge support.

```dart
M3EIconButton(
  variant: M3EIconButtonVariant.tonal,
  size: M3EIconButtonSize.md,
  width: M3EIconButtonWidth.wide,
  icon: const Icon(M3EIcons.favorite_border),
  selectedIcon: const Icon(M3EIcons.favorite),
  isSelected: isFav,
  tooltip: 'Favorite',
  onPressed: () => setState(() => isFav = !isFav),
)
```

- **`M3EIconButtonVariant`:** `standard`, `filled` (default), `tonal`, `outlined`.
- **`M3EIconButtonSize`:** `xs`, `sm` (default), `md`, `lg`, `xl`.
- **`M3EIconButtonWidth`:** `defaultWidth`, `narrow`, `wide`.
- **`M3EIconButtonShapeVariant`:** `round` (default), `square`.
- **Key params:** `required icon`, `onPressed`, `tooltip`, `semanticLabel`, `isSelected`, `selectedIcon`, `haptic`, `badgeValue`, `decoration`, `inflateHitTarget`.
- **Theme:** `M3EThemeData(iconButtonTheme: M3EIconButtonTheme(...))`.

---

## `M3EFab` & `M3EExtendedFab`

```dart
M3EFab(
  icon: const Icon(M3EIcons.add),
  size: M3EFabSize.medium, // small (40) | regular (56) | medium (80) | large (96)
  color: M3EFabColor.primary, // primary | secondary | tertiary | *Filled | surface
  openBuilder: (context) => const DetailPage(), // optional container transform
  onPressed: () {},
)

M3EExtendedFab(
  label: 'Create', // String (required)
  icon: const Icon(M3EIcons.edit),
  size: M3EExtendedFabSize.small, // small (56) | medium (80) | large (96)
  extended: isExpanded,
  onPressed: () {},
)
```

- **Scroll visibility helpers:** Wrap scroll body in `M3EFabScrollVisibility(controller: M3EFabController(), child: ...)` or `M3EExtendedFabScrollVisibility(controller: M3EExtendedFabController(), child: ...)`.
- **Themes:** `M3EFabTheme`, `M3EExtendedFabTheme`.

---

## `M3EFabMenu`

Expandable speed-dial FAB menu (2–6 `M3EFabMenuItem` actions). Escape/back collapses the menu.

```dart
M3EFabMenu(
  color: M3EFabColor.primary,
  size: M3EFabSize.medium,
  position: M3EFabMenuPosition.right, // left | right
  controller: fabMenuController,
  items: [
    M3EFabMenuItem(icon: const Icon(M3EIcons.add), label: 'New preset', onPressed: () {}),
    M3EFabMenuItem(icon: const Icon(M3EIcons.playlist_add), label: 'New setlist', onPressed: () {}),
  ],
)
```

- **`M3EFabMenuItem`:** `required Widget icon`, `required String label`, `VoidCallback? onPressed`, `WidgetBuilder? openBuilder`, `Color? openColor`, `Color? transformScrimColor`.
- **Theme:** `M3EFabMenuTheme`.

---

## `M3EButtonGroup`

Grouped action bar (`standard` or `connected`) with optional single/multi selection, neighbor squish on press, and overflow handling (`scroll`, `menu`, `none`, `experimentalPaging`).

```dart
M3EButtonGroup(
  type: M3EButtonGroupType.connected, // standard | connected
  size: M3EButtonSize.sm,
  style: M3EButtonStyle.tonal,
  selectedIndex: selectedIdx,
  onSelectedIndexChanged: (i) => setState(() => selectedIdx = i),
  actions: const [
    M3EButtonGroupAction(label: Text('2/4')),
    M3EButtonGroupAction(label: Text('3/4')),
    M3EButtonGroupAction(label: Text('4/4')),
    M3EButtonGroupAction(label: Text('6/8')),
  ],
)
```

- **`M3EButtonGroupAction`:** `icon`, `selectedIcon`, `label` (`Widget?`), `selectedLabel`, `isSelected`, `enabled`, `decoration`, `minWidth`, `width`, `tooltip`, `semanticLabel`.
- **Multi-select:** Set `multiSelect: true`, pass `selectedIndices: Set<int>`, and `onSelectedIndicesChanged`.
- **Density:** `M3EButtonGroupDensity` (`regular`, `comfortable`, `compact`, `dense`).
- **Overflow:** `overflow: M3EButtonGroupOverflow.scroll | menu | none | experimentalPaging`, `overflowMenuStyle: popup | bottomSheet`.

---

## `M3ESegmentedButton`

Outlined single- or multi-select pill control with 2–5 `M3ESegment`s.

```dart
M3ESegmentedButton<AppThemeMode>(
  segments: const [
    M3ESegment(value: AppThemeMode.system, label: 'System', icon: Icon(M3EIcons.brightness_auto)),
    M3ESegment(value: AppThemeMode.light, label: 'Light', icon: Icon(M3EIcons.light_mode)),
    M3ESegment(value: AppThemeMode.dark, label: 'Dark', icon: Icon(M3EIcons.dark_mode)),
  ],
  selected: {currentMode}, // Set<T>
  onSelectionChanged: (next) => vm.setThemeMode(next.first),
)
```

- **Params:** `required List<M3ESegment<T>> segments`, `required Set<T> selected`, `required ValueChanged<Set<T>>? onSelectionChanged`, `multiSelect = false`, `showSelectedIcon = true`, `density = M3ESegmentedButtonDensity.regular` (`regular | comfortable | compact | dense`), `enabled = true`.
- **`M3ESegment<T>`:** `required T value`, `String? label`, `Widget? icon`, `bool enabled = true`, `String? semanticLabel`. Note `label` is `String?`, not `Widget`.

---

## `M3ESplitButton`

Primary button paired with an attached dropdown menu trigger (separated by a 2dp gap).

```dart
M3ESplitButton<String>(
  style: M3EButtonStyle.filled, // or .filled(), .tonal(), .elevated(), .outlined()
  label: 'Save',
  leadingIcon: M3EIcons.check, // IconData?
  onPressed: _save,
  onSelected: (value) {},
  items: const [
    M3ESplitButtonItem(value: 'save_copy', child: Text('Save a copy')),
    M3ESplitButtonItem(value: 'export', child: Text('Export JSON')),
  ],
)
```

- **Params:** `required List<M3ESplitButtonItem<T>> items`, `onSelected`, `onPressed`, `String? label`, `IconData? leadingIcon`, `size`, `shape`, `style`, `m3eMenuBuilder`, `selectedValue`, `onMultiSelected`, `leadingTooltip`, `trailingTooltip`.

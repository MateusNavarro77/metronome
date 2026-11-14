# M3E Selection & Text Input Components

## Table of Contents
- [`M3ECheckbox`](#m3echeckbox)
- [`M3ERadio` & `M3ERadioGroup`](#m3eradio--m3eradiogroup)
- [`M3ESwitch`](#m3eswitch)
- [`M3EChip` & `M3EChipGroup`](#m3echip--m3echipgroup)
- [`M3EDropdownMenu`](#m3edropdownmenu)
- [`M3ESlider` & `M3ERangeSlider`](#m3eslider--m3erangeslider)
- [`M3EDatePicker` & `M3ETimePicker`](#m3edatepicker--m3etimepicker)
- [`M3ETextField`](#m3etextfield)
- [`M3ESearchBar` & `M3ESearchAnchor`](#m3esearchbar--m3esearchanchor)

---

## `M3ECheckbox`

```dart
M3ECheckbox(
  value: isChecked, // bool? (supports tristate: true)
  label: const Text('Accent downbeat'),
  onChanged: (v) => setState(() => isChecked = v ?? false),
)
```

- **Params:** `required bool? value`, `required ValueChanged<bool?>? onChanged`, `tristate = false`, `error = false`, `Widget? label`, `checkedChild`, `uncheckedChild`, `boxSize`, `hitSize`, `targetSize`, `semanticLabel`.

---

## `M3ERadio` & `M3ERadioGroup`

Wrap options in `M3ERadioGroup` to enable arrow-key navigation and wrapping semantics.

```dart
M3ERadioGroup<String>(
  groupValue: selected,
  groupLabel: 'Click sound',
  onChanged: (v) => setState(() => selected = v!),
  child: Column(
    children: [
      M3ERadio<String>(
        value: 'wood',
        groupValue: selected,
        label: const Text('Woodblock'),
        onChanged: (v) => setState(() => selected = v!),
      ),
    ],
  ),
)
```

---

## `M3ESwitch`

52x32dp track with spring-scaled handle (`16` off, `24` on/icon, `28` pressed). Supports drag past midpoint.

```dart
M3ESwitch(
  value: enabled,
  selectedIcon: const Icon(M3EIcons.check),
  onChanged: (v) => setState(() => enabled = v),
)
```

- **Params:** `required bool value`, `required ValueChanged<bool>? onChanged`, `Widget? selectedIcon`, `Widget? unselectedIcon`, `double? stateLayerSize`, `semanticLabel`.

---

## `M3EChip` & `M3EChipGroup`

```dart
M3EChipGroup(
  groupLabel: 'Subdivision filters',
  child: Wrap(
    spacing: 8,
    children: [
      M3EChip(
        label: 'Triplets', // String (required)
        type: M3EChipType.filter, // assist | filter | input | suggestion
        selected: isSelected,
        onPressed: () => toggle(),
      ),
    ],
  ),
)
```

- **`M3EChip` params:** `required String label`, `type = M3EChipType.assist`, `leading`, `avatar`, `trailing`, `selected = false`, `elevated = false`, `onPressed`, `onDeleted` (input chips handle Backspace/Delete in `M3EChipGroup`).

---

## `M3EDropdownMenu`

Single or multi-select dropdown with optional search and async `.future(...)` loader.

```dart
M3EDropdownMenu<String>(
  singleSelect: true,
  searchEnabled: true,
  items: const [
    M3EDropdownItem(label: '4/4 Common', value: '4/4'),
    M3EDropdownItem(label: '6/8 Compound', value: '6/8'),
  ],
  fieldStyle: const M3EDropdownFieldStyle(hintText: 'Time signature'),
  onSelectionChanged: (selected) {},
)
```

- **Constructors:** `M3EDropdownMenu(items: ...)` or `M3EDropdownMenu.future(future: ...)`.
- **Key params:** `singleSelect`, `searchEnabled`, `showChipAnimation`, `maxSelections`, `limit`, `controller` (`M3EDropdownController`), `closeOnBackButton`, `fieldStyle`, `dropdownStyle`, `chipStyle`, `searchStyle`, `itemStyle`, `validator`, `autovalidateMode`.

---

## `M3ESlider` & `M3ERangeSlider`

```dart
M3ESlider(
  value: bpm.toDouble(),
  min: 30,
  max: 300,
  divisions: 270,
  size: M3ESliderSize.m, // xs | s | m | l | xl
  label: '$bpm BPM',
  onChanged: (v) => vm.setBpm(v.round()),
)
```

- **Constructors on `M3ESlider`:**
  - `M3ESlider(...)` (standard horizontal)
  - `M3ESlider.centered(...)` (diverges from midpoint)
  - `M3ESlider.wavy(...)` & `M3ESlider.wavyCentered(...)` (animated wave active track)
  - `M3ESlider.vertical(...)` & `M3ESlider.verticalCentered(...)`
- **Constructors on `M3ERangeSlider`:** `M3ERangeSlider(values: M3ESliderRange(a, b), ...)` and `M3ERangeSlider.wavy(...)`.
- **`M3ESliderSize`:** `xs` (handle 44), `s` (44), `m` (52), `l` (68), `xl` (108).
- **Keyboard:** Arrows step, Page Up/Down jump, Home/End jump to bounds.

---

## `M3EDatePicker` & `M3ETimePicker`

```dart
final DateTime? date = await M3EDatePicker.show(
  context,
  initialDate: DateTime.now(),
  firstDate: DateTime(2020),
  lastDate: DateTime(2030),
);

final M3ETime? time = await M3ETimePicker.show(
  context,
  initialTime: const M3ETime(hour: 9, minute: 30),
);
```

- Inline variants: `M3ECalendarDatePicker`, `M3ECalendarDateRangePicker`, `M3EDialTimePicker`, `M3EDatePicker.showRange(...)`.

---

## `M3ETextField`

Expressive filled or outlined field (56dp base height) with floating label spring, optional clear/password buttons, prefix/suffix, supporting/error text, and density.

```dart
M3ETextField(
  controller: controller,
  variant: M3ETextFieldVariant.outlined, // filled | outlined
  label: 'Preset name', // String?
  placeholder: 'e.g. Jazz Swing',
  supportingText: 'Required',
  errorText: errorMessage,
  isRequired: true,
  showClearButton: true,
  onChanged: (value) {},
  onSubmitted: (value) {},
)
```

- **Key params:** `controller`, `focusNode`, `String? label`, `String? supportingText`, `String? errorText`, `Widget? leading`, `Widget? trailing`, `variant`, `obscureText`, `showPasswordToggle`, `showClearButton`, `showErrorIcon`, `isRequired`, `prefixText`, `suffixText`, `placeholder`, `maxLength`, `showCounter`, `maxLines`, `minLines`, `density` (0 to -3). Note `label` is `String?` rather than `InputDecoration`.

---

## `M3ESearchBar` & `M3ESearchAnchor`

```dart
final controller = M3ESearchController();

M3ESearchAnchor.bar(
  searchController: controller,
  barHintText: 'Search presets',
  viewStyle: M3ESearchViewStyle.contained, // contained | divided
  suggestionsBuilder: (context, ctrl) => [
    for (final preset in matches)
      M3EListItem(
        headline: preset.name,
        onTap: () => ctrl.closeView(preset.name),
      ),
  ],
)
```

- **Sliver scrolling search bar:** `M3ESliverSearchBar(scrollBehavior: M3ESearchBarScrollBehavior.scrollAway, child: M3ESearchBar(...))`.
- Use `M3EAppBar.search(...)` to place a search bar directly in the app bar slot.

# M3E Containment & Navigation Components

## Table of Contents
- [`M3ECard` & `M3ECardGroup`](#m3ecard--m3ecardgroup)
- [`M3EList` & `M3EListItem`](#m3elist--m3elistitem)
- [`M3ESelection` & `M3ESelectionAppBar`](#m3eselection--m3eselectionappbar)
- [`M3ECarousel` & `M3EDivider`](#m3ecarousel--m3edivider)
- [`M3EDialog`, `M3EBottomSheet` & `M3ESideSheet`](#m3edialog-m3ebottomsheet--m3esidesheet)
- [`M3EAppBar` & `M3EToolbar`](#m3eappbar--m3etoolbar)
- [`M3ENavigationBar`, `M3ENavigationRail`, `M3ENavigationDrawer`](#m3enavigationbar-m3enavigationrail-m3enavigationdrawer)
- [`M3ETabs` & `M3EMenu`](#m3etabs--m3emenu)

---

## `M3ECard` & `M3ECardGroup`

```dart
M3ECard(
  variant: M3ECardVariant.outlined, // elevated | filled | outlined
  headline: const Text('Preset Name'),
  subhead: const Text('120 BPM · 4/4'),
  supportingText: const Text('Notes or description'),
  actions: M3EButton.text(onPressed: () {}, child: const Text('Load')),
  onPressed: () {},
)
```

- **Capabilities:** Supports custom `child` OR structured slots (`media`, `headline`, `subhead`, `supportingText`, `actions`, `overflow`), optional dividers (`dividerAfterMedia`, `dividerAfterText`), swipe actions (`onSwipe`, `swipeMode: dismiss | reveal | both`, `leadingSwipeAction`, `trailingSwipeAction`), and container transforms (`openBuilder`).
- **`M3ECardGroup`:** `layout: M3ECardGroupLayout.grid | staggered | list | carousel`, optional `onReorder`.

---

## `M3EList` & `M3EListItem`

`M3EList` renders segmented expressive rows by default (`outerRadius`, `innerRadius`, `gap`) with optional selection, drag-to-reorder, swipe actions, and expandable sub-lists.

```dart
M3EList.scrollable(
  itemCount: items.length,
  variant: M3ECardVariant.filled,
  reorder: true,
  onReorder: (oldIndex, newIndex) {},
  itemBuilder: (context, index) => M3EListItem(
    headline: items[index].title, // String (required)
    supportingText: items[index].subtitle, // String?
    overline: items[index].category, // String?
    trailingText: '${items[index].bpm} BPM', // String?
    leading: const Icon(M3EIcons.music_note),
    trailing: const Icon(M3EIcons.drag_handle),
    onTap: () {},
  ),
)
```

- **Constructors on `M3EList`:** `M3EList(...)`, `M3EList.scrollable(...)`, `M3EList.sliver(...)`.
- **Important type check on `M3EListItem`:** `headline`, `supportingText`, `overline`, and `trailingText` are **`String` / `String?`**, NOT `Widget`. Put widgets in `leading` and `trailing`, or use `M3ECard` / `M3ECardListItem` if you need custom multi-widget headlines.
- **Swipe actions:** Pass `swipe: M3EListItemSwipe(leading: [...], trailing: [...], mode: M3EListSwipeMode.both, onDismiss: ...)`.

---

## `M3ESelection` & `M3ESelectionAppBar`

Multi-select host pairing a contextual `M3ESelectionAppBar` with `M3EList` selection:

```dart
M3ESelection(
  controller: selectionController, // M3ESelectionController()
  itemCount: items.length,
  appBar: M3ESelectionAppBar(
    idle: M3EAppBar.top(titleText: 'Presets'),
    actions: [M3EIconButton(icon: const Icon(M3EIcons.delete), onPressed: _deleteSelected)],
  ),
  body: M3EList.scrollable(
    itemCount: items.length,
    selection: true,
    selectionController: selectionController,
    itemBuilder: (context, i) => M3EListItem(headline: items[i].name),
  ),
)
```

---

## `M3ECarousel` & `M3EDivider`

- **`M3ECarousel`:** `type: M3ECarouselType.hero | contained | uncontained | uncontainedMultiAspect | fullScreen`, `children: [M3ECarouselItem(image: ..., title: ..., showScrim: M3ECarouselScrim.gradient())]`. Also `M3ECarouselView.builder` / `.weightedBuilder`.
- **`M3EDivider`:** `axis: M3EDividerAxis.horizontal | vertical`, `inset: M3EDividerInset.full | inset | middle`, `outerMargin`.

---

## `M3EDialog`, `M3EBottomSheet` & `M3ESideSheet`

All `.show` APIs require an ancestor `Navigator` / `Overlay`.

```dart
// Basic dialog
M3EDialog.show<void>(
  context,
  dialog: M3EDialog(
    title: 'Delete preset?', // String (required)
    content: const Text('This action cannot be undone.'),
    actions: [
      M3EButton.text(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      M3EButton.text(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
    ],
  ),
);

// Adaptive dialog (full-screen below 600dp, basic dialog above)
M3EDialog.showAdaptive<void>(
  context,
  title: 'New Preset',
  content: formBody,
  confirmLabel: 'Save',
  onConfirm: _save,
);

// Modal bottom sheet (or .showAdaptive for sheet -> side sheet on wide screens)
M3EBottomSheet.show<void>(
  context,
  showDragHandle: true,
  builder: (context) => const PresetEditorSheet(),
);

// Modal side sheet
M3ESideSheet.show<void>(
  context,
  title: 'Inspector',
  body: const InspectorBody(),
);
```

---

## `M3EAppBar` & `M3EToolbar`

- **`M3EAppBar`:** Constructors `.top(...)`, `.search(...)`, `.bottom(...)`, `.sliver(...)`.
  - Variants: `M3EAppBarVariant` (`small`, `mediumFlexible`, `largeFlexible`, `medium`, `large`).
  - Shape & scroll hiding: `shapeFamily: round | square`, `density: regular | compact`, `hideOnScroll`, `hideMode: none | entire | actions`. Note: set `Scaffold(extendBodyBehindAppBar: true, ...)` when using collapsible `.top` or `.search` bars.
- **`M3EToolbar`:** `M3EToolbar(...)` / `.floating(...)` / `.docked(...)`.
  - Actions: `actions: [M3EToolbarAction(icon: M3EIcons.edit, onPressed: ...), M3EToolbarWidget(child: ...)]`.
  - Optional paired FAB via `floatingActionButton` / `fabIcon` + `onFabPressed`.

---

## `M3ENavigationBar`, `M3ENavigationRail`, `M3ENavigationDrawer`

```dart
// Bottom bar (adapts between compact pill bar and wide chip row when autoLayout: true)
M3ENavigationBar(
  selectedIndex: index,
  onDestinationSelected: onSelect,
  destinations: const [
    M3ENavigationBarDestination(
      icon: Icon(M3EIcons.speed),
      label: 'Metronome',
      badgeCount: null,
    ),
  ],
)

// Navigation rail (note: destinations live inside `sections`, not a flat list)
M3ENavigationRail(
  type: M3ENavigationRailType.collapsed, // collapsed | alwaysCollapse | expanded | alwaysExpand
  modality: M3ENavigationRailModality.standard, // standard | modal
  selectedIndex: index,
  onDestinationSelected: onSelect,
  sections: const [
    M3ENavigationRailSection(
      destinations: [
        M3ENavigationRailDestination(icon: Icon(M3EIcons.speed), label: 'Metronome'),
      ],
    ),
  ],
)
```

- **`M3ENavigationDrawer`:** Takes `destinations: List<M3ENavigationDestination>` (or `sections: [M3ENavigationDrawerSection(...)]`), `type: M3ENavigationDrawerType.standard | modal`, optional `controller: M3ENavigationDrawerController()`.

---

## `M3ETabs` & `M3EMenu`

```dart
M3ETabs(
  variant: M3ETabsVariant.primary, // primary | secondary
  selectedIndex: tabIndex,
  onTabSelected: (i) => setState(() => tabIndex = i),
  tabs: const [M3ETab(label: 'All'), M3ETab(label: 'Favorites')],
)

M3EMenu(
  anchorBuilder: (context, open) => M3EIconButton(
    icon: const Icon(M3EIcons.more_vert),
    onPressed: open,
  ),
  entries: [
    M3EMenuEntry(label: 'Rename', onPressed: _rename),
    M3EMenuEntry(label: 'Delete', isDestructive: true, onPressed: _delete),
  ],
)
```

- `M3EMenu` also accepts hierarchical `children: [M3EMenuGroup(...), M3EMenuSubmenu(...), M3EMenuDivider(), M3EMenuSelectable(...), M3EMenuToggleable(...)]`.

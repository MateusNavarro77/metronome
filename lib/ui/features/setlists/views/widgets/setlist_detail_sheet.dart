import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart'
    hide CornerRounding, RoundedPolygon;

import '../../../../../domain/models/preset.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/swipeable_action_card.dart';
import '../../view_models/setlists_view_model.dart';
import 'setlist_name_dialog.dart';

/// Opens [SetlistDetailSheet] as a modal bottom sheet for managing the songs in
/// [setlistId] (FR-PRE-07, UC-08, UC-09).
Future<void> showSetlistDetailSheet(
  BuildContext context, {
  required SetlistsViewModel viewModel,
  required String setlistId,
  VoidCallback? onNavigateToMetronome,
}) {
  return M3EBottomSheet.show<void>(
    context,
    showDragHandle: true,
    isDismissible: true,
    initialValue: M3EBottomSheetValue.expanded,
    builder: (_) => SetlistDetailSheet(
      viewModel: viewModel,
      setlistId: setlistId,
      onNavigateToMetronome: onNavigateToMetronome,
    ),
  );
}

/// Modal bottom sheet allowing users to view, reorder, add, remove, and play
/// presets within a setlist (FR-PRE-07..08).
class SetlistDetailSheet extends StatelessWidget {
  const SetlistDetailSheet({
    super.key,
    required this.viewModel,
    required this.setlistId,
    this.onNavigateToMetronome,
  });

  final SetlistsViewModel viewModel;
  final String setlistId;
  final VoidCallback? onNavigateToMetronome;

  Future<void> _renameSetlist(BuildContext context, String currentName) async {
    final l10n = context.l10n;
    final newName = await showSetlistNameDialog(
      context,
      title: l10n.renameSetlistDialogTitle,
      confirmLabel: l10n.save,
      initialName: currentName,
    );
    if (newName == null) return;
    await viewModel.renameSetlist(setlistId, newName);
  }

  Future<void> _openAddPresetPicker(BuildContext context) async {
    final selectedIds = await M3EBottomSheet.show<List<String>>(
      context,
      showDragHandle: true,
      isDismissible: true,
      initialValue: M3EBottomSheetValue.expanded,
      builder: (_) =>
          _AddPresetPickerSheet(presets: viewModel.availablePresets),
    );
    if (selectedIds == null || selectedIds.isEmpty) return;

    final previousLength =
        viewModel.getSetlistById(setlistId)?.presetIds.length ?? 0;
    await viewModel.addPresetsToSetlist(setlistId, selectedIds);
    if (!context.mounted) return;

    final l10n = context.l10n;
    HapticFeedback.selectionClick();
    showAppSnackbar(
      context,
      message: l10n.songsAddedToSetlistSnackbar(selectedIds.length),
      actionLabel: l10n.undoAction,
      onAction: () {
        HapticFeedback.selectionClick();
        viewModel.removePresetRangeFromSetlist(
          setlistId,
          previousLength,
          selectedIds.length,
        );
      },
      showCloseButton: true,
      clearFloatingToolbar: false,
    );
  }

  Future<void> _removePresetWithUndo(
    BuildContext context,
    int index,
    String presetName,
  ) async {
    final record = await viewModel.removePresetAtWithUndo(setlistId, index);
    if (record == null || !context.mounted) return;

    final l10n = context.l10n;
    showAppSnackbar(
      context,
      message: l10n.songRemovedFromSetlistSnackbar(presetName),
      actionLabel: l10n.undoAction,
      onAction: () {
        HapticFeedback.selectionClick();
        viewModel.restoreRemovedPreset(record);
      },
      showCloseButton: true,
      clearFloatingToolbar: false,
    );
  }

  void _playFromIndex(BuildContext context, int index) {
    final setlist = viewModel.getSetlistById(setlistId);
    if (setlist == null) return;
    HapticFeedback.selectionClick();
    viewModel.activateSetlist(setlist, initialIndex: index);
    final l10n = context.l10n;
    final setlistName = setlist.displayName(l10n);
    Navigator.of(context).pop();
    showAppSnackbar(
      context,
      message: l10n.setlistActivatedSnackbar(setlistName),
      actionLabel: onNavigateToMetronome != null
          ? l10n.goToMetronomeAction
          : null,
      onAction: onNavigateToMetronome,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sheetHeight = MediaQuery.sizeOf(context).height * 0.82;

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final setlist = viewModel.getSetlistById(setlistId);
        if (setlist == null) {
          return const SizedBox.shrink();
        }
        final presets = viewModel.resolvePresetsForSetlist(setlist);
        final isActiveSetlist = viewModel.activeSetlistId == setlist.id;

        // Assign stable per-occurrence keys so duplicate presets in the same
        // setlist animate and dismiss independently without key collisions.
        final occurrenceCounts = <String, int>{};
        final rowKeys = List<String>.generate(presets.length, (index) {
          final id = presets[index].id;
          final count = (occurrenceCounts[id] ?? 0) + 1;
          occurrenceCounts[id] = count;
          return '${setlist.id}_${id}_$count';
        });

        return ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.dimens.maxContentWidth,
            maxHeight: sheetHeight,
          ),
          child: SafeArea(
            key: Key('setlist_detail_sheet_${setlist.id}'),
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                context.dimens.spaceLg,
                context.dimens.spaceSmPlus4,
                context.dimens.spaceLg,
                context.dimens.spaceLg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              setlist.displayName(l10n),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.titleSmall?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: context.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              l10n.setlistSongCountAndReorderHint(
                                l10n.songCount(presets.length),
                              ),
                              style: context.textTheme.bodyMedium?.copyWith(
                                fontSize: 12,
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      M3EIconButton(
                        key: const Key('setlist_detail_rename_button'),
                        variant: M3EIconButtonVariant.standard,
                        tooltip: l10n.renameSetlistGenericTooltip,
                        onPressed: () => _renameSetlist(context, setlist.name),
                        icon: Icon(
                          Icons.edit_outlined,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(width: context.dimens.spaceXs),
                      M3EButton.filled(
                        key: const Key('setlist_add_preset_button'),
                        size: M3EButtonSize.sm,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        onPressed: () => _openAddPresetPicker(context),
                        label: Text(l10n.addPresetButton),
                      ),
                    ],
                  ),
                  SizedBox(height: context.dimens.spaceMd),

                  Expanded(
                    child: presets.isEmpty
                        ? Center(
                            child: M3ECard(
                              variant: M3ECardVariant.elevated,
                              padding: EdgeInsets.all(context.dimens.spaceLg),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.queue_music_rounded,
                                    size: 32,
                                    color: context.colorScheme.primary,
                                  ),
                                  SizedBox(height: context.dimens.spaceSm),
                                  Text(
                                    l10n.emptySetlistDetailTitle,
                                    textAlign: TextAlign.center,
                                    style: context.textTheme.titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: context.colorScheme.onSurface,
                                        ),
                                  ),
                                  SizedBox(height: context.dimens.spaceXs),
                                  Text(
                                    l10n.emptySetlistDetailSubtitle,
                                    textAlign: TextAlign.center,
                                    style: context.textTheme.bodyMedium
                                        ?.copyWith(
                                          color: context
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ReorderableListView.builder(
                            key: const Key('setlist_reorderable_list'),
                            buildDefaultDragHandles: false,
                            itemCount: presets.length,
                            proxyDecorator: _proxyDecorator,
                            onReorderStart: (_) =>
                                HapticFeedback.mediumImpact(),
                            onReorderEnd: (_) =>
                                HapticFeedback.selectionClick(),
                            onReorderItem: (oldIndex, newIndex) {
                              HapticFeedback.selectionClick();
                              // `onReorderItem` provides the post-removal target index,
                              // while `Setlist.reorder` expects pre-removal `onReorder` indices.
                              final rawNewIndex = oldIndex < newIndex
                                  ? newIndex + 1
                                  : newIndex;
                              viewModel.reorderPresets(
                                setlist.id,
                                oldIndex,
                                rawNewIndex,
                              );
                            },
                            itemBuilder: (context, index) {
                              final preset = presets[index];
                              final presetName = preset.displayName(l10n);
                              final isCurrentSong =
                                  isActiveSetlist &&
                                  viewModel.activeSetlistIndex == index;
                              final stableKey = rowKeys[index];

                              return Padding(
                                key: ValueKey('setlist_row_$stableKey'),
                                padding: EdgeInsets.only(
                                  bottom: context.dimens.spaceSm,
                                ),
                                child: SwipeableActionCard(
                                  dismissKey: ValueKey(
                                    'setlist_row_swipe_$stableKey',
                                  ),
                                  borderRadius: context.dimens.radiusDefault,
                                  endToStartAction: SwipeActionConfig(
                                    label: l10n.removeAction,
                                    icon: Icons.remove_circle_outline_rounded,
                                    backgroundColor:
                                        context.colorScheme.errorContainer,
                                    activeBackgroundColor:
                                        context.colorScheme.error,
                                    foregroundColor:
                                        context.colorScheme.onErrorContainer,
                                    activeForegroundColor:
                                        context.colorScheme.onError,
                                    dismissOnTrigger: true,
                                    onTrigger: () => _removePresetWithUndo(
                                      context,
                                      index,
                                      presetName,
                                    ),
                                  ),
                                  child: M3ECard(
                                    key: Key('setlist_item_tap_$index'),
                                    variant: isCurrentSong
                                        ? M3ECardVariant.filled
                                        : M3ECardVariant.elevated,
                                    borderRadius: BorderRadius.circular(
                                      context.dimens.radiusDefault,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: context.dimens.spaceSmPlus4,
                                      vertical: context.dimens.spaceSm,
                                    ),
                                    onPressed: () =>
                                        _playFromIndex(context, index),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 30,
                                          height: 30,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: isCurrentSong
                                                ? context.colorScheme.primary
                                                : context
                                                      .colorScheme
                                                      .surfaceContainerHigh,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            '${index + 1}',
                                            style: context.textTheme.labelMedium
                                                ?.copyWith(
                                                  letterSpacing: 0,
                                                  color: isCurrentSong
                                                      ? context
                                                            .colorScheme
                                                            .onPrimary
                                                      : context
                                                            .colorScheme
                                                            .onSurface,
                                                ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: context.dimens.spaceSmPlus4,
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                presetName,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: context
                                                    .textTheme
                                                    .titleSmall
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: context
                                                          .colorScheme
                                                          .onSurface,
                                                    ),
                                              ),
                                              Text(
                                                '${l10n.bpmWithUnit(preset.bpm.value)} · ${preset.timeSignature.label} · ${preset.subdivision.localizedLabel(l10n)}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: context
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      fontSize: 12,
                                                      color: context
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        M3EMenu(
                                          position:
                                              M3EMenuAnchorPosition.bottomEnd,
                                          anchorBuilder: (context, open) =>
                                              M3EIconButton(
                                                key: Key(
                                                  'setlist_item_menu_$index',
                                                ),
                                                variant: M3EIconButtonVariant
                                                    .standard,
                                                tooltip: l10n
                                                    .moreActionsTooltip(
                                                      presetName,
                                                    ),
                                                onPressed: () {
                                                  HapticFeedback.selectionClick();
                                                  open();
                                                },
                                                icon: Icon(
                                                  Icons.more_vert_rounded,
                                                  size: 20,
                                                  color: context
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                              ),
                                          children: [
                                            M3EMenuEntry(
                                              label: l10n.playFromHereAction,
                                              leading: const Icon(
                                                Icons.play_arrow_rounded,
                                                size: 20,
                                              ),
                                              onPressed: () => _playFromIndex(
                                                context,
                                                index,
                                              ),
                                            ),
                                            const M3EMenuDivider(),
                                            M3EMenuEntry(
                                              label:
                                                  l10n.removeFromSetlistAction,
                                              leading: const Icon(
                                                Icons
                                                    .remove_circle_outline_rounded,
                                                size: 20,
                                              ),
                                              isDestructive: true,
                                              onPressed: () =>
                                                  _removePresetWithUndo(
                                                    context,
                                                    index,
                                                    presetName,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        ReorderableDragStartListener(
                                          key: Key('setlist_item_drag_$index'),
                                          index: index,
                                          child: SizedBox(
                                            width:
                                                context.dimens.minTouchTarget,
                                            height:
                                                context.dimens.minTouchTarget,
                                            child: Icon(
                                              Icons.drag_handle_rounded,
                                              color: context
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final t = Curves.easeOutCubic.transform(animation.value);
        final scale = lerpDouble(1.0, 1.03, t) ?? 1.0;
        final elevation = lerpDouble(0.0, 8.0, t) ?? 0.0;
        return Transform.scale(
          scale: scale,
          child: Material(
            elevation: elevation,
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(context.dimens.radiusDefault),
            shadowColor: context.colorScheme.shadow.withValues(alpha: 0.35),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  context.dimens.radiusDefault,
                ),
                border: Border.all(
                  color: context.colorScheme.primary.withValues(alpha: 0.7 * t),
                  width: 1.5,
                ),
              ),
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

class _AddPresetPickerSheet extends StatefulWidget {
  const _AddPresetPickerSheet({required this.presets});

  final List<Preset> presets;

  @override
  State<_AddPresetPickerSheet> createState() => _AddPresetPickerSheetState();
}

class _AddPresetPickerSheetState extends State<_AddPresetPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _selectedIds = [];
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Preset> get _filteredPresets {
    final normalized = _query.trim().toLowerCase();
    if (normalized.isEmpty) return widget.presets;
    return widget.presets
        .where((preset) => preset.name.toLowerCase().contains(normalized))
        .toList(growable: false);
  }

  void _toggleSelection(String presetId) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedIds.contains(presetId)) {
        _selectedIds.remove(presetId);
      } else {
        _selectedIds.add(presetId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.72;
    final filtered = _filteredPresets;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: context.dimens.maxContentWidth,
        maxHeight: maxHeight,
      ),
      child: SafeArea(
        key: const Key('add_preset_picker_sheet'),
        top: false,
        child: Padding(
          padding: EdgeInsets.all(context.dimens.spaceLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.addPresetPickerTitle,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: context.dimens.spaceSmPlus4),
              if (widget.presets.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: context.dimens.spaceMd,
                  ),
                  child: Text(
                    l10n.addPresetPickerEmpty,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else ...[
                M3ETextField(
                  key: const Key('add_preset_picker_search_field'),
                  controller: _searchController,
                  variant: M3ETextFieldVariant.outlined,
                  placeholder: l10n.searchPresetsInPickerPlaceholder,
                  density: -1,
                  leading: const Icon(Icons.search_rounded, size: 20),
                  trailing: _query.isNotEmpty
                      ? M3EIconButton(
                          variant: M3EIconButtonVariant.standard,
                          size: M3EIconButtonSize.sm,
                          tooltip: l10n.clearSearchTooltip,
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.close_rounded, size: 18),
                        )
                      : null,
                  onChanged: (value) => setState(() => _query = value),
                ),
                SizedBox(height: context.dimens.spaceSmPlus4),
                Flexible(
                  child: filtered.isEmpty
                      ? Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: context.dimens.spaceMd,
                          ),
                          child: Text(
                            l10n.noPresetsMatchQuery(_query),
                            textAlign: TextAlign.center,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) =>
                              SizedBox(height: context.dimens.spaceSm),
                          itemBuilder: (context, index) {
                            final preset = filtered[index];
                            final orderIndex = _selectedIds.indexOf(preset.id);
                            final isSelected = orderIndex != -1;

                            return M3ECard(
                              key: Key('add_preset_picker_item_${preset.id}'),
                              variant: isSelected
                                  ? M3ECardVariant.filled
                                  : M3ECardVariant.elevated,
                              borderRadius: BorderRadius.circular(
                                context.dimens.radiusDefault,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: context.dimens.spaceMd,
                                vertical: context.dimens.spaceSmPlus2,
                              ),
                              onPressed: () => _toggleSelection(preset.id),
                              child: Row(
                                children: [
                                  M3ECheckbox(
                                    value: isSelected,
                                    onChanged: (_) =>
                                        _toggleSelection(preset.id),
                                  ),
                                  SizedBox(width: context.dimens.spaceSm),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          preset.displayName(l10n),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: context.textTheme.titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: context
                                                    .colorScheme
                                                    .onSurface,
                                              ),
                                        ),
                                        Text(
                                          '${l10n.bpmWithUnit(preset.bpm.value)} · ${preset.timeSignature.label} · ${preset.subdivision.localizedLabel(l10n)}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: context.textTheme.bodyMedium
                                              ?.copyWith(
                                                fontSize: 12,
                                                color: context
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Container(
                                      width: 24,
                                      height: 24,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: context.colorScheme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '${orderIndex + 1}',
                                        style: context.textTheme.labelSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color:
                                                  context.colorScheme.onPrimary,
                                            ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                SizedBox(height: context.dimens.spaceMd),
                SizedBox(
                  width: double.infinity,
                  child: M3EButton.filled(
                    key: const Key('add_preset_picker_confirm_button'),
                    size: M3EButtonSize.md,
                    icon: const Icon(
                      Icons.playlist_add_check_rounded,
                      size: 20,
                    ),
                    onPressed: _selectedIds.isEmpty
                        ? null
                        : () =>
                              Navigator.of(context)
                                  .pop(List<String>.unmodifiable(_selectedIds)),
                    label: Text(
                      l10n.addSelectedPresetsButton(_selectedIds.length),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

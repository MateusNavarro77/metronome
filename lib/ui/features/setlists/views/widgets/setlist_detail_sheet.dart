import 'dart:ui';

import 'package:material_ui/material_ui.dart';

import '../../../../../domain/models/preset.dart';
import '../../../../core/theme/sonic_theme.dart';
import '../../view_models/setlists_view_model.dart';
import 'setlist_name_dialog.dart';

/// Opens [SetlistDetailSheet] as a modal bottom sheet for managing the songs in
/// [setlistId] (FR-PRE-07, UC-08, UC-09).
Future<void> showSetlistDetailSheet(
  BuildContext context, {
  required SetlistsViewModel viewModel,
  required String setlistId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) =>
        SetlistDetailSheet(viewModel: viewModel, setlistId: setlistId),
  );
}

/// Modal bottom sheet allowing users to view, reorder, add, remove, and play
/// presets within a setlist (FR-PRE-07..08).
class SetlistDetailSheet extends StatelessWidget {
  const SetlistDetailSheet({
    super.key,
    required this.viewModel,
    required this.setlistId,
  });

  final SetlistsViewModel viewModel;
  final String setlistId;

  Future<void> _renameSetlist(BuildContext context, String currentName) async {
    final newName = await showSetlistNameDialog(
      context,
      title: 'Rename Setlist',
      confirmLabel: 'Save',
      initialName: currentName,
    );
    if (newName == null) return;
    await viewModel.renameSetlist(setlistId, newName);
  }

  Future<void> _openAddPresetPicker(BuildContext context) async {
    final selectedPresetId = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) =>
          _AddPresetPickerSheet(presets: viewModel.availablePresets),
    );
    if (selectedPresetId == null) return;
    await viewModel.addPresetToSetlist(setlistId, selectedPresetId);
  }

  @override
  Widget build(BuildContext context) {
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

        return Center(
          heightFactor: 1.0,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.dimens.maxContentWidth,
              maxHeight: sheetHeight,
            ),
            child: ClipRRect(
              key: Key('setlist_detail_sheet_${setlist.id}'),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(context.dimens.radiusLg),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: context.colors.surfaceLow.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(context.dimens.radiusLg),
                    ),
                    border: Border(
                      top: BorderSide(color: context.colors.ghostBorder),
                    ),
                  ),
                  child: SafeArea(
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
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: context.colors.surfaceHighest,
                                borderRadius: BorderRadius.circular(
                                  context.dimens.radiusFull,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: context.dimens.spaceMd),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      setlist.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.textTheme.titleSmall
                                          ?.copyWith(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color:
                                                context.colors.onSurfacePrimary,
                                          ),
                                    ),
                                    Text(
                                      '${presets.length} ${presets.length == 1 ? 'song' : 'songs'} · Drag to reorder',
                                      style: context.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontSize: 12,
                                            color:
                                                context.colors.onSurfaceMuted,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                key: const Key('setlist_detail_rename_button'),
                                tooltip: 'Rename setlist',
                                constraints: BoxConstraints(
                                  minWidth: context.dimens.minTouchTarget,
                                  minHeight: context.dimens.minTouchTarget,
                                ),
                                onPressed: () =>
                                    _renameSetlist(context, setlist.name),
                                icon: Icon(
                                  Icons.edit_outlined,
                                  color: context.colors.onSurfaceMuted,
                                ),
                              ),
                              SizedBox(width: context.dimens.spaceXs),
                              FilledButton.icon(
                                key: const Key('setlist_add_preset_button'),
                                onPressed: () => _openAddPresetPicker(context),
                                style: FilledButton.styleFrom(
                                  minimumSize: Size(
                                    0,
                                    context.dimens.minTouchTarget,
                                  ),
                                  backgroundColor: context.colors.primaryAccent,
                                  foregroundColor:
                                      context.colors.onPrimaryAccent,
                                  shape: const StadiumBorder(),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: context.dimens.spaceMd,
                                  ),
                                ),
                                icon: const Icon(Icons.add_rounded, size: 18),
                                label: const Text('Add Preset'),
                              ),
                            ],
                          ),
                          SizedBox(height: context.dimens.spaceMd),

                          Expanded(
                            child: presets.isEmpty
                                ? Center(
                                    child: Container(
                                      padding: EdgeInsets.all(
                                        context.dimens.spaceLg,
                                      ),
                                      decoration: BoxDecoration(
                                        color: context.colors.surfaceContainer,
                                        borderRadius: BorderRadius.circular(
                                          context.dimens.radiusMd,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.queue_music_rounded,
                                            size: 32,
                                            color: context.colors.primaryAccent,
                                          ),
                                          SizedBox(
                                            height: context.dimens.spaceSm,
                                          ),
                                          Text(
                                            'This setlist has no songs yet.',
                                            textAlign: TextAlign.center,
                                            style: context.textTheme.titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: context
                                                      .colors
                                                      .onSurfacePrimary,
                                                ),
                                          ),
                                          SizedBox(
                                            height: context.dimens.spaceXs,
                                          ),
                                          Text(
                                            'Tap "Add Preset" above to build your song order.',
                                            textAlign: TextAlign.center,
                                            style: context.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: context
                                                      .colors
                                                      .onSurfaceMuted,
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
                                    onReorderItem: (oldIndex, newIndex) {
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
                                      final isCurrentSong =
                                          isActiveSetlist &&
                                          viewModel.activeSetlistIndex == index;

                                      return Padding(
                                        key: ValueKey(
                                          'setlist_row_${setlist.id}_$index',
                                        ),
                                        padding: EdgeInsets.only(
                                          bottom: context.dimens.spaceSm,
                                        ),
                                        child: Material(
                                          color: isCurrentSong
                                              ? context.colors.primaryContainer
                                              : context.colors.surfaceContainer,
                                          borderRadius: BorderRadius.circular(
                                            context.dimens.radiusDefault,
                                          ),
                                          child: InkWell(
                                            key: Key('setlist_item_tap_$index'),
                                            borderRadius: BorderRadius.circular(
                                              context.dimens.radiusDefault,
                                            ),
                                            onTap: () {
                                              viewModel.activateSetlist(
                                                setlist,
                                                initialIndex: index,
                                              );
                                              Navigator.of(context).pop();
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    context.dimens.spaceSmPlus4,
                                                vertical:
                                                    context.dimens.spaceSm,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      context
                                                          .dimens
                                                          .radiusDefault,
                                                    ),
                                                border: Border.all(
                                                  color: isCurrentSong
                                                      ? context
                                                            .colors
                                                            .neonGhostBorder
                                                      : context
                                                            .colors
                                                            .ghostBorder,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 30,
                                                    height: 30,
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      color: isCurrentSong
                                                          ? context
                                                                .colors
                                                                .primaryAccent
                                                          : context
                                                                .colors
                                                                .surfaceHigh,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Text(
                                                      '${index + 1}',
                                                      style: context
                                                          .textTheme
                                                          .labelMedium
                                                          ?.copyWith(
                                                            letterSpacing: 0,
                                                            color: isCurrentSong
                                                                ? context
                                                                      .colors
                                                                      .onPrimaryAccent
                                                                : context
                                                                      .colors
                                                                      .onSurfacePrimary,
                                                          ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: context
                                                        .dimens
                                                        .spaceSmPlus4,
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          preset.name,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: context
                                                              .textTheme
                                                              .titleSmall
                                                              ?.copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color:
                                                                    isCurrentSong
                                                                    ? context
                                                                          .colors
                                                                          .onPrimaryContainer
                                                                    : context
                                                                          .colors
                                                                          .onSurfacePrimary,
                                                              ),
                                                        ),
                                                        Text(
                                                          '${preset.bpm.value} BPM · ${preset.timeSignature.label} · ${preset.subdivision.label}',
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: context
                                                              .textTheme
                                                              .bodyMedium
                                                              ?.copyWith(
                                                                fontSize: 12,
                                                                color:
                                                                    isCurrentSong
                                                                    ? context
                                                                          .colors
                                                                          .onPrimaryContainer
                                                                          .withValues(
                                                                            alpha:
                                                                                0.8,
                                                                          )
                                                                    : context
                                                                          .colors
                                                                          .onSurfaceMuted,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  IconButton(
                                                    key: Key(
                                                      'setlist_item_remove_$index',
                                                    ),
                                                    tooltip:
                                                        'Remove ${preset.name}',
                                                    constraints: BoxConstraints(
                                                      minWidth: context
                                                          .dimens
                                                          .minTouchTarget,
                                                      minHeight: context
                                                          .dimens
                                                          .minTouchTarget,
                                                    ),
                                                    onPressed: () {
                                                      viewModel.removePresetAt(
                                                        setlist.id,
                                                        index,
                                                      );
                                                    },
                                                    icon: Icon(
                                                      Icons
                                                          .remove_circle_outline_rounded,
                                                      size: 20,
                                                      color:
                                                          context.colors.error,
                                                    ),
                                                  ),
                                                  ReorderableDragStartListener(
                                                    key: Key(
                                                      'setlist_item_drag_$index',
                                                    ),
                                                    index: index,
                                                    child: SizedBox(
                                                      width: context
                                                          .dimens
                                                          .minTouchTarget,
                                                      height: context
                                                          .dimens
                                                          .minTouchTarget,
                                                      child: Icon(
                                                        Icons
                                                            .drag_handle_rounded,
                                                        color: isCurrentSong
                                                            ? context
                                                                  .colors
                                                                  .onPrimaryContainer
                                                            : context
                                                                  .colors
                                                                  .onSurfaceMuted,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
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
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AddPresetPickerSheet extends StatelessWidget {
  const _AddPresetPickerSheet({required this.presets});

  final List<Preset> presets;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.65;

    return Center(
      heightFactor: 1.0,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: context.dimens.maxContentWidth,
          maxHeight: maxHeight,
        ),
        child: ClipRRect(
          key: const Key('add_preset_picker_sheet'),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(context.dimens.radiusLg),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: context.colors.surfaceLow.withValues(alpha: 0.94),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(context.dimens.radiusLg),
                ),
                border: Border(
                  top: BorderSide(color: context.colors.ghostBorder),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.all(context.dimens.spaceLg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'ADD PRESET TO SETLIST',
                        style: context.textTheme.titleSmall?.copyWith(
                          letterSpacing: 1.4,
                          fontWeight: FontWeight.w700,
                          color: context.colors.onSurfacePrimary,
                        ),
                      ),
                      SizedBox(height: context.dimens.spaceMd),
                      if (presets.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: context.dimens.spaceMd,
                          ),
                          child: Text(
                            'No presets saved yet. Create a preset in the Presets tab first.',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colors.onSurfaceMuted,
                            ),
                          ),
                        )
                      else
                        Flexible(
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: presets.length,
                            separatorBuilder: (_, _) =>
                                SizedBox(height: context.dimens.spaceSm),
                            itemBuilder: (context, index) {
                              final preset = presets[index];
                              return Material(
                                color: context.colors.surfaceContainer,
                                borderRadius: BorderRadius.circular(
                                  context.dimens.radiusDefault,
                                ),
                                child: InkWell(
                                  key: Key(
                                    'add_preset_picker_item_${preset.id}',
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    context.dimens.radiusDefault,
                                  ),
                                  onTap: () =>
                                      Navigator.of(context).pop(preset.id),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: context.dimens.spaceMd,
                                      vertical: context.dimens.spaceSmPlus2,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                preset.name,
                                                style: context
                                                    .textTheme
                                                    .titleSmall
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: context
                                                          .colors
                                                          .onSurfacePrimary,
                                                    ),
                                              ),
                                              Text(
                                                '${preset.bpm.value} BPM · ${preset.timeSignature.label} · ${preset.subdivision.label}',
                                                style: context
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      fontSize: 12,
                                                      color: context
                                                          .colors
                                                          .onSurfaceMuted,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.add_circle_outline_rounded,
                                          color: context.colors.primaryAccent,
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
            ),
          ),
        ),
      ),
    );
  }
}

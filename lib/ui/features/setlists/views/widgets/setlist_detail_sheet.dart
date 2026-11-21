import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart'
    hide CornerRounding, RoundedPolygon;

import '../../../../../domain/models/preset.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../view_models/setlists_view_model.dart';
import 'setlist_name_dialog.dart';

/// Opens [SetlistDetailSheet] as a modal bottom sheet for managing the songs in
/// [setlistId] (FR-PRE-07, UC-08, UC-09).
Future<void> showSetlistDetailSheet(
  BuildContext context, {
  required SetlistsViewModel viewModel,
  required String setlistId,
}) {
  return M3EBottomSheet.show<void>(
    context,
    showDragHandle: true,
    isDismissible: true,
    initialValue: M3EBottomSheetValue.expanded,
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
    final selectedPresetId = await M3EBottomSheet.show<String>(
      context,
      showDragHandle: true,
      isDismissible: true,
      initialValue: M3EBottomSheetValue.expanded,
      builder: (_) =>
          _AddPresetPickerSheet(presets: viewModel.availablePresets),
    );
    if (selectedPresetId == null) return;
    await viewModel.addPresetToSetlist(setlistId, selectedPresetId);
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
                        child: Text(l10n.addPresetButton),
                      ),
                    ],
                  ),
                  SizedBox(height: context.dimens.spaceMd),

                  Expanded(
                    child: presets.isEmpty
                        ? Center(
                            child: M3ECard(
                              variant: M3ECardVariant.outlined,
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
                              final presetName = preset.displayName(l10n);
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
                                child: M3ECard(
                                  key: Key('setlist_item_tap_$index'),
                                  variant: isCurrentSong
                                      ? M3ECardVariant.filled
                                      : M3ECardVariant.outlined,
                                  borderRadius: BorderRadius.circular(
                                    context.dimens.radiusDefault,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: context.dimens.spaceSmPlus4,
                                    vertical: context.dimens.spaceSm,
                                  ),
                                  onPressed: () {
                                    viewModel.activateSetlist(
                                      setlist,
                                      initialIndex: index,
                                    );
                                    Navigator.of(context).pop();
                                  },
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
                                      M3EIconButton(
                                        key: Key('setlist_item_remove_$index'),
                                        variant: M3EIconButtonVariant.standard,
                                        tooltip: l10n.removePresetTooltip(
                                          presetName,
                                        ),
                                        onPressed: () {
                                          viewModel.removePresetAt(
                                            setlist.id,
                                            index,
                                          );
                                        },
                                        icon: Icon(
                                          Icons.remove_circle_outline_rounded,
                                          size: 20,
                                          color: context.colorScheme.error,
                                        ),
                                      ),
                                      ReorderableDragStartListener(
                                        key: Key('setlist_item_drag_$index'),
                                        index: index,
                                        child: SizedBox(
                                          width: context.dimens.minTouchTarget,
                                          height: context.dimens.minTouchTarget,
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
        return Material(elevation: 0, color: Colors.transparent, child: child);
      },
      child: child,
    );
  }
}

class _AddPresetPickerSheet extends StatelessWidget {
  const _AddPresetPickerSheet({required this.presets});

  final List<Preset> presets;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.65;

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
                style: context.textTheme.titleSmall?.copyWith(
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w700,
                  color: context.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: context.dimens.spaceMd),
              if (presets.isEmpty)
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
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: presets.length,
                    separatorBuilder: (_, _) =>
                        SizedBox(height: context.dimens.spaceSm),
                    itemBuilder: (context, index) {
                      final preset = presets[index];
                      return M3ECard(
                        key: Key('add_preset_picker_item_${preset.id}'),
                        variant: M3ECardVariant.outlined,
                        borderRadius: BorderRadius.circular(
                          context.dimens.radiusDefault,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: context.dimens.spaceMd,
                          vertical: context.dimens.spaceSmPlus2,
                        ),
                        onPressed: () => Navigator.of(context).pop(preset.id),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    preset.displayName(l10n),
                                    style: context.textTheme.titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: context.colorScheme.onSurface,
                                        ),
                                  ),
                                  Text(
                                    '${l10n.bpmWithUnit(preset.bpm.value)} · ${preset.timeSignature.label} · ${preset.subdivision.localizedLabel(l10n)}',
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
                            Icon(
                              Icons.add_circle_outline_rounded,
                              color: context.colorScheme.primary,
                            ),
                          ],
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
  }
}

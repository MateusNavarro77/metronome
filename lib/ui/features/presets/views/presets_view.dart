import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart'
    hide CornerRounding, RoundedPolygon;
import 'package:provider/provider.dart';

import '../../../../domain/models/preset.dart';
import '../../../../domain/models/setlist.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/active_status_badge.dart';
import '../../../core/widgets/animated_favorite_button.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/list_action_sheet.dart';
import '../../../core/widgets/swipeable_action_card.dart';
import '../../setlists/views/widgets/setlist_name_dialog.dart';
import '../view_models/presets_view_model.dart';
import 'widgets/preset_editor_sheet.dart';

/// Presets management screen using Material 3 Expressive theming
/// and PRD section 3.7 (FR-PRE-01..05, FR-PRE-10..11, UI-05..06).
class PresetsView extends StatelessWidget {
  const PresetsView({super.key, this.viewModel, this.onNavigateToMetronome});

  /// Optional explicit ViewModel for isolated testing; defaults to Provider lookup.
  final PresetsViewModel? viewModel;

  /// Optional callback to jump directly to the Metronome tab from feedback snackbars.
  final VoidCallback? onNavigateToMetronome;

  @override
  Widget build(BuildContext context) {
    final explicitViewModel = viewModel;
    if (explicitViewModel != null) {
      return ListenableBuilder(
        listenable: explicitViewModel,
        builder: (context, _) => _PresetsViewBody(
          viewModel: explicitViewModel,
          onNavigateToMetronome: onNavigateToMetronome,
        ),
      );
    }
    return _PresetsViewBody(
      viewModel: context.watch<PresetsViewModel>(),
      onNavigateToMetronome: onNavigateToMetronome,
    );
  }
}

class _PresetsViewBody extends StatefulWidget {
  const _PresetsViewBody({required this.viewModel, this.onNavigateToMetronome});

  final PresetsViewModel viewModel;
  final VoidCallback? onNavigateToMetronome;

  @override
  State<_PresetsViewBody> createState() => _PresetsViewBodyState();
}

class _PresetsViewBodyState extends State<_PresetsViewBody> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: widget.viewModel.searchQuery,
    );
  }

  @override
  void didUpdateWidget(covariant _PresetsViewBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_searchController.text != widget.viewModel.searchQuery) {
      _searchController.text = widget.viewModel.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openCreatePresetSheet() async {
    final vm = widget.viewModel;
    final result = await showPresetEditorSheet(
      context,
      initialBpm: vm.currentBpm,
      initialTimeSignature: vm.currentTimeSignature,
      initialSubdivision: vm.currentSubdivision,
      initialAccentEnabled: vm.currentAccentEnabled,
    );
    if (result == null) return;

    await vm.createPreset(
      name: result.name,
      bpm: result.bpm,
      timeSignature: result.timeSignature,
      subdivision: result.subdivision,
      isAccentEnabled: result.isAccentEnabled,
      isFavorite: result.isFavorite,
      note: result.note,
    );
  }

  Future<void> _openEditPresetSheet(Preset preset) async {
    final result = await showPresetEditorSheet(
      context,
      existingPreset: preset,
      initialBpm: preset.bpm,
      initialTimeSignature: preset.timeSignature,
      initialSubdivision: preset.subdivision,
      initialAccentEnabled: preset.isAccentEnabled,
    );
    if (result == null) return;

    await widget.viewModel.updatePreset(
      preset.copyWith(
        name: result.name,
        note: result.note,
        isFavorite: result.isFavorite,
        bpm: result.bpm,
        timeSignature: result.timeSignature,
        subdivision: result.subdivision,
        isAccentEnabled: result.isAccentEnabled,
      ),
    );
  }

  void _loadPreset(Preset preset) {
    HapticFeedback.selectionClick();
    widget.viewModel.loadPreset(preset);
    final l10n = context.l10n;
    final onGoToMetronome = widget.onNavigateToMetronome;
    showAppSnackbar(
      context,
      message: l10n.presetLoadedSnackbar(preset.displayName(l10n)),
      actionLabel: onGoToMetronome != null ? l10n.goToMetronomeAction : null,
      onAction: onGoToMetronome,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> _duplicatePreset(Preset preset) async {
    final l10n = context.l10n;
    final copyName = l10n.presetCopyName(preset.displayName(l10n));
    final created = await widget.viewModel.duplicatePreset(
      preset.id,
      duplicatedName: copyName,
    );
    if (!mounted) return;
    HapticFeedback.selectionClick();
    showAppSnackbar(
      context,
      message: l10n.presetDuplicatedSnackbar(created.displayName(l10n)),
      actionLabel: l10n.undoAction,
      onAction: () {
        widget.viewModel.deletePreset(created.id);
      },
      showCloseButton: true,
    );
  }

  Future<void> _deletePresetWithUndo(Preset preset) async {
    final l10n = context.l10n;
    final vm = widget.viewModel;
    final presetName = preset.displayName(l10n);
    final wasActive = vm.activePresetId == preset.id;

    final record = await vm.deletePresetWithUndo(preset.id);
    if (record == null || !mounted) return;

    final affectedCount = record.affectedSetlists.length;
    final message = affectedCount > 0
        ? l10n.presetDeletedWithSetlistsSnackbar(presetName, affectedCount)
        : l10n.presetDeletedSnackbar(presetName);

    showAppSnackbar(
      context,
      message: message,
      actionLabel: l10n.undoAction,
      onAction: () {
        HapticFeedback.selectionClick();
        vm.restoreDeletedPreset(record, wasActive: wasActive);
      },
      showCloseButton: true,
    );
  }

  Future<void> _openAddToSetlistSheet(Preset preset) async {
    final l10n = context.l10n;
    final vm = widget.viewModel;
    final presetName = preset.displayName(l10n);

    final selection = await M3EBottomSheet.show<_SetlistPickResult>(
      context,
      showDragHandle: true,
      isDismissible: true,
      initialValue: M3EBottomSheetValue.expanded,
      builder: (_) => _SelectSetlistForPresetSheet(
        presetName: presetName,
        setlists: vm.setlists,
      ),
    );
    if (selection == null || !mounted) return;

    if (selection.createNew) {
      final newName = await showSetlistNameDialog(
        context,
        title: l10n.newSetlistDialogTitle,
        confirmLabel: l10n.create,
      );
      if (newName == null || !mounted) return;
      final created = await vm.createSetlist(
        name: newName,
        presetIds: [preset.id],
      );
      if (!mounted) return;
      HapticFeedback.selectionClick();
      showAppSnackbar(
        context,
        message: l10n.presetAddedToSetlistSnackbar(
          presetName,
          created.displayName(l10n),
        ),
        actionLabel: l10n.undoAction,
        onAction: () {
          vm.deleteSetlist(created.id);
        },
        showCloseButton: true,
      );
      return;
    }

    final target = selection.setlist;
    if (target == null) return;
    final updated = await vm.addPresetToSetlist(target.id, preset.id);
    if (!mounted) return;
    final addedIndex = updated.presetIds.length - 1;
    HapticFeedback.selectionClick();
    showAppSnackbar(
      context,
      message: l10n.presetAddedToSetlistSnackbar(
        presetName,
        updated.displayName(l10n),
      ),
      actionLabel: l10n.undoAction,
      onAction: () {
        vm.removePresetAtFromSetlist(updated.id, addedIndex);
      },
      showCloseButton: true,
    );
  }

  void _openPresetActionSheet(Preset preset) {
    final l10n = context.l10n;
    final presetName = preset.displayName(l10n);
    showListItemActionSheet(
      context,
      sheetKey: Key('preset_action_sheet_${preset.id}'),
      title: presetName,
      subtitle:
          '${l10n.bpmWithUnit(preset.bpm.value)} · ${preset.timeSignature.label} · ${preset.subdivision.localizedLabel(l10n)}',
      actions: [
        ListActionItem(
          key: Key('preset_sheet_favorite_${preset.id}'),
          icon: preset.isFavorite
              ? Icons.star_outline_rounded
              : Icons.star_rounded,
          label: preset.isFavorite
              ? l10n.unfavoriteAction
              : l10n.favoriteAction,
          onTap: () => widget.viewModel.toggleFavorite(preset.id),
        ),
        ListActionItem(
          key: Key('preset_sheet_edit_${preset.id}'),
          icon: Icons.edit_outlined,
          label: l10n.editAction,
          onTap: () => _openEditPresetSheet(preset),
        ),
        ListActionItem(
          key: Key('preset_sheet_duplicate_${preset.id}'),
          icon: Icons.copy_rounded,
          label: l10n.duplicateAction,
          onTap: () => _duplicatePreset(preset),
        ),
        ListActionItem(
          key: Key('preset_sheet_add_to_setlist_${preset.id}'),
          icon: Icons.playlist_add_rounded,
          label: l10n.addToSetlistAction,
          onTap: () => _openAddToSetlistSheet(preset),
        ),
        ListActionItem(
          key: Key('preset_sheet_delete_${preset.id}'),
          icon: Icons.delete_outline_rounded,
          label: l10n.delete,
          isDestructive: true,
          onTap: () => _deletePresetWithUndo(preset),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vm = widget.viewModel;
    final allPresets = vm.allPresets;
    final presets = vm.filteredPresets;
    final activePresetId = vm.activePresetId;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.dimens.maxContentWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Architectural Header Bar
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.dimens.spaceMd,
                    context.dimens.spaceSm,
                    context.dimens.spaceMd,
                    context.dimens.spaceSm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.presetsHeader,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.colorScheme.onSurface,
                        ),
                      ),
                      M3EButton.filled(
                        key: const Key('create_preset_button'),
                        size: M3EButtonSize.sm,
                        icon: const Icon(Icons.add_rounded, size: 20),
                        onPressed: _openCreatePresetSheet,
                        label: Text(l10n.newPresetButton),
                      ),
                    ],
                  ),
                ),

                // Search bar (FR-PRE-05)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.dimens.spaceMd,
                  ),
                  child: M3ETextField(
                    key: const Key('presets_search_field'),
                    controller: _searchController,
                    variant: M3ETextFieldVariant.outlined,
                    placeholder: l10n.searchPresetsPlaceholder,
                    density: -1,
                    leading: const Icon(Icons.search_rounded, size: 20),
                    trailing: vm.searchQuery.isNotEmpty
                        ? M3EIconButton(
                            key: const Key('presets_search_clear_button'),
                            variant: M3EIconButtonVariant.standard,
                            size: M3EIconButtonSize.sm,
                            tooltip: l10n.clearSearchTooltip,
                            onPressed: () {
                              _searchController.clear();
                              vm.setSearchQuery('');
                            },
                            icon: const Icon(Icons.close_rounded, size: 18),
                          )
                        : null,
                    onChanged: vm.setSearchQuery,
                  ),
                ),

                // Quick filter chips (All / Favorites)
                if (allPresets.isNotEmpty) ...[
                  SizedBox(height: context.dimens.spaceSm),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.dimens.spaceMd,
                    ),
                    child: M3EChipGroup(
                      groupLabel: l10n.presetsHeader,
                      child: Wrap(
                        spacing: context.dimens.spaceSm,
                        children: [
                          M3EChip(
                            key: const Key('presets_filter_all_chip'),
                            label: l10n.filterAllLabel(allPresets.length),
                            type: M3EChipType.filter,
                            selected: !vm.favoritesOnly,
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              vm.setFavoritesOnly(false);
                            },
                          ),
                          M3EChip(
                            key: const Key('presets_filter_favorites_chip'),
                            label: l10n.filterFavoritesLabel(vm.favoriteCount),
                            type: M3EChipType.filter,
                            leading: Icon(
                              vm.favoritesOnly
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 16,
                            ),
                            selected: vm.favoritesOnly,
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              vm.setFavoritesOnly(!vm.favoritesOnly);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                SizedBox(height: context.dimens.spaceSmPlus4),

                // Preset List or Empty State
                Expanded(
                  child: presets.isEmpty
                      ? SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            context.dimens.spaceMd,
                            context.dimens.spaceMd,
                            context.dimens.spaceMd,
                            context.dimens.spaceMd + bottomInset,
                          ),
                          child: _EmptyPresetsCard(
                            hasAnyPresets: allPresets.isNotEmpty,
                            favoritesOnly: vm.favoritesOnly,
                            searchQuery: vm.searchQuery,
                            onCreatePreset: _openCreatePresetSheet,
                            onClearFilters: () {
                              _searchController.clear();
                              vm.clearFilters();
                            },
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.fromLTRB(
                            context.dimens.spaceMd,
                            0,
                            context.dimens.spaceMd,
                            context.dimens.spaceLg + bottomInset,
                          ),
                          itemCount: presets.length,
                          separatorBuilder: (_, _) =>
                              SizedBox(height: context.dimens.spaceSm),
                          itemBuilder: (context, index) {
                            final preset = presets[index];
                            final isActive = preset.id == activePresetId;
                            return SwipeableActionCard(
                              dismissKey: ValueKey('preset_swipe_${preset.id}'),
                              borderRadius: context.dimens.radiusMd,
                              startToEndAction: SwipeActionConfig(
                                label: preset.isFavorite
                                    ? l10n.unfavoriteAction
                                    : l10n.favoriteAction,
                                icon: preset.isFavorite
                                    ? Icons.star_outline_rounded
                                    : Icons.star_rounded,
                                backgroundColor:
                                    context.colorScheme.primaryContainer,
                                activeBackgroundColor:
                                    context.colorScheme.primary,
                                foregroundColor:
                                    context.colorScheme.onPrimaryContainer,
                                activeForegroundColor:
                                    context.colorScheme.onPrimary,
                                dismissOnTrigger: false,
                                onTrigger: () => vm.toggleFavorite(preset.id),
                              ),
                              endToStartAction: SwipeActionConfig(
                                label: l10n.delete,
                                icon: Icons.delete_outline_rounded,
                                backgroundColor:
                                    context.colorScheme.errorContainer,
                                activeBackgroundColor:
                                    context.colorScheme.error,
                                foregroundColor:
                                    context.colorScheme.onErrorContainer,
                                activeForegroundColor:
                                    context.colorScheme.onError,
                                dismissOnTrigger: true,
                                onTrigger: () => _deletePresetWithUndo(preset),
                              ),
                              child: _PresetCard(
                                preset: preset,
                                isActive: isActive,
                                isPlayingListenable: vm.isPlayingListenable,
                                onTap: () => _loadPreset(preset),
                                onLongPress: () =>
                                    _openPresetActionSheet(preset),
                                onToggleFavorite: () =>
                                    vm.toggleFavorite(preset.id),
                                onEdit: () => _openEditPresetSheet(preset),
                                onDuplicate: () => _duplicatePreset(preset),
                                onAddToSetlist: () =>
                                    _openAddToSetlistSheet(preset),
                                onDelete: () => _deletePresetWithUndo(preset),
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
    );
  }
}

class _PresetCard extends StatelessWidget {
  const _PresetCard({
    required this.preset,
    required this.isActive,
    required this.isPlayingListenable,
    required this.onTap,
    required this.onLongPress,
    required this.onToggleFavorite,
    required this.onEdit,
    required this.onDuplicate,
    required this.onAddToSetlist,
    required this.onDelete,
  });

  final Preset preset;
  final bool isActive;
  final ValueListenable<bool> isPlayingListenable;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onToggleFavorite;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onAddToSetlist;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final presetName = preset.displayName(l10n);

    return Semantics(
      button: true,
      selected: isActive,
      label: l10n.presetCardSemantics(
        presetName,
        preset.bpm.value,
        preset.timeSignature.label,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.dimens.radiusMd),
          border: Border.all(
            color: isActive
                ? context.colorScheme.primary.withValues(alpha: 0.72)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: M3ECard(
          key: Key('preset_card_${preset.id}'),
          variant: isActive ? M3ECardVariant.filled : M3ECardVariant.elevated,
          borderRadius: BorderRadius.circular(context.dimens.radiusMd),
          padding: EdgeInsets.fromLTRB(
            context.dimens.spaceMd,
            context.dimens.spaceSmPlus4,
            context.dimens.spaceSm,
            context.dimens.spaceMd,
          ),
          onPressed: onTap,
          onLongPress: onLongPress,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                presetName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: context.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            if (isActive) ...[
                              SizedBox(width: context.dimens.spaceSm),
                              ActiveStatusBadge(
                                key: Key('preset_active_badge_${preset.id}'),
                                label: l10n.activeBadge,
                                isPlayingListenable: isPlayingListenable,
                              ),
                            ],
                          ],
                        ),
                        if (preset.note.isNotEmpty) ...[
                          SizedBox(height: context.dimens.spaceXs),
                          Text(
                            preset.note,
                            key: Key('preset_note_${preset.id}'),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  AnimatedFavoriteButton(
                    buttonKey: Key('preset_favorite_button_${preset.id}'),
                    isFavorite: preset.isFavorite,
                    tooltip: preset.isFavorite
                        ? l10n.unfavoritePresetTooltip(presetName)
                        : l10n.favoritePresetTooltip(presetName),
                    onPressed: onToggleFavorite,
                  ),
                  M3EMenu(
                    position: M3EMenuAnchorPosition.bottomEnd,
                    anchorBuilder: (context, open) => M3EIconButton(
                      key: Key('preset_menu_button_${preset.id}'),
                      variant: M3EIconButtonVariant.standard,
                      tooltip: l10n.moreActionsTooltip(presetName),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        open();
                      },
                      icon: Icon(
                        Icons.more_vert_rounded,
                        size: 20,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    children: [
                      M3EMenuEntry(
                        label: l10n.editAction,
                        leading: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: onEdit,
                      ),
                      M3EMenuEntry(
                        label: l10n.duplicateAction,
                        leading: const Icon(Icons.copy_rounded, size: 20),
                        onPressed: onDuplicate,
                      ),
                      M3EMenuEntry(
                        label: l10n.addToSetlistAction,
                        leading: const Icon(
                          Icons.playlist_add_rounded,
                          size: 20,
                        ),
                        onPressed: onAddToSetlist,
                      ),
                      const M3EMenuDivider(),
                      M3EMenuEntry(
                        label: l10n.delete,
                        leading: const Icon(
                          Icons.delete_outline_rounded,
                          size: 20,
                        ),
                        isDestructive: true,
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: context.dimens.spaceSm),
              Padding(
                padding: EdgeInsets.only(right: context.dimens.spaceSm),
                child: Wrap(
                  spacing: context.dimens.spaceSm,
                  runSpacing: context.dimens.spaceXs,
                  children: [
                    _ParameterBadge(
                      label: l10n.presetBpmTempoSummary(
                        preset.bpm.value,
                        preset.bpm.tempoMarking.label,
                      ),
                      isActive: isActive,
                    ),
                    _ParameterBadge(
                      label: preset.timeSignature.label,
                      isActive: isActive,
                    ),
                    _ParameterBadge(
                      label:
                          '${preset.subdivision.symbol} ${preset.subdivision.localizedLabel(l10n)}',
                      isActive: isActive,
                    ),
                    _ParameterBadge(
                      label: preset.isAccentEnabled
                          ? l10n.accentOnBadge
                          : l10n.accentOffBadge,
                      isActive: isActive,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParameterBadge extends StatelessWidget {
  const _ParameterBadge({required this.label, required this.isActive});

  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.dimens.spaceSmPlus2,
        vertical: context.dimens.spaceXs,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? context.colorScheme.surfaceContainerLow.withValues(alpha: 0.72)
            : context.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(context.dimens.radiusFull),
      ),
      child: Text(
        label,
        style: context.textTheme.labelMedium?.copyWith(
          fontSize: 11,
          color: context.colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _EmptyPresetsCard extends StatelessWidget {
  const _EmptyPresetsCard({
    required this.hasAnyPresets,
    required this.favoritesOnly,
    required this.searchQuery,
    required this.onCreatePreset,
    required this.onClearFilters,
  });

  final bool hasAnyPresets;
  final bool favoritesOnly;
  final String searchQuery;
  final VoidCallback onCreatePreset;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isFavoritesEmpty =
        hasAnyPresets && favoritesOnly && searchQuery.trim().isEmpty;

    final icon = !hasAnyPresets
        ? Icons.tune_rounded
        : isFavoritesEmpty
        ? Icons.star_outline_rounded
        : Icons.search_off_rounded;

    final title = !hasAnyPresets
        ? l10n.noPresetsSavedTitle
        : isFavoritesEmpty
        ? l10n.noFavoritePresetsTitle
        : l10n.noPresetsMatchQuery(searchQuery);

    final subtitle = !hasAnyPresets
        ? l10n.noPresetsSavedSubtitle
        : isFavoritesEmpty
        ? l10n.noFavoritePresetsSubtitle
        : l10n.noPresetsMatchSubtitle;

    final buttonLabel = !hasAnyPresets
        ? l10n.createPresetButton
        : isFavoritesEmpty
        ? l10n.showAllPresetsButton
        : l10n.clearSearchButton;

    return M3ECard(
      variant: M3ECardVariant.elevated,
      borderRadius: BorderRadius.circular(context.dimens.radiusLg),
      padding: EdgeInsets.all(context.dimens.spaceLg),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: context.colorScheme.primary),
          ),
          SizedBox(height: context.dimens.spaceMd),
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: context.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: context.dimens.spaceXs),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: context.dimens.spaceMd),
          M3EButton.filled(
            key: Key(
              hasAnyPresets
                  ? 'empty_clear_search_button'
                  : 'empty_create_preset_button',
            ),
            size: M3EButtonSize.md,
            onPressed: hasAnyPresets ? onClearFilters : onCreatePreset,
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}

class _SetlistPickResult {
  const _SetlistPickResult.existing(this.setlist) : createNew = false;
  const _SetlistPickResult.createNew() : setlist = null, createNew = true;

  final Setlist? setlist;
  final bool createNew;
}

class _SelectSetlistForPresetSheet extends StatelessWidget {
  const _SelectSetlistForPresetSheet({
    required this.presetName,
    required this.setlists,
  });

  final String presetName;
  final List<Setlist> setlists;

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
        key: const Key('select_setlist_for_preset_sheet'),
        top: false,
        child: Padding(
          padding: EdgeInsets.all(context.dimens.spaceLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.selectSetlistForPresetTitle(presetName),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: context.dimens.spaceMd),
              if (setlists.isNotEmpty) ...[
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: setlists.length,
                    separatorBuilder: (_, _) =>
                        SizedBox(height: context.dimens.spaceSm),
                    itemBuilder: (context, index) {
                      final setlist = setlists[index];
                      return M3ECard(
                        key: Key('pick_setlist_option_${setlist.id}'),
                        variant: M3ECardVariant.elevated,
                        borderRadius: BorderRadius.circular(
                          context.dimens.radiusDefault,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: context.dimens.spaceMd,
                          vertical: context.dimens.spaceSmPlus2,
                        ),
                        onPressed: () =>
                            Navigator.of(context)
                                .pop(_SetlistPickResult.existing(setlist)),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    setlist.displayName(l10n),
                                    style: context.textTheme.titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: context.colorScheme.onSurface,
                                        ),
                                  ),
                                  Text(
                                    l10n.songCount(setlist.presetIds.length),
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
                SizedBox(height: context.dimens.spaceMd),
              ],
              M3EButton.tonal(
                key: const Key('pick_setlist_create_new_button'),
                size: M3EButtonSize.md,
                icon: const Icon(Icons.add_rounded, size: 20),
                onPressed: () =>
                    Navigator.of(context)
                        .pop(const _SetlistPickResult.createNew()),
                label: Text(l10n.createNewSetlistOption),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

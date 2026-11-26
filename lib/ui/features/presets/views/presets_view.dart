import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart'
    hide CornerRounding, RoundedPolygon;
import 'package:provider/provider.dart';

import '../../../../domain/models/preset.dart';
import '../../../../domain/models/setlist.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/app_theme.dart';
import '../view_models/presets_view_model.dart';
import 'widgets/preset_editor_sheet.dart';

/// Presets management screen using Material 3 Expressive theming
/// and PRD section 3.7 (FR-PRE-01..05, FR-PRE-10..11, UI-05..06).
class PresetsView extends StatelessWidget {
  const PresetsView({super.key, this.viewModel});

  /// Optional explicit ViewModel for isolated testing; defaults to Provider lookup.
  final PresetsViewModel? viewModel;

  @override
  Widget build(BuildContext context) {
    final explicitViewModel = viewModel;
    if (explicitViewModel != null) {
      return ListenableBuilder(
        listenable: explicitViewModel,
        builder: (context, _) => _PresetsViewBody(viewModel: explicitViewModel),
      );
    }
    return _PresetsViewBody(viewModel: context.watch<PresetsViewModel>());
  }
}

class _PresetsViewBody extends StatefulWidget {
  const _PresetsViewBody({required this.viewModel});

  final PresetsViewModel viewModel;

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

  Future<void> _confirmDeletePreset(Preset preset) async {
    final containingSetlists = widget.viewModel.setlistsContainingPreset(
      preset.id,
    );

    final confirmed = await M3EDialog.show<bool>(
      context,
      dialog: _buildDeletePresetDialog(
        context,
        preset: preset,
        containingSetlists: containingSetlists,
      ),
    );

    if (confirmed == true) {
      await widget.viewModel.deletePreset(preset.id);
    }
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
                        child: Text(l10n.newPresetButton),
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
                            searchQuery: vm.searchQuery,
                            onCreatePreset: _openCreatePresetSheet,
                            onClearSearch: () {
                              _searchController.clear();
                              vm.setSearchQuery('');
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
                            return _PresetCard(
                              preset: preset,
                              isActive: preset.id == activePresetId,
                              onTap: () => vm.loadPreset(preset),
                              onToggleFavorite: () =>
                                  vm.toggleFavorite(preset.id),
                              onEdit: () => _openEditPresetSheet(preset),
                              onDuplicate: () => vm.duplicatePreset(
                                preset.id,
                                duplicatedName: l10n.presetCopyName(
                                  preset.displayName(l10n),
                                ),
                              ),
                              onDelete: () => _confirmDeletePreset(preset),
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
    required this.onTap,
    required this.onToggleFavorite,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
  });

  final Preset preset;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
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
      child: M3ECard(
        key: Key('preset_card_${preset.id}'),
        variant: isActive ? M3ECardVariant.filled : M3ECardVariant.elevated,
        borderRadius: BorderRadius.circular(context.dimens.radiusMd),
        padding: EdgeInsets.all(context.dimens.spaceMd),
        onPressed: onTap,
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
                            Container(
                              key: Key('preset_active_badge_${preset.id}'),
                              padding: EdgeInsets.symmetric(
                                horizontal: context.dimens.spaceSm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: context.colorScheme.primary,
                                borderRadius: BorderRadius.circular(
                                  context.dimens.radiusFull,
                                ),
                              ),
                              child: Text(
                                l10n.activeBadge,
                                style: context.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: context.colorScheme.onPrimary,
                                ),
                              ),
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
                M3EIconButton(
                  key: Key('preset_favorite_button_${preset.id}'),
                  variant: M3EIconButtonVariant.standard,
                  isSelected: preset.isFavorite,
                  tooltip: preset.isFavorite
                      ? l10n.unfavoritePresetTooltip(presetName)
                      : l10n.favoritePresetTooltip(presetName),
                  onPressed: onToggleFavorite,
                  icon: Icon(
                    Icons.star_outline_rounded,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  selectedIcon: Icon(
                    Icons.star_rounded,
                    color: context.colorScheme.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.dimens.spaceSm),
            Wrap(
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
            SizedBox(height: context.dimens.spaceSm),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _ActionIconButton(
                  buttonKey: Key('preset_edit_button_${preset.id}'),
                  icon: Icons.edit_outlined,
                  tooltip: l10n.editPresetTooltip(presetName),
                  onPressed: onEdit,
                ),
                _ActionIconButton(
                  buttonKey: Key('preset_duplicate_button_${preset.id}'),
                  icon: Icons.copy_rounded,
                  tooltip: l10n.duplicatePresetTooltip(presetName),
                  onPressed: onDuplicate,
                ),
                _ActionIconButton(
                  buttonKey: Key('preset_delete_button_${preset.id}'),
                  icon: Icons.delete_outline_rounded,
                  tooltip: l10n.deletePresetTooltip(presetName),
                  isDestructive: true,
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
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

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.buttonKey,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.isDestructive = false,
  });

  final Key buttonKey;
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return M3EIconButton(
      key: buttonKey,
      variant: M3EIconButtonVariant.standard,
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 20,
        color: isDestructive
            ? context.colorScheme.error
            : context.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _EmptyPresetsCard extends StatelessWidget {
  const _EmptyPresetsCard({
    required this.hasAnyPresets,
    required this.searchQuery,
    required this.onCreatePreset,
    required this.onClearSearch,
  });

  final bool hasAnyPresets;
  final String searchQuery;
  final VoidCallback onCreatePreset;
  final VoidCallback onClearSearch;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
            child: Icon(
              hasAnyPresets ? Icons.search_off_rounded : Icons.tune_rounded,
              size: 28,
              color: context.colorScheme.primary,
            ),
          ),
          SizedBox(height: context.dimens.spaceMd),
          Text(
            hasAnyPresets
                ? l10n.noPresetsMatchQuery(searchQuery)
                : l10n.noPresetsSavedTitle,
            textAlign: TextAlign.center,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: context.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: context.dimens.spaceXs),
          Text(
            hasAnyPresets
                ? l10n.noPresetsMatchSubtitle
                : l10n.noPresetsSavedSubtitle,
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
            onPressed: hasAnyPresets ? onClearSearch : onCreatePreset,
            child: Text(
              hasAnyPresets ? l10n.clearSearchButton : l10n.createPresetButton,
            ),
          ),
        ],
      ),
    );
  }
}

M3EDialog _buildDeletePresetDialog(
  BuildContext context, {
  required Preset preset,
  required List<Setlist> containingSetlists,
}) {
  final l10n = context.l10n;
  final presetName = preset.displayName(l10n);
  final setlistNames = containingSetlists
      .map((s) => s.displayName(l10n))
      .join(', ');

  return M3EDialog(
    key: const Key('delete_preset_confirm_dialog'),
    title: l10n.deletePresetDialogTitle,
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.deletePresetDialogMessage(presetName),
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        if (containingSetlists.isNotEmpty) ...[
          SizedBox(height: context.dimens.spaceMd),
          Container(
            key: const Key('delete_preset_setlist_warning'),
            padding: EdgeInsets.all(context.dimens.spaceSmPlus4),
            decoration: BoxDecoration(
              color: context.colorScheme.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(context.dimens.radiusSm),
            ),
            child: Text(
              l10n.deletePresetSetlistWarning(
                containingSetlists.length,
                setlistNames,
              ),
              style: context.textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                color: context.colorScheme.error,
              ),
            ),
          ),
        ],
      ],
    ),
    actions: [
      M3EButton.text(
        key: const Key('cancel_delete_preset_button'),
        onPressed: () => Navigator.of(context).pop(false),
        child: Text(l10n.cancel),
      ),
      M3EButton.filled(
        key: const Key('confirm_delete_preset_button'),
        onPressed: () => Navigator.of(context).pop(true),
        child: Text(l10n.delete),
      ),
    ],
  );
}

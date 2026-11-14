import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../../domain/models/preset.dart';
import '../../../../domain/models/setlist.dart';
import '../../../core/theme/sonic_theme.dart';
import '../view_models/presets_view_model.dart';
import 'widgets/preset_editor_sheet.dart';

/// Presets management screen adhering to "The Sonic Architect" design system
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

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => _DeletePresetConfirmDialog(
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
    final vm = widget.viewModel;
    final allPresets = vm.allPresets;
    final presets = vm.filteredPresets;
    final activePresetId = vm.activePresetId;

    return Scaffold(
      backgroundColor: context.colors.surfaceLowest,
      body: SafeArea(
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
                        'PRESETS',
                        style: context.textTheme.labelMedium?.copyWith(
                          color: context.colors.onSurfacePrimary,
                          letterSpacing: 2.2,
                        ),
                      ),
                      FilledButton.icon(
                        key: const Key('create_preset_button'),
                        onPressed: _openCreatePresetSheet,
                        style: FilledButton.styleFrom(
                          minimumSize: Size(0, context.dimens.minTouchTarget),
                          backgroundColor: context.colors.primaryAccent,
                          foregroundColor: context.colors.onPrimaryAccent,
                          shape: const StadiumBorder(),
                          padding: EdgeInsets.symmetric(
                            horizontal: context.dimens.spaceMd,
                          ),
                        ),
                        icon: const Icon(Icons.add_rounded, size: 20),
                        label: const Text('New Preset'),
                      ),
                    ],
                  ),
                ),

                // Search bar (FR-PRE-05)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.dimens.spaceMd,
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.dimens.spaceMd,
                      vertical: context.dimens.spaceXs,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.surfaceLow,
                      borderRadius: BorderRadius.circular(
                        context.dimens.radiusFull,
                      ),
                      border: Border.all(color: context.colors.ghostBorder),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: context.colors.onSurfaceMuted,
                        ),
                        SizedBox(width: context.dimens.spaceSm),
                        Expanded(
                          child: TextField(
                            key: const Key('presets_search_field'),
                            controller: _searchController,
                            onChanged: vm.setSearchQuery,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colors.onSurfacePrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search presets by name...',
                              hintStyle: context.textTheme.bodyMedium?.copyWith(
                                color: context.colors.onSurfaceMuted,
                              ),
                              isDense: true,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        if (vm.searchQuery.isNotEmpty)
                          IconButton(
                            key: const Key('presets_search_clear_button'),
                            tooltip: 'Clear search',
                            onPressed: () {
                              _searchController.clear();
                              vm.setSearchQuery('');
                            },
                            icon: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: context.colors.onSurfaceMuted,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: context.dimens.spaceSmPlus4),

                // Preset List or Empty State
                Expanded(
                  child: presets.isEmpty
                      ? SingleChildScrollView(
                          padding: EdgeInsets.all(context.dimens.spaceMd),
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
                            context.dimens.spaceLg,
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
                              onDuplicate: () => vm.duplicatePreset(preset.id),
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
    return Semantics(
      button: true,
      selected: isActive,
      label:
          '${preset.name}, ${preset.bpm.value} BPM, ${preset.timeSignature.label}',
      child: Material(
        color: isActive
            ? context.colors.primaryContainer
            : context.colors.surfaceLow,
        borderRadius: BorderRadius.circular(context.dimens.radiusMd),
        child: InkWell(
          key: Key('preset_card_${preset.id}'),
          borderRadius: BorderRadius.circular(context.dimens.radiusMd),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(context.dimens.spaceMd),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.dimens.radiusMd),
              border: Border.all(
                color: isActive
                    ? context.colors.neonGhostBorder
                    : context.colors.ghostBorder,
              ),
            ),
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
                                  preset.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isActive
                                        ? context.colors.onPrimaryContainer
                                        : context.colors.onSurfacePrimary,
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
                                    color: context.colors.primaryAccent,
                                    borderRadius: BorderRadius.circular(
                                      context.dimens.radiusFull,
                                    ),
                                  ),
                                  child: Text(
                                    'ACTIVE',
                                    style: context.textTheme.labelMedium
                                        ?.copyWith(
                                          fontSize: 9,
                                          letterSpacing: 0.8,
                                          color: context.colors.onPrimaryAccent,
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
                                color: isActive
                                    ? context.colors.onPrimaryContainer
                                          .withValues(alpha: 0.8)
                                    : context.colors.onSurfaceMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      key: Key('preset_favorite_button_${preset.id}'),
                      tooltip: preset.isFavorite
                          ? 'Unfavorite ${preset.name}'
                          : 'Favorite ${preset.name}',
                      constraints: BoxConstraints(
                        minWidth: context.dimens.minTouchTarget,
                        minHeight: context.dimens.minTouchTarget,
                      ),
                      onPressed: onToggleFavorite,
                      icon: Icon(
                        preset.isFavorite
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: preset.isFavorite
                            ? context.colors.primaryAccent
                            : context.colors.onSurfaceMuted,
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
                      label:
                          '${preset.bpm.value} BPM · ${preset.bpm.tempoMarking.label}',
                      isActive: isActive,
                    ),
                    _ParameterBadge(
                      label: preset.timeSignature.label,
                      isActive: isActive,
                    ),
                    _ParameterBadge(
                      label:
                          '${preset.subdivision.symbol} ${preset.subdivision.label}',
                      isActive: isActive,
                    ),
                    _ParameterBadge(
                      label: preset.isAccentEnabled
                          ? 'Accent ON'
                          : 'Accent OFF',
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
                      tooltip: 'Edit ${preset.name}',
                      onPressed: onEdit,
                    ),
                    _ActionIconButton(
                      buttonKey: Key('preset_duplicate_button_${preset.id}'),
                      icon: Icons.copy_rounded,
                      tooltip: 'Duplicate ${preset.name}',
                      onPressed: onDuplicate,
                    ),
                    _ActionIconButton(
                      buttonKey: Key('preset_delete_button_${preset.id}'),
                      icon: Icons.delete_outline_rounded,
                      tooltip: 'Delete ${preset.name}',
                      isDestructive: true,
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
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
            ? context.colors.surfaceLow.withValues(alpha: 0.72)
            : context.colors.surfaceHigh,
        borderRadius: BorderRadius.circular(context.dimens.radiusFull),
      ),
      child: Text(
        label,
        style: context.textTheme.labelMedium?.copyWith(
          fontSize: 11,
          letterSpacing: 0.4,
          color: context.colors.onSurfacePrimary,
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
    return IconButton(
      key: buttonKey,
      tooltip: tooltip,
      constraints: BoxConstraints(
        minWidth: context.dimens.minTouchTarget,
        minHeight: context.dimens.minTouchTarget,
      ),
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 20,
        color: isDestructive
            ? context.colors.error
            : context.colors.onSurfaceMuted,
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
    return Container(
      padding: EdgeInsets.all(context.dimens.spaceLg),
      decoration: BoxDecoration(
        color: context.colors.surfaceLow,
        borderRadius: BorderRadius.circular(context.dimens.radiusLg),
        border: Border.all(color: context.colors.ghostBorder),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: context.colors.surfaceHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasAnyPresets ? Icons.search_off_rounded : Icons.tune_rounded,
              size: 28,
              color: context.colors.primaryAccent,
            ),
          ),
          SizedBox(height: context.dimens.spaceMd),
          Text(
            hasAnyPresets
                ? 'No presets match "$searchQuery"'
                : 'No presets saved yet',
            textAlign: TextAlign.center,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: context.colors.onSurfacePrimary,
            ),
          ),
          SizedBox(height: context.dimens.spaceXs),
          Text(
            hasAnyPresets ? 'Try another keyword or clear your search filter.' : 'Save tempo, time signature, subdivision, and rehearsal notes for one-tap recall.',
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceMuted,
            ),
          ),
          SizedBox(height: context.dimens.spaceMd),
          FilledButton(
            key: Key(
              hasAnyPresets
                  ? 'empty_clear_search_button'
                  : 'empty_create_preset_button',
            ),
            style: FilledButton.styleFrom(
              minimumSize: Size(0, context.dimens.minTouchTarget),
              backgroundColor: context.colors.primaryAccent,
              foregroundColor: context.colors.onPrimaryAccent,
              shape: const StadiumBorder(),
            ),
            onPressed: hasAnyPresets ? onClearSearch : onCreatePreset,
            child: Text(hasAnyPresets ? 'Clear Search' : 'Create Preset'),
          ),
        ],
      ),
    );
  }
}

class _DeletePresetConfirmDialog extends StatelessWidget {
  const _DeletePresetConfirmDialog({
    required this.preset,
    required this.containingSetlists,
  });

  final Preset preset;
  final List<Setlist> containingSetlists;

  @override
  Widget build(BuildContext context) {
    final setlistNames = containingSetlists.map((s) => s.name).join(', ');

    return AlertDialog(
      key: const Key('delete_preset_confirm_dialog'),
      backgroundColor: context.colors.surfaceLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.dimens.radiusMd),
      ),
      title: Text(
        'Delete Preset?',
        style: context.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: context.colors.onSurfacePrimary,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Are you sure you want to delete "${preset.name}"? This action cannot be undone.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceMuted,
            ),
          ),
          if (containingSetlists.isNotEmpty) ...[
            SizedBox(height: context.dimens.spaceMd),
            Container(
              key: const Key('delete_preset_setlist_warning'),
              padding: EdgeInsets.all(context.dimens.spaceSmPlus4),
              decoration: BoxDecoration(
                color: context.colors.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(context.dimens.radiusSm),
              ),
              child: Text(
                'Warning: Used in ${containingSetlists.length} '
                '${containingSetlists.length == 1 ? 'setlist' : 'setlists'}: '
                '$setlistNames. Deleting this preset will remove it from those setlists.',
                style: context.textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  color: context.colors.error,
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          key: const Key('cancel_delete_preset_button'),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Cancel',
            style: TextStyle(color: context.colors.onSurfacePrimary),
          ),
        ),
        FilledButton(
          key: const Key('confirm_delete_preset_button'),
          style: FilledButton.styleFrom(
            backgroundColor: context.colors.error,
            foregroundColor: context.colors.surfaceLowest,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

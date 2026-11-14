import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart'
    hide CornerRounding, RoundedPolygon;
import 'package:provider/provider.dart';

import '../../../../domain/models/preset.dart';
import '../../../../domain/models/setlist.dart';
import '../../../core/theme/app_theme.dart';
import '../view_models/setlists_view_model.dart';
import 'widgets/setlist_detail_sheet.dart';
import 'widgets/setlist_name_dialog.dart';

/// Setlists management screen using Material 3 Expressive theming
/// and PRD section 3.7 (FR-PRE-06..09, UI-05..06).
class SetlistsView extends StatelessWidget {
  const SetlistsView({super.key, this.viewModel});

  /// Optional explicit ViewModel for isolated testing; defaults to Provider lookup.
  final SetlistsViewModel? viewModel;

  @override
  Widget build(BuildContext context) {
    final explicitViewModel = viewModel;
    if (explicitViewModel != null) {
      return ListenableBuilder(
        listenable: explicitViewModel,
        builder: (context, _) =>
            _SetlistsViewBody(viewModel: explicitViewModel),
      );
    }
    return _SetlistsViewBody(viewModel: context.watch<SetlistsViewModel>());
  }
}

class _SetlistsViewBody extends StatelessWidget {
  const _SetlistsViewBody({required this.viewModel});

  final SetlistsViewModel viewModel;

  Future<void> _createSetlist(BuildContext context) async {
    final name = await showSetlistNameDialog(
      context,
      title: 'New Setlist',
      confirmLabel: 'Create',
    );
    if (name == null) return;
    final created = await viewModel.createSetlist(name: name);
    if (!context.mounted) return;
    await showSetlistDetailSheet(
      context,
      viewModel: viewModel,
      setlistId: created.id,
    );
  }

  Future<void> _renameSetlist(BuildContext context, Setlist setlist) async {
    final newName = await showSetlistNameDialog(
      context,
      title: 'Rename Setlist',
      confirmLabel: 'Save',
      initialName: setlist.name,
    );
    if (newName == null) return;
    await viewModel.renameSetlist(setlist.id, newName);
  }

  Future<void> _confirmDeleteSetlist(
    BuildContext context,
    Setlist setlist,
  ) async {
    final confirmed = await M3EDialog.show<bool>(
      context,
      dialog: M3EDialog(
        key: const Key('delete_setlist_confirm_dialog'),
        title: 'Delete Setlist?',
        content: Text(
          'Are you sure you want to delete "${setlist.name}"? Your saved presets will remain in your library.',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          M3EButton.text(
            key: const Key('cancel_delete_setlist_button'),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          M3EButton.filled(
            key: const Key('confirm_delete_setlist_button'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await viewModel.deleteSetlist(setlist.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final setlists = viewModel.setlists;
    final activeSetlistId = viewModel.activeSetlistId;

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.dimens.maxContentWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.dimens.spaceMd,
                    context.dimens.spaceSm,
                    context.dimens.spaceMd,
                    context.dimens.spaceSmPlus4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SETLISTS',
                        style: context.textTheme.labelMedium?.copyWith(
                          color: context.colorScheme.onSurface,
                          letterSpacing: 2.2,
                        ),
                      ),
                      M3EButton.filled(
                        key: const Key('create_setlist_button'),
                        size: M3EButtonSize.sm,
                        icon: const Icon(Icons.add_rounded, size: 20),
                        onPressed: () => _createSetlist(context),
                        child: const Text('New Setlist'),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: setlists.isEmpty
                      ? SingleChildScrollView(
                          padding: EdgeInsets.all(context.dimens.spaceMd),
                          child: _EmptySetlistsCard(
                            onCreateSetlist: () => _createSetlist(context),
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.fromLTRB(
                            context.dimens.spaceMd,
                            0,
                            context.dimens.spaceMd,
                            context.dimens.spaceLg,
                          ),
                          itemCount: setlists.length,
                          separatorBuilder: (_, _) =>
                              SizedBox(height: context.dimens.spaceSm),
                          itemBuilder: (context, index) {
                            final setlist = setlists[index];
                            final presets = viewModel.resolvePresetsForSetlist(
                              setlist,
                            );
                            final isActive = setlist.id == activeSetlistId;

                            return _SetlistCard(
                              setlist: setlist,
                              presets: presets,
                              isActive: isActive,
                              onTap: () => showSetlistDetailSheet(
                                context,
                                viewModel: viewModel,
                                setlistId: setlist.id,
                              ),
                              onActivate: () => viewModel.activateSetlist(
                                setlist,
                                initialIndex: 0,
                              ),
                              onRename: () => _renameSetlist(context, setlist),
                              onDelete: () =>
                                  _confirmDeleteSetlist(context, setlist),
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

class _SetlistCard extends StatelessWidget {
  const _SetlistCard({
    required this.setlist,
    required this.presets,
    required this.isActive,
    required this.onTap,
    required this.onActivate,
    required this.onRename,
    required this.onDelete,
  });

  final Setlist setlist;
  final List<Preset> presets;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onActivate;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final previewText = presets.isEmpty
        ? 'Empty setlist — tap to add presets'
        : presets.take(3).map((p) => p.name).join(' · ') +
              (presets.length > 3 ? ' (+${presets.length - 3})' : '');

    return Semantics(
      button: true,
      selected: isActive,
      label: '${setlist.name}, ${presets.length} songs',
      child: M3ECard(
        key: Key('setlist_card_${setlist.id}'),
        variant: isActive ? M3ECardVariant.filled : M3ECardVariant.outlined,
        borderRadius: BorderRadius.circular(context.dimens.radiusMd),
        padding: EdgeInsets.all(context.dimens.spaceMd),
        onPressed: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              setlist.name,
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
                              key: Key('setlist_active_badge_${setlist.id}'),
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
                                'ACTIVE',
                                style: context.textTheme.labelMedium?.copyWith(
                                  fontSize: 9,
                                  letterSpacing: 0.8,
                                  color: context.colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: context.dimens.spaceXs),
                      Text(
                        '${presets.length} ${presets.length == 1 ? 'song' : 'songs'} · $previewText',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: context.dimens.spaceSmPlus2),
            Row(
              children: [
                M3EButton.filled(
                  key: Key('setlist_activate_button_${setlist.id}'),
                  size: M3EButtonSize.sm,
                  icon: const Icon(Icons.playlist_play_rounded, size: 20),
                  onPressed: presets.isEmpty ? null : onActivate,
                  child: const Text('Activate'),
                ),
                const Spacer(),
                M3EIconButton(
                  key: Key('setlist_rename_button_${setlist.id}'),
                  variant: M3EIconButtonVariant.standard,
                  tooltip: 'Rename ${setlist.name}',
                  onPressed: onRename,
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                M3EIconButton(
                  key: Key('setlist_delete_button_${setlist.id}'),
                  variant: M3EIconButtonVariant.standard,
                  tooltip: 'Delete ${setlist.name}',
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: context.colorScheme.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySetlistsCard extends StatelessWidget {
  const _EmptySetlistsCard({required this.onCreateSetlist});

  final VoidCallback onCreateSetlist;

  @override
  Widget build(BuildContext context) {
    return M3ECard(
      variant: M3ECardVariant.outlined,
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
              Icons.queue_music_rounded,
              size: 28,
              color: context.colorScheme.primary,
            ),
          ),
          SizedBox(height: context.dimens.spaceMd),
          Text(
            'No setlists yet',
            textAlign: TextAlign.center,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: context.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: context.dimens.spaceXs),
          Text(
            'Group your saved presets into ordered gig or rehearsal setlists with seamless bar-synced transitions.',
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: context.dimens.spaceMd),
          M3EButton.filled(
            key: const Key('empty_create_setlist_button'),
            size: M3EButtonSize.md,
            onPressed: onCreateSetlist,
            child: const Text('Create Setlist'),
          ),
        ],
      ),
    );
  }
}

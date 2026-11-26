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
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/list_action_sheet.dart';
import '../../../core/widgets/swipeable_action_card.dart';
import '../view_models/setlists_view_model.dart';
import 'widgets/setlist_detail_sheet.dart';
import 'widgets/setlist_name_dialog.dart';

/// Setlists management screen using Material 3 Expressive theming
/// and PRD section 3.7 (FR-PRE-06..09, UI-05..06).
class SetlistsView extends StatelessWidget {
  const SetlistsView({super.key, this.viewModel, this.onNavigateToMetronome});

  /// Optional explicit ViewModel for isolated testing; defaults to Provider lookup.
  final SetlistsViewModel? viewModel;

  /// Optional callback to jump directly to the Metronome tab from feedback snackbars.
  final VoidCallback? onNavigateToMetronome;

  @override
  Widget build(BuildContext context) {
    final explicitViewModel = viewModel;
    if (explicitViewModel != null) {
      return ListenableBuilder(
        listenable: explicitViewModel,
        builder: (context, _) => _SetlistsViewBody(
          viewModel: explicitViewModel,
          onNavigateToMetronome: onNavigateToMetronome,
        ),
      );
    }
    return _SetlistsViewBody(
      viewModel: context.watch<SetlistsViewModel>(),
      onNavigateToMetronome: onNavigateToMetronome,
    );
  }
}

class _SetlistsViewBody extends StatelessWidget {
  const _SetlistsViewBody({
    required this.viewModel,
    this.onNavigateToMetronome,
  });

  final SetlistsViewModel viewModel;
  final VoidCallback? onNavigateToMetronome;

  Future<void> _createSetlist(BuildContext context) async {
    final l10n = context.l10n;
    final name = await showSetlistNameDialog(
      context,
      title: l10n.newSetlistDialogTitle,
      confirmLabel: l10n.create,
    );
    if (name == null) return;
    final created = await viewModel.createSetlist(name: name);
    if (!context.mounted) return;
    await showSetlistDetailSheet(
      context,
      viewModel: viewModel,
      setlistId: created.id,
      onNavigateToMetronome: onNavigateToMetronome,
    );
  }

  Future<void> _renameSetlist(BuildContext context, Setlist setlist) async {
    final l10n = context.l10n;
    final newName = await showSetlistNameDialog(
      context,
      title: l10n.renameSetlistDialogTitle,
      confirmLabel: l10n.save,
      initialName: setlist.name,
    );
    if (newName == null) return;
    await viewModel.renameSetlist(setlist.id, newName);
  }

  void _activateSetlist(BuildContext context, Setlist setlist) {
    HapticFeedback.selectionClick();
    viewModel.activateSetlist(setlist, initialIndex: 0);
    final l10n = context.l10n;
    showAppSnackbar(
      context,
      message: l10n.setlistActivatedSnackbar(setlist.displayName(l10n)),
      actionLabel: onNavigateToMetronome != null
          ? l10n.goToMetronomeAction
          : null,
      onAction: onNavigateToMetronome,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> _duplicateSetlist(BuildContext context, Setlist setlist) async {
    final l10n = context.l10n;
    final copyName = l10n.setlistCopyName(setlist.displayName(l10n));
    final created = await viewModel.duplicateSetlist(
      setlist.id,
      duplicatedName: copyName,
    );
    if (!context.mounted) return;
    HapticFeedback.selectionClick();
    showAppSnackbar(
      context,
      message: l10n.setlistDuplicatedSnackbar(created.displayName(l10n)),
      actionLabel: l10n.undoAction,
      onAction: () {
        viewModel.deleteSetlist(created.id);
      },
      showCloseButton: true,
    );
  }

  Future<void> _deleteSetlistWithUndo(
    BuildContext context,
    Setlist setlist,
  ) async {
    final l10n = context.l10n;
    final setlistName = setlist.displayName(l10n);
    final wasActive = viewModel.activeSetlistId == setlist.id;
    final previousActiveIndex = viewModel.activeSetlistIndex;

    final record = await viewModel.deleteSetlistWithUndo(setlist.id);
    if (record == null || !context.mounted) return;

    showAppSnackbar(
      context,
      message: l10n.setlistDeletedSnackbar(setlistName),
      actionLabel: l10n.undoAction,
      onAction: () {
        HapticFeedback.selectionClick();
        viewModel.restoreDeletedSetlist(
          record,
          wasActive: wasActive,
          previousActiveIndex: previousActiveIndex,
        );
      },
      showCloseButton: true,
    );
  }

  void _openSetlistActionSheet(
    BuildContext context,
    Setlist setlist,
    List<Preset> presets,
  ) {
    final l10n = context.l10n;
    final setlistName = setlist.displayName(l10n);
    showListItemActionSheet(
      context,
      sheetKey: Key('setlist_action_sheet_${setlist.id}'),
      title: setlistName,
      subtitle: l10n.songCount(presets.length),
      actions: [
        ListActionItem(
          key: Key('setlist_sheet_activate_${setlist.id}'),
          icon: Icons.playlist_play_rounded,
          label: l10n.activateSetlistButton,
          enabled: presets.isNotEmpty,
          onTap: () => _activateSetlist(context, setlist),
        ),
        ListActionItem(
          key: Key('setlist_sheet_open_${setlist.id}'),
          icon: Icons.queue_music_rounded,
          label: l10n.openSetlistAction,
          onTap: () => showSetlistDetailSheet(
            context,
            viewModel: viewModel,
            setlistId: setlist.id,
            onNavigateToMetronome: onNavigateToMetronome,
          ),
        ),
        ListActionItem(
          key: Key('setlist_sheet_rename_${setlist.id}'),
          icon: Icons.edit_outlined,
          label: l10n.renameAction,
          onTap: () => _renameSetlist(context, setlist),
        ),
        ListActionItem(
          key: Key('setlist_sheet_duplicate_${setlist.id}'),
          icon: Icons.copy_rounded,
          label: l10n.duplicateAction,
          onTap: () => _duplicateSetlist(context, setlist),
        ),
        ListActionItem(
          key: Key('setlist_sheet_delete_${setlist.id}'),
          icon: Icons.delete_outline_rounded,
          label: l10n.delete,
          isDestructive: true,
          onTap: () => _deleteSetlistWithUndo(context, setlist),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final setlists = viewModel.setlists;
    final activeSetlistId = viewModel.activeSetlistId;
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
                        l10n.setlistsHeader,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.colorScheme.onSurface,
                        ),
                      ),
                      M3EButton.filled(
                        key: const Key('create_setlist_button'),
                        size: M3EButtonSize.sm,
                        icon: const Icon(Icons.add_rounded, size: 20),
                        onPressed: () => _createSetlist(context),
                        label: Text(l10n.newSetlistButton),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: setlists.isEmpty
                      ? SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            context.dimens.spaceMd,
                            context.dimens.spaceMd,
                            context.dimens.spaceMd,
                            context.dimens.spaceMd + bottomInset,
                          ),
                          child: _EmptySetlistsCard(
                            onCreateSetlist: () => _createSetlist(context),
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.fromLTRB(
                            context.dimens.spaceMd,
                            0,
                            context.dimens.spaceMd,
                            context.dimens.spaceLg + bottomInset,
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

                            return SwipeableActionCard(
                              dismissKey: ValueKey(
                                'setlist_swipe_${setlist.id}',
                              ),
                              borderRadius: context.dimens.radiusMd,
                              startToEndAction: presets.isNotEmpty
                                  ? SwipeActionConfig(
                                      label: l10n.activateSetlistButton,
                                      icon: Icons.playlist_play_rounded,
                                      backgroundColor:
                                          context.colorScheme.primaryContainer,
                                      activeBackgroundColor:
                                          context.colorScheme.primary,
                                      foregroundColor: context
                                          .colorScheme
                                          .onPrimaryContainer,
                                      activeForegroundColor:
                                          context.colorScheme.onPrimary,
                                      dismissOnTrigger: false,
                                      onTrigger: () =>
                                          _activateSetlist(context, setlist),
                                    )
                                  : null,
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
                                onTrigger: () =>
                                    _deleteSetlistWithUndo(context, setlist),
                              ),
                              child: _SetlistCard(
                                setlist: setlist,
                                presets: presets,
                                isActive: isActive,
                                isPlayingListenable:
                                    viewModel.isPlayingListenable,
                                onTap: () => showSetlistDetailSheet(
                                  context,
                                  viewModel: viewModel,
                                  setlistId: setlist.id,
                                  onNavigateToMetronome: onNavigateToMetronome,
                                ),
                                onLongPress: () => _openSetlistActionSheet(
                                  context,
                                  setlist,
                                  presets,
                                ),
                                onActivate: () =>
                                    _activateSetlist(context, setlist),
                                onRename: () =>
                                    _renameSetlist(context, setlist),
                                onDuplicate: () =>
                                    _duplicateSetlist(context, setlist),
                                onDelete: () =>
                                    _deleteSetlistWithUndo(context, setlist),
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

class _SetlistCard extends StatelessWidget {
  const _SetlistCard({
    required this.setlist,
    required this.presets,
    required this.isActive,
    required this.isPlayingListenable,
    required this.onTap,
    required this.onLongPress,
    required this.onActivate,
    required this.onRename,
    required this.onDuplicate,
    required this.onDelete,
  });

  final Setlist setlist;
  final List<Preset> presets;
  final bool isActive;
  final ValueListenable<bool> isPlayingListenable;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onActivate;
  final VoidCallback onRename;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final setlistName = setlist.displayName(l10n);
    final songCountLabel = l10n.songCount(presets.length);
    final previewText = presets.isEmpty
        ? l10n.emptySetlistPreview
        : presets.take(3).map((p) => p.displayName(l10n)).join(' · ') +
              (presets.length > 3 ? ' (+${presets.length - 3})' : '');

    return Semantics(
      button: true,
      selected: isActive,
      label: l10n.setlistCardSemantics(setlistName, songCountLabel),
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
          key: Key('setlist_card_${setlist.id}'),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: context.dimens.spaceXs),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  setlistName,
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
                                  key: Key(
                                    'setlist_active_badge_${setlist.id}',
                                  ),
                                  label: l10n.activeBadge,
                                  isPlayingListenable: isPlayingListenable,
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: context.dimens.spaceXs),
                          Text(
                            l10n.setlistCardSubtitle(
                              songCountLabel,
                              previewText,
                            ),
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
                  ),
                  M3EMenu(
                    position: M3EMenuAnchorPosition.bottomEnd,
                    anchorBuilder: (context, open) => M3EIconButton(
                      key: Key('setlist_menu_button_${setlist.id}'),
                      variant: M3EIconButtonVariant.standard,
                      tooltip: l10n.moreActionsTooltip(setlistName),
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
                        label: l10n.openSetlistAction,
                        leading: const Icon(
                          Icons.queue_music_rounded,
                          size: 20,
                        ),
                        onPressed: onTap,
                      ),
                      M3EMenuEntry(
                        label: l10n.renameAction,
                        leading: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: onRename,
                      ),
                      M3EMenuEntry(
                        label: l10n.duplicateAction,
                        leading: const Icon(Icons.copy_rounded, size: 20),
                        onPressed: onDuplicate,
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
              SizedBox(height: context.dimens.spaceSmPlus4),
              // High-prominence full-width Activate CTA for effortless stage use
              Padding(
                padding: EdgeInsets.only(right: context.dimens.spaceSm),
                child: SizedBox(
                  width: double.infinity,
                  child: M3EButton.filled(
                    key: Key('setlist_activate_button_${setlist.id}'),
                    size: M3EButtonSize.md,
                    icon: Icon(
                      isActive
                          ? Icons.replay_rounded
                          : Icons.playlist_play_rounded,
                      size: 22,
                    ),
                    onPressed: presets.isEmpty ? null : onActivate,
                    label: Text(
                      presets.isEmpty
                          ? l10n.setlistEmptyActionHint
                          : isActive
                          ? l10n.activateSetlistActiveButton
                          : l10n.activateSetlistButton,
                    ),
                  ),
                ),
              ),
            ],
          ),
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
              Icons.queue_music_rounded,
              size: 28,
              color: context.colorScheme.primary,
            ),
          ),
          SizedBox(height: context.dimens.spaceMd),
          Text(
            l10n.noSetlistsTitle,
            textAlign: TextAlign.center,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: context.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: context.dimens.spaceXs),
          Text(
            l10n.noSetlistsSubtitle,
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
            child: Text(l10n.createSetlistButton),
          ),
        ],
      ),
    );
  }
}

import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart'
    hide CornerRounding, RoundedPolygon;

import '../../../../../domain/models/preset.dart';
import '../../../../../domain/models/setlist.dart';
import '../../../../core/theme/app_theme.dart';

/// Stage-friendly stepper bar shown on the main Metronome screen when a
/// [Setlist] is active (FR-PRE-08, FR-PRE-09, UI-02).
class ActiveSetlistStepperBar extends StatelessWidget {
  const ActiveSetlistStepperBar({
    super.key,
    required this.setlist,
    required this.currentPreset,
    required this.positionLabel,
    required this.canStepPrevious,
    required this.canStepNext,
    required this.hasPendingBarTransition,
    this.isCompact = false,
    required this.onPrevious,
    required this.onNext,
    required this.onDeactivate,
  });

  final Setlist setlist;
  final Preset currentPreset;
  final String positionLabel;
  final bool canStepPrevious;
  final bool canStepNext;
  final bool hasPendingBarTransition;
  final bool isCompact;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onDeactivate;

  @override
  Widget build(BuildContext context) {
    final verticalPad = isCompact
        ? context.dimens.spaceSm
        : context.dimens.spaceSmPlus4;

    return M3ECard(
      key: const Key('active_setlist_stepper_bar'),
      variant: M3ECardVariant.outlined,
      padding: EdgeInsets.symmetric(
        horizontal: context.dimens.spaceSmPlus4,
        vertical: verticalPad,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.queue_music_rounded,
                size: 16,
                color: context.colorScheme.primary,
              ),
              SizedBox(width: context.dimens.spaceXs),
              Expanded(
                child: Text(
                  setlist.name.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.labelMedium?.copyWith(
                    fontSize: 10,
                    letterSpacing: 1.2,
                    color: context.colorScheme.primary,
                  ),
                ),
              ),
              if (hasPendingBarTransition) ...[
                Container(
                  key: const Key('setlist_pending_transition_badge'),
                  padding: EdgeInsets.symmetric(
                    horizontal: context.dimens.spaceSm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: context.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(
                      context.dimens.radiusFull,
                    ),
                  ),
                  child: Text(
                    'NEXT BAR',
                    style: context.textTheme.labelMedium?.copyWith(
                      fontSize: 9,
                      letterSpacing: 0.8,
                      color: context.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                SizedBox(width: context.dimens.spaceXs),
              ],
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.dimens.spaceSmPlus2,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(
                    context.dimens.radiusFull,
                  ),
                ),
                child: Text(
                  positionLabel,
                  key: const Key('active_setlist_position_label'),
                  style: context.textTheme.labelMedium?.copyWith(
                    fontSize: 11,
                    letterSpacing: 0.4,
                    color: context.colorScheme.onSurface,
                  ),
                ),
              ),
              SizedBox(width: context.dimens.spaceXs),
              M3EIconButton(
                key: const Key('setlist_deactivate_button'),
                variant: M3EIconButtonVariant.standard,
                size: M3EIconButtonSize.sm,
                tooltip: 'Exit setlist',
                onPressed: onDeactivate,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          SizedBox(height: context.dimens.spaceXs),
          Row(
            children: [
              _StepButton(
                buttonKey: const Key('setlist_prev_button'),
                icon: Icons.skip_previous_rounded,
                semanticLabel: 'Previous song in setlist',
                enabled: canStepPrevious,
                onTap: onPrevious,
              ),
              SizedBox(width: context.dimens.spaceSmPlus2),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currentPreset.name,
                      key: const Key('active_setlist_preset_name'),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                    if (currentPreset.note.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        currentPreset.note,
                        key: const Key('active_setlist_preset_note'),
                        textAlign: TextAlign.center,
                        maxLines: 1,
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
              SizedBox(width: context.dimens.spaceSmPlus2),
              _StepButton(
                buttonKey: const Key('setlist_next_button'),
                icon: Icons.skip_next_rounded,
                semanticLabel: 'Next song in setlist',
                enabled: canStepNext,
                onTap: onNext,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.buttonKey,
    required this.icon,
    required this.semanticLabel,
    required this.enabled,
    required this.onTap,
  });

  final Key buttonKey;
  final IconData icon;
  final String semanticLabel;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return M3EIconButton(
      key: buttonKey,
      variant: M3EIconButtonVariant.tonal,
      size: M3EIconButtonSize.md,
      width: M3EIconButtonWidth.wide,
      shape: M3EIconButtonShapeVariant.round,
      icon: Icon(icon),
      tooltip: semanticLabel,
      semanticLabel: semanticLabel,
      onPressed: enabled ? onTap : null,
    );
  }
}

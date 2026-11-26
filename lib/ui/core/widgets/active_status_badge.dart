import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart'
    hide CornerRounding, RoundedPolygon;

import '../theme/app_theme.dart';

/// Expressive pill badge highlighting the currently active preset or setlist,
/// reacting smoothly when the metronome starts or stops playback.
class ActiveStatusBadge extends StatelessWidget {
  const ActiveStatusBadge({
    super.key,
    required this.label,
    this.isPlayingListenable,
  });

  final String label;
  final ValueListenable<bool>? isPlayingListenable;

  @override
  Widget build(BuildContext context) {
    final listenable = isPlayingListenable;
    if (listenable == null) {
      return _buildPill(context, isPlaying: false);
    }
    return ValueListenableBuilder<bool>(
      valueListenable: listenable,
      builder: (context, isPlaying, _) =>
          _buildPill(context, isPlaying: isPlaying),
    );
  }

  Widget _buildPill(BuildContext context, {required bool isPlaying}) {
    final bgColor = isPlaying
        ? context.colorScheme.tertiary
        : context.colorScheme.primary;
    final fgColor = isPlaying
        ? context.colorScheme.onTertiary
        : context.colorScheme.onPrimary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.symmetric(
        horizontal: context.dimens.spaceSm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(context.dimens.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeIn,
            child: isPlaying
                ? Padding(
                    key: const ValueKey('playing_icon'),
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      Icons.graphic_eq_rounded,
                      size: 12,
                      color: fgColor,
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('idle_icon')),
          ),
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: fgColor,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:material_ui/material_ui.dart';

import '../../../../../domain/models/subdivision.dart';
import '../../../../../domain/models/time_signature.dart';
import '../../../../core/theme/app_theme.dart';

/// Visual pulse indicator displaying one marker per beat of the bar (FR-VIS-01, UI-13).
///
/// Distinguishes the strong beat (Beat 1) by both color and shape/size,
/// highlights medium beats in compound meters (e.g. Beat 4 in 6/8), and
/// shows active subdivision progress.
class BeatIndicatorBar extends StatelessWidget {
  const BeatIndicatorBar({
    super.key,
    required this.timeSignature,
    required this.subdivision,
    required this.isPlaying,
    required this.currentBeat,
    required this.currentSubdivision,
    this.isAccentEnabled = true,
    this.isCompact = false,
  });

  final TimeSignature timeSignature;
  final Subdivision subdivision;
  final bool isPlaying;
  final int currentBeat;
  final int currentSubdivision;
  final bool isAccentEnabled;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final beatCount = timeSignature.numerator;

    return Semantics(
      label: isPlaying
          ? 'Beat ${currentBeat + 1} of $beatCount'
          : 'Pulse indicator stopped, $beatCount beats per bar',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.dimens.spaceMd,
          vertical: isCompact ? context.dimens.spaceSm : context.dimens.spaceMd,
        ),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(context.dimens.radiusMd),
          border: Border.all(color: context.colorScheme.outlineVariant),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(beatCount, (index) {
                final accent = isAccentEnabled
                    ? timeSignature.accentForBeat(index)
                    : BeatAccent.weak;
                final isActive = isPlaying && currentBeat == index;
                final isDownbeat = accent == BeatAccent.strong;
                final isMedium = accent == BeatAccent.medium;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: beatCount > 8 ? 2.0 : context.dimens.spaceXs,
                    ),
                    child: _BeatCapsule(
                      beatNumber: index + 1,
                      isActive: isActive,
                      isDownbeat: isDownbeat,
                      isMedium: isMedium,
                    ),
                  ),
                );
              }),
            ),
            if (subdivision != Subdivision.none) ...[
              SizedBox(height: context.dimens.spaceSm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(subdivision.pulsesPerBeat, (subIndex) {
                  final isSubActive =
                      isPlaying && currentSubdivision == subIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 60),
                    margin: EdgeInsets.symmetric(
                      horizontal: context.dimens.spaceXs,
                    ),
                    width: isSubActive
                        ? context.dimens.subdivisionPulseActiveWidth
                        : context.dimens.subdivisionPulseInactiveWidth,
                    height: context.dimens.subdivisionPulseHeight,
                    decoration: BoxDecoration(
                      color: isSubActive
                          ? context.colorScheme.primary
                          : context.colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(
                        context.dimens.radiusFull,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BeatCapsule extends StatelessWidget {
  const _BeatCapsule({
    required this.beatNumber,
    required this.isActive,
    required this.isDownbeat,
    required this.isMedium,
  });

  final int beatNumber;
  final bool isActive;
  final bool isDownbeat;
  final bool isMedium;

  @override
  Widget build(BuildContext context) {
    final Color fillColor;
    final Color activeLabelColor;
    if (isActive) {
      if (isDownbeat) {
        fillColor = context.colorScheme.primary;
        activeLabelColor = context.colorScheme.onPrimary;
      } else if (isMedium) {
        fillColor = context.colorScheme.tertiary;
        activeLabelColor = context.colorScheme.onTertiary;
      } else {
        fillColor = context.colorScheme.secondary;
        activeLabelColor = context.colorScheme.onSecondary;
      }
    } else {
      fillColor = isDownbeat
          ? context.colorScheme.surfaceContainerHighest
          : context.colorScheme.surfaceContainerHigh;
      activeLabelColor = context.colorScheme.onPrimary;
    }

    // Distinguish Beat 1 by height/shape as well as color (FR-VIS-01, UI-13)
    final double targetHeight = isDownbeat
        ? (isActive
              ? context.dimens.beatCapsuleActiveDownbeat
              : context.dimens.beatCapsuleInactiveDownbeat)
        : (isActive
              ? context.dimens.beatCapsuleActiveRegular
              : context.dimens.beatCapsuleInactiveRegular);

    return SizedBox(
      height: context.dimens.beatPillContainerHeight,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 70),
          curve: Curves.easeOut,
          height: targetHeight,
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(
              isDownbeat ? context.dimens.radiusSm : context.dimens.radiusFull,
            ),
            boxShadow: isActive && isDownbeat
                ? [
                    BoxShadow(
                      color: context.colorScheme.primary.withValues(
                        alpha: 0.28,
                      ),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '$beatNumber',
                  style: context.textTheme.labelMedium?.copyWith(
                    fontSize: 11,
                    letterSpacing: 0,
                    color: isActive
                        ? activeLabelColor
                        : (isDownbeat
                              ? context.colorScheme.onSurface
                              : context.colorScheme.onSurfaceVariant),
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

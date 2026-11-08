import 'package:flutter/material.dart';

import '../../../../../domain/models/subdivision.dart';
import '../../../../../domain/models/time_signature.dart';
import '../../../../core/theme/sonic_theme.dart';

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
    this.isCompact = false,
  });

  final TimeSignature timeSignature;
  final Subdivision subdivision;
  final bool isPlaying;
  final int currentBeat;
  final int currentSubdivision;
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
          horizontal: SonicDimens.spaceMd,
          vertical: isCompact ? SonicDimens.spaceSm : SonicDimens.spaceMd,
        ),
        decoration: BoxDecoration(
          color: SonicColors.surfaceLow,
          borderRadius: BorderRadius.circular(SonicDimens.radiusMd),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(beatCount, (index) {
                final accent = timeSignature.accentForBeat(index);
                final isActive = isPlaying && currentBeat == index;
                final isDownbeat = accent == BeatAccent.strong;
                final isMedium = accent == BeatAccent.medium;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
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
              const SizedBox(height: SonicDimens.spaceSm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(subdivision.pulsesPerBeat, (subIndex) {
                  final isSubActive =
                      isPlaying && currentSubdivision == subIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 60),
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    width: isSubActive ? 14.0 : 8.0,
                    height: 6.0,
                    decoration: BoxDecoration(
                      color: isSubActive
                          ? SonicColors.primaryNeon
                          : SonicColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(
                        SonicDimens.radiusFull,
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
    if (isActive) {
      fillColor = isDownbeat
          ? SonicColors.primaryNeon
          : isMedium
          ? SonicColors.secondaryGreen
          : SonicColors.onSurfacePrimary;
    } else {
      fillColor = isDownbeat
          ? SonicColors.surfaceHighest
          : SonicColors.surfaceHigh;
    }

    // Distinguish Beat 1 by height/shape as well as color (FR-VIS-01, UI-13)
    final double targetHeight = isDownbeat
        ? (isActive ? 38.0 : 32.0)
        : (isActive ? 28.0 : 22.0);

    return SizedBox(
      height: 40.0,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 70),
          curve: Curves.easeOut,
          height: targetHeight,
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(
              isDownbeat ? SonicDimens.radiusSm : SonicDimens.radiusFull,
            ),
            boxShadow: isActive && isDownbeat
                ? const [
                    BoxShadow(
                      color: SonicColors.pulseGlow,
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              '$beatNumber',
              style: SonicTheme.labelMd.copyWith(
                fontSize: 11,
                letterSpacing: 0,
                color: isActive
                    ? SonicColors.primaryContainer
                    : (isDownbeat
                          ? SonicColors.onSurfacePrimary
                          : SonicColors.onSurfaceMuted),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart'
    hide CornerRounding, RoundedPolygon;

import '../../../../../domain/models/bpm.dart';
import '../../../../../domain/models/tempo_marking.dart';
import '../../../../core/theme/app_theme.dart';

/// Hero BPM display with tactile `-`/`+` step buttons and quick-adjust slider
/// (FR-BPM-01..03, FR-AND-01..02).
class BpmControlSection extends StatelessWidget {
  const BpmControlSection({
    super.key,
    required this.bpm,
    required this.tempoMarking,
    required this.isPlaying,
    this.isDownbeatActive = false,
    this.isCompact = false,
    required this.onAdjustBpm,
    required this.onStartHoldAdjust,
    required this.onStopHoldAdjust,
    required this.onSliderChanged,
  });

  final int bpm;
  final TempoMarking tempoMarking;
  final bool isPlaying;
  final bool isDownbeatActive;
  final bool isCompact;
  final ValueChanged<int> onAdjustBpm;
  final ValueChanged<int> onStartHoldAdjust;
  final VoidCallback onStopHoldAdjust;
  final ValueChanged<int> onSliderChanged;

  @override
  Widget build(BuildContext context) {
    final verticalPad = isCompact
        ? context.dimens.spaceSm
        : context.dimens.spaceMd;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.dimens.spaceMd,
        vertical: verticalPad,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tempo marking pill (FR-AND-01)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.dimens.spaceMd,
              vertical: context.dimens.spaceXs,
            ),
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(context.dimens.radiusFull),
            ),
            child: Text(
              tempoMarking.label.toUpperCase(),
              key: const Key('tempo_marking_text'),
              style: context.textTheme.labelMedium?.copyWith(
                color: context.colorScheme.secondary,
              ),
            ),
          ),
          SizedBox(
            height: isCompact ? context.dimens.spaceXs : context.dimens.spaceSm,
          ),
          // Hero BPM value flanked by - and + buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StepperButton(
                buttonKey: const Key('bpm_decrement_button'),
                icon: Icons.remove_rounded,
                semanticLabel: 'Decrease BPM by 1',
                enabled: bpm > Bpm.min,
                onTap: () => onAdjustBpm(-1),
                onHoldStart: () => onStartHoldAdjust(-1),
                onHoldEnd: onStopHoldAdjust,
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Semantics(
                      label: '$bpm beats per minute, ${tempoMarking.label}',
                      child: Text(
                        '$bpm',
                        key: const Key('bpm_value_text'),
                        textAlign: TextAlign.center,
                        style: isCompact
                            ? context.textTheme.displayLarge?.copyWith(
                                fontSize: 52,
                                fontWeight: FontWeight.w700,
                                height: 1.0,
                                color: context.colorScheme.onSurface,
                              )
                            : context.textTheme.displayLarge?.copyWith(
                                fontSize: 64,
                                fontWeight: FontWeight.w700,
                                height: 1.0,
                                color: context.colorScheme.onSurface,
                              ),
                      ),
                    ),
                    Text(
                      'BPM',
                      style: context.textTheme.labelMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              _StepperButton(
                buttonKey: const Key('bpm_increment_button'),
                icon: Icons.add_rounded,
                semanticLabel: 'Increase BPM by 1',
                enabled: bpm < Bpm.max,
                onTap: () => onAdjustBpm(1),
                onHoldStart: () => onStartHoldAdjust(1),
                onHoldEnd: onStopHoldAdjust,
              ),
            ],
          ),
          // Quick-adjust slider covering 30..300 BPM (FR-BPM-03)
          Semantics(
            label: 'BPM quick adjust slider',
            value: '$bpm BPM',
            child: M3ESlider(
              key: const Key('bpm_slider'),
              value: bpm.toDouble(),
              min: Bpm.min.toDouble(),
              max: Bpm.max.toDouble(),
              size: isCompact ? M3ESliderSize.xs : M3ESliderSize.s,
              label: '$bpm',
              onChanged: (value) => onSliderChanged(value.round()),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.dimens.spaceSm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${Bpm.min}',
                  style: context.textTheme.labelMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${Bpm.max}',
                  style: context.textTheme.labelMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.buttonKey,
    required this.icon,
    required this.semanticLabel,
    required this.enabled,
    required this.onTap,
    required this.onHoldStart,
    required this.onHoldEnd,
  });

  final Key buttonKey;
  final IconData icon;
  final String semanticLabel;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback onHoldStart;
  final VoidCallback onHoldEnd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: enabled ? (_) => onHoldStart() : null,
      onLongPressEnd: enabled ? (_) => onHoldEnd() : null,
      onLongPressCancel: enabled ? onHoldEnd : null,
      child: M3EIconButton(
        key: buttonKey,
        variant: M3EIconButtonVariant.tonal,
        size: M3EIconButtonSize.lg,
        shape: M3EIconButtonShapeVariant.round,
        icon: Icon(icon),
        tooltip: semanticLabel,
        semanticLabel: semanticLabel,
        onPressed: enabled ? onTap : null,
      ),
    );
  }
}

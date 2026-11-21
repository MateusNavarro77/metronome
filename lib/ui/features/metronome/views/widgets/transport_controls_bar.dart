import 'package:flutter/services.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart'
    hide CornerRounding, RoundedPolygon;

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_theme.dart';

/// Bottom thumb-zone controls housing the large Tap Tempo button and the
/// primary Play/Stop CTA button (FR-TAP-01, FR-TAP-05, FR-PLY-01..03).
class TransportControlsBar extends StatefulWidget {
  const TransportControlsBar({
    super.key,
    required this.isPlaying,
    required this.isDownbeatActive,
    this.isCompact = false,
    required this.onTogglePlayStop,
    required this.onTapTempo,
  });

  final bool isPlaying;
  final bool isDownbeatActive;
  final bool isCompact;
  final VoidCallback onTogglePlayStop;
  final ValueChanged<Duration?> onTapTempo;

  @override
  State<TransportControlsBar> createState() => _TransportControlsBarState();
}

class _TransportControlsBarState extends State<TransportControlsBar> {
  bool _tapPressed = false;

  void _handleTapDown(PointerDownEvent event) {
    setState(() => _tapPressed = true);
    HapticFeedback.selectionClick();
    // Measure interval at the exact touch event timestamp (FR-TAP-05)
    final timestamp = event.timeStamp == Duration.zero ? null : event.timeStamp;
    widget.onTapTempo(timestamp);
  }

  void _handleTapUp(PointerEvent _) {
    if (_tapPressed) {
      setState(() => _tapPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controlHeight = widget.isCompact
        ? context.dimens.pulseButtonSizeCompact
        : context.dimens.pulseButtonSize;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Large Tap Tempo button (FR-TAP-01, FR-TAP-05, FR-TAP-07)
        Expanded(
          child: Semantics(
            button: true,
            label: l10n.tapTempoSemantics,
            child: Listener(
              key: const Key('tap_tempo_button'),
              behavior: HitTestBehavior.opaque,
              onPointerDown: _handleTapDown,
              onPointerUp: _handleTapUp,
              onPointerCancel: _handleTapUp,
              child: AnimatedContainer(
                duration: M3EMotion.short2,
                curve: M3EMotion.emphasized,
                height: controlHeight,
                decoration: BoxDecoration(
                  color: _tapPressed
                      ? context.colorScheme.primaryContainer
                      : context.colorScheme.surfaceContainerHigh,
                  borderRadius: M3EShapes.radiusMedium,
                  border: Border.all(
                    color: _tapPressed
                        ? context.colorScheme.primary
                        : context.colorScheme.outlineVariant,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.dimens.spaceSmPlus4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.touch_app_rounded,
                            color: _tapPressed
                                ? context.colorScheme.onPrimaryContainer
                                : context.colorScheme.onSurface,
                            size: widget.isCompact ? 24 : 28,
                          ),
                          SizedBox(width: context.dimens.spaceSmPlus2),
                          Text(
                            l10n.tapTempoLabel,
                            style: context.textTheme.labelMedium?.copyWith(
                              fontSize: widget.isCompact ? 13 : 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.8,
                              color: _tapPressed
                                  ? context.colorScheme.onPrimaryContainer
                                  : context.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: context.dimens.spaceMd),
        // Primary Play/Stop CTA button with M3E round -> square shape morphing
        M3EButton.filled(
          key: const Key('play_stop_button'),
          decoration: M3EButtonDecoration(
            backgroundColor: WidgetStatePropertyAll<Color?>(
              context.colorScheme.primary,
            ),
            foregroundColor: WidgetStatePropertyAll<Color?>(
              context.colorScheme.onPrimary,
            ),
          ),
          size: M3EButtonSize.custom(
            width: controlHeight,
            height: controlHeight,
            hPadding: 0,
            iconSize: widget.isCompact ? 42 : 50,
          ),
          shape: M3EButtonShape.round,
          isSelected: widget.isPlaying,
          icon: const Icon(Icons.play_arrow_rounded),
          selectedIcon: const Icon(Icons.stop_rounded),
          semanticLabel: widget.isPlaying
              ? l10n.stopMetronomeSemantics
              : l10n.startMetronomeSemantics,
          onPressed: widget.onTogglePlayStop,
        ),
      ],
    );
  }
}

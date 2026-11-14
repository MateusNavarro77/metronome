import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

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
            label: 'Tap tempo',
            child: Listener(
              key: const Key('tap_tempo_button'),
              behavior: HitTestBehavior.opaque,
              onPointerDown: _handleTapDown,
              onPointerUp: _handleTapUp,
              onPointerCancel: _handleTapUp,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 80),
                height: controlHeight,
                decoration: BoxDecoration(
                  color: _tapPressed
                      ? context.colorScheme.primaryContainer
                      : context.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(context.dimens.radiusMd),
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
                            'TAP TEMPO',
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
        // Primary Circular Play/Stop CTA button
        Semantics(
          button: true,
          label: widget.isPlaying ? 'Stop metronome' : 'Start metronome',
          child: AnimatedScale(
            scale: widget.isPlaying ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 90),
            child: Container(
              width: controlHeight,
              height: controlHeight,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: context.colorScheme.shadow.withValues(
                      alpha: widget.isPlaying ? 0.24 : 0.14,
                    ),
                    blurRadius: widget.isPlaying ? 20.0 : 10.0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                shape: const CircleBorder(),
                color: context.colorScheme.primary,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  key: const Key('play_stop_button'),
                  customBorder: const CircleBorder(),
                  onTap: widget.onTogglePlayStop,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: widget.isPlaying ? 0.0 : 3.0,
                      ),
                      child: Icon(
                        widget.isPlaying
                            ? Icons.stop_rounded
                            : Icons.play_arrow_rounded,
                        size: widget.isCompact ? 42 : 50,
                        color: context.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

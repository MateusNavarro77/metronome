import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/sonic_theme.dart';

/// Bottom thumb-zone controls housing the large Tap Tempo button and the
/// glowing Neon Green Play/Stop "Pulse" CTA button (FR-TAP-01, FR-TAP-05, FR-PLY-01..03).
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Large Tap Tempo pill button (FR-TAP-01, FR-TAP-05, FR-TAP-07)
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
                height: widget.isCompact
                    ? context.dimens.tapTempoHeightCompact
                    : context.dimens.tapTempoHeight,
                decoration: BoxDecoration(
                  color: _tapPressed
                      ? context.colors.primaryContainer
                      : context.colors.surfaceHigh,
                  borderRadius: BorderRadius.circular(
                    context.dimens.radiusFull,
                  ),
                  border: Border.all(
                    color: _tapPressed
                        ? context.colors.primaryAccent
                        : context.colors.ghostBorder,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      color: _tapPressed
                          ? context.colors.primaryAccent
                          : context.colors.onSurfacePrimary,
                      size: 22,
                    ),
                    SizedBox(width: context.dimens.spaceSm),
                    Text(
                      'TAP TEMPO',
                      style: context.textTheme.labelMedium?.copyWith(
                        color: _tapPressed
                            ? context.colors.primaryAccent
                            : context.colors.onSurfacePrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: context.dimens.spaceLg),
        // Primary "Pulse" Play/Stop button (specs/DESIGN_DARK.md, specs/DESIGN_LIGHT.md)
        Semantics(
          button: true,
          label: widget.isPlaying ? 'Stop metronome' : 'Start metronome',
          child: AnimatedScale(
            scale: widget.isPlaying && widget.isDownbeatActive ? 1.06 : 1.0,
            duration: const Duration(milliseconds: 90),
            child: Container(
              height: widget.isCompact
                  ? context.dimens.pulseButtonSizeCompact
                  : context.dimens.pulseButtonSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(context.dimens.radiusFull),
                boxShadow: [
                  BoxShadow(
                    color: widget.isPlaying
                        ? context.colors.pulseGlow
                        : context.colors.pulseGlowIdle,
                    blurRadius: widget.isPlaying ? 32.0 : 18.0,
                    spreadRadius: widget.isPlaying ? 2.0 : 0.0,
                  ),
                ],
              ),
              child: Material(
                color: context.colors.primaryAccent,
                borderRadius: BorderRadius.circular(context.dimens.radiusFull),
                child: InkWell(
                  key: const Key('play_stop_button'),
                  borderRadius: BorderRadius.circular(
                    context.dimens.radiusFull,
                  ),
                  onTap: widget.onTogglePlayStop,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.dimens.spaceLg,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.isPlaying
                              ? Icons.stop_rounded
                              : Icons.play_arrow_rounded,
                          size: 36,
                          color: context.colors.onPrimaryAccent,
                        ),
                        SizedBox(width: context.dimens.spaceXs),
                        Text(
                          widget.isPlaying ? 'STOP' : 'PLAY',
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: context.colors.onPrimaryAccent,
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
      ],
    );
  }
}

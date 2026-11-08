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
                height: widget.isCompact ? 56.0 : 68.0,
                decoration: BoxDecoration(
                  color: _tapPressed
                      ? SonicColors.primaryContainer
                      : SonicColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(SonicDimens.radiusFull),
                  border: Border.all(
                    color: _tapPressed
                        ? SonicColors.primaryNeon
                        : SonicColors.ghostBorder,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      color: _tapPressed
                          ? SonicColors.primaryNeon
                          : SonicColors.onSurfacePrimary,
                      size: 22,
                    ),
                    const SizedBox(width: SonicDimens.spaceSm),
                    Text(
                      'TAP TEMPO',
                      style: SonicTheme.labelMd.copyWith(
                        color: _tapPressed
                            ? SonicColors.primaryNeon
                            : SonicColors.onSurfacePrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: SonicDimens.spaceLg),
        // Primary "Pulse" Play/Stop button (DESIGN.md Section 5, FR-PLY-01..03)
        Semantics(
          button: true,
          label: widget.isPlaying ? 'Stop metronome' : 'Start metronome',
          child: AnimatedScale(
            scale: widget.isPlaying && widget.isDownbeatActive ? 1.06 : 1.0,
            duration: const Duration(milliseconds: 90),
            child: Container(
              height: widget.isCompact ? 72.0 : SonicDimens.pulseButtonSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(SonicDimens.radiusFull),
                boxShadow: [
                  BoxShadow(
                    color: widget.isPlaying
                        ? SonicColors.pulseGlow
                        : const Color(0x3300FF41),
                    blurRadius: widget.isPlaying ? 32.0 : 18.0,
                    spreadRadius: widget.isPlaying ? 2.0 : 0.0,
                  ),
                ],
              ),
              child: Material(
                color: SonicColors.primaryNeon,
                borderRadius: BorderRadius.circular(SonicDimens.radiusFull),
                child: InkWell(
                  key: const Key('play_stop_button'),
                  borderRadius: BorderRadius.circular(SonicDimens.radiusFull),
                  onTap: widget.onTogglePlayStop,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SonicDimens.spaceLg,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.isPlaying
                              ? Icons.stop_rounded
                              : Icons.play_arrow_rounded,
                          size: 36,
                          color: SonicColors.primaryContainer,
                        ),
                        const SizedBox(width: SonicDimens.spaceXs),
                        Text(
                          widget.isPlaying ? 'STOP' : 'PLAY',
                          style: SonicTheme.titleSm.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: SonicColors.primaryContainer,
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metronome/blocs/metronome/metronome_bloc.dart';

class TapBpmFab extends StatefulWidget {
  const TapBpmFab({super.key});

  @override
  State<TapBpmFab> createState() => _TapBpmFabState();
}

class _TapBpmFabState extends State<TapBpmFab> {
  final GlobalKey _fabKey = GlobalKey();

  void _handleTap() {
    // 1. Dispatch BLoC event
    context.read<MetronomeBloc>().add(MetronomeTapped());

    // 2. Play explicit wave animation over the whole screen
    _playWaveAnimation();
  }

  void _playWaveAnimation() {
    final RenderBox? renderBox =
        _fabKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Offset centerPosition =
        renderBox.localToGlobal(renderBox.size.center(Offset.zero));

    final overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        return _WaveOverlayWidget(
          center: centerPosition,
          waveColor: Theme.of(context).colorScheme.primary,
          onComplete: () {
            overlayEntry.remove();
          },
        );
      },
    );

    overlayState.insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FloatingActionButton.large(
      key: _fabKey,
      child: Icon(Icons.touch_app, color: colorScheme.onSurface),
      backgroundColor: colorScheme.onInverseSurface,
      onPressed: _handleTap,
    );
  }
}

class _WaveOverlayWidget extends StatefulWidget {
  final Offset center;
  final Color waveColor;
  final VoidCallback onComplete;

  const _WaveOverlayWidget({
    required this.center,
    required this.waveColor,
    required this.onComplete,
  });

  @override
  State<_WaveOverlayWidget> createState() => _WaveOverlayWidgetState();
}

class _WaveOverlayWidgetState extends State<_WaveOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    // Set maxRadius relative to screen width and height (e.g. 45% of the shortest side)
    // so it explicitly limits the extent of the wave while still drawing over safe areas.
    final maxRadius = screenSize.shortestSide * 0.45;

    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _WavePainter(
                center: widget.center,
                progress: _controller.value,
                maxRadius: maxRadius,
                waveColor: widget.waveColor,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final Offset center;
  final double progress; // 0.0 to 1.0
  final double maxRadius;
  final Color waveColor;

  _WavePainter({
    required this.center,
    required this.progress,
    required this.maxRadius,
    required this.waveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Easing for expansion (starts fast, slows down)
    final double radius = maxRadius * (1 - (1 - progress) * (1 - progress));
    
    // Fade out as it expands
    final double opacity = 1.0 - progress;

    final paint = Paint()
      ..color = waveColor.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0 + (progress * 5.0) // slightly thickens as it expands
      ..isAntiAlias = true;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.center != center ||
        oldDelegate.waveColor != waveColor;
  }
}

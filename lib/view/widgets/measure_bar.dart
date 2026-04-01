import 'package:flutter/material.dart';

/// Beat indicator dots for the current measure.
///
/// Follows DESIGN.md:
/// - Inactive dots: [onSurfaceVariant], circle shape, no border
/// - Active dot: [primary] with neon glow BoxShadow
/// - Animated transitions between beat states
class MeasureBar extends StatelessWidget {
  final int? currentIndex;
  final int notesPerMeasure;
  static const double _dotSize = 14;

  const MeasureBar({
    super.key,
    this.currentIndex,
    required this.notesPerMeasure,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(notesPerMeasure, (index) {
        final isActive = currentIndex != null && currentIndex == index;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            height: isActive ? _dotSize + 2 : _dotSize,
            width: isActive ? _dotSize + 2 : _dotSize,
            decoration: BoxDecoration(
              color:
                  isActive
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
              shape: BoxShape.circle,
              boxShadow:
                  isActive
                      ? [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.6),
                          blurRadius: 14,
                          spreadRadius: 2,
                        ),
                      ]
                      : null,
            ),
          ),
        );
      }),
    );
  }
}

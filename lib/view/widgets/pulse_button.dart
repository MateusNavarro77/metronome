import 'package:flutter/material.dart';

class PulseButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPressed;

  const PulseButton({
    super.key,
    required this.isPlaying,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow:
            isPlaying
                ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.45),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ]
                : null,
      ),
      child: FloatingActionButton.large(
        onPressed: onPressed,
        child:
            isPlaying
                ? const Icon(Icons.pause, size: 64)
                : const Icon(Icons.play_arrow, size: 64),
      ),
    );
  }
}

import 'package:flutter/services.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart'
    hide CornerRounding, RoundedPolygon;

import '../theme/app_theme.dart';

/// Expressive favorite star button with spring-like scale bounce and haptic
/// feedback whenever [isFavorite] changes (via tap or swipe).
class AnimatedFavoriteButton extends StatefulWidget {
  const AnimatedFavoriteButton({
    super.key,
    this.buttonKey,
    required this.isFavorite,
    required this.tooltip,
    required this.onPressed,
  });

  final Key? buttonKey;
  final bool isFavorite;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  State<AnimatedFavoriteButton> createState() => _AnimatedFavoriteButtonState();
}

class _AnimatedFavoriteButtonState extends State<AnimatedFavoriteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.32,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.32,
          end: 0.92,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.92,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant AnimatedFavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: M3EIconButton(
        key: widget.buttonKey,
        variant: M3EIconButtonVariant.standard,
        isSelected: widget.isFavorite,
        tooltip: widget.tooltip,
        onPressed: () {
          HapticFeedback.selectionClick();
          widget.onPressed();
        },
        icon: Icon(
          Icons.star_outline_rounded,
          color: context.colorScheme.onSurfaceVariant,
        ),
        selectedIcon: Icon(
          Icons.star_rounded,
          color: context.colorScheme.primary,
        ),
      ),
    );
  }
}

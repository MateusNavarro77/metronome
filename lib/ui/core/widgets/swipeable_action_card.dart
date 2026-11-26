import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart'
    hide CornerRounding, RoundedPolygon;

import '../theme/app_theme.dart';

/// Configuration for one horizontal swipe direction on [SwipeableActionCard].
class SwipeActionConfig {
  const SwipeActionConfig({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.activeBackgroundColor,
    required this.foregroundColor,
    required this.activeForegroundColor,
    required this.onTrigger,
    this.dismissOnTrigger = false,
    this.semanticsLabel,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color activeBackgroundColor;
  final Color foregroundColor;
  final Color activeForegroundColor;
  final FutureOr<void> Function() onTrigger;

  /// When `false` (default), the card executes [onTrigger] once the threshold
  /// is crossed and springs back cleanly. When `true`, the card dismisses out
  /// of the list before calling [onTrigger].
  final bool dismissOnTrigger;

  final String? semanticsLabel;
}

/// Gmail-style threshold swipe wrapper with expressive icon scale pop and
/// threshold haptic feedback for mobile list cards.
class SwipeableActionCard extends StatefulWidget {
  const SwipeableActionCard({
    super.key,
    required this.dismissKey,
    required this.borderRadius,
    required this.child,
    this.startToEndAction,
    this.endToStartAction,
  });

  final Key dismissKey;
  final double borderRadius;
  final SwipeActionConfig? startToEndAction;
  final SwipeActionConfig? endToStartAction;
  final Widget child;

  @override
  State<SwipeableActionCard> createState() => _SwipeableActionCardState();
}

class _SwipeableActionCardState extends State<SwipeableActionCard> {
  bool _reached = false;
  DismissDirection _activeDirection = DismissDirection.none;

  DismissDirection? get _direction {
    final hasStart = widget.startToEndAction != null;
    final hasEnd = widget.endToStartAction != null;
    if (hasStart && hasEnd) return DismissDirection.horizontal;
    if (hasStart) return DismissDirection.startToEnd;
    if (hasEnd) return DismissDirection.endToStart;
    return null;
  }

  void _handleUpdate(DismissUpdateDetails details) {
    final directionChanged = details.direction != _activeDirection;
    final reachedChanged = details.reached != _reached;
    if (!directionChanged && !reachedChanged) return;

    if (reachedChanged) {
      HapticFeedback.selectionClick();
    }

    setState(() {
      _activeDirection = details.direction;
      _reached = details.reached;
    });
  }

  Future<bool?> _handleConfirmDismiss(DismissDirection direction) async {
    final action = switch (direction) {
      DismissDirection.startToEnd => widget.startToEndAction,
      DismissDirection.endToStart => widget.endToStartAction,
      _ => null,
    };
    if (action == null) return false;

    if (!action.dismissOnTrigger) {
      HapticFeedback.lightImpact();
      await action.onTrigger();
      if (mounted) {
        setState(() {
          _reached = false;
          _activeDirection = DismissDirection.none;
        });
      }
      return false;
    }

    HapticFeedback.mediumImpact();
    return true;
  }

  void _handleDismissed(DismissDirection direction) {
    final action = switch (direction) {
      DismissDirection.startToEnd => widget.startToEndAction,
      DismissDirection.endToStart => widget.endToStartAction,
      _ => null,
    };
    action?.onTrigger();
  }

  @override
  Widget build(BuildContext context) {
    final direction = _direction;
    if (direction == null) {
      return widget.child;
    }

    final radius = BorderRadius.circular(widget.borderRadius);

    return ClipRRect(
      borderRadius: radius,
      child: Dismissible(
        key: widget.dismissKey,
        direction: direction,
        dismissThresholds: const {
          DismissDirection.startToEnd: 0.30,
          DismissDirection.endToStart: 0.35,
        },
        movementDuration: const Duration(milliseconds: 220),
        resizeDuration: const Duration(milliseconds: 200),
        onUpdate: _handleUpdate,
        confirmDismiss: _handleConfirmDismiss,
        onDismissed: _handleDismissed,
        background: widget.startToEndAction != null
            ? _SwipeBackdrop(
                action: widget.startToEndAction!,
                alignment: AlignmentDirectional.centerStart,
                isReached:
                    _reached && _activeDirection == DismissDirection.startToEnd,
              )
            : const SizedBox.shrink(),
        secondaryBackground: widget.endToStartAction != null
            ? _SwipeBackdrop(
                action: widget.endToStartAction!,
                alignment: AlignmentDirectional.centerEnd,
                isReached:
                    _reached && _activeDirection == DismissDirection.endToStart,
              )
            : const SizedBox.shrink(),
        child: widget.child,
      ),
    );
  }
}

class _SwipeBackdrop extends StatelessWidget {
  const _SwipeBackdrop({
    required this.action,
    required this.alignment,
    required this.isReached,
  });

  final SwipeActionConfig action;
  final AlignmentGeometry alignment;
  final bool isReached;

  @override
  Widget build(BuildContext context) {
    final isStart = alignment == AlignmentDirectional.centerStart;
    final bgColor = isReached
        ? action.activeBackgroundColor
        : action.backgroundColor;
    final fgColor = isReached
        ? action.activeForegroundColor
        : action.foregroundColor;

    final iconWidget = AnimatedScale(
      scale: isReached ? 1.24 : 0.96,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutBack,
      child: Icon(action.icon, color: fgColor, size: 24),
    );

    final labelWidget = AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 140),
      style: (context.textTheme.labelLarge ?? const TextStyle(fontSize: 13))
          .copyWith(
            color: fgColor,
            fontWeight: isReached ? FontWeight.w700 : FontWeight.w600,
          ),
      child: Text(action.label),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      color: bgColor,
      alignment: alignment,
      padding: EdgeInsets.symmetric(horizontal: context.dimens.spaceLg),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: isStart
            ? [
                iconWidget,
                SizedBox(width: context.dimens.spaceSmPlus2),
                labelWidget,
              ]
            : [
                labelWidget,
                SizedBox(width: context.dimens.spaceSmPlus2),
                iconWidget,
              ],
      ),
    );
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';

/// A glassmorphic bottom-sheet picker for selecting time signatures.
///
/// Follows DESIGN.md rules:
/// - Backdrop blur (16px) with semi-transparent background
/// - No divider lines — spacing only
/// - Selection chips with Ghost Border on active state
/// - xl top border radius
class TimeSignaturePicker extends StatelessWidget {
  final int currentBeatsPerBar;
  final ValueChanged<int> onSelected;

  const TimeSignaturePicker({
    super.key,
    required this.currentBeatsPerBar,
    required this.onSelected,
  });

  static const List<_TimeSignatureOption> _options = [
    _TimeSignatureOption(beatsPerBar: 2, label: '2/4'),
    _TimeSignatureOption(beatsPerBar: 3, label: '3/4'),
    _TimeSignatureOption(beatsPerBar: 4, label: '4/4'),
    _TimeSignatureOption(beatsPerBar: 5, label: '5/4'),
    _TimeSignatureOption(beatsPerBar: 6, label: '6/8'),
    _TimeSignatureOption(beatsPerBar: 7, label: '7/8'),
    _TimeSignatureOption(beatsPerBar: 9, label: '9/8'),
    _TimeSignatureOption(beatsPerBar: 12, label: '12/8'),
  ];

  /// Shows the time signature picker as a modal bottom sheet.
  static Future<int?> show(BuildContext context, int currentBeatsPerBar) {
    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => TimeSignaturePicker(
        currentBeatsPerBar: currentBeatsPerBar,
        onSelected: (value) => Navigator.of(context).pop(value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.85),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Drag Handle ──
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Title ──
                  Text(
                    'TIME SIGNATURE',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 20),

                  // ── Options Grid ──
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: _options.map((option) {
                      final isSelected =
                          option.beatsPerBar == currentBeatsPerBar;
                      return _buildChip(context, option, isSelected);
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(
    BuildContext context,
    _TimeSignatureOption option,
    bool isSelected,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => onSelected(option.beatsPerBar),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 72,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.15)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.6),
                  width: 1.5,
                )
              : Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1,
                ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          option.label,
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
        ),
      ),
    );
  }
}

class _TimeSignatureOption {
  final int beatsPerBar;
  final String label;

  const _TimeSignatureOption({
    required this.beatsPerBar,
    required this.label,
  });
}

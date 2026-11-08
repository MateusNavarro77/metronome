import 'package:flutter/material.dart';

import '../../../../../domain/models/subdivision.dart';
import '../../../../../domain/models/time_signature.dart';
import '../../../../core/theme/sonic_theme.dart';

/// Pill-selector controls for Time Signature (2/4, 3/4, 4/4, 6/8) and
/// Subdivisions (Quarter, Eighths, Triplets, Sixteenths) (FR-CMP-01, FR-SUB-01, FR-SUB-04).
class MeterAndSubdivisionSection extends StatelessWidget {
  const MeterAndSubdivisionSection({
    super.key,
    required this.selectedTimeSignature,
    required this.selectedSubdivision,
    this.isCompact = false,
    required this.onTimeSignatureSelected,
    required this.onSubdivisionSelected,
  });

  final TimeSignature selectedTimeSignature;
  final Subdivision selectedSubdivision;
  final bool isCompact;
  final ValueChanged<TimeSignature> onTimeSignatureSelected;
  final ValueChanged<Subdivision> onSubdivisionSelected;

  @override
  Widget build(BuildContext context) {
    final cardPadding = isCompact ? SonicDimens.spaceSm + 2 : SonicDimens.spaceMd;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Time Signature selector plate
        Container(
          padding: EdgeInsets.all(cardPadding),
          decoration: BoxDecoration(
            color: SonicColors.surfaceLow,
            borderRadius: BorderRadius.circular(SonicDimens.radiusMd),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TIME SIGNATURE', style: SonicTheme.labelMd),
              const SizedBox(height: SonicDimens.spaceXs + 2),
              Row(
                children: TimeSignature.presets.map((signature) {
                  final isSelected = signature == selectedTimeSignature;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: _SelectionPill(
                        pillKey: Key('time_sig_${signature.label}'),
                        label: signature.label,
                        semanticLabel: 'Time signature ${signature.label}',
                        isSelected: isSelected,
                        onTap: () => onTimeSignatureSelected(signature),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        SizedBox(height: isCompact ? SonicDimens.spaceXs + 2 : SonicDimens.spaceSm),
        // Subdivision selector plate
        Container(
          padding: EdgeInsets.all(cardPadding),
          decoration: BoxDecoration(
            color: SonicColors.surfaceLow,
            borderRadius: BorderRadius.circular(SonicDimens.radiusMd),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('SUBDIVISIONS', style: SonicTheme.labelMd),
                  Text(
                    '${selectedSubdivision.symbol} ${selectedSubdivision.label}',
                    key: const Key('active_subdivision_label'),
                    style: SonicTheme.bodyMd.copyWith(
                      color: SonicColors.secondaryGreen,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SonicDimens.spaceXs + 2),
              Row(
                children: Subdivision.values.map((subdivision) {
                  final isSelected = subdivision == selectedSubdivision;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: _SelectionPill(
                        pillKey: Key('subdivision_${subdivision.name}'),
                        label: '${subdivision.symbol} ${subdivision.shortLabel}',
                        semanticLabel:
                            'Subdivision ${subdivision.label} (${subdivision.pulsesPerBeat} per beat)',
                        isSelected: isSelected,
                        onTap: () => onSubdivisionSelected(subdivision),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SelectionPill extends StatelessWidget {
  const _SelectionPill({
    required this.pillKey,
    required this.label,
    required this.semanticLabel,
    required this.isSelected,
    required this.onTap,
  });

  final Key pillKey;
  final String label;
  final String semanticLabel;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: semanticLabel,
      child: Material(
        color: isSelected
            ? SonicColors.primaryContainer
            : SonicColors.surfaceHigh,
        borderRadius: BorderRadius.circular(SonicDimens.radiusFull),
        child: InkWell(
          key: pillKey,
          borderRadius: BorderRadius.circular(SonicDimens.radiusFull),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(
              minHeight: SonicDimens.minTouchTarget,
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SonicDimens.radiusFull),
              border: Border.all(
                color: isSelected
                    ? SonicColors.neonGhostBorder
                    : SonicColors.ghostBorder,
              ),
            ),
            child: Text(
              label,
              style: SonicTheme.titleSm.copyWith(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? SonicColors.primaryNeon
                    : SonicColors.onSurfaceMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

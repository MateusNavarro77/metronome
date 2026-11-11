import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../../domain/models/subdivision.dart';
import '../../../../../domain/models/time_signature.dart';
import '../../../../core/theme/sonic_theme.dart';

/// Compact horizontal bar containing the Time Signature modal trigger,
/// Subdivision modal trigger, and dedicated Accent toggle button
/// (FR-CMP-01, FR-CMP-03, FR-SUB-01, FR-SUB-04, UI-01).
class MeterAndSubdivisionSection extends StatelessWidget {
  const MeterAndSubdivisionSection({
    super.key,
    required this.selectedTimeSignature,
    required this.selectedSubdivision,
    this.isAccentEnabled = true,
    this.isCompact = false,
    required this.onTimeSignatureSelected,
    required this.onSubdivisionSelected,
    this.onToggleAccent,
  });

  final TimeSignature selectedTimeSignature;
  final Subdivision selectedSubdivision;
  final bool isAccentEnabled;
  final bool isCompact;
  final ValueChanged<TimeSignature> onTimeSignatureSelected;
  final ValueChanged<Subdivision> onSubdivisionSelected;
  final VoidCallback? onToggleAccent;

  void _openTimeSignatureSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => TimeSignatureBottomSheet(
        initialTimeSignature: selectedTimeSignature,
        onTimeSignatureSelected: onTimeSignatureSelected,
      ),
    );
  }

  void _openSubdivisionSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SubdivisionBottomSheet(
        selectedSubdivision: selectedSubdivision,
        onSubdivisionSelected: onSubdivisionSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final verticalPadding = isCompact
        ? context.dimens.spaceSm
        : context.dimens.spaceSmPlus4;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Time Signature trigger card
          Expanded(
            child: _SummaryTriggerCard(
              cardKey: const Key('time_signature_selector_button'),
              caption: 'TIME SIG',
              semanticLabel:
                  'Time signature ${selectedTimeSignature.label}. Tap to change.',
              verticalPadding: verticalPadding,
              onTap: () => _openTimeSignatureSheet(context),
              valueWidget: Text(
                selectedTimeSignature.label,
                key: const Key('active_time_signature_label'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.titleSmall?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: context.colors.onSurfacePrimary,
                ),
              ),
            ),
          ),
          SizedBox(width: context.dimens.spaceSm),
          // 2. Subdivision trigger card
          Expanded(
            child: _SummaryTriggerCard(
              cardKey: const Key('subdivision_selector_button'),
              caption: 'SUBDIVISION',
              semanticLabel:
                  'Subdivision ${selectedSubdivision.label}. Tap to change.',
              verticalPadding: verticalPadding,
              onTap: () => _openSubdivisionSheet(context),
              valueWidget: Text(
                '${selectedSubdivision.symbol} ${selectedSubdivision.label}',
                key: const Key('active_subdivision_label'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.titleSmall?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: context.colors.secondaryAccent,
                ),
              ),
            ),
          ),
          if (onToggleAccent != null) ...[
            SizedBox(width: context.dimens.spaceSm),
            // 3. Dedicated Accent toggle button
            _AccentToggleCard(
              isAccentEnabled: isAccentEnabled,
              verticalPadding: verticalPadding,
              onToggle: onToggleAccent!,
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryTriggerCard extends StatelessWidget {
  const _SummaryTriggerCard({
    required this.cardKey,
    required this.caption,
    required this.semanticLabel,
    required this.verticalPadding,
    required this.onTap,
    required this.valueWidget,
  });

  final Key cardKey;
  final String caption;
  final String semanticLabel;
  final double verticalPadding;
  final VoidCallback onTap;
  final Widget valueWidget;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: context.colors.surfaceLow,
        borderRadius: BorderRadius.circular(context.dimens.radiusMd),
        child: InkWell(
          key: cardKey,
          borderRadius: BorderRadius.circular(context.dimens.radiusMd),
          onTap: onTap,
          child: Container(
            constraints: BoxConstraints(
              minHeight: context.dimens.minTouchTarget,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: context.dimens.spaceSmPlus4,
              vertical: verticalPadding,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.dimens.radiusMd),
              border: Border.all(color: context.colors.ghostBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.labelMedium?.copyWith(
                          fontSize: 10,
                          letterSpacing: 1.1,
                          color: context.colors.onSurfaceMuted,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: context.colors.onSurfaceMuted,
                    ),
                  ],
                ),
                SizedBox(height: context.dimens.spaceXs),
                valueWidget,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccentToggleCard extends StatelessWidget {
  const _AccentToggleCard({
    required this.isAccentEnabled,
    this.verticalPadding = 0,
    required this.onToggle,
  });

  final bool isAccentEnabled;
  final double verticalPadding;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: isAccentEnabled,
      label: isAccentEnabled
          ? 'Accent on Beat 1 enabled'
          : 'Accent on Beat 1 disabled',
      child: Center(
        child: IconButton(
          // Set the desired size
          constraints: BoxConstraints(
            maxWidth: context.dimens.stepperButtonSize,
            minWidth: context.dimens.stepperButtonSize,
            maxHeight: context.dimens.stepperButtonSize,
            minHeight: context.dimens.stepperButtonSize,
          ),
          iconSize: context.dimens.stepperButtonSize,
          key: const Key('accent_toggle_button'),
          tooltip: isAccentEnabled
              ? 'Downbeat accent ON'
              : 'Downbeat accent OFF',
          isSelected: isAccentEnabled,
          onPressed: onToggle,
          style: IconButton.styleFrom(
            backgroundColor: isAccentEnabled
                ? context.colors.primaryContainer
                : context.colors.surfaceLow,
            foregroundColor: isAccentEnabled
                ? context.colors.primaryAccent
                : context.colors.onSurfaceMuted,
            side: BorderSide(
              color: isAccentEnabled
                  ? context.colors.neonGhostBorder
                  : context.colors.ghostBorder,
            ),
            shape: const CircleBorder(),
          ),
          icon: Icon(
            size: context.dimens.stepperIconSize,
            isAccentEnabled
                ? Icons.volume_up_rounded
                : Icons.volume_mute_rounded,
          ),
        ),
      ),
    );
  }
}

/// Modal bottom sheet for selecting preset or custom Time Signatures
/// (FR-CMP-01, FR-CMP-03).
class TimeSignatureBottomSheet extends StatefulWidget {
  const TimeSignatureBottomSheet({
    super.key,
    required this.initialTimeSignature,
    required this.onTimeSignatureSelected,
  });

  final TimeSignature initialTimeSignature;
  final ValueChanged<TimeSignature> onTimeSignatureSelected;

  @override
  State<TimeSignatureBottomSheet> createState() =>
      _TimeSignatureBottomSheetState();
}

class _TimeSignatureBottomSheetState extends State<TimeSignatureBottomSheet> {
  static const List<int> _validDenominators = [2, 4, 8, 16];

  late TimeSignature _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialTimeSignature;
  }

  void _selectPreset(TimeSignature preset) {
    setState(() {
      _current = preset;
    });
    widget.onTimeSignatureSelected(preset);
    Navigator.of(context).pop();
  }

  void _updateCustom({int? numerator, int? denominator}) {
    final nextNumerator = (numerator ?? _current.numerator).clamp(1, 16);
    final nextDenominator = denominator ?? _current.denominator;
    final nextSig = TimeSignature(nextNumerator, nextDenominator);
    if (nextSig == _current) return;
    setState(() {
      _current = nextSig;
    });
    widget.onTimeSignatureSelected(nextSig);
  }

  @override
  Widget build(BuildContext context) {
    return _SonicModalSheetContainer(
      key: const Key('time_signature_bottom_sheet'),
      title: 'TIME SIGNATURE',
      trailing: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.dimens.spaceSmPlus4,
          vertical: context.dimens.spaceXs,
        ),
        decoration: BoxDecoration(
          color: context.colors.primaryContainer,
          borderRadius: BorderRadius.circular(context.dimens.radiusFull),
          border: Border.all(color: context.colors.neonGhostBorder),
        ),
        child: Text(
          _current.label,
          style: context.textTheme.titleSmall?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: context.colors.primaryAccent,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'PRESETS',
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colors.onSurfaceMuted,
            ),
          ),
          SizedBox(height: context.dimens.spaceSm),
          Row(
            children: TimeSignature.presets.map((signature) {
              final isSelected = signature == _current;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.dimens.spaceXs,
                  ),
                  child: _SelectionPill(
                    pillKey: Key('time_sig_${signature.label}'),
                    label: signature.label,
                    semanticLabel: 'Time signature ${signature.label}',
                    isSelected: isSelected,
                    onTap: () => _selectPreset(signature),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: context.dimens.spaceLg),
          Text(
            'CUSTOM METER',
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colors.onSurfaceMuted,
            ),
          ),
          SizedBox(height: context.dimens.spaceSm),
          // Beats per bar (Numerator 1..16) stepper
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.dimens.spaceMd,
              vertical: context.dimens.spaceSmPlus2,
            ),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainer,
              borderRadius: BorderRadius.circular(context.dimens.radiusDefault),
              border: Border.all(color: context.colors.ghostBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BEATS PER BAR',
                      style: context.textTheme.labelMedium?.copyWith(
                        fontSize: 11,
                        color: context.colors.onSurfaceMuted,
                      ),
                    ),
                    SizedBox(height: context.dimens.spaceXs),
                    Text(
                      'Numerator (1–16)',
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: context.colors.onSurfaceMuted,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ModalStepperButton(
                      buttonKey: const Key('custom_numerator_decrement'),
                      icon: Icons.remove_rounded,
                      semanticLabel: 'Decrease beats per bar',
                      enabled: _current.numerator > 1,
                      onTap: () =>
                          _updateCustom(numerator: _current.numerator - 1),
                    ),
                    Container(
                      constraints: const BoxConstraints(minWidth: 48),
                      alignment: Alignment.center,
                      child: Text(
                        '${_current.numerator}',
                        key: const Key('custom_numerator_value'),
                        style: context.textTheme.headlineMedium?.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: context.colors.onSurfacePrimary,
                        ),
                      ),
                    ),
                    _ModalStepperButton(
                      buttonKey: const Key('custom_numerator_increment'),
                      icon: Icons.add_rounded,
                      semanticLabel: 'Increase beats per bar',
                      enabled: _current.numerator < 16,
                      onTap: () =>
                          _updateCustom(numerator: _current.numerator + 1),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: context.dimens.spaceSmPlus4),
          // Note value (Denominator 2, 4, 8, 16) pill selector
          Container(
            padding: EdgeInsets.all(context.dimens.spaceMd),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainer,
              borderRadius: BorderRadius.circular(context.dimens.radiusDefault),
              border: Border.all(color: context.colors.ghostBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NOTE VALUE (DENOMINATOR)',
                  style: context.textTheme.labelMedium?.copyWith(
                    fontSize: 11,
                    color: context.colors.onSurfaceMuted,
                  ),
                ),
                SizedBox(height: context.dimens.spaceSm),
                Row(
                  children: _validDenominators.map((denom) {
                    final isSelected = _current.denominator == denom;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.dimens.spaceXs,
                        ),
                        child: _SelectionPill(
                          pillKey: Key('custom_denominator_$denom'),
                          label: '/$denom',
                          semanticLabel: 'Denominator $denom',
                          isSelected: isSelected,
                          onTap: () => _updateCustom(denominator: denom),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Modal bottom sheet for selecting beat subdivisions (FR-SUB-01, FR-SUB-04).
class SubdivisionBottomSheet extends StatelessWidget {
  const SubdivisionBottomSheet({
    super.key,
    required this.selectedSubdivision,
    required this.onSubdivisionSelected,
  });

  final Subdivision selectedSubdivision;
  final ValueChanged<Subdivision> onSubdivisionSelected;

  @override
  Widget build(BuildContext context) {
    return _SonicModalSheetContainer(
      key: const Key('subdivision_bottom_sheet'),
      title: 'SUBDIVISIONS',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: Subdivision.values.map((subdivision) {
          final isSelected = subdivision == selectedSubdivision;
          return Padding(
            padding: EdgeInsets.only(bottom: context.dimens.spaceSm),
            child: Semantics(
              button: true,
              selected: isSelected,
              label:
                  'Subdivision ${subdivision.label} (${subdivision.pulsesPerBeat} per beat)',
              child: Material(
                color: isSelected
                    ? context.colors.primaryContainer
                    : context.colors.surfaceHigh,
                borderRadius: BorderRadius.circular(
                  context.dimens.radiusDefault,
                ),
                child: InkWell(
                  key: Key('subdivision_${subdivision.name}'),
                  borderRadius: BorderRadius.circular(
                    context.dimens.radiusDefault,
                  ),
                  onTap: () {
                    onSubdivisionSelected(subdivision);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: context.dimens.minTouchTarget + 8,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: context.dimens.spaceMd,
                      vertical: context.dimens.spaceSmPlus4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        context.dimens.radiusDefault,
                      ),
                      border: Border.all(
                        color: isSelected
                            ? context.colors.neonGhostBorder
                            : context.colors.ghostBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? context.colors.surfaceLow.withValues(
                                    alpha: 0.35,
                                  )
                                : context.colors.surfaceHighest,
                            borderRadius: BorderRadius.circular(
                              context.dimens.radiusSm,
                            ),
                          ),
                          child: Text(
                            subdivision.symbol,
                            style: context.textTheme.titleSmall?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? context.colors.primaryAccent
                                  : context.colors.onSurfacePrimary,
                            ),
                          ),
                        ),
                        SizedBox(width: context.dimens.spaceMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subdivision.label,
                                style: context.textTheme.titleSmall?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? context.colors.primaryAccent
                                      : context.colors.onSurfacePrimary,
                                ),
                              ),
                              Text(
                                '${subdivision.pulsesPerBeat} '
                                '${subdivision.pulsesPerBeat == 1 ? 'pulse' : 'pulses'} per beat',
                                style: context.textTheme.bodyMedium?.copyWith(
                                  fontSize: 12,
                                  color: context.colors.onSurfaceMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.dimens.spaceSmPlus2,
                            vertical: context.dimens.spaceXs,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? context.colors.primaryAccent
                                : context.colors.surfaceHighest,
                            borderRadius: BorderRadius.circular(
                              context.dimens.radiusFull,
                            ),
                          ),
                          child: Text(
                            subdivision.shortLabel,
                            style: context.textTheme.labelMedium?.copyWith(
                              letterSpacing: 0.5,
                              color: isSelected
                                  ? context.colors.onPrimaryAccent
                                  : context.colors.onSurfaceMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SonicModalSheetContainer extends StatelessWidget {
  const _SonicModalSheetContainer({
    super.key,
    required this.title,
    this.trailing,
    required this.child,
  });

  final String title;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(context.dimens.radiusLg),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          constraints: BoxConstraints(maxWidth: context.dimens.maxContentWidth),
          decoration: BoxDecoration(
            color: context.colors.surfaceLow.withValues(alpha: 0.92),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(context.dimens.radiusLg),
            ),
            border: Border(top: BorderSide(color: context.colors.ghostBorder)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                context.dimens.spaceLg,
                context.dimens.spaceSmPlus4,
                context.dimens.spaceLg,
                context.dimens.spaceLg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.colors.surfaceHighest,
                        borderRadius: BorderRadius.circular(
                          context.dimens.radiusFull,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: context.dimens.spaceMd),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: context.textTheme.titleSmall?.copyWith(
                          letterSpacing: 1.6,
                          fontWeight: FontWeight.w700,
                          color: context.colors.onSurfacePrimary,
                        ),
                      ),
                      ?trailing,
                    ],
                  ),
                  SizedBox(height: context.dimens.spaceMd),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModalStepperButton extends StatelessWidget {
  const _ModalStepperButton({
    required this.buttonKey,
    required this.icon,
    required this.semanticLabel,
    required this.enabled,
    required this.onTap,
  });

  final Key buttonKey;
  final IconData icon;
  final String semanticLabel;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      child: Material(
        color: enabled ? context.colors.surfaceHigh : context.colors.surfaceLow,
        shape: const CircleBorder(),
        child: InkWell(
          key: buttonKey,
          customBorder: const CircleBorder(),
          onTap: enabled ? onTap : null,
          child: SizedBox(
            width: context.dimens.minTouchTarget,
            height: context.dimens.minTouchTarget,
            child: Icon(
              icon,
              size: 22,
              color: enabled
                  ? context.colors.onSurfacePrimary
                  : context.colors.onSurfaceMuted.withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
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
            ? context.colors.primaryContainer
            : context.colors.surfaceHigh,
        borderRadius: BorderRadius.circular(context.dimens.radiusFull),
        child: InkWell(
          key: pillKey,
          borderRadius: BorderRadius.circular(context.dimens.radiusFull),
          onTap: onTap,
          child: Container(
            constraints: BoxConstraints(
              minHeight: context.dimens.minTouchTarget,
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.dimens.radiusFull),
              border: Border.all(
                color: isSelected
                    ? context.colors.neonGhostBorder
                    : context.colors.ghostBorder,
              ),
            ),
            child: Text(
              label,
              style: context.textTheme.titleSmall?.copyWith(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? context.colors.primaryAccent
                    : context.colors.onSurfaceMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart'
    hide CornerRounding, RoundedPolygon;

import '../../../../../domain/models/subdivision.dart';
import '../../../../../domain/models/time_signature.dart';
import '../../../../core/theme/app_theme.dart';

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
    M3EBottomSheet.show<void>(
      context,
      showDragHandle: true,
      isDismissible: true,
      initialValue: M3EBottomSheetValue.expanded,
      builder: (_) => TimeSignatureBottomSheet(
        initialTimeSignature: selectedTimeSignature,
        onTimeSignatureSelected: onTimeSignatureSelected,
      ),
    );
  }

  void _openSubdivisionSheet(BuildContext context) {
    M3EBottomSheet.show<void>(
      context,
      showDragHandle: true,
      isDismissible: true,
      initialValue: M3EBottomSheetValue.expanded,
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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
                color: context.colorScheme.onSurface,
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
                color: context.colorScheme.secondary,
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
      child: M3ECard(
        key: cardKey,
        variant: M3ECardVariant.outlined,
        onPressed: onTap,
        padding: EdgeInsets.symmetric(
          horizontal: context.dimens.spaceSmPlus4,
          vertical: verticalPadding,
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
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            SizedBox(height: context.dimens.spaceXs),
            valueWidget,
          ],
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
    return Center(
      child: M3EIconButton(
        key: const Key('accent_toggle_button'),
        variant: isAccentEnabled
            ? M3EIconButtonVariant.tonal
            : M3EIconButtonVariant.outlined,
        size: M3EIconButtonSize.md,
        shape: M3EIconButtonShapeVariant.round,
        isSelected: isAccentEnabled,
        tooltip: isAccentEnabled ? 'Downbeat accent ON' : 'Downbeat accent OFF',
        semanticLabel: isAccentEnabled
            ? 'Accent on Beat 1 enabled'
            : 'Accent on Beat 1 disabled',
        icon: const Icon(Icons.volume_mute_rounded),
        selectedIcon: const Icon(Icons.volume_up_rounded),
        onPressed: onToggle,
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
          color: context.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(context.dimens.radiusFull),
          border: Border.all(
            color: context.colorScheme.primary.withValues(alpha: 0.45),
          ),
        ),
        child: Text(
          _current.label,
          style: context.textTheme.titleSmall?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: context.colorScheme.onPrimaryContainer,
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
              color: context.colorScheme.onSurfaceVariant,
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
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: context.dimens.spaceSm),
          // Beats per bar (Numerator 1..16) stepper
          M3ECard(
            variant: M3ECardVariant.outlined,
            padding: EdgeInsets.symmetric(
              horizontal: context.dimens.spaceMd,
              vertical: context.dimens.spaceSmPlus2,
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
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: context.dimens.spaceXs),
                    Text(
                      'Numerator (1–16)',
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: context.colorScheme.onSurfaceVariant,
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
                          color: context.colorScheme.onSurface,
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
          M3ECard(
            variant: M3ECardVariant.outlined,
            padding: EdgeInsets.all(context.dimens.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NOTE VALUE (DENOMINATOR)',
                  style: context.textTheme.labelMedium?.copyWith(
                    fontSize: 11,
                    color: context.colorScheme.onSurfaceVariant,
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
              child: M3ECard(
                key: Key('subdivision_${subdivision.name}'),
                variant: isSelected
                    ? M3ECardVariant.filled
                    : M3ECardVariant.outlined,
                color: isSelected ? context.colorScheme.primaryContainer : null,
                padding: EdgeInsets.symmetric(
                  horizontal: context.dimens.spaceMd,
                  vertical: context.dimens.spaceSmPlus4,
                ),
                onPressed: () {
                  onSubdivisionSelected(subdivision);
                  Navigator.of(context).pop();
                },
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? context.colorScheme.surfaceContainerLow
                                  .withValues(alpha: 0.45)
                            : context.colorScheme.surfaceContainerHighest,
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
                              ? context.colorScheme.onPrimaryContainer
                              : context.colorScheme.onSurface,
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
                                  ? context.colorScheme.onPrimaryContainer
                                  : context.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            '${subdivision.pulsesPerBeat} '
                            '${subdivision.pulsesPerBeat == 1 ? 'pulse' : 'pulses'} per beat',
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                              color: isSelected
                                  ? context.colorScheme.onPrimaryContainer
                                        .withValues(alpha: 0.8)
                                  : context.colorScheme.onSurfaceVariant,
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
                            ? context.colorScheme.primary
                            : context.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(
                          context.dimens.radiusFull,
                        ),
                      ),
                      child: Text(
                        subdivision.shortLabel,
                        style: context.textTheme.labelMedium?.copyWith(
                          letterSpacing: 0.5,
                          color: isSelected
                              ? context.colorScheme.onPrimary
                              : context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
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
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          context.dimens.spaceLg,
          context.dimens.spaceXs,
          context.dimens.spaceLg,
          context.dimens.spaceLg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: context.textTheme.titleSmall?.copyWith(
                    letterSpacing: 1.6,
                    fontWeight: FontWeight.w700,
                    color: context.colorScheme.onSurface,
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
    return M3EIconButton(
      key: buttonKey,
      variant: M3EIconButtonVariant.tonal,
      size: M3EIconButtonSize.md,
      shape: M3EIconButtonShapeVariant.round,
      icon: Icon(icon),
      tooltip: semanticLabel,
      semanticLabel: semanticLabel,
      onPressed: enabled ? onTap : null,
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
    return M3EButton(
      key: pillKey,
      style: isSelected ? M3EButtonStyle.filled : M3EButtonStyle.tonal,
      size: M3EButtonSize.sm,
      shape: isSelected ? M3EButtonShape.square : M3EButtonShape.round,
      isSelected: isSelected,
      semanticLabel: semanticLabel,
      onPressed: onTap,
      child: Text(label),
    );
  }
}

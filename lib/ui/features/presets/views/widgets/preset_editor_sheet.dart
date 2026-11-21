import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart'
    hide CornerRounding, RoundedPolygon;

import '../../../../../domain/models/bpm.dart';
import '../../../../../domain/models/preset.dart';
import '../../../../../domain/models/subdivision.dart';
import '../../../../../domain/models/time_signature.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_theme.dart';

/// Result returned when the user confirms [PresetEditorSheet].
class PresetEditorResult {
  const PresetEditorResult({
    required this.name,
    required this.note,
    required this.isFavorite,
    required this.bpm,
    required this.timeSignature,
    required this.subdivision,
    required this.isAccentEnabled,
  });

  final String name;
  final String note;
  final bool isFavorite;
  final Bpm bpm;
  final TimeSignature timeSignature;
  final Subdivision subdivision;
  final bool isAccentEnabled;
}

/// Opens [PresetEditorSheet] as a modal bottom sheet and returns the saved
/// [PresetEditorResult], or `null` if dismissed/cancelled.
Future<PresetEditorResult?> showPresetEditorSheet(
  BuildContext context, {
  Preset? existingPreset,
  required Bpm initialBpm,
  required TimeSignature initialTimeSignature,
  required Subdivision initialSubdivision,
  required bool initialAccentEnabled,
}) {
  return M3EBottomSheet.show<PresetEditorResult>(
    context,
    showDragHandle: false,
    isDismissible: true,
    initialValue: M3EBottomSheetValue.expanded,
    builder: (_) => PresetEditorSheet(
      existingPreset: existingPreset,
      initialBpm: existingPreset?.bpm ?? initialBpm,
      initialTimeSignature:
          existingPreset?.timeSignature ?? initialTimeSignature,
      initialSubdivision: existingPreset?.subdivision ?? initialSubdivision,
      initialAccentEnabled:
          existingPreset?.isAccentEnabled ?? initialAccentEnabled,
    ),
  );
}

/// Modal bottom sheet for creating or editing a [Preset]
/// (FR-PRE-01, FR-PRE-03, FR-PRE-11).
class PresetEditorSheet extends StatefulWidget {
  const PresetEditorSheet({
    super.key,
    this.existingPreset,
    required this.initialBpm,
    required this.initialTimeSignature,
    required this.initialSubdivision,
    required this.initialAccentEnabled,
  });

  final Preset? existingPreset;
  final Bpm initialBpm;
  final TimeSignature initialTimeSignature;
  final Subdivision initialSubdivision;
  final bool initialAccentEnabled;

  @override
  State<PresetEditorSheet> createState() => _PresetEditorSheetState();
}

class _PresetEditorSheetState extends State<PresetEditorSheet> {
  static const List<int> _validDenominators = [2, 4, 8, 16];

  late final TextEditingController _nameController;
  late final TextEditingController _noteController;
  late Bpm _bpm;
  late TimeSignature _timeSignature;
  late Subdivision _subdivision;
  late bool _isAccentEnabled;
  late bool _isFavorite;
  String? _nameError;

  bool get _isEditing => widget.existingPreset != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingPreset?.name ?? '',
    );
    _noteController = TextEditingController(
      text: widget.existingPreset?.note ?? '',
    );
    _bpm = widget.initialBpm;
    _timeSignature = widget.initialTimeSignature;
    _subdivision = widget.initialSubdivision;
    _isAccentEnabled = widget.initialAccentEnabled;
    _isFavorite = widget.existingPreset?.isFavorite ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    final trimmedName = _nameController.text.trim();
    if (trimmedName.isEmpty) {
      setState(() {
        _nameError = context.l10n.presetNameRequiredError;
      });
      return;
    }

    Navigator.of(context).pop(
      PresetEditorResult(
        name: trimmedName,
        note: _noteController.text.trim(),
        isFavorite: _isFavorite,
        bpm: _bpm,
        timeSignature: _timeSignature,
        subdivision: _subdivision,
        isAccentEnabled: _isAccentEnabled,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final maxSheetHeight = MediaQuery.sizeOf(context).height * 0.9;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: context.dimens.maxContentWidth,
          maxHeight: maxSheetHeight,
        ),
        child: SafeArea(
          key: const Key('preset_editor_sheet'),
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: context.dimens.spaceSmPlus4,
                  bottom: context.dimens.spaceSm,
                ),
                child: Center(
                  child: Container(
                    key: const Key('preset_editor_drag_handle'),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.4,
                      ),
                      borderRadius: BorderRadius.circular(
                        context.dimens.radiusFull,
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    context.dimens.spaceLg,
                    context.dimens.spaceSm,
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
                            _isEditing
                                ? l10n.editPresetSheetTitle
                                : l10n.newPresetSheetTitle,
                            style: context.textTheme.titleSmall?.copyWith(
                              letterSpacing: 1.6,
                              fontWeight: FontWeight.w700,
                              color: context.colorScheme.onSurface,
                            ),
                          ),
                          M3EIconButton(
                            key: const Key('preset_editor_favorite_toggle'),
                            variant: M3EIconButtonVariant.standard,
                            isSelected: _isFavorite,
                            tooltip: _isFavorite
                                ? l10n.removeFromFavoritesTooltip
                                : l10n.markAsFavoriteTooltip,
                            onPressed: () {
                              setState(() {
                                _isFavorite = !_isFavorite;
                              });
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
                        ],
                      ),
                      SizedBox(height: context.dimens.spaceSm),

                      M3ETextField(
                        key: const Key('preset_name_input'),
                        controller: _nameController,
                        variant: M3ETextFieldVariant.outlined,
                        label: l10n.presetNameLabel,
                        placeholder: l10n.presetNamePlaceholder,
                        errorText: _nameError,
                        textInputAction: TextInputAction.next,
                        onChanged: (_) {
                          if (_nameError != null) {
                            setState(() => _nameError = null);
                          }
                        },
                      ),
                      SizedBox(height: context.dimens.spaceSmPlus4),

                      M3ETextField(
                        key: const Key('preset_note_input'),
                        controller: _noteController,
                        variant: M3ETextFieldVariant.outlined,
                        label: l10n.presetNoteLabel,
                        placeholder: l10n.presetNotePlaceholder,
                        maxLines: 2,
                        textInputAction: TextInputAction.done,
                      ),
                      SizedBox(height: context.dimens.spaceMd),

                      // BPM editor section
                      M3ECard(
                        variant: M3ECardVariant.outlined,
                        padding: EdgeInsets.all(context.dimens.spaceMd),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10n.tempoSectionLabel,
                                  style: context.textTheme.labelMedium
                                      ?.copyWith(
                                        color: context
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                                Text(
                                  _bpm.tempoMarking.label.toUpperCase(),
                                  style: context.textTheme.labelMedium
                                      ?.copyWith(
                                        color: context.colorScheme.secondary,
                                      ),
                                ),
                              ],
                            ),
                            SizedBox(height: context.dimens.spaceSm),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _CircleIconButton(
                                  buttonKey: const Key(
                                    'preset_editor_bpm_decrement',
                                  ),
                                  icon: Icons.remove_rounded,
                                  semanticLabel:
                                      l10n.decreasePresetBpmSemantics,
                                  enabled: _bpm.value > Bpm.min,
                                  onTap: () => setState(() {
                                    _bpm = _bpm.adjust(-1);
                                  }),
                                ),
                                Text(
                                  l10n.bpmWithUnit(_bpm.value),
                                  key: const Key('preset_editor_bpm_value'),
                                  style: context.textTheme.headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: context.colorScheme.onSurface,
                                      ),
                                ),
                                _CircleIconButton(
                                  buttonKey: const Key(
                                    'preset_editor_bpm_increment',
                                  ),
                                  icon: Icons.add_rounded,
                                  semanticLabel:
                                      l10n.increasePresetBpmSemantics,
                                  enabled: _bpm.value < Bpm.max,
                                  onTap: () => setState(() {
                                    _bpm = _bpm.adjust(1);
                                  }),
                                ),
                              ],
                            ),
                            SizedBox(height: context.dimens.spaceXs),
                            M3ESlider(
                              key: const Key('preset_editor_bpm_slider'),
                              value: _bpm.value.toDouble(),
                              min: Bpm.min.toDouble(),
                              max: Bpm.max.toDouble(),
                              divisions: Bpm.max - Bpm.min,
                              size: M3ESliderSize.xs,
                              label: l10n.bpmWithUnit(_bpm.value),
                              onChanged: (value) {
                                setState(() {
                                  _bpm = Bpm.clamped(value.round());
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: context.dimens.spaceSmPlus4),

                      // Time signature section
                      M3ECard(
                        variant: M3ECardVariant.outlined,
                        padding: EdgeInsets.all(context.dimens.spaceMd),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10n.timeSignatureSheetTitle,
                                  style: context.textTheme.labelMedium
                                      ?.copyWith(
                                        color: context
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                                Text(
                                  _timeSignature.label,
                                  key: const Key(
                                    'preset_editor_time_sig_value',
                                  ),
                                  style: context.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: context.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: context.dimens.spaceSm),
                            Row(
                              children: TimeSignature.presets.map((sig) {
                                final selected = sig == _timeSignature;
                                return Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: context.dimens.spaceXs,
                                    ),
                                    child: _SelectChip(
                                      chipKey: Key(
                                        'preset_editor_time_sig_${sig.label}',
                                      ),
                                      label: sig.label,
                                      isSelected: selected,
                                      onTap: () => setState(() {
                                        _timeSignature = sig;
                                      }),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            SizedBox(height: context.dimens.spaceSmPlus2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10n.beatsCountLabel(
                                    _timeSignature.numerator,
                                  ),
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: context.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _CircleIconButton(
                                      buttonKey: const Key(
                                        'preset_editor_numerator_decrement',
                                      ),
                                      icon: Icons.remove_rounded,
                                      semanticLabel:
                                          l10n.decreaseBeatsPerBarSemantics,
                                      enabled: _timeSignature.numerator > 1,
                                      onTap: () => setState(() {
                                        _timeSignature = TimeSignature(
                                          _timeSignature.numerator - 1,
                                          _timeSignature.denominator,
                                        );
                                      }),
                                    ),
                                    SizedBox(width: context.dimens.spaceSm),
                                    _CircleIconButton(
                                      buttonKey: const Key(
                                        'preset_editor_numerator_increment',
                                      ),
                                      icon: Icons.add_rounded,
                                      semanticLabel:
                                          l10n.increaseBeatsPerBarSemantics,
                                      enabled: _timeSignature.numerator < 16,
                                      onTap: () => setState(() {
                                        _timeSignature = TimeSignature(
                                          _timeSignature.numerator + 1,
                                          _timeSignature.denominator,
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: context.dimens.spaceSm),
                            Row(
                              children: _validDenominators.map((denom) {
                                final selected =
                                    _timeSignature.denominator == denom;
                                return Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: context.dimens.spaceXs,
                                    ),
                                    child: _SelectChip(
                                      chipKey: Key(
                                        'preset_editor_denominator_$denom',
                                      ),
                                      label: '/$denom',
                                      isSelected: selected,
                                      onTap: () => setState(() {
                                        _timeSignature = TimeSignature(
                                          _timeSignature.numerator,
                                          denom,
                                        );
                                      }),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: context.dimens.spaceSmPlus4),

                      // Subdivision selector
                      M3ECard(
                        variant: M3ECardVariant.outlined,
                        padding: EdgeInsets.all(context.dimens.spaceMd),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              l10n.subdivisionCaption,
                              style: context.textTheme.labelMedium?.copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(height: context.dimens.spaceSm),
                            Wrap(
                              spacing: context.dimens.spaceSm,
                              runSpacing: context.dimens.spaceSm,
                              children: Subdivision.values.map((sub) {
                                final selected = sub == _subdivision;
                                return _SelectChip(
                                  chipKey: Key(
                                    'preset_editor_subdivision_${sub.name}',
                                  ),
                                  label:
                                      '${sub.symbol} ${sub.localizedLabel(l10n)}',
                                  isSelected: selected,
                                  onTap: () => setState(() {
                                    _subdivision = sub;
                                  }),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: context.dimens.spaceSmPlus4),

                      // Downbeat accent toggle
                      M3ECard(
                        variant: M3ECardVariant.outlined,
                        padding: EdgeInsets.symmetric(
                          horizontal: context.dimens.spaceMd,
                          vertical: context.dimens.spaceSm,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.accentOnBeat1Label,
                              style: context.textTheme.labelMedium?.copyWith(
                                color: context.colorScheme.onSurface,
                              ),
                            ),
                            M3ESwitch(
                              key: const Key('preset_editor_accent_toggle'),
                              value: _isAccentEnabled,
                              selectedIcon: const Icon(Icons.check_rounded),
                              onChanged: (value) {
                                setState(() {
                                  _isAccentEnabled = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: context.dimens.spaceLg),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: M3EButton.outlined(
                              key: const Key('preset_editor_cancel_button'),
                              size: M3EButtonSize.md,
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(l10n.cancel),
                            ),
                          ),
                          SizedBox(width: context.dimens.spaceSmPlus4),
                          Expanded(
                            child: M3EButton.filled(
                              key: const Key('preset_editor_save_button'),
                              size: M3EButtonSize.md,
                              onPressed: _submit,
                              child: Text(
                                _isEditing
                                    ? l10n.saveChangesButton
                                    : l10n.savePresetButton,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
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
      size: M3EIconButtonSize.sm,
      tooltip: semanticLabel,
      onPressed: enabled ? onTap : null,
      icon: Icon(icon, size: 22),
    );
  }
}

class _SelectChip extends StatelessWidget {
  const _SelectChip({
    required this.chipKey,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final Key chipKey;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final content = Text(label, maxLines: 1, overflow: TextOverflow.ellipsis);
    if (isSelected) {
      return M3EButton.filled(
        key: chipKey,
        size: M3EButtonSize.xs,
        onPressed: onTap,
        child: content,
      );
    }
    return M3EButton.tonal(
      key: chipKey,
      size: M3EButtonSize.xs,
      onPressed: onTap,
      child: content,
    );
  }
}

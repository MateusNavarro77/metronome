import 'dart:ui';

import 'package:material_ui/material_ui.dart';

import '../../../../../domain/models/bpm.dart';
import '../../../../../domain/models/preset.dart';
import '../../../../../domain/models/subdivision.dart';
import '../../../../../domain/models/time_signature.dart';
import '../../../../core/theme/sonic_theme.dart';

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
  return showModalBottomSheet<PresetEditorResult>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
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
        _nameError = 'Enter a preset name to save.';
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
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final maxSheetHeight = MediaQuery.sizeOf(context).height * 0.9;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Center(
        heightFactor: 1.0,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.dimens.maxContentWidth,
            maxHeight: maxSheetHeight,
          ),
          child: ClipRRect(
            key: const Key('preset_editor_sheet'),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(context.dimens.radiusLg),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: context.colors.surfaceLow.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(context.dimens.radiusLg),
                  ),
                  border: Border(
                    top: BorderSide(color: context.colors.ghostBorder),
                  ),
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
                              _isEditing ? 'EDIT PRESET' : 'NEW PRESET',
                              style: context.textTheme.titleSmall?.copyWith(
                                letterSpacing: 1.6,
                                fontWeight: FontWeight.w700,
                                color: context.colors.onSurfacePrimary,
                              ),
                            ),
                            IconButton(
                              key: const Key('preset_editor_favorite_toggle'),
                              tooltip: _isFavorite
                                  ? 'Remove from favorites'
                                  : 'Mark as favorite',
                              onPressed: () {
                                setState(() {
                                  _isFavorite = !_isFavorite;
                                });
                              },
                              icon: Icon(
                                _isFavorite
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                color: _isFavorite
                                    ? context.colors.primaryAccent
                                    : context.colors.onSurfaceMuted,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: context.dimens.spaceSm),

                        // Name input (borderless tonal container with neon bottom accent)
                        _TonalTextField(
                          fieldKey: const Key('preset_name_input'),
                          controller: _nameController,
                          label: 'PRESET NAME',
                          hintText: 'e.g. Opening Groove',
                          errorText: _nameError,
                          textInputAction: TextInputAction.next,
                          onChanged: (_) {
                            if (_nameError != null) {
                              setState(() => _nameError = null);
                            }
                          },
                        ),
                        SizedBox(height: context.dimens.spaceSmPlus4),

                        // Optional Note input (FR-PRE-11)
                        _TonalTextField(
                          fieldKey: const Key('preset_note_input'),
                          controller: _noteController,
                          label: 'NOTE (OPTIONAL)',
                          hintText: 'e.g. Count-in at the start',
                          maxLines: 2,
                          textInputAction: TextInputAction.done,
                        ),
                        SizedBox(height: context.dimens.spaceMd),

                        // BPM editor section
                        Container(
                          padding: EdgeInsets.all(context.dimens.spaceMd),
                          decoration: BoxDecoration(
                            color: context.colors.surfaceContainer,
                            borderRadius: BorderRadius.circular(
                              context.dimens.radiusDefault,
                            ),
                            border: Border.all(
                              color: context.colors.ghostBorder,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'TEMPO',
                                    style: context.textTheme.labelMedium
                                        ?.copyWith(
                                          color: context.colors.onSurfaceMuted,
                                        ),
                                  ),
                                  Text(
                                    _bpm.tempoMarking.label.toUpperCase(),
                                    style: context.textTheme.labelMedium
                                        ?.copyWith(
                                          color: context.colors.secondaryAccent,
                                        ),
                                  ),
                                ],
                              ),
                              SizedBox(height: context.dimens.spaceSm),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _CircleIconButton(
                                    buttonKey: const Key(
                                      'preset_editor_bpm_decrement',
                                    ),
                                    icon: Icons.remove_rounded,
                                    semanticLabel: 'Decrease preset BPM',
                                    enabled: _bpm.value > Bpm.min,
                                    onTap: () => setState(() {
                                      _bpm = _bpm.adjust(-1);
                                    }),
                                  ),
                                  Text(
                                    '${_bpm.value} BPM',
                                    key: const Key('preset_editor_bpm_value'),
                                    style: context.textTheme.headlineMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color:
                                              context.colors.onSurfacePrimary,
                                        ),
                                  ),
                                  _CircleIconButton(
                                    buttonKey: const Key(
                                      'preset_editor_bpm_increment',
                                    ),
                                    icon: Icons.add_rounded,
                                    semanticLabel: 'Increase preset BPM',
                                    enabled: _bpm.value < Bpm.max,
                                    onTap: () => setState(() {
                                      _bpm = _bpm.adjust(1);
                                    }),
                                  ),
                                ],
                              ),
                              Slider(
                                key: const Key('preset_editor_bpm_slider'),
                                value: _bpm.value.toDouble(),
                                min: Bpm.min.toDouble(),
                                max: Bpm.max.toDouble(),
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
                        Container(
                          padding: EdgeInsets.all(context.dimens.spaceMd),
                          decoration: BoxDecoration(
                            color: context.colors.surfaceContainer,
                            borderRadius: BorderRadius.circular(
                              context.dimens.radiusDefault,
                            ),
                            border: Border.all(
                              color: context.colors.ghostBorder,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'TIME SIGNATURE',
                                    style: context.textTheme.labelMedium
                                        ?.copyWith(
                                          color: context.colors.onSurfaceMuted,
                                        ),
                                  ),
                                  Text(
                                    _timeSignature.label,
                                    key: const Key(
                                      'preset_editor_time_sig_value',
                                    ),
                                    style: context.textTheme.titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: context.colors.primaryAccent,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Beats: ${_timeSignature.numerator}',
                                    style: context.textTheme.bodyMedium
                                        ?.copyWith(
                                          color: context.colors.onSurfaceMuted,
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
                                        semanticLabel: 'Decrease beats per bar',
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
                                        semanticLabel: 'Increase beats per bar',
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
                        Container(
                          padding: EdgeInsets.all(context.dimens.spaceMd),
                          decoration: BoxDecoration(
                            color: context.colors.surfaceContainer,
                            borderRadius: BorderRadius.circular(
                              context.dimens.radiusDefault,
                            ),
                            border: Border.all(
                              color: context.colors.ghostBorder,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'SUBDIVISION',
                                style: context.textTheme.labelMedium?.copyWith(
                                  color: context.colors.onSurfaceMuted,
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
                                    label: '${sub.symbol} ${sub.label}',
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
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.dimens.spaceMd,
                            vertical: context.dimens.spaceSm,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.surfaceContainer,
                            borderRadius: BorderRadius.circular(
                              context.dimens.radiusDefault,
                            ),
                            border: Border.all(
                              color: context.colors.ghostBorder,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'ACCENT ON BEAT 1',
                                style: context.textTheme.labelMedium?.copyWith(
                                  color: context.colors.onSurfacePrimary,
                                ),
                              ),
                              Switch(
                                key: const Key('preset_editor_accent_toggle'),
                                value: _isAccentEnabled,
                                activeThumbColor: context.colors.primaryAccent,
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
                              child: OutlinedButton(
                                key: const Key('preset_editor_cancel_button'),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: Size(
                                    0,
                                    context.dimens.minTouchTarget,
                                  ),
                                  side: BorderSide(
                                    color: context.colors.ghostBorder,
                                  ),
                                  shape: const StadiumBorder(),
                                  foregroundColor:
                                      context.colors.onSurfacePrimary,
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancel'),
                              ),
                            ),
                            SizedBox(width: context.dimens.spaceSmPlus4),
                            Expanded(
                              child: FilledButton(
                                key: const Key('preset_editor_save_button'),
                                style: FilledButton.styleFrom(
                                  minimumSize: Size(
                                    0,
                                    context.dimens.minTouchTarget,
                                  ),
                                  backgroundColor: context.colors.primaryAccent,
                                  foregroundColor:
                                      context.colors.onPrimaryAccent,
                                  shape: const StadiumBorder(),
                                ),
                                onPressed: _submit,
                                child: Text(
                                  _isEditing ? 'Save Changes' : 'Save Preset',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TonalTextField extends StatelessWidget {
  const _TonalTextField({
    required this.fieldKey,
    required this.controller,
    required this.label,
    required this.hintText,
    this.errorText,
    this.maxLines = 1,
    this.textInputAction,
    this.onChanged,
  });

  final Key fieldKey;
  final TextEditingController controller;
  final String label;
  final String hintText;
  final String? errorText;
  final int maxLines;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        context.dimens.spaceMd,
        context.dimens.spaceSmPlus2,
        context.dimens.spaceMd,
        context.dimens.spaceXs,
      ),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainer,
        borderRadius: BorderRadius.circular(context.dimens.radiusDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.textTheme.labelMedium?.copyWith(
              fontSize: 10,
              color: context.colors.onSurfaceMuted,
            ),
          ),
          TextField(
            key: fieldKey,
            controller: controller,
            maxLines: maxLines,
            textInputAction: textInputAction,
            onChanged: onChanged,
            style: context.textTheme.titleSmall?.copyWith(
              color: context.colors.onSurfacePrimary,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceMuted.withValues(alpha: 0.7),
              ),
              errorText: errorText,
              isDense: true,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: context.colors.primaryAccent,
                  width: 2.0,
                ),
              ),
              errorBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: context.colors.error, width: 2.0),
              ),
              focusedErrorBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: context.colors.error, width: 2.0),
              ),
            ),
          ),
        ],
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
    return Material(
      color: isSelected
          ? context.colors.primaryContainer
          : context.colors.surfaceHigh,
      borderRadius: BorderRadius.circular(context.dimens.radiusFull),
      child: InkWell(
        key: chipKey,
        borderRadius: BorderRadius.circular(context.dimens.radiusFull),
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(minHeight: context.dimens.minTouchTarget),
          padding: EdgeInsets.symmetric(
            horizontal: context.dimens.spaceSmPlus4,
            vertical: context.dimens.spaceSm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(context.dimens.radiusFull),
            border: Border.all(
              color: isSelected
                  ? context.colors.neonGhostBorder
                  : context.colors.ghostBorder,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.labelMedium?.copyWith(
              letterSpacing: 0.4,
              color: isSelected
                  ? context.colors.primaryAccent
                  : context.colors.onSurfacePrimary,
            ),
          ),
        ),
      ),
    );
  }
}

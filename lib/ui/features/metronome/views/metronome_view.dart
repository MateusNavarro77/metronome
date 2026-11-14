import 'package:material_ui/material_ui.dart';

import '../../../core/theme/sonic_theme.dart';
import '../../presets/views/widgets/preset_editor_sheet.dart';
import '../view_models/metronome_view_model.dart';
import 'widgets/active_setlist_stepper_bar.dart';
import 'widgets/beat_indicator_bar.dart';
import 'widgets/bpm_control_section.dart';
import 'widgets/meter_and_subdivision_section.dart';
import 'widgets/transport_controls_bar.dart';

/// Main Metronome screen implementing the "Sonic Architect" design system
/// (specs/DESIGN_DARK.md, specs/DESIGN_LIGHT.md) and all must-have single-screen
/// requirements (UI-01..UI-04, UI-08, UI-09, UI-13, UI-14).
class MetronomeView extends StatelessWidget {
  const MetronomeView({
    super.key,
    required this.viewModel,
    this.onOpenSettings,
  });

  final MetronomeViewModel viewModel;
  final VoidCallback? onOpenSettings;

  Future<void> _onSavePreset(BuildContext context) async {
    final result = await showPresetEditorSheet(
      context,
      initialBpm: viewModel.state.bpm,
      initialTimeSignature: viewModel.state.timeSignature,
      initialSubdivision: viewModel.state.subdivision,
      initialAccentEnabled: viewModel.isAccentEnabled,
    );
    if (result == null) return;

    final saved = await viewModel.saveCurrentAsPreset(
      name: result.name,
      note: result.note,
      isFavorite: result.isFavorite,
      bpm: result.bpm,
      timeSignature: result.timeSignature,
      subdivision: result.subdivision,
      isAccentEnabled: result.isAccentEnabled,
    );
    if (saved == null || !context.mounted) return;

    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text('Saved preset "${saved.name}"'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceLowest,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) {
            final isDownbeatActive =
                viewModel.isPlaying &&
                viewModel.isAccentEnabled &&
                viewModel.currentBeat == 0 &&
                viewModel.currentSubdivision == 0;

            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide =
                    constraints.maxWidth > context.dimens.wideBreakpoint;
                final isCompactHeight =
                    constraints.maxHeight <
                    context.dimens.compactHeightBreakpoint;
                final gap = isCompactHeight
                    ? context.dimens.spaceXs + 2
                    : context.dimens.spaceMd;

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: context.dimens.maxContentWidth,
                    ),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isWide
                                ? context.dimens.spaceLg
                                : context.dimens.spaceMd,
                            vertical: isCompactHeight
                                ? context.dimens.spaceXs
                                : context.dimens.spaceSm,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Top Section: Header + Visual Pulse Indicator (FR-VIS-01)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _HeaderBar(
                                    isPlaying: viewModel.isPlaying,
                                    canSavePresets: viewModel.canSavePresets,
                                    onSavePreset: () => _onSavePreset(context),
                                    onOpenSettings: onOpenSettings,
                                  ),
                                  SizedBox(height: gap),
                                  BeatIndicatorBar(
                                    timeSignature: viewModel.timeSignature,
                                    subdivision: viewModel.subdivision,
                                    isPlaying: viewModel.isPlaying,
                                    isAccentEnabled: viewModel.isAccentEnabled,
                                    currentBeat: viewModel.currentBeat,
                                    currentSubdivision:
                                        viewModel.currentSubdivision,
                                    isCompact: isCompactHeight,
                                  ),
                                ],
                              ),
                              SizedBox(height: gap),
                              // Hero BPM Control Section (FR-BPM-01..04, FR-AND-01..02)
                              BpmControlSection(
                                bpm: viewModel.bpmValue,
                                tempoMarking: viewModel.tempoMarking,
                                isPlaying: viewModel.isPlaying,
                                isDownbeatActive: isDownbeatActive,
                                isCompact: isCompactHeight,
                                onAdjustBpm: viewModel.adjustBpm,
                                onStartHoldAdjust:
                                    viewModel.startContinuousBpmAdjustment,
                                onStopHoldAdjust:
                                    viewModel.stopContinuousBpmAdjustment,
                                onSliderChanged: viewModel.setBpm,
                              ),
                              SizedBox(height: gap),
                              // Transport Controls (Tap tempo + Circular Play/Stop Pulse CTA)
                              TransportControlsBar(
                                isPlaying: viewModel.isPlaying,
                                isDownbeatActive: isDownbeatActive,
                                isCompact: isCompactHeight,
                                onTogglePlayStop: viewModel.togglePlayStop,
                                onTapTempo: (timestamp) => viewModel
                                    .registerTapTempo(timestamp: timestamp),
                              ),
                              SizedBox(height: gap),
                              // Lower Section: Time Signature, Subdivisions & Accent (UI-09)
                              MeterAndSubdivisionSection(
                                selectedTimeSignature: viewModel.timeSignature,
                                selectedSubdivision: viewModel.subdivision,
                                isAccentEnabled: viewModel.isAccentEnabled,
                                isCompact: isCompactHeight,
                                onTimeSignatureSelected:
                                    viewModel.selectTimeSignature,
                                onSubdivisionSelected:
                                    viewModel.selectSubdivision,
                                onToggleAccent: viewModel.toggleAccent,
                              ),
                              if (viewModel.activeSetlist != null &&
                                  viewModel.currentSetlistPreset != null) ...[
                                SizedBox(height: gap),
                                ActiveSetlistStepperBar(
                                  setlist: viewModel.activeSetlist!,
                                  currentPreset:
                                      viewModel.currentSetlistPreset!,
                                  positionLabel:
                                      viewModel.activeSetlistPositionLabel,
                                  canStepPrevious:
                                      viewModel.canStepPreviousSetlistItem,
                                  canStepNext: viewModel.canStepNextSetlistItem,
                                  hasPendingBarTransition:
                                      viewModel.hasPendingBarTransition,
                                  isCompact: isCompactHeight,
                                  onPrevious: viewModel.previousSetlistItem,
                                  onNext: viewModel.nextSetlistItem,
                                  onDeactivate: viewModel.deactivateSetlist,
                                ),
                              ],
                              SizedBox(height: gap),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({
    required this.isPlaying,
    required this.canSavePresets,
    required this.onSavePreset,
    this.onOpenSettings,
  });

  final bool isPlaying;
  final bool canSavePresets;
  final VoidCallback onSavePreset;
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'METRONOME',
          style: context.textTheme.labelMedium?.copyWith(
            color: context.colors.onSurfacePrimary,
            letterSpacing: 2.2,
          ),
        ),
        if (canSavePresets)
          Material(
            color: context.colors.surfaceHigh,
            borderRadius: BorderRadius.circular(context.dimens.radiusFull),
            child: InkWell(
              key: const Key('save_preset_header_button'),
              borderRadius: BorderRadius.circular(context.dimens.radiusFull),
              onTap: onSavePreset,
              child: Container(
                constraints: BoxConstraints(
                  minHeight: context.dimens.minTouchTarget,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: context.dimens.spaceMd,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    context.dimens.radiusFull,
                  ),
                  border: Border.all(color: context.colors.ghostBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bookmark_add_outlined,
                      size: 18,
                      color: context.colors.primaryAccent,
                    ),
                    SizedBox(width: context.dimens.spaceXs),
                    Text(
                      'Save Preset',
                      style: context.textTheme.labelMedium?.copyWith(
                        letterSpacing: 0.4,
                        color: context.colors.onSurfacePrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

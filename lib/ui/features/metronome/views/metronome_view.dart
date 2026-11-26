import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart'
    hide CornerRounding, RoundedPolygon;

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/app_theme.dart';
import '../../presets/views/widgets/preset_editor_sheet.dart';
import '../view_models/metronome_view_model.dart';
import 'widgets/active_setlist_stepper_bar.dart';
import 'widgets/beat_indicator_bar.dart';
import 'widgets/bpm_control_section.dart';
import 'widgets/meter_and_subdivision_section.dart';
import 'widgets/transport_controls_bar.dart';

/// Main Metronome screen implementing Material 3 Expressive theming
/// and all must-have single-screen requirements (UI-01..UI-04, UI-08, UI-09, UI-13, UI-14).
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

    final l10n = context.l10n;
    M3ESnackbar.show(
      context,
      message: l10n.savedPresetSnackbar(saved.displayName(l10n)),
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: SafeArea(
        bottom: false,
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
                final availableHeight = (constraints.maxHeight - bottomInset)
                    .clamp(0.0, double.infinity);
                final isCompactHeight =
                    availableHeight < context.dimens.compactHeightBreakpoint;
                final gap = isCompactHeight
                    ? context.dimens.spaceXs + 2
                    : context.dimens.spaceMd;
                final horizontalPadding = isWide
                    ? context.dimens.spaceLg
                    : context.dimens.spaceMd;
                final verticalPadding = isCompactHeight
                    ? context.dimens.spaceXs
                    : context.dimens.spaceSm;

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
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            verticalPadding,
                            horizontalPadding,
                            bottomInset + verticalPadding,
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
                                  currentPosition:
                                      viewModel.activeSetlistCurrentPosition,
                                  totalCount: viewModel.activeSetlistTotal,
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
    final l10n = context.l10n;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.metronomeHeader,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: context.colorScheme.onSurface,
          ),
        ),
        if (canSavePresets)
          M3EButton.tonal(
            key: const Key('save_preset_header_button'),
            size: M3EButtonSize.xs,
            icon: const Icon(Icons.bookmark_add_outlined),
            label: Text(l10n.savePresetAction),
            onPressed: onSavePreset,
          ),
      ],
    );
  }
}

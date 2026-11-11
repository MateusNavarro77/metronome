import 'package:flutter/material.dart';

import '../../../core/theme/sonic_theme.dart';
import '../view_models/metronome_view_model.dart';
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
                              SizedBox(height: gap),

                              // Lower Section: Time Signature, Subdivisions & Accent (UI-09)
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
  const _HeaderBar({required this.isPlaying, this.onOpenSettings});

  final bool isPlaying;
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
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/theme/sonic_theme.dart';
import '../view_models/metronome_view_model.dart';
import 'widgets/beat_indicator_bar.dart';
import 'widgets/bpm_control_section.dart';
import 'widgets/meter_and_subdivision_section.dart';
import 'widgets/transport_controls_bar.dart';

/// Main Metronome screen implementing the "Sonic Architect" design system (`DESIGN.md`)
/// and all must-have single-screen requirements (UI-01..UI-04, UI-08, UI-09, UI-13, UI-14).
class MetronomeView extends StatelessWidget {
  const MetronomeView({super.key, required this.viewModel});

  final MetronomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SonicColors.surfaceLowest,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) {
            final isDownbeatActive =
                viewModel.isPlaying &&
                viewModel.currentBeat == 0 &&
                viewModel.currentSubdivision == 0;

            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 680;
                final isCompactHeight = constraints.maxHeight < 680;
                final gap = isCompactHeight
                    ? SonicDimens.spaceXs + 2
                    : SonicDimens.spaceMd;

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isWide
                                ? SonicDimens.spaceLg
                                : SonicDimens.spaceMd,
                            vertical: isCompactHeight
                                ? SonicDimens.spaceXs
                                : SonicDimens.spaceSm,
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
                                  _HeaderBar(isPlaying: viewModel.isPlaying),
                                  SizedBox(height: gap),
                                  BeatIndicatorBar(
                                    timeSignature: viewModel.timeSignature,
                                    subdivision: viewModel.subdivision,
                                    isPlaying: viewModel.isPlaying,
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
                              // Lower Section: Time Signature, Subdivisions & Thumb-Zone Transport (UI-09)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  MeterAndSubdivisionSection(
                                    selectedTimeSignature:
                                        viewModel.timeSignature,
                                    selectedSubdivision: viewModel.subdivision,
                                    isCompact: isCompactHeight,
                                    onTimeSignatureSelected:
                                        viewModel.selectTimeSignature,
                                    onSubdivisionSelected:
                                        viewModel.selectSubdivision,
                                  ),
                                  SizedBox(height: gap),
                                  TransportControlsBar(
                                    isPlaying: viewModel.isPlaying,
                                    isDownbeatActive: isDownbeatActive,
                                    isCompact: isCompactHeight,
                                    onTogglePlayStop: viewModel.togglePlayStop,
                                    onTapTempo: (timestamp) => viewModel
                                        .registerTapTempo(timestamp: timestamp),
                                  ),
                                ],
                              ),
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
  const _HeaderBar({required this.isPlaying});

  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'METRONOME',
          style: SonicTheme.labelMd.copyWith(
            color: SonicColors.onSurfacePrimary,
            letterSpacing: 2.2,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SonicDimens.spaceSm + 4,
            vertical: SonicDimens.spaceXs,
          ),
          decoration: BoxDecoration(
            color: isPlaying
                ? SonicColors.primaryContainer
                : SonicColors.surfaceHigh,
            borderRadius: BorderRadius.circular(SonicDimens.radiusFull),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPlaying
                      ? SonicColors.primaryNeon
                      : SonicColors.onSurfaceMuted,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                isPlaying ? 'PLAYING' : 'STOPPED',
                key: const Key('playback_state_badge'),
                style: SonicTheme.labelMd.copyWith(
                  fontSize: 10,
                  color: isPlaying
                      ? SonicColors.primaryNeon
                      : SonicColors.onSurfaceMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

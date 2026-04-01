import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metronome/blocs/metronome/metronome_bloc.dart';
import 'package:metronome/blocs/theme/theme_bloc.dart';
import 'package:metronome/shared/constants.dart';
import 'package:metronome/view/widgets/app_package_data.dart';
import 'package:metronome/view/widgets/measure_bar.dart';
import 'package:metronome/view/widgets/time_signature_picker.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late StreamSubscription<MetronomeState> sub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      sub = context
          .read<MetronomeBloc>()
          .stream
          .distinct((previous, next) => previous.isRunning == next.isRunning)
          .listen((event) {
            debugPrint('isRunning: ${event.isRunning}');
            if (event.isRunning) {
              WakelockPlus.enable();
            } else {
              WakelockPlus.disable();
            }
          });
    });
  }

  @override
  void dispose() {
    sub.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      context.read<MetronomeBloc>().add(MetronomePaused());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Measure Bar ──
                    BlocBuilder<MetronomeBloc, MetronomeState>(
                      buildWhen:
                          (previous, current) =>
                              previous.tick?.barIndex !=
                                  current.tick?.barIndex ||
                              previous.beatsPerBar != current.beatsPerBar,
                      builder: (context, state) {
                        return MeasureBar(
                          notesPerMeasure: state.beatsPerBar,
                          currentIndex: state.tick?.barIndex,
                        );
                      },
                    ),

                    const SizedBox(height: 48),

                    // ── BPM Display with Radial Glow ──
                    BlocBuilder<MetronomeBloc, MetronomeState>(
                      builder: (context, state) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                colorScheme.primary.withValues(alpha: 0.08),
                                Colors.transparent,
                              ],
                              radius: 0.8,
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  // Decrement button
                                  _buildControlButton(
                                    context,
                                    icon: Icons.remove,
                                    onPressed: () {
                                      context.read<MetronomeBloc>().add(
                                        MetronomeBpmDecremented(),
                                      );
                                    },
                                  ),

                                  // BPM value (hero element)
                                  Text(
                                    '${state.bpm}',
                                    style: textTheme.displayLarge,
                                  ),

                                  // Increment button
                                  _buildControlButton(
                                    context,
                                    icon: Icons.add,
                                    onPressed: () {
                                      context.read<MetronomeBloc>().add(
                                        MetronomeBpmIncremented(),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('BPM', style: textTheme.labelMedium),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // ── Slider ──
                    BlocBuilder<MetronomeBloc, MetronomeState>(
                      buildWhen:
                          (previous, current) => previous.bpm != current.bpm,
                      builder: (context, state) {
                        return Slider(
                          value: state.bpm.toDouble(),
                          min: kMinBpm.toDouble(),
                          max: kMaxBpm.toDouble(),
                          onChanged: (value) {
                            context.read<MetronomeBloc>().add(
                              MetronomeBpmChanged(bpm: value.round()),
                            );
                          },
                        );
                      },
                    ),

                    // const SizedBox(height: 32),

                    // // ── Time Signature (tappable chip) ──
                    // Text(
                    //   'TIME SIGNATURE',
                    //   style: textTheme.labelMedium,
                    // ),
                    const SizedBox(height: 12),
                    BlocBuilder<MetronomeBloc, MetronomeState>(
                      buildWhen:
                          (previous, current) =>
                              previous.beatsPerBar != current.beatsPerBar,
                      builder: (context, state) {
                        return GestureDetector(
                          onTap: () async {
                            final result = await TimeSignaturePicker.show(
                              context,
                              state.beatsPerBar,
                            );
                            if (result != null && context.mounted) {
                              context.read<MetronomeBloc>().add(
                                MetronomeBeatsPerBarChanged(
                                  beatsPerBar: result,
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _beatsPerBarToLabel(state.beatsPerBar),
                                  style: textTheme.titleSmall,
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.unfold_more,
                                  color: colorScheme.onSurfaceVariant,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // ── Controls Row ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Theme toggle
                        BlocBuilder<ThemeBloc, ThemeState>(
                          builder: (context, state) {
                            return _buildControlButton(
                              context,
                              icon:
                                  state is ThemeDark
                                      ? Icons.light_mode_outlined
                                      : Icons.dark_mode_outlined,
                              onPressed:
                                  () => context.read<ThemeBloc>().add(
                                    ThemeToggled(),
                                  ),
                            );
                          },
                        ),

                        // Play / Pause ("Pulse Button")
                        BlocBuilder<MetronomeBloc, MetronomeState>(
                          buildWhen:
                              (previous, current) =>
                                  previous.isRunning != current.isRunning,
                          builder: (context, state) {
                            return _buildPulseButton(
                              context,
                              isPlaying: state.isRunning,
                              onPressed: () {
                                if (state.isRunning) {
                                  context.read<MetronomeBloc>().add(
                                    MetronomePaused(),
                                  );
                                  return;
                                }
                                context.read<MetronomeBloc>().add(
                                  MetronomePlayed(),
                                );
                              },
                            );
                          },
                        ),

                        // Accent toggle
                        BlocBuilder<MetronomeBloc, MetronomeState>(
                          buildWhen:
                              (previous, current) =>
                                  previous.accentOnFirstBeat !=
                                  current.accentOnFirstBeat,
                          builder: (context, state) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Switch(
                                  value: state.accentOnFirstBeat,
                                  onChanged: (value) {
                                    context.read<MetronomeBloc>().add(
                                      MetronomeAccentFirstBeatToggled(),
                                    );
                                  },
                                ),
                                const SizedBox(height: 4),
                                Text('ACCENT', style: textTheme.labelSmall),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Version info at bottom ──
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AppPackageData(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Helper Widgets
  // ─────────────────────────────────────────────

  /// A secondary control button with surfaceContainerHigh background
  /// and full rounding, per DESIGN.md.
  Widget _buildControlButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(onPressed: onPressed, icon: Icon(icon));
  }

  /// The primary CTA — neon green with glow when active.
  Widget _buildPulseButton(
    BuildContext context, {
    required bool isPlaying,
    required VoidCallback onPressed,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow:
            isPlaying
                ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.45),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ]
                : null,
      ),
      child: SizedBox(
        width: 80,
        height: 80,
        child: FittedBox(
          child: FloatingActionButton(
            onPressed: onPressed,
            child:
                isPlaying
                    ? const Icon(Icons.pause, size: 28)
                    : const Icon(Icons.play_arrow, size: 28),
          ),
        ),
      ),
    );
  }

  /// Converts beatsPerBar int to display label.
  String _beatsPerBarToLabel(int beatsPerBar) {
    const map = {
      2: '2/4',
      3: '3/4',
      4: '4/4',
      5: '5/4',
      6: '6/8',
      7: '7/8',
      9: '9/8',
      12: '12/8',
    };
    return map[beatsPerBar] ?? '$beatsPerBar/4';
  }
}

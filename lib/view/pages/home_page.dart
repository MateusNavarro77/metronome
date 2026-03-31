import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metronome/blocs/metronome/metronome_bloc.dart';
import 'package:metronome/blocs/theme/theme_bloc.dart';
import 'package:metronome/shared/constants.dart';
import 'package:metronome/view/widgets/app_package_data.dart';

import 'package:metronome/view/widgets/measure_bar.dart';
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
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BlocBuilder<MetronomeBloc, MetronomeState>(
                      buildWhen:
                          (previous, current) =>
                              previous.tick?.barIndex != current.tick?.barIndex ||
                              previous.beatsPerBar != current.beatsPerBar,
                      builder: (context, state) {
                        return MeasureBar(
                          notesPerMeasure: state.beatsPerBar,
                          currentIndex: state.tick?.barIndex,
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () {
                            context.read<MetronomeBloc>().add(
                              MetronomeBpmDecremented(),
                            );
                          },
                          icon: Icon(Icons.remove),
                        ),
                        BlocBuilder<MetronomeBloc, MetronomeState>(
                          builder: (context, state) {
                            return Text(
                              '${state.bpm}',
                              style: Theme.of(context).textTheme.displayLarge,
                            );
                          },
                        ),
                        IconButton(
                          onPressed: () {
                            context.read<MetronomeBloc>().add(
                              MetronomeBpmIncremented(),
                            );
                          },
                          icon: Icon(Icons.add),
                        ),
                      ],
                    ),
                    const Text('BPM'),
                    const SizedBox(height: 20),
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
                    const SizedBox(height: 20),
                    const Text('Time Signature'),
                    BlocBuilder<MetronomeBloc, MetronomeState>(
                      buildWhen: (previous, current) => previous.beatsPerBar != current.beatsPerBar,
                      builder: (context, state) {
                        return SizedBox(
                          width: 100,

                          child: DropdownButton<int>(
                            isExpanded: true,
                            value: state.beatsPerBar,
                            items: const [
                              DropdownMenuItem(value: 2, child: Text('2/4')),
                              DropdownMenuItem(value: 3, child: Text('3/4')),
                              DropdownMenuItem(value: 4, child: Text('4/4')),
                              DropdownMenuItem(value: 5, child: Text('5/4')),
                              DropdownMenuItem(value: 6, child: Text('6/8')),
                              DropdownMenuItem(value: 7, child: Text('7/8')),
                              DropdownMenuItem(value: 9, child: Text('9/8')),
                              DropdownMenuItem(value: 12, child: Text('12/8')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                context.read<MetronomeBloc>().add(
                                  MetronomeBeatsPerBarChanged(beatsPerBar: value),
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        BlocBuilder<ThemeBloc, ThemeState>(
                          builder: (context, state) {
                            return IconButton(
                              onPressed:
                                  () => context.read<ThemeBloc>().add(
                                    ThemeToggled(),
                                  ),
                              icon: Icon(
                                state is ThemeDark
                                    ? Icons.light_mode
                                    : Icons.dark_mode,
                              ),
                            );
                          },
                        ),
                        BlocBuilder<MetronomeBloc, MetronomeState>(
                          buildWhen:
                              (previous, current) =>
                                  previous.isRunning != current.isRunning,
                          builder: (context, state) {
                            return SizedBox(
                              width: 80,
                              height: 80,
                              child: FittedBox(
                                child: FloatingActionButton(
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
                                  child:
                                      state.isRunning
                                          ? Icon(Icons.pause)
                                          : Icon(Icons.play_arrow),
                                ),
                              ),
                            );
                          },
                        ),
                        BlocBuilder<MetronomeBloc, MetronomeState>(
                          buildWhen:
                              (previous, current) =>
                                  previous.accentOnFirstBeat !=
                                  current.accentOnFirstBeat,
                          builder: (context, state) {
                            return Switch(
                              value: state.accentOnFirstBeat,
                              onChanged: (value) {
                                context.read<MetronomeBloc>().add(
                                  MetronomeAccentFirstBeatToggled(),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Align(
                alignment: AlignmentGeometry.bottomCenter,
                child: AppPackageData(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metronome/blocs/metronome/metronome_bloc.dart';
import 'package:metronome/view/widgets/app_package_data.dart';
import 'package:metronome/view/widgets/bpm_display.dart';
import 'package:metronome/view/widgets/bpm_slider.dart';
import 'package:metronome/view/widgets/measure_bar.dart';
import 'package:metronome/view/widgets/metronome_controls.dart';
import 'package:metronome/view/widgets/time_signature_selector.dart';
import 'package:metronome/view/widgets/tap_bpm_fab.dart';
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
      floatingActionButton: const TapBpmFab(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
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

                    const BpmDisplay(),

                    const SizedBox(height: 32),

                    const BpmSlider(),

                    const TimeSignatureSelector(),

                    const SizedBox(height: 40),

                    const MetronomeControls(),
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
}

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metronome/data/repositories/metronome_repository.dart';
import 'package:metronome/data/services/simulated_metronome_engine.dart';
import 'package:metronome/domain/models/subdivision.dart';
import 'package:metronome/domain/models/tempo_marking.dart';
import 'package:metronome/domain/models/time_signature.dart';
import 'package:metronome/ui/features/metronome/view_models/metronome_view_model.dart';

void main() {
  group('MetronomeRepository & MetronomeViewModel', () {
    late SimulatedMetronomeEngine engine;
    late MetronomeRepository repository;
    late MetronomeViewModel viewModel;
    late Duration currentTime;

    setUp(() {
      currentTime = Duration.zero;
      engine = SimulatedMetronomeEngine();
      repository = MetronomeRepository(engine: engine);
      viewModel = MetronomeViewModel(
        repository: repository,
        clock: () => currentTime,
      );
    });

    tearDown(() async {
      viewModel.dispose();
      await repository.dispose();
    });

    test('starts on Beat 1 (strong) and advances beats and subdivisions', () async {
      check(viewModel.isPlaying).isFalse();
      check(viewModel.bpmValue).equals(120);
      check(viewModel.tempoMarking).equals(TempoMarking.allegro);

      await viewModel.togglePlayStop();
      check(viewModel.isPlaying).isTrue();
      check(viewModel.currentBeat).equals(0);
      check(engine.emittedEvents).length.equals(1);
      check(engine.emittedEvents.first.accent).equals(BeatAccent.strong);

      // Advance 3 pulses in 4/4 (Subdivision.none)
      engine.advancePulses(3);
      await Future<void>.delayed(Duration.zero);
      check(viewModel.currentBeat).equals(3);

      // Next pulse wraps around to Beat 0 (bar 2)
      engine.advancePulses(1);
      await Future<void>.delayed(Duration.zero);
      check(viewModel.currentBeat).equals(0);

      // Stop resets state to Beat 0
      await viewModel.togglePlayStop();
      check(viewModel.isPlaying).isFalse();
      check(viewModel.currentBeat).equals(0);
    });

    test('updates BPM, TimeSignature, and Subdivision dynamically', () {
      viewModel.setBpm(72);
      check(viewModel.bpmValue).equals(72);
      check(viewModel.tempoMarking).equals(TempoMarking.adagio);

      viewModel.selectTimeSignature(TimeSignature.sixEight);
      check(viewModel.timeSignature).equals(TimeSignature.sixEight);

      viewModel.selectSubdivision(Subdivision.triplet);
      check(viewModel.subdivision).equals(Subdivision.triplet);
    });

    test('computes BPM via registerTapTempo using monotonic clock', () {
      currentTime = const Duration(milliseconds: 1000);
      viewModel.registerTapTempo();
      check(viewModel.bpmValue).equals(120); // Unchanged on 1st tap

      // 400 ms later -> 150 BPM (Allegro)
      currentTime = const Duration(milliseconds: 1400);
      viewModel.registerTapTempo();
      check(viewModel.bpmValue).equals(150);
    });
  });
}

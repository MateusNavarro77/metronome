import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metronome/data/repositories/metronome_repository.dart';
import 'package:metronome/data/repositories/preferences_repository.dart';
import 'package:metronome/data/repositories/preset_library_repository.dart';
import 'package:metronome/data/services/simulated_metronome_engine.dart';
import 'package:metronome/domain/models/bpm.dart';
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

    test(
      'starts on Beat 1 (strong) and advances beats and subdivisions',
      () async {
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
      },
    );

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

    test('toggles accent on/off and emits weak click on Beat 1 when accent is disabled', () async {
      check(viewModel.isAccentEnabled).isTrue();

      viewModel.toggleAccent();
      check(viewModel.isAccentEnabled).isFalse();

      await viewModel.togglePlayStop();
      check(viewModel.isPlaying).isTrue();
      check(engine.emittedEvents.first.accent).equals(BeatAccent.weak);

      // Advance to beat 2, still weak
      engine.advancePulses(1);
      await Future<void>.delayed(Duration.zero);
      check(engine.emittedEvents.last.accent).equals(BeatAccent.weak);

      // Turn accent back on during playback
      viewModel.toggleAccent();
      check(viewModel.isAccentEnabled).isTrue();

      // Advance 3 more pulses to wrap to Beat 0 of bar 2
      engine.advancePulses(3);
      await Future<void>.delayed(Duration.zero);
      check(viewModel.currentBeat).equals(0);
      check(engine.emittedEvents.last.accent).equals(BeatAccent.strong);
    });

    test(
      'initializes with persisted accent preference from PreferencesRepository',
      () {
        final prefsRepo = PreferencesRepository(preferences: null);
        prefsRepo.setAccentEnabled(false);

        final vm = MetronomeViewModel(
          repository: repository,
          preferencesRepository: prefsRepo,
        );

        check(vm.isAccentEnabled).isFalse();
        vm.toggleAccent();
        check(vm.isAccentEnabled).isTrue();
        check(prefsRepo.getAccentEnabled()).isTrue();
        vm.dispose();
      },
    );

    test('toggles accent on/off and emits weak click on Beat 1 when accent is disabled', () async {
      check(viewModel.isAccentEnabled).isTrue();

      viewModel.toggleAccent();
      check(viewModel.isAccentEnabled).isFalse();

      await viewModel.togglePlayStop();
      check(viewModel.isPlaying).isTrue();
      check(engine.emittedEvents.first.accent).equals(BeatAccent.weak);

      // Advance to beat 2, still weak
      engine.advancePulses(1);
      await Future<void>.delayed(Duration.zero);
      check(engine.emittedEvents.last.accent).equals(BeatAccent.weak);

      // Turn accent back on during playback
      viewModel.toggleAccent();
      check(viewModel.isAccentEnabled).isTrue();

      // Advance 3 more pulses to wrap to Beat 0 of bar 2
      engine.advancePulses(3);
      await Future<void>.delayed(Duration.zero);
      check(viewModel.currentBeat).equals(0);
      check(engine.emittedEvents.last.accent).equals(BeatAccent.strong);
    });

    test(
      'initializes with persisted accent preference from PreferencesRepository',
      () {
        final prefsRepo = PreferencesRepository(preferences: null);
        prefsRepo.setAccentEnabled(false);

        final vm = MetronomeViewModel(
          repository: repository,
          preferencesRepository: prefsRepo,
        );

        check(vm.isAccentEnabled).isFalse();
        vm.toggleAccent();
        check(vm.isAccentEnabled).isTrue();
        check(prefsRepo.getAccentEnabled()).isTrue();
        vm.dispose();
      },
    );

    test('applies preset immediately when stopped and bar-synced when playing (FR-PRE-02, FR-PRE-09)', () async {
      final library = PresetLibraryRepository();
      final prefsRepo = PreferencesRepository();
      final vm = MetronomeViewModel(
        repository: repository,
        preferencesRepository: prefsRepo,
        presetLibraryRepository: library,
      );
      addTearDown(() async {
        vm.dispose();
        await library.dispose();
      });

      final p1 = await library.createPreset(
        name: 'Opener',
        bpm: const Bpm(120),
        timeSignature: TimeSignature.fourFour,
        subdivision: Subdivision.none,
        isAccentEnabled: true,
      );
      final p2 = await library.createPreset(
        name: 'Waltz',
        bpm: const Bpm(90),
        timeSignature: TimeSignature.threeFour,
        subdivision: Subdivision.eighth,
        isAccentEnabled: false,
      );

      // Stopped: applies immediately to engine and viewModel
      vm.loadPreset(p1);
      check(vm.bpmValue).equals(120);
      check(vm.activePresetId).equals(p1.id);
      check(vm.hasPendingBarTransition).isFalse();
      check(engine.bpm).equals(const Bpm(120));

      // Start playback on Beat 0
      await vm.togglePlayStop();
      check(engine.emittedEvents.length).equals(1);
      check(engine.emittedEvents.last.beatIndex).equals(0);

      // Switch to p2 mid-bar: UI updates immediately, engine queues for next bar
      vm.loadPreset(p2);
      check(vm.bpmValue).equals(90);
      check(vm.timeSignature).equals(TimeSignature.threeFour);
      check(vm.subdivision).equals(Subdivision.eighth);
      check(vm.isAccentEnabled).isFalse();
      check(vm.hasPendingBarTransition).isTrue();
      check(engine.hasPendingBarTransition).isTrue();
      check(engine.bpm).equals(const Bpm(120));
      check(engine.timeSignature).equals(TimeSignature.fourFour);

      // Advance remaining 3 beats of the 4/4 bar -> still old configuration
      engine.advancePulses(3);
      await Future<void>.delayed(Duration.zero);
      check(engine.bpm).equals(const Bpm(120));
      check(engine.emittedEvents.last.beatIndex).equals(3);
      check(vm.hasPendingBarTransition).isTrue();

      // Advance into Beat 1 of the next bar -> engine switches cleanly!
      engine.advancePulses(1);
      await Future<void>.delayed(Duration.zero);
      check(engine.bpm).equals(const Bpm(90));
      check(engine.timeSignature).equals(TimeSignature.threeFour);
      check(engine.subdivision).equals(Subdivision.eighth);
      check(engine.isAccentEnabled).isFalse();
      check(engine.emittedEvents.last.beatIndex).equals(0);
      check(engine.emittedEvents.last.accent).equals(BeatAccent.weak);
      check(vm.hasPendingBarTransition).isFalse();
    });

    test('activates setlist, steps prev/next, saves current as preset, and reacts to library updates (FR-PRE-08, UC-06)', () async {
      final library = PresetLibraryRepository();
      final vm = MetronomeViewModel(
        repository: repository,
        presetLibraryRepository: library,
      );
      addTearDown(() async {
        vm.dispose();
        await library.dispose();
      });

      final p1 = await library.createPreset(
        name: 'Song 1',
        bpm: const Bpm(100),
        timeSignature: TimeSignature.fourFour,
        subdivision: Subdivision.none,
        isAccentEnabled: true,
        note: 'Count 4 in',
      );
      final p2 = await library.createPreset(
        name: 'Song 2',
        bpm: const Bpm(140),
        timeSignature: TimeSignature.sixEight,
        subdivision: Subdivision.eighth,
        isAccentEnabled: true,
      );
      final setlist = await library.createSetlist(
        name: 'Encore',
        presetIds: [p1.id, p2.id],
      );

      vm.activateSetlist(setlist);
      check(vm.activeSetlist).equals(setlist);
      check(vm.activeSetlistIndex).equals(0);
      check(vm.activeSetlistPositionLabel).equals('1 of 2');
      check(vm.canStepPreviousSetlistItem).isFalse();
      check(vm.canStepNextSetlistItem).isTrue();
      check(vm.bpmValue).equals(100);

      // Manual BPM edit does not deactivate setlist
      vm.setBpm(104);
      check(vm.bpmValue).equals(104);
      check(vm.activeSetlist).isNotNull();

      // Step next & previous
      vm.nextSetlistItem();
      check(vm.activeSetlistIndex).equals(1);
      check(vm.activeSetlistPositionLabel).equals('2 of 2');
      check(vm.canStepPreviousSetlistItem).isTrue();
      check(vm.canStepNextSetlistItem).isFalse();
      check(vm.bpmValue).equals(140);
      check(vm.timeSignature).equals(TimeSignature.sixEight);

      vm.previousSetlistItem();
      check(vm.activeSetlistIndex).equals(0);
      check(vm.bpmValue).equals(100);

      // Save current state as preset
      vm.setBpm(116);
      final saved = await vm.saveCurrentAsPreset(
        name: 'Custom Save',
        note: 'Bridge',
        isFavorite: true,
      );
      check(saved).isNotNull();
      check(saved!.bpm).equals(const Bpm(116));
      check(saved.note).equals('Bridge');
      check(saved.isFavorite).isTrue();
      check(vm.activePresetId).equals(saved.id);

      // Deleting active setlist automatically clears active setlist
      await library.deleteSetlist(setlist.id);
      await Future<void>.delayed(Duration.zero);
      check(vm.activeSetlist).isNull();
    });

    test('applies preset immediately when stopped and bar-synced when playing (FR-PRE-02, FR-PRE-09)', () async {
      final library = PresetLibraryRepository();
      final prefsRepo = PreferencesRepository();
      final vm = MetronomeViewModel(
        repository: repository,
        preferencesRepository: prefsRepo,
        presetLibraryRepository: library,
      );
      addTearDown(() async {
        vm.dispose();
        await library.dispose();
      });

      final p1 = await library.createPreset(
        name: 'Opener',
        bpm: const Bpm(120),
        timeSignature: TimeSignature.fourFour,
        subdivision: Subdivision.none,
        isAccentEnabled: true,
      );
      final p2 = await library.createPreset(
        name: 'Waltz',
        bpm: const Bpm(90),
        timeSignature: TimeSignature.threeFour,
        subdivision: Subdivision.eighth,
        isAccentEnabled: false,
      );

      // Stopped: applies immediately to engine and viewModel
      vm.loadPreset(p1);
      check(vm.bpmValue).equals(120);
      check(vm.activePresetId).equals(p1.id);
      check(vm.hasPendingBarTransition).isFalse();
      check(engine.bpm).equals(const Bpm(120));

      // Start playback on Beat 0
      await vm.togglePlayStop();
      check(engine.emittedEvents.length).equals(1);
      check(engine.emittedEvents.last.beatIndex).equals(0);

      // Switch to p2 mid-bar: UI updates immediately, engine queues for next bar
      vm.loadPreset(p2);
      check(vm.bpmValue).equals(90);
      check(vm.timeSignature).equals(TimeSignature.threeFour);
      check(vm.subdivision).equals(Subdivision.eighth);
      check(vm.isAccentEnabled).isFalse();
      check(vm.hasPendingBarTransition).isTrue();
      check(engine.hasPendingBarTransition).isTrue();
      check(engine.bpm).equals(const Bpm(120));
      check(engine.timeSignature).equals(TimeSignature.fourFour);

      // Advance remaining 3 beats of the 4/4 bar -> still old configuration
      engine.advancePulses(3);
      await Future<void>.delayed(Duration.zero);
      check(engine.bpm).equals(const Bpm(120));
      check(engine.emittedEvents.last.beatIndex).equals(3);
      check(vm.hasPendingBarTransition).isTrue();

      // Advance into Beat 1 of the next bar -> engine switches cleanly!
      engine.advancePulses(1);
      await Future<void>.delayed(Duration.zero);
      check(engine.bpm).equals(const Bpm(90));
      check(engine.timeSignature).equals(TimeSignature.threeFour);
      check(engine.subdivision).equals(Subdivision.eighth);
      check(engine.isAccentEnabled).isFalse();
      check(engine.emittedEvents.last.beatIndex).equals(0);
      check(engine.emittedEvents.last.accent).equals(BeatAccent.weak);
      check(vm.hasPendingBarTransition).isFalse();
    });

    test('activates setlist, steps prev/next, saves current as preset, and reacts to library updates (FR-PRE-08, UC-06)', () async {
      final library = PresetLibraryRepository();
      final vm = MetronomeViewModel(
        repository: repository,
        presetLibraryRepository: library,
      );
      addTearDown(() async {
        vm.dispose();
        await library.dispose();
      });

      final p1 = await library.createPreset(
        name: 'Song 1',
        bpm: const Bpm(100),
        timeSignature: TimeSignature.fourFour,
        subdivision: Subdivision.none,
        isAccentEnabled: true,
        note: 'Count 4 in',
      );
      final p2 = await library.createPreset(
        name: 'Song 2',
        bpm: const Bpm(140),
        timeSignature: TimeSignature.sixEight,
        subdivision: Subdivision.eighth,
        isAccentEnabled: true,
      );
      final setlist = await library.createSetlist(
        name: 'Encore',
        presetIds: [p1.id, p2.id],
      );

      vm.activateSetlist(setlist);
      check(vm.activeSetlist).equals(setlist);
      check(vm.activeSetlistIndex).equals(0);
      check(vm.activeSetlistPositionLabel).equals('1 of 2');
      check(vm.canStepPreviousSetlistItem).isFalse();
      check(vm.canStepNextSetlistItem).isTrue();
      check(vm.bpmValue).equals(100);

      // Manual BPM edit does not deactivate setlist
      vm.setBpm(104);
      check(vm.bpmValue).equals(104);
      check(vm.activeSetlist).isNotNull();

      // Step next & previous
      vm.nextSetlistItem();
      check(vm.activeSetlistIndex).equals(1);
      check(vm.activeSetlistPositionLabel).equals('2 of 2');
      check(vm.canStepPreviousSetlistItem).isTrue();
      check(vm.canStepNextSetlistItem).isFalse();
      check(vm.bpmValue).equals(140);
      check(vm.timeSignature).equals(TimeSignature.sixEight);

      vm.previousSetlistItem();
      check(vm.activeSetlistIndex).equals(0);
      check(vm.bpmValue).equals(100);

      // Save current state as preset
      vm.setBpm(116);
      final saved = await vm.saveCurrentAsPreset(
        name: 'Custom Save',
        note: 'Bridge',
        isFavorite: true,
      );
      check(saved).isNotNull();
      check(saved!.bpm).equals(const Bpm(116));
      check(saved.note).equals('Bridge');
      check(saved.isFavorite).isTrue();
      check(vm.activePresetId).equals(saved.id);

      // Deleting active setlist automatically clears active setlist
      await library.deleteSetlist(setlist.id);
      await Future<void>.delayed(Duration.zero);
      check(vm.activeSetlist).isNull();
    });
  });
}

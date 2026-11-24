import 'dart:async';

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metronome/data/repositories/metronome_repository.dart';
import 'package:metronome/data/repositories/preferences_repository.dart';
import 'package:metronome/data/services/background_playback_coordinator.dart';
import 'package:metronome/data/services/background_playback_service.dart';
import 'package:metronome/data/services/simulated_metronome_engine.dart';
import 'package:metronome/domain/models/time_signature.dart';

class _FakeBackgroundPlaybackService implements BackgroundPlaybackService {
  final StreamController<BackgroundPlaybackCommand> _commandsController =
      StreamController<BackgroundPlaybackCommand>.broadcast();

  final List<BackgroundPlaybackSnapshot> syncedSnapshots = [];
  int initializeCalls = 0;
  int permissionRequestCalls = 0;
  int dismissCalls = 0;

  @override
  Stream<BackgroundPlaybackCommand> get commands => _commandsController.stream;

  void emitCommand(BackgroundPlaybackCommand command) {
    _commandsController.add(command);
  }

  @override
  Future<void> initialize() async {
    initializeCalls++;
  }

  @override
  Future<void> requestNotificationPermission() async {
    permissionRequestCalls++;
  }

  @override
  Future<void> syncState(BackgroundPlaybackSnapshot snapshot) async {
    syncedSnapshots.add(snapshot);
  }

  @override
  Future<void> dismissNotification() async {
    dismissCalls++;
  }

  @override
  Future<void> dispose() async {
    await _commandsController.close();
  }
}

void main() {
  group('BackgroundPlaybackCoordinator', () {
    late SimulatedMetronomeEngine engine;
    late MetronomeRepository metronomeRepo;
    late PreferencesRepository prefsRepo;
    late _FakeBackgroundPlaybackService service;
    late BackgroundPlaybackCoordinator coordinator;

    setUp(() {
      engine = SimulatedMetronomeEngine();
      metronomeRepo = MetronomeRepository(engine: engine);
      prefsRepo = PreferencesRepository(preferences: null);
      service = _FakeBackgroundPlaybackService();
      coordinator = BackgroundPlaybackCoordinator(
        metronomeRepository: metronomeRepo,
        preferencesRepository: prefsRepo,
        backgroundService: service,
      );
    });

    tearDown(() async {
      await coordinator.dispose();
      await metronomeRepo.dispose();
      await service.dispose();
    });

    test('activates notification on play, requests permission, and deduplicates beat ticks and meter changes', () async {
      await metronomeRepo.start();
      await Future<void>.delayed(Duration.zero);

      check(coordinator.isNotificationSessionActive).isTrue();
      check(service.permissionRequestCalls).equals(1);
      check(service.syncedSnapshots.length).equals(1);
      check(service.syncedSnapshots.last)
          .equals(const BackgroundPlaybackSnapshot(isPlaying: true, bpm: 120));
      check(service.syncedSnapshots.last.title).equals('120 BPM');

      // Emit beat ticks & change time signature — should not spam notification
      engine.advancePulses(3);
      metronomeRepo.setTimeSignature(TimeSignature.sixEight);
      await Future<void>.delayed(Duration.zero);

      check(service.syncedSnapshots.length).equals(1);
    });

    test(
      'keeps notification alive on pause and resumes on play command',
      () async {
        await metronomeRepo.start();
        await Future<void>.delayed(Duration.zero);

        service.emitCommand(BackgroundPlaybackCommand.pause);
        await Future<void>.delayed(Duration.zero);

        check(metronomeRepo.state.isPlaying).isFalse();
        check(coordinator.isNotificationSessionActive).isTrue();
        check(service.dismissCalls).equals(0);
        check(service.syncedSnapshots.last.isPlaying).isFalse();

        service.emitCommand(BackgroundPlaybackCommand.play);
        await Future<void>.delayed(Duration.zero);

        check(metronomeRepo.state.isPlaying).isTrue();
        check(service.syncedSnapshots.last.isPlaying).isTrue();
      },
    );

    test('stops playback and dismisses notification on stop command', () async {
      await metronomeRepo.start();
      await Future<void>.delayed(Duration.zero);

      service.emitCommand(BackgroundPlaybackCommand.stop);
      await Future<void>.delayed(Duration.zero);

      check(metronomeRepo.state.isPlaying).isFalse();
      check(coordinator.isNotificationSessionActive).isFalse();
      check(service.dismissCalls).equals(1);
    });

    test(
      'adjusts BPM by +/- 1 on decreaseBpm and increaseBpm commands',
      () async {
        await metronomeRepo.start();
        await Future<void>.delayed(Duration.zero);

        service.emitCommand(BackgroundPlaybackCommand.increaseBpm);
        await Future<void>.delayed(Duration.zero);
        check(metronomeRepo.state.bpm.value).equals(121);
        check(service.syncedSnapshots.last.bpm).equals(121);
        check(service.syncedSnapshots.last.title).equals('121 BPM');

        service.emitCommand(BackgroundPlaybackCommand.decreaseBpm);
        service.emitCommand(BackgroundPlaybackCommand.decreaseBpm);
        await Future<void>.delayed(Duration.zero);
        check(metronomeRepo.state.bpm.value).equals(119);
        check(service.syncedSnapshots.last.bpm).equals(119);
        check(service.syncedSnapshots.last.title).equals('119 BPM');
      },
    );

    test(
      'stops playback when app backgrounds if background playback is disabled',
      () async {
        await prefsRepo.setBackgroundPlaybackEnabled(false);
        await coordinator.setBackgroundPlaybackEnabled(false);

        await metronomeRepo.start();
        await Future<void>.delayed(Duration.zero);

        check(coordinator.isNotificationSessionActive).isFalse();
        check(service.syncedSnapshots).isEmpty();

        await coordinator.onAppBackgrounded();
        check(metronomeRepo.state.isPlaying).isFalse();
      },
    );

    test(
      'keeps playing when app backgrounds if background playback is enabled',
      () async {
        await metronomeRepo.start();
        await Future<void>.delayed(Duration.zero);

        await coordinator.onAppBackgrounded();

        check(metronomeRepo.state.isPlaying).isTrue();
        check(coordinator.isNotificationSessionActive).isTrue();
      },
    );

    test(
      'dismisses active notification when user disables background playback',
      () async {
        await metronomeRepo.start();
        await Future<void>.delayed(Duration.zero);
        check(coordinator.isNotificationSessionActive).isTrue();

        await prefsRepo.setBackgroundPlaybackEnabled(false);
        await coordinator.setBackgroundPlaybackEnabled(false);

        check(coordinator.isNotificationSessionActive).isFalse();
        check(service.dismissCalls).equals(1);
      },
    );
  });
}

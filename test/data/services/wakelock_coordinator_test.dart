import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metronome/data/repositories/metronome_repository.dart';
import 'package:metronome/data/repositories/preferences_repository.dart';
import 'package:metronome/data/services/simulated_metronome_engine.dart';
import 'package:metronome/data/services/wakelock_coordinator.dart';
import 'package:metronome/data/services/wakelock_service.dart';

class _FakeWakelockService implements WakelockService {
  final List<bool> calls = [];
  bool isEnabled = false;
  bool disposed = false;

  @override
  Future<void> setEnabled(bool enabled) async {
    calls.add(enabled);
    isEnabled = enabled;
  }

  @override
  Future<void> dispose() async {
    disposed = true;
  }
}

void main() {
  group('WakelockCoordinator', () {
    late SimulatedMetronomeEngine engine;
    late MetronomeRepository metronomeRepo;
    late PreferencesRepository preferencesRepo;
    late _FakeWakelockService wakelockService;
    late WakelockCoordinator coordinator;

    setUp(() {
      engine = SimulatedMetronomeEngine();
      metronomeRepo = MetronomeRepository(engine: engine);
      preferencesRepo = PreferencesRepository(preferences: null);
      wakelockService = _FakeWakelockService();
      coordinator = WakelockCoordinator(
        metronomeRepository: metronomeRepo,
        preferencesRepository: preferencesRepo,
        wakelockService: wakelockService,
      );
    });

    tearDown(() async {
      await coordinator.dispose();
      await metronomeRepo.dispose();
    });

    test(
      'enables wakelock on start and disables on stop when preference is true',
      () async {
        check(coordinator.isKeepScreenAwakeEnabled).isTrue();
        check(wakelockService.calls).isEmpty();

        await metronomeRepo.start();
        await Future<void>.delayed(Duration.zero);

        check(coordinator.isWakelockActive).isTrue();
        check(wakelockService.isEnabled).isTrue();
        check(wakelockService.calls).deepEquals([true]);

        await metronomeRepo.stop();
        await Future<void>.delayed(Duration.zero);

        check(coordinator.isWakelockActive).isFalse();
        check(wakelockService.isEnabled).isFalse();
        check(wakelockService.calls).deepEquals([true, false]);
      },
    );

    test(
      'does not enable wakelock while playing when preference is false',
      () async {
        await preferencesRepo.setKeepScreenAwake(false);
        await coordinator.syncPreference();

        await metronomeRepo.start();
        await Future<void>.delayed(Duration.zero);

        check(coordinator.isWakelockActive).isFalse();
        check(wakelockService.isEnabled).isFalse();
        check(wakelockService.calls).isEmpty();
      },
    );

    test(
      'toggling preference during playback updates wakelock immediately',
      () async {
        await metronomeRepo.start();
        await Future<void>.delayed(Duration.zero);
        check(wakelockService.calls).deepEquals([true]);

        await preferencesRepo.setKeepScreenAwake(false);
        await coordinator.syncPreference();
        check(coordinator.isWakelockActive).isFalse();
        check(wakelockService.calls).deepEquals([true, false]);

        await preferencesRepo.setKeepScreenAwake(true);
        await coordinator.syncPreference();
        check(coordinator.isWakelockActive).isTrue();
        check(wakelockService.calls).deepEquals([true, false, true]);
      },
    );

    test('releases wakelock on app background and re-acquires on resume if still playing', () async {
      await metronomeRepo.start();
      await Future<void>.delayed(Duration.zero);
      check(wakelockService.isEnabled).isTrue();

      await coordinator.onAppBackgrounded();
      check(coordinator.isWakelockActive).isFalse();
      check(wakelockService.isEnabled).isFalse();

      await coordinator.onAppResumed();
      check(coordinator.isWakelockActive).isTrue();
      check(wakelockService.isEnabled).isTrue();
      check(wakelockService.calls).deepEquals([true, false, true]);
    });

    test('does not re-acquire wakelock on resume if metronome stopped in background', () async {
      await metronomeRepo.start();
      await Future<void>.delayed(Duration.zero);

      await coordinator.onAppBackgrounded();
      await metronomeRepo.stop();
      await Future<void>.delayed(Duration.zero);

      await coordinator.onAppResumed();
      check(coordinator.isWakelockActive).isFalse();
      check(wakelockService.isEnabled).isFalse();
      check(wakelockService.calls).deepEquals([true, false]);
    });

    test('disables active wakelock on dispose', () async {
      await metronomeRepo.start();
      await Future<void>.delayed(Duration.zero);
      check(wakelockService.isEnabled).isTrue();

      await coordinator.dispose();
      check(coordinator.isWakelockActive).isFalse();
      check(wakelockService.isEnabled).isFalse();
      check(wakelockService.calls).deepEquals([true, false]);
    });
  });
}

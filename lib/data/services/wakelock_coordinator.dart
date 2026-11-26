import 'dart:async';

import '../../domain/models/metronome_state.dart';
import '../repositories/metronome_repository.dart';
import '../repositories/preferences_repository.dart';
import 'wakelock_service.dart';

/// Coordinates [MetronomeRepository] playback state, app foreground lifecycle,
/// and the "Keep screen awake" user preference with [WakelockService]
/// (FR-CFG-02).
class WakelockCoordinator {
  WakelockCoordinator({
    required MetronomeRepository metronomeRepository,
    required PreferencesRepository preferencesRepository,
    required WakelockService wakelockService,
  }) : _metronomeRepository = metronomeRepository,
       _preferencesRepository = preferencesRepository,
       _wakelockService = wakelockService {
    _stateSubscription = _metronomeRepository.stateChanges.listen(
      _onMetronomeStateChanged,
    );
  }

  final MetronomeRepository _metronomeRepository;
  final PreferencesRepository _preferencesRepository;
  final WakelockService _wakelockService;

  StreamSubscription<MetronomeState>? _stateSubscription;
  bool _isAppInForeground = true;
  bool _isWakelockActive = false;
  bool _isDisposed = false;

  /// Whether the "Keep screen awake" preference is currently enabled.
  bool get isKeepScreenAwakeEnabled =>
      _preferencesRepository.getKeepScreenAwake();

  /// Whether the screen wake lock is currently active.
  bool get isWakelockActive => _isWakelockActive;

  /// Whether the screen wake lock should be active given current state.
  bool get shouldKeepScreenAwake =>
      !_isDisposed &&
      _isAppInForeground &&
      isKeepScreenAwakeEnabled &&
      _metronomeRepository.state.isPlaying;

  /// Synchronizes wake lock state when the user toggles the preference.
  Future<void> syncPreference() => _syncWakelock();

  /// Releases the wake lock when the app moves to the background.
  Future<void> onAppBackgrounded() async {
    _isAppInForeground = false;
    await _syncWakelock();
  }

  /// Re-evaluates the wake lock when the app returns to the foreground.
  Future<void> onAppResumed() async {
    _isAppInForeground = true;
    await _syncWakelock();
  }

  void _onMetronomeStateChanged(MetronomeState state) {
    unawaited(_syncWakelock());
  }

  Future<void> _syncWakelock() async {
    final desired = shouldKeepScreenAwake;
    if (_isWakelockActive == desired) return;
    _isWakelockActive = desired;
    await _wakelockService.setEnabled(desired);
  }

  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await _stateSubscription?.cancel();
    if (_isWakelockActive) {
      _isWakelockActive = false;
      await _wakelockService.setEnabled(false);
    }
  }
}

import 'dart:async';

import '../../domain/models/metronome_state.dart';
import '../repositories/metronome_repository.dart';
import '../repositories/preferences_repository.dart';
import '../repositories/preset_library_repository.dart';
import 'background_playback_service.dart';

/// Coordinates [MetronomeRepository] state with [BackgroundPlaybackService],
/// handling notification lifecycle, control actions (`-1 BPM`, `Play/Pause`,
/// `+1 BPM`, `Close`), and app background transitions.
class BackgroundPlaybackCoordinator {
  BackgroundPlaybackCoordinator({
    required MetronomeRepository metronomeRepository,
    required PreferencesRepository preferencesRepository,
    required BackgroundPlaybackService backgroundService,
    PresetLibraryRepository? presetLibraryRepository,
  }) : _metronomeRepository = metronomeRepository,
       _preferencesRepository = preferencesRepository,
       _backgroundService = backgroundService {
    _stateSubscription = _metronomeRepository.stateChanges.listen(
      _onMetronomeStateChanged,
    );
    _commandSubscription = _backgroundService.commands.listen(
      _onBackgroundCommand,
    );
  }

  final MetronomeRepository _metronomeRepository;
  final PreferencesRepository _preferencesRepository;
  final BackgroundPlaybackService _backgroundService;

  StreamSubscription<MetronomeState>? _stateSubscription;
  StreamSubscription<BackgroundPlaybackCommand>? _commandSubscription;

  bool _notificationSessionActive = false;
  BackgroundPlaybackSnapshot? _lastSyncedSnapshot;

  /// Whether a background notification session is currently active (playing or
  /// paused with controls still shown).
  bool get isNotificationSessionActive => _notificationSessionActive;

  /// Whether background playback is currently enabled in user preferences.
  bool get isBackgroundPlaybackEnabled =>
      _preferencesRepository.getBackgroundPlaybackEnabled();

  /// Initializes the underlying platform service.
  Future<void> initialize() => _backgroundService.initialize();

  /// Synchronizes coordinator behavior when the user toggles the
  /// "Background playback" preference.
  Future<void> setBackgroundPlaybackEnabled(bool enabled) async {
    if (!enabled) {
      await _endNotificationSession();
      return;
    }

    if (_metronomeRepository.state.isPlaying) {
      _notificationSessionActive = true;
      await _backgroundService.requestNotificationPermission();
      await _pushSnapshot(_buildSnapshot(_metronomeRepository.state));
    }
  }

  /// Called when the application moves to the background (e.g. Home button).
  ///
  /// When background playback is disabled, stops the metronome immediately.
  /// When enabled and playing, ensures the notification is synchronized.
  Future<void> onAppBackgrounded() async {
    if (!isBackgroundPlaybackEnabled) {
      if (_metronomeRepository.state.isPlaying) {
        await _metronomeRepository.stop();
      }
      await _endNotificationSession();
      return;
    }

    if (_notificationSessionActive) {
      await _pushSnapshot(_buildSnapshot(_metronomeRepository.state));
    }
  }

  void _onMetronomeStateChanged(MetronomeState state) {
    if (!isBackgroundPlaybackEnabled) {
      if (_notificationSessionActive) {
        unawaited(_endNotificationSession());
      }
      return;
    }

    if (state.isPlaying && !_notificationSessionActive) {
      _notificationSessionActive = true;
      unawaited(_backgroundService.requestNotificationPermission());
    }

    if (!_notificationSessionActive) return;

    final snapshot = _buildSnapshot(state);
    if (snapshot == _lastSyncedSnapshot) return;
    unawaited(_pushSnapshot(snapshot));
  }

  Future<void> _onBackgroundCommand(BackgroundPlaybackCommand command) async {
    switch (command) {
      case BackgroundPlaybackCommand.play:
        if (!isBackgroundPlaybackEnabled) return;
        _notificationSessionActive = true;
        await _metronomeRepository.start();
      case BackgroundPlaybackCommand.pause:
        await _metronomeRepository.stop();
      case BackgroundPlaybackCommand.stop:
        _notificationSessionActive = false;
        _lastSyncedSnapshot = null;
        await _metronomeRepository.stop();
        await _backgroundService.dismissNotification();
      case BackgroundPlaybackCommand.decreaseBpm:
        _metronomeRepository.setBpm(_metronomeRepository.state.bpm.adjust(-1));
      case BackgroundPlaybackCommand.increaseBpm:
        _metronomeRepository.setBpm(_metronomeRepository.state.bpm.adjust(1));
    }
  }

  BackgroundPlaybackSnapshot _buildSnapshot(MetronomeState state) {
    return BackgroundPlaybackSnapshot(
      isPlaying: state.isPlaying,
      bpm: state.bpm.value,
    );
  }

  Future<void> _pushSnapshot(BackgroundPlaybackSnapshot snapshot) async {
    _lastSyncedSnapshot = snapshot;
    await _backgroundService.syncState(snapshot);
  }

  Future<void> _endNotificationSession() async {
    final wasActive = _notificationSessionActive || _lastSyncedSnapshot != null;
    _notificationSessionActive = false;
    _lastSyncedSnapshot = null;
    if (wasActive) {
      await _backgroundService.dismissNotification();
    }
  }

  Future<void> dispose() async {
    await _stateSubscription?.cancel();
    await _commandSubscription?.cancel();
  }
}

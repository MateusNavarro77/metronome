import 'dart:async';

/// Commands emitted by system controls (Android custom metronome notification,
/// iOS Lock Screen / Control Center, Bluetooth media buttons, or audio
/// interruptions).
enum BackgroundPlaybackCommand {
  /// Resume or start metronome playback.
  play,

  /// Pause metronome playback while keeping the notification available.
  pause,

  /// Stop metronome playback and dismiss the notification.
  stop,

  /// Decrease tempo by 1 BPM.
  decreaseBpm,

  /// Increase tempo by 1 BPM.
  increaseBpm,
}

/// Immutable snapshot of metronome state displayed in system background controls.
class BackgroundPlaybackSnapshot {
  const BackgroundPlaybackSnapshot({
    required this.isPlaying,
    required this.bpm,
  });

  /// Whether the metronome is currently playing.
  final bool isPlaying;

  /// Current tempo in beats per minute (`30..300`).
  final int bpm;

  /// Formatted title shown in system controls.
  String get title => '$bpm BPM';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is BackgroundPlaybackSnapshot &&
            other.isPlaying == isPlaying &&
            other.bpm == bpm);
  }

  @override
  int get hashCode => Object.hash(isPlaying, bpm);

  @override
  String toString() =>
      'BackgroundPlaybackSnapshot(isPlaying: $isPlaying, bpm: $bpm)';
}

/// Abstract platform service managing background audio session, Android custom
/// metronome notification, and iOS Now Playing controls (NFR-MAN-02).
abstract interface class BackgroundPlaybackService {
  /// Broadcast stream of commands triggered from outside the app UI.
  Stream<BackgroundPlaybackCommand> get commands;

  /// Initializes the platform audio session and background controls.
  Future<void> initialize();

  /// Requests notification display permission when required (Android 13+).
  Future<void> requestNotificationPermission();

  /// Updates the active background notification / Now Playing state.
  Future<void> syncState(BackgroundPlaybackSnapshot snapshot);

  /// Dismisses the notification and ends the active background session.
  Future<void> dismissNotification();

  /// Releases resources and closes streams.
  Future<void> dispose();
}

/// Safe no-op [BackgroundPlaybackService] for unsupported platforms and tests.
class NoopBackgroundPlaybackService implements BackgroundPlaybackService {
  final StreamController<BackgroundPlaybackCommand> _commandsController =
      StreamController<BackgroundPlaybackCommand>.broadcast();

  @override
  Stream<BackgroundPlaybackCommand> get commands => _commandsController.stream;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> requestNotificationPermission() async {}

  @override
  Future<void> syncState(BackgroundPlaybackSnapshot snapshot) async {}

  @override
  Future<void> dismissNotification() async {}

  @override
  Future<void> dispose() async {
    await _commandsController.close();
  }
}

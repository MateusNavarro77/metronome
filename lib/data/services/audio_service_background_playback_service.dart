import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'background_playback_service.dart';

/// Platform implementation of [BackgroundPlaybackService]:
/// - **Android**: custom native `RemoteViews` foreground service notification
///   (`MetronomeNotificationService`) with `-1`, `+1`, `Play/Pause`, and `Close`
///   controls.
/// - **iOS**: `audio_service` Now Playing lock-screen / Control Center controls.
/// - **Both**: `audio_session` configured to mix with other music apps while
///   pausing on phone calls and headphone disconnect.
class AudioServiceBackgroundPlaybackService
    implements BackgroundPlaybackService {
  static const MethodChannel _notificationsChannel = MethodChannel(
    'com.mateusnavarro77.metronome/notifications',
  );

  static const MediaControl _decreaseBpmControl = MediaControl(
    androidIcon: 'drawable/ic_notification_minus',
    label: '-1 BPM',
    action: MediaAction.skipToPrevious,
  );

  static const MediaControl _increaseBpmControl = MediaControl(
    androidIcon: 'drawable/ic_notification_plus',
    label: '+1 BPM',
    action: MediaAction.skipToNext,
  );

  final StreamController<BackgroundPlaybackCommand> _commandsController =
      StreamController<BackgroundPlaybackCommand>.broadcast();

  _MetronomeAudioHandler? _iosHandler;
  StreamSubscription<void>? _becomingNoisySubscription;
  StreamSubscription<AudioInterruptionEvent>? _interruptionSubscription;

  bool _isInitialized = false;
  bool _permissionRequested = false;

  bool get _isRunningInTest =>
      WidgetsBinding.instance.runtimeType.toString().contains('Test');

  bool get _isAndroid =>
      !kIsWeb &&
      !_isRunningInTest &&
      defaultTargetPlatform == TargetPlatform.android;

  bool get _isIos =>
      !kIsWeb &&
      !_isRunningInTest &&
      defaultTargetPlatform == TargetPlatform.iOS;

  bool get _isSupportedPlatform => _isAndroid || _isIos;

  @override
  Stream<BackgroundPlaybackCommand> get commands => _commandsController.stream;

  @override
  Future<void> initialize() async {
    if (_isInitialized || !_isSupportedPlatform) return;
    _isInitialized = true;

    try {
      await _configureAudioSession();
    } catch (_) {
      // Ignore audio session failures on headless/unsupported runners.
    }

    if (_isAndroid) {
      _notificationsChannel.setMethodCallHandler(_handleAndroidMethodCall);
      return;
    }

    if (_isIos) {
      try {
        _iosHandler = await AudioService.init(
          builder: () => _MetronomeAudioHandler(onCommand: _emitCommand),
          config: const AudioServiceConfig(
            androidNotificationChannelId:
                'com.mateusnavarro77.metronome.channel.audio',
            androidNotificationChannelName: 'Metronome Playback',
          ),
        );
      } catch (_) {
        _iosHandler = null;
      }
    }
  }

  Future<void> _handleAndroidMethodCall(MethodCall call) async {
    if (call.method != 'onNotificationCommand') return;
    final commandName = call.arguments as String?;
    switch (commandName) {
      case 'play':
        _emitCommand(BackgroundPlaybackCommand.play);
      case 'pause':
        _emitCommand(BackgroundPlaybackCommand.pause);
      case 'stop':
        _emitCommand(BackgroundPlaybackCommand.stop);
      case 'decreaseBpm':
        _emitCommand(BackgroundPlaybackCommand.decreaseBpm);
      case 'increaseBpm':
        _emitCommand(BackgroundPlaybackCommand.increaseBpm);
    }
  }

  Future<void> _configureAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(
      const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.mixWithOthers,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        avAudioSessionRouteSharingPolicy:
            AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: false,
      ),
    );

    // Pause when headphones or Bluetooth audio devices disconnect.
    _becomingNoisySubscription = session.becomingNoisyEventStream.listen((_) {
      _emitCommand(BackgroundPlaybackCommand.pause);
    });

    // Pause on phone calls / audio interruptions while allowing mixing with
    // other music apps.
    _interruptionSubscription = session.interruptionEventStream.listen((event) {
      if (event.begin &&
          (event.type == AudioInterruptionType.pause ||
              event.type == AudioInterruptionType.unknown)) {
        _emitCommand(BackgroundPlaybackCommand.pause);
      }
    });
  }

  @override
  Future<void> requestNotificationPermission() async {
    if (_permissionRequested || !_isAndroid) return;
    _permissionRequested = true;
    try {
      await _notificationsChannel.invokeMethod<void>(
        'requestNotificationPermission',
      );
    } catch (_) {
      // Ignore if channel is unavailable.
    }
  }

  @override
  Future<void> syncState(BackgroundPlaybackSnapshot snapshot) async {
    if (!_isSupportedPlatform) return;
    if (!_isInitialized) {
      await initialize();
    }

    if (_isAndroid) {
      try {
        await _notificationsChannel.invokeMethod<void>('syncNotification', {
          'bpm': snapshot.bpm,
          'isPlaying': snapshot.isPlaying,
        });
      } catch (_) {
        // Ignore if channel is unavailable.
      }
      return;
    }

    final handler = _iosHandler;
    if (handler == null) return;

    handler.updateSnapshot(
      snapshot: snapshot,
      decreaseBpmControl: _decreaseBpmControl,
      increaseBpmControl: _increaseBpmControl,
    );
  }

  @override
  Future<void> dismissNotification() async {
    if (_isAndroid) {
      try {
        await _notificationsChannel.invokeMethod<void>('dismissNotification');
      } catch (_) {}
      return;
    }
    await _iosHandler?.dismissNotification();
  }

  void _emitCommand(BackgroundPlaybackCommand command) {
    if (!_commandsController.isClosed) {
      _commandsController.add(command);
    }
  }

  @override
  Future<void> dispose() async {
    if (_isAndroid) {
      _notificationsChannel.setMethodCallHandler(null);
    }
    await _becomingNoisySubscription?.cancel();
    await _interruptionSubscription?.cancel();
    await dismissNotification();
    await _commandsController.close();
  }
}

class _MetronomeAudioHandler extends BaseAudioHandler {
  _MetronomeAudioHandler({
    required void Function(BackgroundPlaybackCommand command) onCommand,
  }) : _onCommand = onCommand;

  final void Function(BackgroundPlaybackCommand command) _onCommand;
  bool _isCurrentlyPlaying = false;

  void updateSnapshot({
    required BackgroundPlaybackSnapshot snapshot,
    required MediaControl decreaseBpmControl,
    required MediaControl increaseBpmControl,
  }) {
    _isCurrentlyPlaying = snapshot.isPlaying;

    mediaItem.add(MediaItem(id: 'metronome_live', title: snapshot.title));

    playbackState.add(
      PlaybackState(
        controls: [
          decreaseBpmControl,
          snapshot.isPlaying ? MediaControl.pause : MediaControl.play,
          increaseBpmControl,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.play,
          MediaAction.pause,
          MediaAction.playPause,
          MediaAction.stop,
          MediaAction.skipToPrevious,
          MediaAction.skipToNext,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: AudioProcessingState.ready,
        playing: snapshot.isPlaying,
      ),
    );
  }

  Future<void> dismissNotification() async {
    _isCurrentlyPlaying = false;
    playbackState.add(
      playbackState.value.copyWith(
        controls: const [],
        playing: false,
        processingState: AudioProcessingState.idle,
      ),
    );
    await super.stop();
  }

  @override
  Future<void> play() async {
    _onCommand(BackgroundPlaybackCommand.play);
  }

  @override
  Future<void> pause() async {
    _onCommand(BackgroundPlaybackCommand.pause);
  }

  @override
  Future<void> stop() async {
    _onCommand(BackgroundPlaybackCommand.stop);
    await dismissNotification();
  }

  @override
  Future<void> skipToPrevious() async {
    _onCommand(BackgroundPlaybackCommand.decreaseBpm);
  }

  @override
  Future<void> skipToNext() async {
    _onCommand(BackgroundPlaybackCommand.increaseBpm);
  }

  @override
  Future<void> onTaskRemoved() async {
    if (!_isCurrentlyPlaying) {
      await stop();
    }
  }
}

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

import '../../domain/models/beat_event.dart';
import '../../domain/models/bpm.dart';
import '../../domain/models/subdivision.dart';
import '../../domain/models/time_signature.dart';
import '../../domain/use_cases/click_scheduler.dart';
import 'metronome_engine.dart';
import 'pcm_click_synthesizer.dart';

/// Low-latency audio implementation of [MetronomeEngine] powered by preloaded
/// in-memory PCM samples in `flutter_soloud` (C++ SoLoud/miniaudio engine)
/// and drift-compensated monotonic scheduling.
class SoloudMetronomeEngine implements MetronomeEngine {
  SoloudMetronomeEngine({
    ClickScheduler scheduler = const ClickScheduler(),
    PcmClickSynthesizer synthesizer = const PcmClickSynthesizer(),
  }) : _scheduler = scheduler,
       _synthesizer = synthesizer;

  final ClickScheduler _scheduler;
  final PcmClickSynthesizer _synthesizer;
  final StreamController<BeatEvent> _beatController =
      StreamController<BeatEvent>.broadcast();

  final Map<BeatAccent, AudioSource> _preloadedSounds = {};
  final Stopwatch _stopwatch = Stopwatch();

  Timer? _nextPulseTimer;
  bool _isInitialized = false;
  bool _audioAvailable = false;
  bool _isPlaying = false;
  bool _isAccentEnabled = true;

  Bpm _bpm = Bpm.initial;
  TimeSignature _timeSignature = TimeSignature.fourFour;
  Subdivision _subdivision = Subdivision.none;

  Bpm? _pendingBpm;
  TimeSignature? _pendingTimeSignature;
  Subdivision? _pendingSubdivision;
  bool? _pendingAccentEnabled;

  int _currentBeat = 0;
  int _currentSubdivision = 0;
  Duration _nextTargetTimestamp = Duration.zero;

  @override
  Stream<BeatEvent> get beatEvents => _beatController.stream;

  @override
  bool get isPlaying => _isPlaying;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      final soloud = SoLoud.instance;
      if (!soloud.isInitialized) {
        await soloud.init(sampleRate: 44100, bufferSize: 512);
      }
      for (final accent in BeatAccent.values) {
        final wavBytes = _synthesizer.buildWavBytes(accent);
        final source = await soloud.loadMem(
          'click_${accent.name}.wav',
          wavBytes,
        );
        _preloadedSounds[accent] = source;
      }
      _audioAvailable = true;
    } catch (_) {
      // Fallback gracefully if running in a headless environment without audio output
      _audioAvailable = false;
    }
  }

  @override
  Future<void> start({
    required Bpm bpm,
    required TimeSignature timeSignature,
    required Subdivision subdivision,
    bool isAccentEnabled = true,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }
    _nextPulseTimer?.cancel();
    _clearPendingConfiguration();

    _bpm = bpm;
    _timeSignature = timeSignature;
    _subdivision = subdivision;
    _isAccentEnabled = isAccentEnabled;
    _currentBeat = 0;
    _currentSubdivision = 0;
    _isPlaying = true;

    _stopwatch
      ..reset()
      ..start();
    _nextTargetTimestamp = Duration.zero;

    // Immediately fire Beat 1 (strong beat) on start (FR-PLY-02, NFR-LAT-01).
    _emitCurrentPulseAndScheduleNext();
  }

  @override
  Future<void> stop() async {
    _nextPulseTimer?.cancel();
    _nextPulseTimer = null;
    _clearPendingConfiguration();
    _isPlaying = false;
    _stopwatch.stop();
    _currentBeat = 0;
    _currentSubdivision = 0;
  }

  @override
  void updateConfiguration({
    Bpm? bpm,
    TimeSignature? timeSignature,
    Subdivision? subdivision,
    bool? isAccentEnabled,
  }) {
    if (bpm != null) {
      _bpm = bpm;
      _pendingBpm = null;
    }
    if (timeSignature != null) {
      _timeSignature = timeSignature;
      _pendingTimeSignature = null;
      if (_currentBeat >= _timeSignature.numerator) {
        _currentBeat = 0;
      }
    }
    if (subdivision != null) {
      _pendingSubdivision = null;
      if (subdivision != _subdivision) {
        _subdivision = subdivision;
        // Apply subdivision change cleanly from the next beat (FR-SUB-03)
        if (_currentSubdivision >= _subdivision.pulsesPerBeat) {
          _currentSubdivision = 0;
        }
      }
    }
    if (isAccentEnabled != null) {
      _isAccentEnabled = isAccentEnabled;
      _pendingAccentEnabled = null;
    }
  }

  @override
  void scheduleNextBarConfiguration({
    Bpm? bpm,
    TimeSignature? timeSignature,
    Subdivision? subdivision,
    bool? isAccentEnabled,
  }) {
    if (!_isPlaying) {
      _clearPendingConfiguration();
      updateConfiguration(
        bpm: bpm,
        timeSignature: timeSignature,
        subdivision: subdivision,
        isAccentEnabled: isAccentEnabled,
      );
      return;
    }
    if (bpm != null) _pendingBpm = bpm;
    if (timeSignature != null) _pendingTimeSignature = timeSignature;
    if (subdivision != null) _pendingSubdivision = subdivision;
    if (isAccentEnabled != null) _pendingAccentEnabled = isAccentEnabled;
  }

  void _applyPendingBarConfigurationIfDownbeat() {
    if (_currentBeat != 0 || _currentSubdivision != 0) return;
    if (_pendingBpm != null) _bpm = _pendingBpm!;
    if (_pendingTimeSignature != null) _timeSignature = _pendingTimeSignature!;
    if (_pendingSubdivision != null) _subdivision = _pendingSubdivision!;
    if (_pendingAccentEnabled != null) {
      _isAccentEnabled = _pendingAccentEnabled!;
    }
    _clearPendingConfiguration();
  }

  void _clearPendingConfiguration() {
    _pendingBpm = null;
    _pendingTimeSignature = null;
    _pendingSubdivision = null;
    _pendingAccentEnabled = null;
  }

  void _emitCurrentPulseAndScheduleNext() {
    if (!_isPlaying) return;

    _applyPendingBarConfigurationIfDownbeat();

    final accent = _scheduler.resolveAccent(
      timeSignature: _timeSignature,
      beatIndex: _currentBeat,
      subdivisionIndex: _currentSubdivision,
      isAccentEnabled: _isAccentEnabled,
    );

    _triggerSound(accent);

    final event = BeatEvent(
      beatIndex: _currentBeat,
      subdivisionIndex: _currentSubdivision,
      accent: accent,
      timestamp: _stopwatch.elapsed,
    );

    if (!_beatController.isClosed) {
      _beatController.add(event);
    }

    // Advance indices for the next pulse
    final nextPos = _scheduler.nextPulsePosition(
      currentBeat: _currentBeat,
      currentSubdivision: _currentSubdivision,
      timeSignature: _timeSignature,
      subdivision: _subdivision,
    );
    _currentBeat = nextPos.beatIndex;
    _currentSubdivision = nextPos.subdivisionIndex;

    // Drift-compensated scheduling against the monotonic Stopwatch
    final interval = _scheduler.pulseInterval(
      bpm: _bpm,
      subdivision: _subdivision,
    );
    _nextTargetTimestamp += interval;
    final now = _stopwatch.elapsed;
    final delay = _nextTargetTimestamp - now;
    final clampedDelay = delay.isNegative ? Duration.zero : delay;

    _nextPulseTimer = Timer(clampedDelay, _emitCurrentPulseAndScheduleNext);
  }

  void _triggerSound(BeatAccent accent) {
    if (_audioAvailable) {
      final source = _preloadedSounds[accent];
      if (source != null) {
        SoLoud.instance.play(source, volume: accent.defaultRelativeVolume);
        return;
      }
    }
    // Fallback to subtle system click when native audio device is unavailable
    SystemSound.play(SystemSoundType.click);
  }

  @override
  Future<void> dispose() async {
    await stop();
    if (_audioAvailable) {
      try {
        await SoLoud.instance.disposeAllSources();
      } catch (_) {}
    }
    await _beatController.close();
  }
}

import 'dart:async';

import '../../domain/models/beat_event.dart';
import '../../domain/models/bpm.dart';
import '../../domain/models/subdivision.dart';
import '../../domain/models/time_signature.dart';
import '../../domain/use_cases/click_scheduler.dart';
import 'metronome_engine.dart';

/// Deterministic, synchronous/step-controllable [MetronomeEngine] for unit and
/// widget tests (NFR-MAN-02, NFR-TST-01).
class SimulatedMetronomeEngine implements MetronomeEngine {
  SimulatedMetronomeEngine({ClickScheduler scheduler = const ClickScheduler()})
    : _scheduler = scheduler;

  final ClickScheduler _scheduler;
  final StreamController<BeatEvent> _beatController =
      StreamController<BeatEvent>.broadcast();

  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isAccentEnabled = true;
  Bpm _bpm = Bpm.initial;
  TimeSignature _timeSignature = TimeSignature.fourFour;
  Subdivision _subdivision = Subdivision.none;

  int _currentBeat = 0;
  int _currentSubdivision = 0;
  Duration _elapsed = Duration.zero;

  /// History of all [BeatEvent]s emitted since last [start].
  final List<BeatEvent> emittedEvents = [];

  Bpm get bpm => _bpm;
  TimeSignature get timeSignature => _timeSignature;
  Subdivision get subdivision => _subdivision;
  bool get isAccentEnabled => _isAccentEnabled;
  bool get isInitialized => _isInitialized;

  @override
  Stream<BeatEvent> get beatEvents => _beatController.stream;

  @override
  bool get isPlaying => _isPlaying;

  @override
  Future<void> initialize() async {
    _isInitialized = true;
  }

  @override
  Future<void> start({
    required Bpm bpm,
    required TimeSignature timeSignature,
    required Subdivision subdivision,
    bool isAccentEnabled = true,
  }) async {
    _isInitialized = true;
    _bpm = bpm;
    _timeSignature = timeSignature;
    _subdivision = subdivision;
    _isAccentEnabled = isAccentEnabled;
    _currentBeat = 0;
    _currentSubdivision = 0;
    _elapsed = Duration.zero;
    _isPlaying = true;
    emittedEvents.clear();

    // Emit Beat 1 immediately upon start (FR-PLY-02)
    emitNextPulse();
  }

  @override
  Future<void> stop() async {
    _isPlaying = false;
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
    if (bpm != null) _bpm = bpm;
    if (timeSignature != null) {
      _timeSignature = timeSignature;
      if (_currentBeat >= _timeSignature.numerator) {
        _currentBeat = 0;
      }
    }
    if (subdivision != null) {
      _subdivision = subdivision;
      if (_currentSubdivision >= _subdivision.pulsesPerBeat) {
        _currentSubdivision = 0;
      }
    }
    if (isAccentEnabled != null) {
      _isAccentEnabled = isAccentEnabled;
    }
  }

  /// Advances the simulated engine by [count] pulses, emitting each [BeatEvent].
  void advancePulses([int count = 1]) {
    for (var i = 0; i < count; i++) {
      if (!_isPlaying) return;
      final step = _scheduler.pulseInterval(
        bpm: _bpm,
        subdivision: _subdivision,
      );
      _elapsed += step;
      emitNextPulse();
    }
  }

  /// Emits the current pulse and advances internal counters to the next position.
  void emitNextPulse() {
    if (!_isPlaying) return;

    final accent = _scheduler.resolveAccent(
      timeSignature: _timeSignature,
      beatIndex: _currentBeat,
      subdivisionIndex: _currentSubdivision,
      isAccentEnabled: _isAccentEnabled,
    );

    final event = BeatEvent(
      beatIndex: _currentBeat,
      subdivisionIndex: _currentSubdivision,
      accent: accent,
      timestamp: _elapsed,
    );

    emittedEvents.add(event);
    if (!_beatController.isClosed) {
      _beatController.add(event);
    }

    final nextPos = _scheduler.nextPulsePosition(
      currentBeat: _currentBeat,
      currentSubdivision: _currentSubdivision,
      timeSignature: _timeSignature,
      subdivision: _subdivision,
    );
    _currentBeat = nextPos.beatIndex;
    _currentSubdivision = nextPos.subdivisionIndex;
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _beatController.close();
  }
}

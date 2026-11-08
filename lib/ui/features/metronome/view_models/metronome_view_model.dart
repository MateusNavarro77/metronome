import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/metronome_repository.dart';
import '../../../../domain/models/bpm.dart';
import '../../../../domain/models/metronome_state.dart';
import '../../../../domain/models/subdivision.dart';
import '../../../../domain/models/tempo_marking.dart';
import '../../../../domain/models/time_signature.dart';
import '../../../../domain/use_cases/tap_tempo_calculator.dart';

/// ViewModel for the main Metronome screen following the MVVM pattern.
///
/// Manages UI state, continuous button hold acceleration (FR-BPM-02), and
/// monotonic tap tempo calculation (FR-TAP-05).
class MetronomeViewModel extends ChangeNotifier {
  MetronomeViewModel({
    required MetronomeRepository repository,
    TapTempoCalculator? tapTempoCalculator,
    Duration Function()? clock,
  }) : _repository = repository,
       _tapTempoCalculator = tapTempoCalculator ?? TapTempoCalculator(),
       _clock = clock {
    _monotonicWatch.start();
    _stateSubscription = _repository.stateChanges.listen((_) {
      notifyListeners();
    });
  }

  final MetronomeRepository _repository;
  final TapTempoCalculator _tapTempoCalculator;
  final Duration Function()? _clock;
  final Stopwatch _monotonicWatch = Stopwatch();

  StreamSubscription<MetronomeState>? _stateSubscription;
  Timer? _holdRepeatTimer;
  int _holdTicks = 0;

  /// Current immutable [MetronomeState] snapshot.
  MetronomeState get state => _repository.state;

  /// Current BPM value (`30..300`).
  int get bpmValue => state.bpm.value;

  /// Current [TempoMarking] (e.g. Allegro, Andante).
  TempoMarking get tempoMarking => state.tempoMarking;

  /// Current [TimeSignature].
  TimeSignature get timeSignature => state.timeSignature;

  /// Current [Subdivision].
  Subdivision get subdivision => state.subdivision;

  /// Whether the metronome is currently playing.
  bool get isPlaying => state.isPlaying;

  /// Active 0-based beat index within the bar (`0 .. timeSignature.numerator - 1`).
  int get currentBeat => state.currentBeat;

  /// Active 0-based subdivision index within the beat (`0 .. subdivision.pulsesPerBeat - 1`).
  int get currentSubdivision => state.currentSubdivision;

  /// Initializes the audio engine.
  Future<void> initialize() => _repository.initialize();

  /// Sets the BPM to [value] (clamped to `[30, 300]`).
  void setBpm(int value) {
    _repository.setBpm(Bpm.clamped(value));
  }

  /// Adjusts the BPM by [delta] (e.g. `-1`, `+1`, `-5`, `+5`).
  void adjustBpm(int delta) {
    _repository.setBpm(state.bpm.adjust(delta));
  }

  /// Starts continuous BPM adjustment with acceleration while a `-` or `+`
  /// button is held down (FR-BPM-02).
  void startContinuousBpmAdjustment(int direction) {
    stopContinuousBpmAdjustment();
    final stepSign = direction.sign;
    if (stepSign == 0) return;

    _holdTicks = 0;
    _holdRepeatTimer = Timer.periodic(
      const Duration(milliseconds: 110),
      (_) {
        _holdTicks++;
        // Accelerate step size the longer the user holds the button
        final magnitude = switch (_holdTicks) {
          < 8 => 1,
          < 18 => 2,
          _ => 5,
        };
        adjustBpm(stepSign * magnitude);
      },
    );
  }

  /// Stops continuous BPM adjustment when the button is released or cancelled.
  void stopContinuousBpmAdjustment() {
    _holdRepeatTimer?.cancel();
    _holdRepeatTimer = null;
    _holdTicks = 0;
  }

  /// Registers a tap on the Tap Tempo button at the exact monotonic touch instant
  /// (FR-TAP-02..05).
  ///
  /// Optionally accepts [timestamp] from `PointerDownEvent.timeStamp`; falls back
  /// to the injected clock or internal monotonic [Stopwatch].
  void registerTapTempo({Duration? timestamp}) {
    final instant = timestamp ?? _clock?.call() ?? _monotonicWatch.elapsed;
    final calculatedBpm = _tapTempoCalculator.registerTap(instant);
    if (calculatedBpm != null) {
      _repository.setBpm(calculatedBpm);
    }
    notifyListeners();
  }

  /// Selects a [TimeSignature] (FR-CMP-01).
  void selectTimeSignature(TimeSignature signature) {
    _repository.setTimeSignature(signature);
  }

  /// Selects a [Subdivision] (FR-SUB-01).
  void selectSubdivision(Subdivision subdivision) {
    _repository.setSubdivision(subdivision);
  }

  /// Toggles play/stop (FR-PLY-01).
  Future<void> togglePlayStop() => _repository.togglePlayStop();

  @override
  void dispose() {
    stopContinuousBpmAdjustment();
    _stateSubscription?.cancel();
    super.dispose();
  }
}

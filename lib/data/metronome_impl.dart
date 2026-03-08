import 'dart:async';

import 'package:metronome/domain/metronome.dart';
import 'package:metronome/domain/tick.dart';

class MetronomeImpl implements Metronome {
  int _bpm;
  int _beatCounter = 0;
  final int _beatsPerMeasure = 4;

  final StreamController<Tick> _metronomeStreamController =
      StreamController<Tick>.broadcast();

  final Stopwatch _clock = Stopwatch();

  Timer? _scheduler;

  bool _isRunning = false;

  double _beatDuration = 0;
  double _nextBeatTime = 0;

  static const Duration _schedulerInterval = Duration(milliseconds: 25);

  static const double _lookAhead = 0.1; // seconds

  MetronomeImpl({int bpm = 60}) : _bpm = bpm {
    _updateBeatDuration();
  }

  @override
  int get beatsPerMeasure => _beatsPerMeasure;

  @override
  int get bpm => _bpm;

  @override
  bool get isRunning => _isRunning;

  @override
  Future<void> dispose() async {
    stop();
    await _metronomeStreamController.close();
  }

  @override
  void setBpm(int bpm) {
    _bpm = bpm;
    _updateBeatDuration();
  }

  @override
  void start() {
    if (_isRunning) return;

    _isRunning = true;

    _beatCounter = 0;
    _nextBeatTime = 0;

    _clock
      ..reset()
      ..start();

    _scheduler = Timer.periodic(_schedulerInterval, _schedulerLoop);
  }

  @override
  void stop() {
    _scheduler?.cancel();
    _scheduler = null;

    _clock.stop();

    _isRunning = false;
    _beatCounter = 0;
  }

  @override
  Stream<Tick> tickStream() => _metronomeStreamController.stream;

  void _updateBeatDuration() {
    _beatDuration = 60.0 / _bpm;
  }

  void _schedulerLoop(Timer _) {
    final elapsed = _clock.elapsedMicroseconds / 1e6;

    while (_nextBeatTime < elapsed + _lookAhead) {
      _emitTick();
      _beatCounter++;
      _nextBeatTime += _beatDuration;
    }
  }

  void _emitTick() {
    final int measureIndex = _beatCounter % _beatsPerMeasure;

    _metronomeStreamController.add(
      Tick(
        tickType: measureIndex == 0 ? TickType.accent : TickType.regular,
        measureIndex: measureIndex,
      ),
    );
  }
}

import 'dart:async';

import 'package:metronome/domain/metronome.dart';
import 'package:metronome/domain/tick.dart';

class MetronomeImpl implements Metronome {
  late int _bpm;
  late int _beatCounter;
  late int _beatsPerBar;
  final StreamController<Tick> _metronomeStreamController =
      StreamController<Tick>.broadcast();
  Timer? _timer;
  bool _isRunning = false;
  MetronomeImpl({int bpm = 60, int beatsPerBar = 4}) {
    _bpm = bpm;
    _beatsPerBar = beatsPerBar;
    _beatCounter = 0;
  }

  @override
  int get beatsPerBar => _beatsPerBar;

  @override
  int get bpm => _bpm;

  @override
  bool get isRunning => _isRunning;

  @override
  Future<void> dispose() async {
    if (_timer != null) {
      stop();
    }
    _metronomeStreamController.close();
  }

  @override
  void setBpm(int bpm) {
    _bpm = bpm;
    if (_isRunning) {
      final intervalInMs = _calculateIntervalInMs();
      _timer?.cancel();
      _timer = null;
      _timer = Timer.periodic(
        Duration(milliseconds: intervalInMs),
        (_) => _handleTick(),
      );
    }
  }

  @override
  void start() {
    if (_isRunning) return;
    final intervalInMs = _calculateIntervalInMs();
    _handleTick();
    _timer = Timer.periodic(
      Duration(milliseconds: intervalInMs),
      (_) => _handleTick(),
    );
    _isRunning = true;
  }

  @override
  void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    _beatCounter = 0;
  }

  @override
  Stream<Tick> tickStream() => _metronomeStreamController.stream;

  int _calculateIntervalInMs() {
    return (60000 / bpm).round();
  }

  void _handleTick() {
    final int tickIndex = _beatCounter % beatsPerBar;
    final Tick tick;
    if (tickIndex == 0) {
      tick = AccentTick(barIndex: tickIndex);
    } else {
      tick = RegularTick(barIndex: tickIndex);
    }
    _metronomeStreamController.add(tick);
    _beatCounter++;
  }

  @override
  void setBeatsPerBar(int beatsPerBar) {
    // TODO: implement setBeatsPerBar
  }
}

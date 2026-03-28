import 'dart:async';
import 'dart:ffi';

import 'package:flutter/rendering.dart';
import 'package:metronome/domain/metronome.dart';
import 'package:metronome/domain/tick.dart';
import 'package:metronome/ffi.dart';
import 'package:metronome/shared/constants.dart';

class MetronomeImpl implements Metronome {
  late int _bpm;
  late int _beatsPerBar;
  bool _isRunning = false;

  final StreamController<Tick> _metronomeStreamController =
      StreamController<Tick>.broadcast();

  late final NativeCallable<Void Function(Int32)> _tickCallable;

  MetronomeImpl({int bpm = kDefaultBpm, int beatsPerBar = kDefaultBeatsPerBar}) {
    _bpm = bpm;
    _beatsPerBar = beatsPerBar;

    // Create a native callable that can be called from the C++ audio thread
    _tickCallable = NativeCallable<Void Function(Int32)>.listener(_onNativeTick);
    
    // Register the callback with the native side
    MetronomeFFI.setTickCallback(_tickCallable.nativeFunction);
  }

  void _onNativeTick(int beatIndex) {
    // This is called from the UI isolate, but triggered by the native side
    final Tick tick;
    // The native index is beat % 4, but we should use _beatsPerBar if we want flexibility.
    // However, the current C++ code is hardcoded to 4 beats.
    debugPrint('tick $beatIndex');
    if (beatIndex == 0) {
      tick = AccentTick(barIndex: beatIndex);
    } else {
      tick = RegularTick(barIndex: beatIndex);
    }
    _metronomeStreamController.add(tick);
  }

  @override
  int get beatsPerBar => _beatsPerBar;

  @override
  int get bpm => _bpm;

  @override
  bool get isRunning => _isRunning;

  @override
  Future<void> dispose() async {
    stop();
    _tickCallable.close();
    await _metronomeStreamController.close();
  }

  @override
  void setBpm(int bpm) {
    _bpm = bpm;
    MetronomeFFI.setBpm(bpm.toDouble());
  }

  @override
  void start() {
    if (_isRunning) return;
    MetronomeFFI.start(_bpm.toDouble());
    _isRunning = true;
  }

  @override
  void stop() {
    MetronomeFFI.stop();
    _isRunning = false;
  }

  @override
  Stream<Tick> tickStream() => _metronomeStreamController.stream;

  @override
  void setBeatsPerBar(int beatsPerBar) {
    _beatsPerBar = beatsPerBar;
    MetronomeFFI.setBeatsPerBar(beatsPerBar);
  }
  
  @override
  void setUseAccentTick(bool useAccentTick) {
    MetronomeFFI.setUseAccentTick(useAccentTick);
  }
  
 
}

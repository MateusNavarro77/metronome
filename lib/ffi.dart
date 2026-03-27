import 'dart:ffi';
import 'dart:io';

class MetronomeFFI {
  static final DynamicLibrary _lib =
      Platform.isAndroid
          ? DynamicLibrary.open("libmetronome.so")
          : throw UnsupportedError("Platform not supported");

  static final _start = _lib
      .lookupFunction<Void Function(Double), void Function(double)>(
        'start_metronome',
      );

  static final _stop = _lib.lookupFunction<Void Function(), void Function()>(
    'stop_metronome',
  );

  static final _setBpm = _lib
      .lookupFunction<Void Function(Double), void Function(double)>('set_bpm');

  static void start(double bpm) => _start(bpm);
  static void stop() => _stop();
  static void setBpm(double bpm) => _setBpm(bpm);
}

import 'dart:ffi';
import 'dart:io';

class MetronomeFFI {
  static final DynamicLibrary _lib =
      Platform.isAndroid
          ? DynamicLibrary.open("libmetronome.so")
          : throw UnsupportedError("Platform not supported");

  static final _initAudio = _lib
      .lookupFunction<Void Function(Double), void Function(double)>(
        'init_audio',
      );

  static final _shutdownAudio = _lib
      .lookupFunction<Void Function(), void Function()>('shutdown_audio');

  static final _play = _lib.lookupFunction<Void Function(), void Function()>(
    'play_metronome',
  );

  static final _pause = _lib.lookupFunction<Void Function(), void Function()>(
    'pause_metronome',
  );

  static final _setBpm = _lib
      .lookupFunction<Void Function(Double), void Function(double)>('set_bpm');

  static final _setBeatsPerBar = _lib
      .lookupFunction<Void Function(Int32), void Function(int)>(
        'set_beats_per_bar',
      );

  static final _setUseAccentTick = _lib
      .lookupFunction<Void Function(Bool), void Function(bool)>(
        'set_use_accent_tick',
      );

  static final _setTickCallback = _lib.lookupFunction<
    Void Function(Pointer<NativeFunction<Void Function(Int32)>>),
    void Function(Pointer<NativeFunction<Void Function(Int32)>>)
  >('set_tick_callback');

  static void init(double bpm) => _initAudio(bpm);

  static void play() => _play();

  static void pause() => _pause();

  static void shutdown() => _shutdownAudio();

  static void setBpm(double bpm) => _setBpm(bpm);

  static void setBeatsPerBar(int beats) => _setBeatsPerBar(beats);

  static void setUseAccentTick(bool value) => _setUseAccentTick(value);

  static void setTickCallback(
    Pointer<NativeFunction<Void Function(Int32)>> callback,
  ) {
    _setTickCallback(callback);
  }
}

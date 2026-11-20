import 'dart:async';

import '../../domain/models/beat_event.dart';
import '../../domain/models/bpm.dart';
import '../../domain/models/metronome_sound.dart';
import '../../domain/models/sound_settings.dart';
import '../../domain/models/subdivision.dart';
import '../../domain/models/time_signature.dart';

/// Single interface for the Metronome audio and timing engine (Section 2.4, NFR-MAN-02).
///
/// The UI and Repository drive the engine through this interface and receive
/// [beatEvents] from it, allowing the native/low-latency implementation and
/// deterministic test simulations to be swapped seamlessly.
abstract interface class MetronomeEngine {
  /// Stream of [BeatEvent] pulses emitted on every main beat and subdivision.
  Stream<BeatEvent> get beatEvents;

  /// Whether the engine is currently playing.
  bool get isPlaying;

  /// Initializes any underlying audio resources.
  Future<void> initialize();

  /// Starts playback immediately on Beat 1 (strong beat) (FR-PLY-02).
  Future<void> start({
    required Bpm bpm,
    required TimeSignature timeSignature,
    required Subdivision subdivision,
    bool isAccentEnabled = true,
    SoundSettings soundSettings = const SoundSettings(),
  });

  /// Stops playback immediately with no residual sounds and resets to Beat 1 (FR-PLY-04).
  Future<void> stop();

  /// Updates the active configuration without interrupting playback (FR-BPM-04, FR-SUB-03, FR-SND-02..04).
  void updateConfiguration({
    Bpm? bpm,
    TimeSignature? timeSignature,
    Subdivision? subdivision,
    bool? isAccentEnabled,
    SoundSettings? soundSettings,
  });

  /// Schedules a configuration update to take effect at the start of the next bar
  /// (`beatIndex == 0 && subdivisionIndex == 0`) without interrupting playback (FR-PRE-09).
  ///
  /// If the engine is currently stopped, the configuration applies immediately.
  void scheduleNextBarConfiguration({
    Bpm? bpm,
    TimeSignature? timeSignature,
    Subdivision? subdivision,
    bool? isAccentEnabled,
  });

  /// Plays a single preview click for [sound] and [accent] at [volume] (`0.0..1.0`) (FR-SND-07).
  Future<void> previewSound({
    required MetronomeSound sound,
    BeatAccent accent = BeatAccent.strong,
    double volume = 1.0,
  });

  /// Releases audio and stream resources.
  Future<void> dispose();
}

import 'dart:async';

import '../../domain/models/beat_event.dart';
import '../../domain/models/bpm.dart';
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
  });

  /// Stops playback immediately with no residual sounds and resets to Beat 1 (FR-PLY-04).
  Future<void> stop();

  /// Updates the active configuration without interrupting playback (FR-BPM-04, FR-SUB-03).
  void updateConfiguration({
    Bpm? bpm,
    TimeSignature? timeSignature,
    Subdivision? subdivision,
    bool? isAccentEnabled,
  });

  /// Releases audio and stream resources.
  Future<void> dispose();
}

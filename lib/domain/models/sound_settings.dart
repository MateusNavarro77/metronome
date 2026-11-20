import 'metronome_sound.dart';
import 'time_signature.dart';

/// Immutable domain configuration for metronome sound timbre, independent
/// beat/subdivision volumes (`0..100`), and mute mode (FR-SND-01..05, FR-SND-08).
///
/// Pure Dart domain model with zero Flutter dependencies (NFR-MAN-01).
class const SoundSettings({
  this.sound = MetronomeSound.click,
  this.strongVolume = defaultStrongVolume,
  this.weakVolume = defaultWeakVolume,
  this.subdivisionVolume = defaultSubdivisionVolume,
  this.isMuted = false,
}) {
  this
    : assert(strongVolume >= 0 && strongVolume <= 100),
      assert(weakVolume >= 0 && weakVolume <= 100),
      assert(subdivisionVolume >= 0 && subdivisionVolume <= 100);

  static const int minVolume = 0;
  static const int maxVolume = 100;
  static const int defaultStrongVolume = 100;
  static const int defaultWeakVolume = 65;
  static const int defaultSubdivisionVolume = 35;

  final MetronomeSound sound;

  /// Strong-beat volume percentage (`0..100`) (FR-SND-04).
  final int strongVolume;

  /// Weak-beat volume percentage (`0..100`) (FR-SND-04).
  final int weakVolume;

  /// Subdivision volume percentage (`0..100`) (FR-SND-04).
  final int subdivisionVolume;

  /// Whether audio output is muted while keeping visual feedback active (FR-SND-08).
  final bool isMuted;

  /// Creates a [SoundSettings] clamping all volume percentages to `0..100`.
  factory SoundSettings.clamped({
    MetronomeSound sound = MetronomeSound.click,
    int strongVolume = defaultStrongVolume,
    int weakVolume = defaultWeakVolume,
    int subdivisionVolume = defaultSubdivisionVolume,
    bool isMuted = false,
  }) {
    return SoundSettings(
      sound: sound,
      strongVolume: strongVolume.clamp(minVolume, maxVolume),
      weakVolume: weakVolume.clamp(minVolume, maxVolume),
      subdivisionVolume: subdivisionVolume.clamp(minVolume, maxVolume),
      isMuted: isMuted,
    );
  }

  /// Effective normalized playback gain (`0.0..1.0`) for [accent].
  ///
  /// Returns `0.0` when [isMuted] is `true`. Compound medium accents follow
  /// [weakVolume] so setting Weak Beats to `0%` silences all non-downbeats,
  /// while the medium sample itself provides intermediate tonal distinction.
  double effectiveVolumeFor(BeatAccent accent) {
    if (isMuted) return 0.0;
    final percent = switch (accent) {
      BeatAccent.strong => strongVolume,
      BeatAccent.medium => weakVolume,
      BeatAccent.weak => weakVolume,
      BeatAccent.subdivision => subdivisionVolume,
    };
    return percent.clamp(minVolume, maxVolume) / 100.0;
  }

  SoundSettings copyWith({
    MetronomeSound? sound,
    int? strongVolume,
    int? weakVolume,
    int? subdivisionVolume,
    bool? isMuted,
  }) {
    return SoundSettings.clamped(
      sound: sound ?? this.sound,
      strongVolume: strongVolume ?? this.strongVolume,
      weakVolume: weakVolume ?? this.weakVolume,
      subdivisionVolume: subdivisionVolume ?? this.subdivisionVolume,
      isMuted: isMuted ?? this.isMuted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SoundSettings &&
          other.sound == sound &&
          other.strongVolume == strongVolume &&
          other.weakVolume == weakVolume &&
          other.subdivisionVolume == subdivisionVolume &&
          other.isMuted == isMuted);

  @override
  int get hashCode =>
      Object.hash(sound, strongVolume, weakVolume, subdivisionVolume, isMuted);
}

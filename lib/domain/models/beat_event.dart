import 'time_signature.dart';

/// Represents a single pulse (main beat or subdivision) emitted by the engine.
class const BeatEvent({
  required final int beatIndex,
  required final int subdivisionIndex,
  required final BeatAccent accent,
  required final Duration timestamp,
}) {
  /// Whether this pulse is the main beat (`subdivisionIndex == 0`).
  bool get isMainBeat => subdivisionIndex == 0;

  /// Whether this pulse is the first beat of the bar (`beatIndex == 0 && subdivisionIndex == 0`).
  bool get isDownbeat => beatIndex == 0 && subdivisionIndex == 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BeatEvent &&
          other.beatIndex == beatIndex &&
          other.subdivisionIndex == subdivisionIndex &&
          other.accent == accent &&
          other.timestamp == timestamp);

  @override
  int get hashCode =>
      Object.hash(beatIndex, subdivisionIndex, accent, timestamp);

  @override
  String toString() =>
      'BeatEvent(beat: $beatIndex, sub: $subdivisionIndex, accent: ${accent.label}, t: ${timestamp.inMilliseconds}ms)';
}

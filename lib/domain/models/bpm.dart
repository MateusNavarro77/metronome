import 'tempo_marking.dart';

/// Represents a validated tempo in Beats Per Minute (FR-BPM-01).
///
/// Enforces the valid range of [min] (30) to [max] (300) BPM in whole-number
/// steps and provides safe clamping and step adjustments.
class const Bpm(final int value) {
  this : assert(value >= min && value <= max, 'BPM must be between $min and $max');

  /// Minimum allowed BPM (FR-BPM-01).
  static const int min = 30;

  /// Maximum allowed BPM (FR-BPM-01).
  static const int max = 300;

  /// Default initial BPM on first launch (UI-08).
  static const int defaultValue = 120;

  /// Default [Bpm] instance (120 BPM).
  static const Bpm initial = Bpm(defaultValue);

  /// Creates a [Bpm] by clamping [raw] into the `[30, 300]` range.
  factory Bpm.clamped(int raw) => Bpm(raw.clamp(min, max));

  /// Parses and validates a user-entered string (FR-BPM-06).
  ///
  /// Returns `null` if [input] is not an integer or is outside `[30, 300]`.
  static Bpm? tryParse(String input) {
    final parsed = int.tryParse(input.trim());
    if (parsed == null || parsed < min || parsed > max) {
      return null;
    }
    return Bpm(parsed);
  }

  /// Returns a new [Bpm] adjusted by [delta], clamped to `[30, 300]`.
  Bpm adjust(int delta) => Bpm.clamped(value + delta);

  /// Duration of a single beat at this BPM.
  Duration get beatDuration => Duration(
    microseconds: (Duration.microsecondsPerMinute / value).round(),
  );

  /// The musical tempo marking name for this BPM (FR-AND-01).
  TempoMarking get tempoMarking => TempoMarking.fromBpm(value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Bpm && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => '$value BPM';
}

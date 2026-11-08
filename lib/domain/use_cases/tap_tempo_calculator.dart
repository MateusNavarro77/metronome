import '../models/bpm.dart';

/// Pure-Dart calculator for Tap Tempo (FR-TAP-01 to FR-TAP-06).
///
/// Rules from `specs/prd_metronomo.md`:
/// - Computes BPM from the average of intervals between the most recent taps
///   (minimum 2 taps, maximum last 8 taps / 7 intervals).
/// - Restarts the sequence when more than 2 seconds (`2000 ms`) pass between
///   two consecutive taps (matching the 30 BPM lower limit).
/// - Clamps the resulting BPM to `[30, 300]`.
class TapTempoCalculator {
  /// Maximum number of recent tap timestamps kept in the window (FR-TAP-02).
  static const int maxTapCount = 8;

  /// Reset threshold between consecutive taps (FR-TAP-03: 2 seconds = 30 BPM).
  static const Duration resetTimeout = Duration(seconds: 2);

  final List<Duration> _tapTimestamps = [];

  /// Number of taps recorded in the active sequence.
  int get tapCount => _tapTimestamps.length;

  /// Records a tap at [timestamp] (measured from a monotonic clock) and
  /// returns the calculated [Bpm] if at least 2 taps are in the current
  /// window, or `null` if this tap started a new sequence.
  Bpm? registerTap(Duration timestamp) {
    if (_tapTimestamps.isNotEmpty) {
      final interval = timestamp - _tapTimestamps.last;
      if (interval > resetTimeout || interval.isNegative) {
        _tapTimestamps.clear();
      }
    }

    _tapTimestamps.add(timestamp);
    if (_tapTimestamps.length > maxTapCount) {
      _tapTimestamps.removeAt(0);
    }

    if (_tapTimestamps.length < 2) {
      return null;
    }

    final totalSpanMicroseconds =
        (_tapTimestamps.last - _tapTimestamps.first).inMicroseconds;
    final intervalCount = _tapTimestamps.length - 1;
    final averageIntervalMicroseconds = totalSpanMicroseconds / intervalCount;

    if (averageIntervalMicroseconds <= 0) {
      return const Bpm(Bpm.max);
    }

    final rawBpm =
        (Duration.microsecondsPerMinute / averageIntervalMicroseconds).round();
    return Bpm.clamped(rawBpm);
  }

  /// Clears all recorded taps.
  void reset() => _tapTimestamps.clear();
}

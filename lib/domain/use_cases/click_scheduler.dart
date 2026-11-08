import '../models/beat_event.dart';
import '../models/bpm.dart';
import '../models/subdivision.dart';
import '../models/time_signature.dart';

/// Pure-Dart schedule calculator for metronome pulses (NFR-MAN-01, NFR-TST-01).
///
/// Computes the exact timing and [BeatAccent] of each main beat and subdivision
/// pulse across a bar or sequence of pulses.
class ClickScheduler {
  const ClickScheduler();

  /// Duration between consecutive pulses (including subdivisions) for [bpm]
  /// and [subdivision].
  Duration pulseInterval({
    required Bpm bpm,
    required Subdivision subdivision,
  }) {
    final microsPerPulse =
        Duration.microsecondsPerMinute /
        (bpm.value * subdivision.pulsesPerBeat);
    return Duration(microseconds: microsPerPulse.round());
  }

  /// Resolves the [BeatAccent] for a given [beatIndex] and [subdivisionIndex]
  /// in [timeSignature].
  BeatAccent resolveAccent({
    required TimeSignature timeSignature,
    required int beatIndex,
    required int subdivisionIndex,
  }) {
    if (subdivisionIndex > 0) {
      return BeatAccent.subdivision;
    }
    return timeSignature.accentForBeat(beatIndex);
  }

  /// Generates the ordered list of [BeatEvent]s for one complete bar starting
  /// at [barStartTimestamp].
  List<BeatEvent> generateBarSchedule({
    required Bpm bpm,
    required TimeSignature timeSignature,
    required Subdivision subdivision,
    Duration barStartTimestamp = Duration.zero,
  }) {
    final events = <BeatEvent>[];
    final step = pulseInterval(bpm: bpm, subdivision: subdivision);
    var elapsed = barStartTimestamp;

    for (var beat = 0; beat < timeSignature.numerator; beat++) {
      for (var sub = 0; sub < subdivision.pulsesPerBeat; sub++) {
        events.add(
          BeatEvent(
            beatIndex: beat,
            subdivisionIndex: sub,
            accent: resolveAccent(
              timeSignature: timeSignature,
              beatIndex: beat,
              subdivisionIndex: sub,
            ),
            timestamp: elapsed,
          ),
        );
        elapsed += step;
      }
    }

    return events;
  }

  /// Computes the next `(beatIndex, subdivisionIndex)` pair following the
  /// current indices for [timeSignature] and [subdivision].
  ({int beatIndex, int subdivisionIndex}) nextPulsePosition({
    required int currentBeat,
    required int currentSubdivision,
    required TimeSignature timeSignature,
    required Subdivision subdivision,
  }) {
    final nextSub = currentSubdivision + 1;
    if (nextSub < subdivision.pulsesPerBeat) {
      return (beatIndex: currentBeat, subdivisionIndex: nextSub);
    }
    final nextBeat = (currentBeat + 1) % timeSignature.numerator;
    return (beatIndex: nextBeat, subdivisionIndex: 0);
  }
}

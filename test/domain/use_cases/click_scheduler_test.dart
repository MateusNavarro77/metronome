import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metronome/domain/models/bpm.dart';
import 'package:metronome/domain/models/subdivision.dart';
import 'package:metronome/domain/models/time_signature.dart';
import 'package:metronome/domain/use_cases/click_scheduler.dart';

void main() {
  group(
    'ClickScheduler & TimeSignature accents (FR-CMP-01..05, FR-SUB-01)',
    () {
      const scheduler = ClickScheduler();

      test(
        'generates 4 main beats in 4/4 with strong beat 1 and weak beats 2..4',
        () {
          final events = scheduler.generateBarSchedule(
            bpm: const Bpm(120),
            timeSignature: TimeSignature.fourFour,
            subdivision: Subdivision.none,
          );

          check(events).length.equals(4);
          check(events[0].accent).equals(BeatAccent.strong);
          check(events[0].timestamp).equals(Duration.zero);

          check(events[1].accent).equals(BeatAccent.weak);
          check(events[1].timestamp).equals(const Duration(milliseconds: 500));

          check(events[2].accent).equals(BeatAccent.weak);
          check(events[2].timestamp).equals(const Duration(milliseconds: 1000));

          check(events[3].accent).equals(BeatAccent.weak);
          check(events[3].timestamp).equals(const Duration(milliseconds: 1500));
        },
      );

      test(
        'assigns strong accent to beat 1 and medium accent to beat 4 in 6/8',
        () {
          final events = scheduler.generateBarSchedule(
            bpm: const Bpm(120),
            timeSignature: TimeSignature.sixEight,
            subdivision: Subdivision.none,
          );

          check(events).length.equals(6);
          check(events.map((e) => e.accent).toList()).deepEquals([
            BeatAccent.strong,
            BeatAccent.weak,
            BeatAccent.weak,
            BeatAccent.medium,
            BeatAccent.weak,
            BeatAccent.weak,
          ]);
        },
      );

      test(
        'generates 16 pulses per bar in 4/4 with sixteenth subdivisions',
        () {
          final events = scheduler.generateBarSchedule(
            bpm: const Bpm(120),
            timeSignature: TimeSignature.fourFour,
            subdivision: Subdivision.sixteenth,
          );

          check(events).length.equals(16);
          // First pulse of beat 0 is strong
          check(events[0].beatIndex).equals(0);
          check(events[0].subdivisionIndex).equals(0);
          check(events[0].accent).equals(BeatAccent.strong);

          // Pulses 1..3 of beat 0 are subdivisions (125 ms apart at 120 BPM)
          check(events[1].subdivisionIndex).equals(1);
          check(events[1].accent).equals(BeatAccent.subdivision);
          check(events[1].timestamp).equals(const Duration(milliseconds: 125));

          // Pulse 4 is main beat 1 (weak)
          check(events[4].beatIndex).equals(1);
          check(events[4].subdivisionIndex).equals(0);
          check(events[4].accent).equals(BeatAccent.weak);
          check(events[4].timestamp).equals(const Duration(milliseconds: 500));
        },
      );

      test(
        'assigns weak accent to all main beats when isAccentEnabled is false',
        () {
          final events = scheduler.generateBarSchedule(
            bpm: const Bpm(120),
            timeSignature: TimeSignature.fourFour,
            subdivision: Subdivision.none,
            isAccentEnabled: false,
          );

          check(events).length.equals(4);
          check(events.map((e) => e.accent).toList()).deepEquals([
            BeatAccent.weak,
            BeatAccent.weak,
            BeatAccent.weak,
            BeatAccent.weak,
          ]);
        },
      );

      test('assigns weak accent to all main beats in 6/8 when isAccentEnabled is false', () {
        final events = scheduler.generateBarSchedule(
          bpm: const Bpm(120),
          timeSignature: TimeSignature.sixEight,
          subdivision: Subdivision.none,
          isAccentEnabled: false,
        );

        check(events).length.equals(6);
        check(events.map((e) => e.accent).toList()).deepEquals([
          BeatAccent.weak,
          BeatAccent.weak,
          BeatAccent.weak,
          BeatAccent.weak,
          BeatAccent.weak,
          BeatAccent.weak,
        ]);
      });

      test('keeps distinct subdivision accents while main beats are weak when isAccentEnabled is false', () {
        final events = scheduler.generateBarSchedule(
          bpm: const Bpm(120),
          timeSignature: TimeSignature.fourFour,
          subdivision: Subdivision.eighth,
          isAccentEnabled: false,
        );

        check(events).length.equals(8);
        // Beat 0: main is weak, sub is subdivision
        check(events[0].accent).equals(BeatAccent.weak);
        check(events[1].accent).equals(BeatAccent.subdivision);
        // Beat 1: main is weak, sub is subdivision
        check(events[2].accent).equals(BeatAccent.weak);
        check(events[3].accent).equals(BeatAccent.subdivision);
      });

      test(
        'assigns weak accent to all main beats when isAccentEnabled is false',
        () {
          final events = scheduler.generateBarSchedule(
            bpm: const Bpm(120),
            timeSignature: TimeSignature.fourFour,
            subdivision: Subdivision.none,
            isAccentEnabled: false,
          );

          check(events).length.equals(4);
          check(events.map((e) => e.accent).toList()).deepEquals([
            BeatAccent.weak,
            BeatAccent.weak,
            BeatAccent.weak,
            BeatAccent.weak,
          ]);
        },
      );

      test('assigns weak accent to all main beats in 6/8 when isAccentEnabled is false', () {
        final events = scheduler.generateBarSchedule(
          bpm: const Bpm(120),
          timeSignature: TimeSignature.sixEight,
          subdivision: Subdivision.none,
          isAccentEnabled: false,
        );

        check(events).length.equals(6);
        check(events.map((e) => e.accent).toList()).deepEquals([
          BeatAccent.weak,
          BeatAccent.weak,
          BeatAccent.weak,
          BeatAccent.weak,
          BeatAccent.weak,
          BeatAccent.weak,
        ]);
      });

      test('keeps distinct subdivision accents while main beats are weak when isAccentEnabled is false', () {
        final events = scheduler.generateBarSchedule(
          bpm: const Bpm(120),
          timeSignature: TimeSignature.fourFour,
          subdivision: Subdivision.eighth,
          isAccentEnabled: false,
        );

        check(events).length.equals(8);
        // Beat 0: main is weak, sub is subdivision
        check(events[0].accent).equals(BeatAccent.weak);
        check(events[1].accent).equals(BeatAccent.subdivision);
        // Beat 1: main is weak, sub is subdivision
        check(events[2].accent).equals(BeatAccent.weak);
        check(events[3].accent).equals(BeatAccent.subdivision);
      });
    },
  );
}

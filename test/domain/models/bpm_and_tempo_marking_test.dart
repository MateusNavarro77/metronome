import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metronome/domain/models/bpm.dart';
import 'package:metronome/domain/models/tempo_marking.dart';

void main() {
  group('Bpm domain model (FR-BPM-01, FR-AND-01)', () {
    test('defaults to 120 BPM (Allegro)', () {
      check(Bpm.initial.value).equals(120);
      check(Bpm.initial.tempoMarking).equals(TempoMarking.allegro);
    });

    test('clamps out-of-range values to [30, 300]', () {
      check(Bpm.clamped(10).value).equals(30);
      check(Bpm.clamped(29).value).equals(30);
      check(Bpm.clamped(30).value).equals(30);
      check(Bpm.clamped(300).value).equals(300);
      check(Bpm.clamped(301).value).equals(300);
      check(Bpm.clamped(999).value).equals(300);
    });

    test('adjusts by delta and clamps at boundaries', () {
      check(const Bpm(120).adjust(5).value).equals(125);
      check(const Bpm(120).adjust(-10).value).equals(110);
      check(const Bpm(30).adjust(-1).value).equals(30);
      check(const Bpm(300).adjust(1).value).equals(300);
    });

    test('tryParse accepts valid integer strings in [30, 300] and rejects invalid ones', () {
      check(Bpm.tryParse('120')).equals(const Bpm(120));
      check(Bpm.tryParse(' 30 ')).equals(const Bpm(30));
      check(Bpm.tryParse('300')).equals(const Bpm(300));
      check(Bpm.tryParse('29')).isNull();
      check(Bpm.tryParse('301')).isNull();
      check(Bpm.tryParse('abc')).isNull();
      check(Bpm.tryParse('')).isNull();
    });

    test('calculates beatDuration accurately', () {
      check(const Bpm(60).beatDuration).equals(const Duration(seconds: 1));
      check(const Bpm(120).beatDuration)
          .equals(const Duration(milliseconds: 500));
    });
  });

  group('TempoMarking table (Section 3.8, FR-AND-01)', () {
    test('maps all boundary BPM values to the exact specification table', () {
      final cases = <(int, TempoMarking)>[
        (30, TempoMarking.largo),
        (59, TempoMarking.largo),
        (60, TempoMarking.larghetto),
        (65, TempoMarking.larghetto),
        (66, TempoMarking.adagio),
        (75, TempoMarking.adagio),
        (76, TempoMarking.andante),
        (107, TempoMarking.andante),
        (108, TempoMarking.moderato),
        (119, TempoMarking.moderato),
        (120, TempoMarking.allegro),
        (155, TempoMarking.allegro),
        (156, TempoMarking.vivace),
        (175, TempoMarking.vivace),
        (176, TempoMarking.presto),
        (199, TempoMarking.presto),
        (200, TempoMarking.prestissimo),
        (300, TempoMarking.prestissimo),
      ];

      for (final (bpm, expectedMarking) in cases) {
        check(
          because: 'BPM $bpm should map to ${expectedMarking.label}',
          TempoMarking.fromBpm(bpm),
        ).equals(expectedMarking);
      }
    });
  });
}

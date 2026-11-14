import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metronome/domain/models/bpm.dart';
import 'package:metronome/domain/models/preset.dart';
import 'package:metronome/domain/models/setlist.dart';
import 'package:metronome/domain/models/subdivision.dart';
import 'package:metronome/domain/models/time_signature.dart';

void main() {
  final t0 = DateTime.utc(2026, 11, 1, 10, 0, 0);
  final t1 = DateTime.utc(2026, 11, 1, 12, 30, 0);

  group('Preset domain model (FR-PRE-01..04, FR-PRE-11)', () {
    test('constructs with defaults, supports copyWith and value equality', () {
      final preset = Preset(
        id: 'p1',
        name: 'Jazz Swing',
        bpm: const Bpm(144),
        timeSignature: TimeSignature.fourFour,
        subdivision: Subdivision.triplet,
        createdAt: t0,
        updatedAt: t0,
      );

      check(preset.isAccentEnabled).isTrue();
      check(preset.isFavorite).isFalse();
      check(preset.note).equals('');

      final identical = Preset(
        id: 'p1',
        name: 'Jazz Swing',
        bpm: const Bpm(144),
        timeSignature: TimeSignature.fourFour,
        subdivision: Subdivision.triplet,
        createdAt: t0,
        updatedAt: t0,
      );
      check(preset).equals(identical);
      check(preset.hashCode).equals(identical.hashCode);

      final updated = preset.copyWith(
        bpm: const Bpm(160),
        isFavorite: true,
        note: 'Ride cymbal pattern',
        updatedAt: t1,
      );
      check(updated.bpm).equals(const Bpm(160));
      check(updated.isFavorite).isTrue();
      check(updated.note).equals('Ride cymbal pattern');
      check(updated.name).equals('Jazz Swing');
      check(updated).not((it) => it.equals(preset));
    });

    test('serializes to JSON and round-trips accurately', () {
      final preset = Preset(
        id: 'p2',
        name: 'Compound Groove',
        bpm: const Bpm(92),
        timeSignature: TimeSignature.sixEight,
        subdivision: Subdivision.eighth,
        isAccentEnabled: false,
        isFavorite: true,
        note: 'Count-in 1 bar',
        createdAt: t0,
        updatedAt: t1,
      );

      final decoded = Preset.fromJson(preset.toJson());
      check(decoded).equals(preset);
    });

    test('fromJson validates id and applies safe fallbacks/clamping', () {
      check(() => Preset.fromJson({'name': 'No Id'})).throws<FormatException>();

      final sanitized = Preset.fromJson({
        'id': 'p3',
        'name': '   ',
        'bpm': 999,
        'timeSignatureNumerator': 99,
        'timeSignatureDenominator': 7,
        'subdivision': 'invalid_subdivision',
      });

      check(sanitized.name).equals('Untitled Preset');
      check(sanitized.bpm).equals(const Bpm(Bpm.max));
      check(sanitized.timeSignature).equals(const TimeSignature(16, 4));
      check(sanitized.subdivision).equals(Subdivision.none);
      check(sanitized.isAccentEnabled).isTrue();
      check(sanitized.isFavorite).isFalse();
      check(sanitized.note).equals('');
    });
  });

  group('Setlist domain model (FR-PRE-06..07, Section 6.3)', () {
    test('supports deep list equality, containsPreset, and copyWith', () {
      final s1 = Setlist(
        id: 's1',
        name: 'Sunday Service',
        presetIds: const ['p1', 'p2', 'p1'],
        createdAt: t0,
        updatedAt: t0,
      );
      final s2 = Setlist(
        id: 's1',
        name: 'Sunday Service',
        presetIds: ['p1', 'p2', 'p1'],
        createdAt: t0,
        updatedAt: t0,
      );

      check(s1).equals(s2);
      check(s1.hashCode).equals(s2.hashCode);
      check(s1.containsPreset('p2')).isTrue();
      check(s1.containsPreset('p99')).isFalse();
    });

    test('removePresetReferences removes all occurrences of presetId', () {
      final setlist = Setlist(
        id: 's1',
        name: 'Show',
        presetIds: const ['p1', 'p2', 'p1', 'p3'],
        createdAt: t0,
        updatedAt: t0,
      );

      final cleaned = setlist.removePresetReferences('p1', updatedAt: t1);
      check(cleaned.presetIds).deepEquals(const ['p2', 'p3']);
      check(cleaned.updatedAt).equals(t1);

      final unchanged = setlist.removePresetReferences(
        'missing',
        updatedAt: t1,
      );
      check(identical(unchanged, setlist)).isTrue();
    });

    test('reorder moves items cleanly using ReorderableListView semantics', () {
      final setlist = Setlist(
        id: 's1',
        name: 'Show',
        presetIds: const ['p1', 'p2', 'p3'],
        createdAt: t0,
        updatedAt: t0,
      );

      // Drag index 0 to the end (pre-removal index 3 -> post-removal index 2)
      final movedForward = setlist.reorder(0, 3, updatedAt: t1);
      check(movedForward.presetIds).deepEquals(const ['p2', 'p3', 'p1']);

      // Drag index 2 up to index 0
      final movedBack = movedForward.reorder(2, 0, updatedAt: t1);
      check(movedBack.presetIds).deepEquals(const ['p1', 'p2', 'p3']);

      // Out-of-bounds or no-op returns identical instance
      check(identical(setlist.reorder(-1, 1, updatedAt: t1), setlist)).isTrue();
      check(identical(setlist.reorder(1, 1, updatedAt: t1), setlist)).isTrue();
    });

    test('serializes to JSON and round-trips accurately', () {
      final setlist = Setlist(
        id: 's2',
        name: 'Tour',
        presetIds: const ['p1', 'p3'],
        createdAt: t0,
        updatedAt: t1,
      );

      final decoded = Setlist.fromJson(setlist.toJson());
      check(decoded).equals(setlist);
    });
  });
}

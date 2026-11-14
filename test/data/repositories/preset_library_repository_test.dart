import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metronome/data/repositories/preset_library_repository.dart';
import 'package:metronome/domain/models/bpm.dart';
import 'package:metronome/domain/models/subdivision.dart';
import 'package:metronome/domain/models/time_signature.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PresetLibraryRepository', () {
    late DateTime now;

    setUp(() {
      now = DateTime.utc(2026, 11, 13, 12, 0, 0);
    });

    DateTime tick() {
      now = now.add(const Duration(seconds: 1));
      return now;
    }

    test('creates, sorts favorites first, searches, duplicates, and updates presets', () async {
      final repo = PresetLibraryRepository(clock: tick);
      addTearDown(repo.dispose);

      final p1 = await repo.createPreset(
        name: 'Zebra Groove',
        bpm: const Bpm(110),
        timeSignature: TimeSignature.fourFour,
        subdivision: Subdivision.eighth,
        isAccentEnabled: true,
        note: 'Verse groove',
      );
      final p2 = await repo.createPreset(
        name: 'Alpha Ballad',
        bpm: const Bpm(72),
        timeSignature: TimeSignature.threeFour,
        subdivision: Subdivision.none,
        isAccentEnabled: true,
      );
      final p3 = await repo.createPreset(
        name: 'Middle Funk',
        bpm: const Bpm(105),
        timeSignature: TimeSignature.fourFour,
        subdivision: Subdivision.sixteenth,
        isAccentEnabled: false,
        isFavorite: true,
      );

      // Favorites listed first, then alphabetical (FR-PRE-04)
      check(repo.presets.map((p) => p.id).toList())
          .deepEquals([p3.id, p2.id, p1.id]);

      // Toggle favorite on Zebra Groove -> moves into favorite section sorted before Middle Funk? No, M < Z
      await repo.toggleFavorite(p1.id);
      check(repo.presets.map((p) => p.id).toList())
          .deepEquals([p3.id, p1.id, p2.id]);

      // Search case-insensitively (FR-PRE-05)
      check(repo.searchPresets('BALLAD').map((p) => p.id).toList())
          .deepEquals([p2.id]);
      check(repo.searchPresets('   ')).length.equals(3);

      // Duplicate preset (FR-PRE-03)
      final copy = await repo.duplicatePreset(p2.id);
      check(copy.id).not((it) => it.equals(p2.id));
      check(copy.name).equals('Alpha Ballad (Copy)');
      check(copy.bpm).equals(p2.bpm);
      check(copy.timeSignature).equals(p2.timeSignature);
      check(copy.subdivision).equals(p2.subdivision);

      // Update preset (FR-PRE-03)
      final edited = await repo.updatePreset(
        copy.copyWith(name: 'Alpha Bridge', note: 'Bridge double time'),
      );
      check(edited.name).equals('Alpha Bridge');
      check(edited.note).equals('Bridge double time');
      check(repo.getPresetById(copy.id)?.name).equals('Alpha Bridge');
    });

    test('manages setlists, detects preset usage, and cleans references on preset delete', () async {
      final repo = PresetLibraryRepository(clock: tick);
      addTearDown(repo.dispose);

      final p1 = await repo.createPreset(
        name: 'Intro',
        bpm: const Bpm(120),
        timeSignature: TimeSignature.fourFour,
        subdivision: Subdivision.none,
        isAccentEnabled: true,
      );
      final p2 = await repo.createPreset(
        name: 'Chorus',
        bpm: const Bpm(136),
        timeSignature: TimeSignature.sixEight,
        subdivision: Subdivision.triplet,
        isAccentEnabled: true,
      );
      final p3 = await repo.createPreset(
        name: 'Outro',
        bpm: const Bpm(84),
        timeSignature: TimeSignature.threeFour,
        subdivision: Subdivision.eighth,
        isAccentEnabled: false,
      );

      final s1 = await repo.createSetlist(name: 'Gig A');
      final s2 = await repo.createSetlist(
        name: 'Gig B',
        presetIds: [p1.id, p3.id],
      );

      // Same preset can appear in multiple setlists & multiple times (FR-PRE-07)
      await repo.addPresetToSetlist(s1.id, p1.id);
      await repo.addPresetToSetlist(s1.id, p2.id);
      await repo.addPresetToSetlist(s1.id, p3.id);

      check(repo.findSetlistsContainingPreset(p1.id).map((s) => s.id).toList())
          .deepEquals([s1.id, s2.id]);
      check(repo.findSetlistsContainingPreset(p2.id).map((s) => s.id).toList())
          .deepEquals([s1.id]);

      // Reorder items in s1
      final reordered = await repo.reorderSetlistPresets(s1.id, 0, 3);
      check(reordered.presetIds).deepEquals([p2.id, p3.id, p1.id]);

      // Remove item at index 1 (p3)
      final afterRemove = await repo.removePresetAtFromSetlist(s1.id, 1);
      check(afterRemove.presetIds).deepEquals([p2.id, p1.id]);

      // Rename setlist (FR-PRE-06)
      final renamed = await repo.renameSetlist(s1.id, 'Festival Main');
      check(renamed.name).equals('Festival Main');

      // Delete preset p1 -> removes p1 references from both s1 and s2 (FR-PRE-10, Section 6.3)
      await repo.deletePreset(p1.id);
      check(repo.getPresetById(p1.id)).isNull();
      check(repo.getSetlistById(s1.id)?.presetIds)
          .isNotNull()
          .deepEquals([p2.id]);
      check(repo.getSetlistById(s2.id)?.presetIds)
          .isNotNull()
          .deepEquals([p3.id]);

      // Delete setlist s2 -> presets remain intact
      await repo.deleteSetlist(s2.id);
      check(repo.getSetlistById(s2.id)).isNull();
      check(repo.getPresetById(p3.id)).isNotNull();
    });

    test('persists presets and setlists to SharedPreferences and survives malformed entries', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final repo1 = PresetLibraryRepository(preferences: prefs, clock: tick);
      final preset = await repo1.createPreset(
        name: 'Saved Groove',
        bpm: const Bpm(128),
        timeSignature: const TimeSignature(7, 8),
        subdivision: Subdivision.eighth,
        isAccentEnabled: true,
        isFavorite: true,
        note: '2+2+3 feel',
      );
      final setlist = await repo1.createSetlist(
        name: 'Studio Session',
        presetIds: [preset.id],
      );
      await repo1.dispose();

      // Reload in a fresh repository instance
      final repo2 = PresetLibraryRepository(preferences: prefs);
      addTearDown(repo2.dispose);

      check(repo2.presets).deepEquals([preset]);
      check(repo2.setlists).deepEquals([setlist]);

      // Verify malformed JSON doesn't crash initialization
      await prefs.setString(
        PresetLibraryRepository.keyPresets,
        '{not valid json',
      );
      final repo3 = PresetLibraryRepository(preferences: prefs);
      addTearDown(repo3.dispose);
      check(repo3.presets).isEmpty();
    });
  });
}

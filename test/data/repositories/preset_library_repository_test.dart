import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metronome/data/repositories/preset_library_repository.dart';
import 'package:metronome/data/services/database/app_database.dart';
import 'package:metronome/domain/models/bpm.dart';
import 'package:metronome/domain/models/subdivision.dart';
import 'package:metronome/domain/models/time_signature.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
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
      final copy = await repo.duplicatePreset(
        p2.id,
        duplicatedName: '${p2.name} (Copy)',
      );
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

    test('persists presets, setlists, ordering, and undo flows in SQLite across repository reloads', () async {
      final appDb = await AppDatabase.openInMemory(factory: databaseFactoryFfi);
      addTearDown(appDb.close);

      final repo1 = PresetLibraryRepository(database: appDb, clock: tick);
      await repo1.initialize();

      final p1 = await repo1.createPreset(
        name: 'Saved Groove',
        bpm: const Bpm(128),
        timeSignature: const TimeSignature(7, 8),
        subdivision: Subdivision.eighth,
        isAccentEnabled: true,
        isFavorite: true,
        note: '2+2+3 feel',
      );
      final p2 = await repo1.createPreset(
        name: 'Ballad',
        bpm: const Bpm(72),
        timeSignature: TimeSignature.threeFour,
        subdivision: Subdivision.none,
        isAccentEnabled: false,
      );

      final s1 = await repo1.createSetlist(
        name: 'Studio Session',
        presetIds: [p1.id, p2.id, p1.id],
      );
      final s2 = await repo1.createSetlist(name: 'Encore', presetIds: [p2.id]);
      final s1Copy = await repo1.duplicateSetlist(
        s1.id,
        duplicatedName: 'Studio Session (Copy)',
      );

      // Delete and restore a preset to verify atomic SQLite undo persistence.
      final deletedPreset = await repo1.deletePresetWithUndo(p1.id);
      check(deletedPreset).isNotNull();
      await repo1.restoreDeletedPreset(deletedPreset!);

      // Delete and restore a setlist to verify persisted position ordering.
      final deletedSetlist = await repo1.deleteSetlistWithUndo(s1Copy.id);
      check(deletedSetlist).isNotNull();
      await repo1.restoreDeletedSetlist(deletedSetlist!);

      final expectedPresets = repo1.presets;
      final expectedSetlists = repo1.setlists;
      await repo1.dispose();

      // Reload in a fresh repository instance backed by the same SQLite DB.
      final repo2 = PresetLibraryRepository(database: appDb);
      addTearDown(repo2.dispose);
      await repo2.initialize();

      check(repo2.presets).deepEquals(expectedPresets);
      check(repo2.setlists).deepEquals(expectedSetlists);
      check(repo2.setlists.map((s) => s.id).toList())
          .deepEquals([s1.id, s1Copy.id, s2.id]);
      check(repo2.getSetlistById(s1.id)?.presetIds)
          .isNotNull()
          .deepEquals([p1.id, p2.id, p1.id]);
    });

    test('supports lossless undo for deleting presets, setlists, and setlist entries plus setlist duplication and batch adds', () async {
      final repo = PresetLibraryRepository(clock: tick);
      addTearDown(repo.dispose);

      final p1 = await repo.createPreset(
        name: 'Opener',
        bpm: const Bpm(120),
        timeSignature: TimeSignature.fourFour,
        subdivision: Subdivision.none,
        isAccentEnabled: true,
      );
      final p2 = await repo.createPreset(
        name: 'Bridge',
        bpm: const Bpm(136),
        timeSignature: TimeSignature.threeFour,
        subdivision: Subdivision.eighth,
        isAccentEnabled: true,
      );
      final p3 = await repo.createPreset(
        name: 'Finale',
        bpm: const Bpm(152),
        timeSignature: TimeSignature.sixEight,
        subdivision: Subdivision.triplet,
        isAccentEnabled: false,
      );

      final s1 = await repo.createSetlist(
        name: 'Main Show',
        presetIds: [p1.id, p2.id, p1.id],
      );
      final s2 = await repo.createSetlist(name: 'Encore', presetIds: [p1.id]);

      // Delete p1 with undo -> removes from both setlists (including duplicate occurrences)
      final deletedPreset = await repo.deletePresetWithUndo(p1.id);
      check(deletedPreset).isNotNull();
      check(deletedPreset!.affectedSetlists.map((s) => s.id).toList())
          .deepEquals([s1.id, s2.id]);
      check(repo.getPresetById(p1.id)).isNull();
      check(repo.getSetlistById(s1.id)?.presetIds)
          .isNotNull()
          .deepEquals([p2.id]);
      check(repo.getSetlistById(s2.id)?.presetIds).isNotNull().isEmpty();

      // Restore deleted preset -> exact indices restored across both setlists
      await repo.restoreDeletedPreset(deletedPreset);
      check(repo.getPresetById(p1.id)).equals(p1);
      check(repo.getSetlistById(s1.id)?.presetIds)
          .isNotNull()
          .deepEquals([p1.id, p2.id, p1.id]);
      check(repo.getSetlistById(s2.id)?.presetIds)
          .isNotNull()
          .deepEquals([p1.id]);

      // Duplicate setlist -> inserted right after original with identical preset order
      final duplicated = await repo.duplicateSetlist(
        s1.id,
        duplicatedName: 'Main Show (Copy)',
      );
      check(repo.setlists.map((s) => s.id).toList())
          .deepEquals([s1.id, duplicated.id, s2.id]);
      check(duplicated.presetIds).deepEquals([p1.id, p2.id, p1.id]);

      // Delete setlist with undo -> restores to exact original index
      final deletedSetlist = await repo.deleteSetlistWithUndo(duplicated.id);
      check(deletedSetlist).isNotNull();
      check(deletedSetlist!.originalIndex).equals(1);
      check(repo.setlists.map((s) => s.id).toList()).deepEquals([s1.id, s2.id]);

      await repo.restoreDeletedSetlist(deletedSetlist);
      check(repo.setlists.map((s) => s.id).toList())
          .deepEquals([s1.id, duplicated.id, s2.id]);

      // Batch add multiple presets and undo range
      await repo.addPresetsToSetlist(s2.id, [p2.id, p3.id]);
      check(repo.getSetlistById(s2.id)?.presetIds)
          .isNotNull()
          .deepEquals([p1.id, p2.id, p3.id]);

      await repo.removePresetRangeFromSetlist(s2.id, 1, 2);
      check(repo.getSetlistById(s2.id)?.presetIds)
          .isNotNull()
          .deepEquals([p1.id]);

      // Remove single entry with undo -> reinserts at exact index
      final removedEntry = await repo.removePresetAtWithUndo(s1.id, 1);
      check(removedEntry).isNotNull();
      check(repo.getSetlistById(s1.id)?.presetIds)
          .isNotNull()
          .deepEquals([p1.id, p1.id]);

      await repo.insertPresetInSetlist(
        removedEntry!.setlistId,
        removedEntry.index,
        removedEntry.presetId,
      );
      check(repo.getSetlistById(s1.id)?.presetIds)
          .isNotNull()
          .deepEquals([p1.id, p2.id, p1.id]);
    });
  });
}

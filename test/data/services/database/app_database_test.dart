import 'dart:io';

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metronome/data/services/database/app_database.dart';
import 'package:metronome/data/services/database/migrations/database_migration.dart';
import 'package:metronome/data/services/database/migrations/migration_v1.dart';
import 'package:metronome/data/services/database/preset_dao.dart';
import 'package:metronome/data/services/database/setlist_dao.dart';
import 'package:metronome/domain/models/bpm.dart';
import 'package:metronome/domain/models/preset.dart';
import 'package:metronome/domain/models/setlist.dart';
import 'package:metronome/domain/models/subdivision.dart';
import 'package:metronome/domain/models/time_signature.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _TestMigrationV2 extends DatabaseMigration {
  const _TestMigrationV2();

  @override
  int get version => 2;

  @override
  Future<void> migrate(DatabaseExecutor db) async {
    await db.execute(
      "ALTER TABLE presets ADD COLUMN tag TEXT NOT NULL DEFAULT ''",
    );
  }
}

class _InvalidVersionMigration extends DatabaseMigration {
  const _InvalidVersionMigration(this.version);

  @override
  final int version;

  @override
  Future<void> migrate(DatabaseExecutor db) async {}
}

void main() {
  sqfliteFfiInit();

  group('AppDatabase & Migrations', () {
    test('creates v1 tables, indexes, and enables foreign keys', () async {
      final appDb = await AppDatabase.openInMemory(factory: databaseFactoryFfi);
      addTearDown(appDb.close);

      check(appDb.isOpen).isTrue();

      final fkResult = await appDb.database.rawQuery('PRAGMA foreign_keys');
      check(fkResult.single['foreign_keys']).equals(1);

      final tables = await appDb.database.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name",
      );
      final tableNames = tables
          .map((row) => row['name'] as String)
          .where((name) => !name.startsWith('sqlite_'))
          .toList();
      check(tableNames).deepEquals(['presets', 'setlist_presets', 'setlists']);
    });

    test('runs incremental migrations onUpgrade in ascending order', () async {
      final tempDir = await Directory.systemTemp.createTemp('metronome_db_');
      addTearDown(() async {
        if (tempDir.existsSync()) {
          await tempDir.delete(recursive: true);
        }
      });
      final dbPath = p.join(tempDir.path, 'upgrade_test.db');

      final v1Db = await AppDatabase.open(
        path: dbPath,
        factory: databaseFactoryFfi,
        migrations: const [MigrationV1()],
        singleInstance: false,
      );
      await v1Db.close();

      final v2Db = await AppDatabase.open(
        path: dbPath,
        factory: databaseFactoryFfi,
        migrations: const [_TestMigrationV2(), MigrationV1()],
        singleInstance: false,
      );
      addTearDown(v2Db.close);

      final columns = await v2Db.database.rawQuery(
        'PRAGMA table_info(presets)',
      );
      final columnNames = columns.map((row) => row['name'] as String).toList();
      check(columnNames).contains('tag');
    });

    test('validates migration registry invariants', () async {
      await check(
        AppDatabase.openInMemory(
          factory: databaseFactoryFfi,
          migrations: const [],
        ),
      ).throws<ArgumentError>();

      await check(
        AppDatabase.openInMemory(
          factory: databaseFactoryFfi,
          migrations: const [_InvalidVersionMigration(0)],
        ),
      ).throws<ArgumentError>();

      await check(
        AppDatabase.openInMemory(
          factory: databaseFactoryFfi,
          migrations: const [MigrationV1(), MigrationV1()],
        ),
      ).throws<ArgumentError>();
    });
  });

  group('PresetDao & SetlistDao', () {
    late AppDatabase appDb;
    late PresetDao presetDao;
    late SetlistDao setlistDao;

    final createdAt = DateTime.utc(2026, 11, 26, 10, 0, 0);
    final updatedAt = DateTime.utc(2026, 11, 26, 10, 5, 0);

    Preset makePreset(String id, String name) => Preset(
      id: id,
      name: name,
      bpm: const Bpm(128),
      timeSignature: const TimeSignature(7, 8),
      subdivision: Subdivision.eighth,
      isAccentEnabled: true,
      isFavorite: true,
      note: '2+2+3 feel',
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    setUp(() async {
      appDb = await AppDatabase.openInMemory(factory: databaseFactoryFfi);
      presetDao = PresetDao(appDb.database);
      setlistDao = SetlistDao(appDb.database);
    });

    tearDown(() async {
      await appDb.close();
    });

    test('performs CRUD on presets without cascading on update', () async {
      final p1 = makePreset('p1', 'Song A');
      await presetDao.insert(p1);

      final s1 = Setlist(
        id: 's1',
        name: 'Gig 1',
        presetIds: const ['p1', 'p1'],
        createdAt: createdAt,
        updatedAt: createdAt,
      );
      await setlistDao.insert(s1, position: 0);

      final edited = p1.copyWith(name: 'Song A (Edited)', isFavorite: false);
      await presetDao.update(edited);

      check(await presetDao.getById('p1')).equals(edited);
      final loadedSetlists = await setlistDao.getAll();
      check(loadedSetlists.single.presetIds).deepEquals(['p1', 'p1']);
    });

    test(
      'cascades setlist_presets rows on preset and setlist delete',
      () async {
        final p1 = makePreset('p1', 'Song A');
        final p2 = makePreset('p2', 'Song B');
        await presetDao.insert(p1);
        await presetDao.insert(p2);

        final s1 = Setlist(
          id: 's1',
          name: 'Set 1',
          presetIds: const ['p1', 'p2', 'p1'],
          createdAt: createdAt,
          updatedAt: createdAt,
        );
        await setlistDao.insert(s1, position: 0);

        // Deleting preset p1 cascades its references out of setlist_presets.
        await presetDao.delete('p1');
        final afterPresetDelete = await setlistDao.getAll();
        check(afterPresetDelete.single.presetIds).deepEquals(['p2']);

        // Deleting setlist s1 cascades its remaining setlist_presets rows, while p2 stays.
        await setlistDao.deleteAndSyncPositions(
          's1',
          remainingOrderedIds: const [],
        );
        check(await setlistDao.getAll()).isEmpty();
        check(await presetDao.getById('p2')).equals(p2);

        final orphanRows = await appDb.database.query('setlist_presets');
        check(orphanRows).isEmpty();
      },
    );

    test('preserves setlist ordering on insertAndSyncPositions', () async {
      final p1 = makePreset('p1', 'Song A');
      await presetDao.insert(p1);

      final s1 = Setlist(
        id: 's1',
        name: 'First',
        presetIds: const ['p1'],
        createdAt: createdAt,
        updatedAt: createdAt,
      );
      final s2 = Setlist(
        id: 's2',
        name: 'Third',
        presetIds: const [],
        createdAt: createdAt,
        updatedAt: createdAt,
      );
      final sMiddle = Setlist(
        id: 's_mid',
        name: 'Second',
        presetIds: const ['p1', 'p1'],
        createdAt: updatedAt,
        updatedAt: updatedAt,
      );

      await setlistDao.insert(s1, position: 0);
      await setlistDao.insert(s2, position: 1);
      await setlistDao.insertAndSyncPositions(
        sMiddle,
        orderedSetlistIds: const ['s1', 's_mid', 's2'],
      );

      final all = await setlistDao.getAll();
      check(all.map((s) => s.id).toList()).deepEquals(['s1', 's_mid', 's2']);
      check(all[1].presetIds).deepEquals(['p1', 'p1']);
    });
  });
}

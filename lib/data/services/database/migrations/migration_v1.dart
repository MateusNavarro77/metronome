import 'package:sqflite/sqflite.dart';

import 'database_migration.dart';

/// Initial SQLite schema creating `presets`, `setlists`, and `setlist_presets`.
class MigrationV1 extends DatabaseMigration {
  const MigrationV1();

  @override
  int get version => 1;

  @override
  Future<void> migrate(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE presets (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        bpm INTEGER NOT NULL,
        time_signature_numerator INTEGER NOT NULL,
        time_signature_denominator INTEGER NOT NULL,
        subdivision TEXT NOT NULL,
        is_accent_enabled INTEGER NOT NULL,
        is_favorite INTEGER NOT NULL,
        note TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE setlists (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        position INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE setlist_presets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        setlist_id TEXT NOT NULL,
        preset_id TEXT NOT NULL,
        position INTEGER NOT NULL,
        FOREIGN KEY (setlist_id) REFERENCES setlists(id) ON DELETE CASCADE,
        FOREIGN KEY (preset_id) REFERENCES presets(id) ON DELETE CASCADE
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_setlists_position ON setlists(position)',
    );
    await db.execute(
      'CREATE INDEX idx_setlist_presets_setlist_position '
      'ON setlist_presets(setlist_id, position)',
    );
    await db.execute(
      'CREATE INDEX idx_setlist_presets_preset_id '
      'ON setlist_presets(preset_id)',
    );
  }
}

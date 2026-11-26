import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'migrations/database_migration.dart';

/// Manages the SQLite database lifecycle, foreign-key enforcement, and
/// versioned migrations.
class AppDatabase {
  AppDatabase._(this._database);

  static const String defaultDatabaseName = 'metronome.db';

  final Database _database;

  /// Underlying `sqflite` [Database] handle.
  Database get database => _database;

  /// Whether the database connection is currently open.
  bool get isOpen => _database.isOpen;

  /// Highest schema version defined by [databaseMigrations].
  static int get latestVersion => databaseMigrations.last.version;

  /// Opens (or creates) the SQLite database at [path], running any pending
  /// [migrations] in ascending version order.
  ///
  /// When [path] is omitted, resolves `<databasesPath>/metronome.db`.
  static Future<AppDatabase> open({
    String? path,
    DatabaseFactory? factory,
    List<DatabaseMigration> migrations = databaseMigrations,
    bool singleInstance = true,
  }) async {
    final orderedMigrations = _validateAndSortMigrations(migrations);
    final dbFactory = factory ?? databaseFactory;
    final resolvedPath =
        path ?? p.join(await dbFactory.getDatabasesPath(), defaultDatabaseName);
    final targetVersion = orderedMigrations.last.version;

    final db = await dbFactory.openDatabase(
      resolvedPath,
      options: OpenDatabaseOptions(
        version: targetVersion,
        singleInstance: singleInstance,
        onConfigure: (database) async {
          await database.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: (database, version) async {
          for (final migration in orderedMigrations) {
            if (migration.version <= version) {
              await migration.migrate(database);
            }
          }
        },
        onUpgrade: (database, oldVersion, newVersion) async {
          for (final migration in orderedMigrations) {
            if (migration.version > oldVersion &&
                migration.version <= newVersion) {
              await migration.migrate(database);
            }
          }
        },
      ),
    );

    return AppDatabase._(db);
  }

  /// Opens an isolated in-memory SQLite database (ideal for unit tests).
  static Future<AppDatabase> openInMemory({
    DatabaseFactory? factory,
    List<DatabaseMigration> migrations = databaseMigrations,
  }) {
    return open(
      path: inMemoryDatabasePath,
      factory: factory,
      migrations: migrations,
      singleInstance: false,
    );
  }

  /// Runs [action] inside a single SQLite transaction.
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) {
    return _database.transaction(action);
  }

  /// Closes the database connection if still open.
  Future<void> close() async {
    if (_database.isOpen) {
      await _database.close();
    }
  }

  static List<DatabaseMigration> _validateAndSortMigrations(
    List<DatabaseMigration> migrations,
  ) {
    if (migrations.isEmpty) {
      throw ArgumentError.value(
        migrations,
        'migrations',
        'At least one migration must be registered.',
      );
    }

    final sorted = List<DatabaseMigration>.of(migrations)
      ..sort((a, b) => a.version.compareTo(b.version));

    for (var i = 0; i < sorted.length; i++) {
      final version = sorted[i].version;
      if (version <= 0) {
        throw ArgumentError.value(
          version,
          'migrations',
          'Migration versions must be positive integers.',
        );
      }
      if (i > 0 && version == sorted[i - 1].version) {
        throw ArgumentError.value(
          version,
          'migrations',
          'Duplicate migration version: $version.',
        );
      }
    }

    return sorted;
  }
}

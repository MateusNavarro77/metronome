import 'package:sqflite/sqflite.dart';

import 'migration_v1.dart';

/// Contract for a single versioned SQLite schema migration.
///
/// Each migration lives in its own file under
/// `lib/data/services/database/migrations/` and is registered in
/// [databaseMigrations] in strictly ascending [version] order.
abstract class DatabaseMigration {
  const DatabaseMigration();

  /// Target schema version produced by this migration (starting at `1`).
  int get version;

  /// Applies the DDL/DML statements for this migration.
  ///
  /// Uses [DatabaseExecutor] because `sqflite` already executes `onCreate` and
  /// `onUpgrade` inside a transaction.
  Future<void> migrate(DatabaseExecutor db);
}

/// Ordered registry of all schema migrations for the application database.
const List<DatabaseMigration> databaseMigrations = [MigrationV1()];

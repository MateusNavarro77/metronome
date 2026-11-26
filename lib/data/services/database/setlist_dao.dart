import 'package:sqflite/sqflite.dart';

import '../../../domain/models/setlist.dart';

/// Data Access Object for the `setlists` and `setlist_presets` SQLite tables.
class SetlistDao {
  const SetlistDao(this._db);

  static const String setlistsTable = 'setlists';
  static const String setlistPresetsTable = 'setlist_presets';

  static const String colId = 'id';
  static const String colName = 'name';
  static const String colPosition = 'position';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  static const String colItemSetlistId = 'setlist_id';
  static const String colItemPresetId = 'preset_id';
  static const String colItemPosition = 'position';

  final Database _db;

  /// Returns all persisted setlists ordered by their `position`, hydrated with
  /// their ordered `presetIds`.
  Future<List<Setlist>> getAll({DatabaseExecutor? executor}) async {
    final db = executor ?? _db;
    final setlistRows = await db.query(
      setlistsTable,
      orderBy: '$colPosition ASC, $colCreatedAt ASC, $colId ASC',
    );
    if (setlistRows.isEmpty) return const [];

    final itemRows = await db.query(
      setlistPresetsTable,
      columns: [colItemSetlistId, colItemPresetId],
      orderBy: '$colItemSetlistId ASC, $colItemPosition ASC, $colId ASC',
    );

    final presetIdsBySetlist = <String, List<String>>{};
    for (final row in itemRows) {
      final setlistId = row[colItemSetlistId] as String;
      final presetId = row[colItemPresetId] as String;
      presetIdsBySetlist.putIfAbsent(setlistId, () => <String>[]).add(presetId);
    }

    return setlistRows
        .map((row) {
          final id = row[colId] as String;
          final presetIds = presetIdsBySetlist[id] ?? const <String>[];
          return fromRow(row, presetIds: presetIds);
        })
        .toList(growable: false);
  }

  /// Inserts a new [setlist] at [position] along with its ordered items.
  Future<void> insert(
    Setlist setlist, {
    required int position,
    DatabaseExecutor? executor,
  }) async {
    if (executor != null) {
      await _insertInExecutor(executor, setlist, position);
      return;
    }
    await _db.transaction((txn) => _insertInExecutor(txn, setlist, position));
  }

  /// Inserts [setlist] and rewrites the `position` column for all setlists in
  /// [orderedSetlistIds] atomically (used for duplication and undo restore).
  Future<void> insertAndSyncPositions(
    Setlist setlist, {
    required List<String> orderedSetlistIds,
    DatabaseExecutor? executor,
  }) async {
    Future<void> work(DatabaseExecutor db) async {
      final targetPosition = orderedSetlistIds.indexOf(setlist.id);
      await _insertInExecutor(
        db,
        setlist,
        targetPosition >= 0 ? targetPosition : orderedSetlistIds.length,
      );
      await _updatePositionsInExecutor(db, orderedSetlistIds);
    }

    if (executor != null) {
      await work(executor);
      return;
    }
    await _db.transaction(work);
  }

  /// Updates [setlist]'s metadata (`name`, `updated_at`) and replaces its
  /// ordered `setlist_presets` items atomically.
  Future<void> update(Setlist setlist, {DatabaseExecutor? executor}) async {
    if (executor != null) {
      await _updateInExecutor(executor, setlist);
      return;
    }
    await _db.transaction((txn) => _updateInExecutor(txn, setlist));
  }

  /// Deletes [setlistId] (cascading its `setlist_presets` rows) and compacts
  /// the `position` column for [remainingOrderedIds].
  Future<void> deleteAndSyncPositions(
    String setlistId, {
    required List<String> remainingOrderedIds,
    DatabaseExecutor? executor,
  }) async {
    Future<void> work(DatabaseExecutor db) async {
      await db.delete(
        setlistsTable,
        where: '$colId = ?',
        whereArgs: [setlistId],
      );
      await _updatePositionsInExecutor(db, remainingOrderedIds);
    }

    if (executor != null) {
      await work(executor);
      return;
    }
    await _db.transaction(work);
  }

  Future<void> _insertInExecutor(
    DatabaseExecutor db,
    Setlist setlist,
    int position,
  ) async {
    await db.insert(setlistsTable, {
      colId: setlist.id,
      colName: setlist.name,
      colPosition: position,
      colCreatedAt: setlist.createdAt.toIso8601String(),
      colUpdatedAt: setlist.updatedAt.toIso8601String(),
    });
    await _insertItemsInExecutor(db, setlist.id, setlist.presetIds);
  }

  Future<void> _updateInExecutor(DatabaseExecutor db, Setlist setlist) async {
    await db.update(
      setlistsTable,
      {
        colName: setlist.name,
        colUpdatedAt: setlist.updatedAt.toIso8601String(),
      },
      where: '$colId = ?',
      whereArgs: [setlist.id],
    );
    await db.delete(
      setlistPresetsTable,
      where: '$colItemSetlistId = ?',
      whereArgs: [setlist.id],
    );
    await _insertItemsInExecutor(db, setlist.id, setlist.presetIds);
  }

  Future<void> _insertItemsInExecutor(
    DatabaseExecutor db,
    String setlistId,
    List<String> presetIds,
  ) async {
    for (var i = 0; i < presetIds.length; i++) {
      await db.insert(setlistPresetsTable, {
        colItemSetlistId: setlistId,
        colItemPresetId: presetIds[i],
        colItemPosition: i,
      });
    }
  }

  Future<void> _updatePositionsInExecutor(
    DatabaseExecutor db,
    List<String> orderedSetlistIds,
  ) async {
    for (var i = 0; i < orderedSetlistIds.length; i++) {
      await db.update(
        setlistsTable,
        {colPosition: i},
        where: '$colId = ?',
        whereArgs: [orderedSetlistIds[i]],
      );
    }
  }

  /// Converts a `setlists` SQLite row and its ordered [presetIds] into a
  /// [Setlist] domain model.
  static Setlist fromRow(
    Map<String, Object?> row, {
    required List<String> presetIds,
  }) {
    final id = row[colId] as String;
    final name = row[colName] as String? ?? '';

    final epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    final rawCreatedAt = row[colCreatedAt] as String?;
    final createdAt = rawCreatedAt != null
        ? (DateTime.tryParse(rawCreatedAt) ?? epoch)
        : epoch;
    final rawUpdatedAt = row[colUpdatedAt] as String?;
    final updatedAt = rawUpdatedAt != null
        ? (DateTime.tryParse(rawUpdatedAt) ?? createdAt)
        : createdAt;

    return Setlist(
      id: id,
      name: name,
      presetIds: List<String>.unmodifiable(presetIds),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

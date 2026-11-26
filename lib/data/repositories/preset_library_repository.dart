import 'dart:async';

import 'package:sqflite/sqflite.dart';

import '../../domain/models/bpm.dart';
import '../../domain/models/preset.dart';
import '../../domain/models/setlist.dart';
import '../../domain/models/subdivision.dart';
import '../../domain/models/time_signature.dart';
import '../services/database/app_database.dart';
import '../services/database/preset_dao.dart';
import '../services/database/setlist_dao.dart';

/// Snapshot returned when deleting a [Preset] so the operation can be undone
/// without losing any setlist placements.
class DeletedPresetRecord {
  const DeletedPresetRecord({
    required this.preset,
    required this.removedSetlistPositions,
    required this.affectedSetlists,
  });

  /// The deleted preset snapshot.
  final Preset preset;

  /// Exact 0-based indices where [preset] appeared in each affected setlist.
  final Map<String, List<int>> removedSetlistPositions;

  /// Snapshot of setlists that contained [preset] prior to deletion.
  final List<Setlist> affectedSetlists;
}

/// Snapshot returned when deleting a [Setlist] so it can be restored to its
/// original index.
class DeletedSetlistRecord {
  const DeletedSetlistRecord({
    required this.setlist,
    required this.originalIndex,
  });

  /// The deleted setlist snapshot.
  final Setlist setlist;

  /// Original 0-based index of [setlist] in the repository list.
  final int originalIndex;
}

/// Snapshot returned when removing a single entry from a [Setlist].
class RemovedSetlistEntryRecord {
  const RemovedSetlistEntryRecord({
    required this.setlistId,
    required this.presetId,
    required this.index,
  });

  final String setlistId;
  final String presetId;
  final int index;
}

/// Single source of truth and local SQLite persistence for [Preset]s and
/// [Setlist]s (FR-PRE-01..11, Section 6.1–6.3, NFR-REL-02).
///
/// Maintains an in-memory cache for synchronous reads, hydrated once via
/// [initialize] from SQLite. When no [AppDatabase] / DAOs are provided,
/// operates safely in-memory (ideal for unit and widget tests).
class PresetLibraryRepository {
  PresetLibraryRepository({
    AppDatabase? database,
    PresetDao? presetDao,
    SetlistDao? setlistDao,
    DateTime Function()? clock,
    String Function()? idGenerator,
  }) : _database = database,
       _presetDao =
           presetDao ??
           (database != null ? PresetDao(database.database) : null),
       _setlistDao =
           setlistDao ??
           (database != null ? SetlistDao(database.database) : null),
       _clock = clock ?? DateTime.now,
       _idGenerator = idGenerator;

  final AppDatabase? _database;
  final PresetDao? _presetDao;
  final SetlistDao? _setlistDao;
  final DateTime Function() _clock;
  final String Function()? _idGenerator;

  final StreamController<void> _changesController =
      StreamController<void>.broadcast();

  final List<Preset> _presets = [];
  final List<Setlist> _setlists = [];
  int _idCounter = 0;

  /// Hydrates the in-memory cache from SQLite.
  ///
  /// Must be called once on startup when backed by an [AppDatabase].
  /// Safe to call as a no-op when running in-memory.
  Future<void> initialize() async {
    if (_presetDao == null && _setlistDao == null) return;

    final loadedPresets = await _presetDao?.getAll() ?? const <Preset>[];
    final loadedSetlists = await _setlistDao?.getAll() ?? const <Setlist>[];

    _presets
      ..clear()
      ..addAll(loadedPresets);
    _setlists
      ..clear()
      ..addAll(loadedSetlists);
    _notifyChanges();
  }

  /// Reactive stream emitting whenever presets or setlists change.
  Stream<void> get changes => _changesController.stream;

  /// All saved presets sorted with favorites first, then alphabetically by name
  /// (FR-PRE-04).
  List<Preset> get presets {
    final sorted = List<Preset>.of(_presets)..sort(_comparePresets);
    return List<Preset>.unmodifiable(sorted);
  }

  /// All saved setlists in persisted order.
  List<Setlist> get setlists => List<Setlist>.unmodifiable(_setlists);

  /// Finds a preset by [id], or `null` if none exists.
  Preset? getPresetById(String id) {
    for (final preset in _presets) {
      if (preset.id == id) return preset;
    }
    return null;
  }

  /// Finds a setlist by [id], or `null` if none exists.
  Setlist? getSetlistById(String id) {
    for (final setlist in _setlists) {
      if (setlist.id == id) return setlist;
    }
    return null;
  }

  /// Filters presets by [query] (case-insensitive substring match on name),
  /// preserving favorites-first sorting (FR-PRE-04, FR-PRE-05).
  List<Preset> searchPresets(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return presets;
    final matches =
        _presets
            .where((preset) => preset.name.toLowerCase().contains(normalized))
            .toList()
          ..sort(_comparePresets);
    return List<Preset>.unmodifiable(matches);
  }

  /// Returns all setlists that contain [presetId] (FR-PRE-10).
  List<Setlist> findSetlistsContainingPreset(String presetId) {
    return List<Setlist>.unmodifiable(
      _setlists.where((setlist) => setlist.containsPreset(presetId)),
    );
  }

  /// Creates and persists a new [Preset] (FR-PRE-01, FR-PRE-11).
  Future<Preset> createPreset({
    required String name,
    required Bpm bpm,
    required TimeSignature timeSignature,
    required Subdivision subdivision,
    required bool isAccentEnabled,
    bool isFavorite = false,
    String note = '',
  }) async {
    final now = _clock();
    final trimmedName = name.trim();
    final preset = Preset(
      id: _nextId('preset', now),
      name: trimmedName,
      bpm: bpm,
      timeSignature: timeSignature,
      subdivision: subdivision,
      isAccentEnabled: isAccentEnabled,
      isFavorite: isFavorite,
      note: note.trim(),
      createdAt: now,
      updatedAt: now,
    );
    await _presetDao?.insert(preset);
    _presets.add(preset);
    _notifyChanges();
    return preset;
  }

  /// Updates an existing [Preset] and persists the change (FR-PRE-03).
  Future<Preset> updatePreset(Preset updated) async {
    final index = _presets.indexWhere((item) => item.id == updated.id);
    if (index == -1) {
      throw StateError('Preset not found: ${updated.id}');
    }
    final trimmedName = updated.name.trim();
    final saved = updated.copyWith(
      name: trimmedName,
      note: updated.note.trim(),
      updatedAt: _clock(),
    );
    await _presetDao?.update(saved);
    _presets[index] = saved;
    _notifyChanges();
    return saved;
  }

  /// Duplicates an existing preset using [duplicatedName] provided by the caller
  /// (FR-PRE-03).
  Future<Preset> duplicatePreset(
    String presetId, {
    required String duplicatedName,
  }) async {
    final original = getPresetById(presetId);
    if (original == null) {
      throw StateError('Preset not found: $presetId');
    }
    final now = _clock();
    final copy = original.copyWith(
      id: _nextId('preset', now),
      name: duplicatedName.trim(),
      createdAt: now,
      updatedAt: now,
    );
    await _presetDao?.insert(copy);
    _presets.add(copy);
    _notifyChanges();
    return copy;
  }

  /// Toggles the favorite flag for [presetId] (FR-PRE-04).
  Future<Preset?> toggleFavorite(String presetId) async {
    final index = _presets.indexWhere((item) => item.id == presetId);
    if (index == -1) return null;
    final existing = _presets[index];
    final updated = existing.copyWith(
      isFavorite: !existing.isFavorite,
      updatedAt: _clock(),
    );
    await _presetDao?.update(updated);
    _presets[index] = updated;
    _notifyChanges();
    return updated;
  }

  /// Deletes [presetId] and removes all references to it from every setlist
  /// (FR-PRE-03, Section 6.3).
  Future<void> deletePreset(String presetId) async {
    await deletePresetWithUndo(presetId);
  }

  /// Deletes [presetId], cleans up references in every setlist, and returns a
  /// [DeletedPresetRecord] so the deletion can be undone losslessly.
  Future<DeletedPresetRecord?> deletePresetWithUndo(String presetId) async {
    final presetIndex = _presets.indexWhere((item) => item.id == presetId);
    if (presetIndex == -1) return null;
    final deletedPreset = _presets[presetIndex];

    final now = _clock();
    final removedPositions = <String, List<int>>{};
    final affectedSetlists = <Setlist>[];
    final updatedSetlistsByIndex = <int, Setlist>{};

    for (var i = 0; i < _setlists.length; i++) {
      final current = _setlists[i];
      if (current.containsPreset(presetId)) {
        final indices = <int>[];
        for (var j = 0; j < current.presetIds.length; j++) {
          if (current.presetIds[j] == presetId) {
            indices.add(j);
          }
        }
        removedPositions[current.id] = List<int>.unmodifiable(indices);
        affectedSetlists.add(current);
        updatedSetlistsByIndex[i] = current.removePresetReferences(
          presetId,
          updatedAt: now,
        );
      }
    }

    await _runAtomic((executor) async {
      await _presetDao?.delete(presetId, executor: executor);
      for (final updatedSetlist in updatedSetlistsByIndex.values) {
        await _setlistDao?.update(updatedSetlist, executor: executor);
      }
    });

    _presets.removeAt(presetIndex);
    for (final entry in updatedSetlistsByIndex.entries) {
      _setlists[entry.key] = entry.value;
    }
    _notifyChanges();

    return DeletedPresetRecord(
      preset: deletedPreset,
      removedSetlistPositions: Map<String, List<int>>.unmodifiable(
        removedPositions,
      ),
      affectedSetlists: List<Setlist>.unmodifiable(affectedSetlists),
    );
  }

  /// Restores a previously deleted [Preset] along with its exact placements in
  /// any still-existing setlists.
  Future<void> restoreDeletedPreset(DeletedPresetRecord record) async {
    final alreadyExists = _presets.any((item) => item.id == record.preset.id);

    final now = _clock();
    final updatedSetlistsByIndex = <int, Setlist>{};
    for (final entry in record.removedSetlistPositions.entries) {
      final setlistIndex = _setlists.indexWhere((s) => s.id == entry.key);
      if (setlistIndex == -1) continue;

      final current = _setlists[setlistIndex];
      final nextIds = List<String>.of(current.presetIds);
      final sortedIndices = List<int>.of(entry.value)..sort();
      for (final targetIndex in sortedIndices) {
        final clamped = targetIndex.clamp(0, nextIds.length);
        nextIds.insert(clamped, record.preset.id);
      }
      updatedSetlistsByIndex[setlistIndex] = current.copyWith(
        presetIds: List<String>.unmodifiable(nextIds),
        updatedAt: now,
      );
    }

    await _runAtomic((executor) async {
      if (!alreadyExists) {
        await _presetDao?.insert(record.preset, executor: executor);
      }
      for (final updatedSetlist in updatedSetlistsByIndex.values) {
        await _setlistDao?.update(updatedSetlist, executor: executor);
      }
    });

    if (!alreadyExists) {
      _presets.add(record.preset);
    }
    for (final entry in updatedSetlistsByIndex.entries) {
      _setlists[entry.key] = entry.value;
    }
    _notifyChanges();
  }

  /// Creates and persists a new [Setlist] (FR-PRE-06).
  Future<Setlist> createSetlist({
    required String name,
    List<String> presetIds = const [],
  }) async {
    final now = _clock();
    final trimmedName = name.trim();
    final setlist = Setlist(
      id: _nextId('setlist', now),
      name: trimmedName,
      presetIds: List<String>.unmodifiable(presetIds),
      createdAt: now,
      updatedAt: now,
    );
    await _setlistDao?.insert(setlist, position: _setlists.length);
    _setlists.add(setlist);
    _notifyChanges();
    return setlist;
  }

  /// Updates an existing [Setlist] and persists the change (FR-PRE-06).
  Future<Setlist> updateSetlist(Setlist updated) async {
    final index = _setlists.indexWhere((item) => item.id == updated.id);
    if (index == -1) {
      throw StateError('Setlist not found: ${updated.id}');
    }
    final trimmedName = updated.name.trim();
    final saved = updated.copyWith(name: trimmedName, updatedAt: _clock());
    await _setlistDao?.update(saved);
    _setlists[index] = saved;
    _notifyChanges();
    return saved;
  }

  /// Renames [setlistId] to [newName] (FR-PRE-06).
  Future<Setlist> renameSetlist(String setlistId, String newName) async {
    final existing = getSetlistById(setlistId);
    if (existing == null) {
      throw StateError('Setlist not found: $setlistId');
    }
    return updateSetlist(existing.copyWith(name: newName));
  }

  /// Duplicates an existing setlist with [duplicatedName], inserting the copy
  /// right after the original.
  Future<Setlist> duplicateSetlist(
    String setlistId, {
    required String duplicatedName,
  }) async {
    final index = _setlists.indexWhere((item) => item.id == setlistId);
    if (index == -1) {
      throw StateError('Setlist not found: $setlistId');
    }
    final original = _setlists[index];
    final now = _clock();
    final copy = original.copyWith(
      id: _nextId('setlist', now),
      name: duplicatedName.trim(),
      presetIds: List<String>.unmodifiable(original.presetIds),
      createdAt: now,
      updatedAt: now,
    );
    final nextOrderedIds = [
      ..._setlists.take(index + 1).map((s) => s.id),
      copy.id,
      ..._setlists.skip(index + 1).map((s) => s.id),
    ];
    await _setlistDao?.insertAndSyncPositions(
      copy,
      orderedSetlistIds: nextOrderedIds,
    );
    _setlists.insert(index + 1, copy);
    _notifyChanges();
    return copy;
  }

  /// Appends [presetId] to [setlistId] (FR-PRE-07).
  Future<Setlist> addPresetToSetlist(String setlistId, String presetId) async {
    return addPresetsToSetlist(setlistId, [presetId]);
  }

  /// Appends multiple [presetIds] to [setlistId] in a single atomic update.
  Future<Setlist> addPresetsToSetlist(
    String setlistId,
    List<String> presetIds,
  ) async {
    final index = _setlists.indexWhere((item) => item.id == setlistId);
    if (index == -1) {
      throw StateError('Setlist not found: $setlistId');
    }
    final existing = _setlists[index];
    if (presetIds.isEmpty) return existing;
    final nextIds = List<String>.unmodifiable([
      ...existing.presetIds,
      ...presetIds,
    ]);
    final updated = existing.copyWith(presetIds: nextIds, updatedAt: _clock());
    await _setlistDao?.update(updated);
    _setlists[index] = updated;
    _notifyChanges();
    return updated;
  }

  /// Inserts [presetId] into [setlistId] at [index] (clamped to bounds).
  Future<Setlist> insertPresetInSetlist(
    String setlistId,
    int index,
    String presetId,
  ) async {
    final listIndex = _setlists.indexWhere((item) => item.id == setlistId);
    if (listIndex == -1) {
      throw StateError('Setlist not found: $setlistId');
    }
    final existing = _setlists[listIndex];
    final nextIds = List<String>.of(existing.presetIds);
    nextIds.insert(index.clamp(0, nextIds.length), presetId);
    final updated = existing.copyWith(
      presetIds: List<String>.unmodifiable(nextIds),
      updatedAt: _clock(),
    );
    await _setlistDao?.update(updated);
    _setlists[listIndex] = updated;
    _notifyChanges();
    return updated;
  }

  /// Removes [count] entries starting at [startIndex] from [setlistId].
  Future<Setlist> removePresetRangeFromSetlist(
    String setlistId,
    int startIndex,
    int count,
  ) async {
    final listIndex = _setlists.indexWhere((item) => item.id == setlistId);
    if (listIndex == -1) {
      throw StateError('Setlist not found: $setlistId');
    }
    final existing = _setlists[listIndex];
    if (count <= 0 ||
        startIndex < 0 ||
        startIndex >= existing.presetIds.length) {
      return existing;
    }
    final endIndex = (startIndex + count).clamp(
      startIndex,
      existing.presetIds.length,
    );
    final nextIds = List<String>.of(existing.presetIds)
      ..removeRange(startIndex, endIndex);
    final updated = existing.copyWith(
      presetIds: List<String>.unmodifiable(nextIds),
      updatedAt: _clock(),
    );
    await _setlistDao?.update(updated);
    _setlists[listIndex] = updated;
    _notifyChanges();
    return updated;
  }

  /// Removes the preset entry at [index] within [setlistId] (FR-PRE-07).
  Future<Setlist> removePresetAtFromSetlist(String setlistId, int index) async {
    final listIndex = _setlists.indexWhere((item) => item.id == setlistId);
    if (listIndex == -1) {
      throw StateError('Setlist not found: $setlistId');
    }
    final existing = _setlists[listIndex];
    if (index < 0 || index >= existing.presetIds.length) {
      return existing;
    }
    final nextIds = List<String>.of(existing.presetIds)..removeAt(index);
    final updated = existing.copyWith(
      presetIds: List<String>.unmodifiable(nextIds),
      updatedAt: _clock(),
    );
    await _setlistDao?.update(updated);
    _setlists[listIndex] = updated;
    _notifyChanges();
    return updated;
  }

  /// Removes the preset entry at [index] within [setlistId] and returns a
  /// [RemovedSetlistEntryRecord] for lossless Undo.
  Future<RemovedSetlistEntryRecord?> removePresetAtWithUndo(
    String setlistId,
    int index,
  ) async {
    final existing = getSetlistById(setlistId);
    if (existing == null || index < 0 || index >= existing.presetIds.length) {
      return null;
    }
    final removedPresetId = existing.presetIds[index];
    await removePresetAtFromSetlist(setlistId, index);
    return RemovedSetlistEntryRecord(
      setlistId: setlistId,
      presetId: removedPresetId,
      index: index,
    );
  }

  /// Reorders preset items inside [setlistId] using `ReorderableListView`
  /// index semantics (FR-PRE-07).
  Future<Setlist> reorderSetlistPresets(
    String setlistId,
    int oldIndex,
    int newIndex,
  ) async {
    final listIndex = _setlists.indexWhere((item) => item.id == setlistId);
    if (listIndex == -1) {
      throw StateError('Setlist not found: $setlistId');
    }
    final existing = _setlists[listIndex];
    final updated = existing.reorder(oldIndex, newIndex, updatedAt: _clock());
    if (updated == existing) return existing;

    await _setlistDao?.update(updated);
    _setlists[listIndex] = updated;
    _notifyChanges();
    return updated;
  }

  /// Deletes [setlistId] from the library (FR-PRE-06). Presets inside it are kept.
  Future<void> deleteSetlist(String setlistId) async {
    await deleteSetlistWithUndo(setlistId);
  }

  /// Deletes [setlistId] and returns a [DeletedSetlistRecord] for lossless Undo.
  Future<DeletedSetlistRecord?> deleteSetlistWithUndo(String setlistId) async {
    final index = _setlists.indexWhere((item) => item.id == setlistId);
    if (index == -1) return null;
    final deleted = _setlists[index];
    final remainingIds = [
      for (var i = 0; i < _setlists.length; i++)
        if (i != index) _setlists[i].id,
    ];

    await _setlistDao?.deleteAndSyncPositions(
      setlistId,
      remainingOrderedIds: remainingIds,
    );
    _setlists.removeAt(index);
    _notifyChanges();
    return DeletedSetlistRecord(setlist: deleted, originalIndex: index);
  }

  /// Restores a previously deleted [Setlist] to its original index.
  Future<void> restoreDeletedSetlist(DeletedSetlistRecord record) async {
    final exists = _setlists.any((item) => item.id == record.setlist.id);
    if (exists) return;

    final targetIndex = record.originalIndex.clamp(0, _setlists.length);
    final nextOrderedIds = [
      ..._setlists.take(targetIndex).map((s) => s.id),
      record.setlist.id,
      ..._setlists.skip(targetIndex).map((s) => s.id),
    ];

    await _setlistDao?.insertAndSyncPositions(
      record.setlist,
      orderedSetlistIds: nextOrderedIds,
    );
    _setlists.insert(targetIndex, record.setlist);
    _notifyChanges();
  }

  Future<void> dispose() async {
    await _changesController.close();
  }

  Future<void> _runAtomic(
    Future<void> Function(DatabaseExecutor? executor) work,
  ) async {
    final database = _database;
    if (database != null) {
      await database.transaction((txn) => work(txn));
      return;
    }
    await work(null);
  }

  String _nextId(String prefix, DateTime now) {
    final custom = _idGenerator?.call();
    if (custom != null && custom.isNotEmpty) return custom;
    _idCounter++;
    return '${prefix}_${now.microsecondsSinceEpoch}_$_idCounter';
  }

  static int _comparePresets(Preset a, Preset b) {
    if (a.isFavorite != b.isFavorite) {
      return a.isFavorite ? -1 : 1;
    }
    final nameOrder = a.name.toLowerCase().compareTo(b.name.toLowerCase());
    if (nameOrder != 0) return nameOrder;
    final createdOrder = a.createdAt.compareTo(b.createdAt);
    if (createdOrder != 0) return createdOrder;
    return a.id.compareTo(b.id);
  }

  void _notifyChanges() {
    if (!_changesController.isClosed) {
      _changesController.add(null);
    }
  }
}

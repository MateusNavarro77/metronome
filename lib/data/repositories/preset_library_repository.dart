import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/bpm.dart';
import '../../domain/models/preset.dart';
import '../../domain/models/setlist.dart';
import '../../domain/models/subdivision.dart';
import '../../domain/models/time_signature.dart';

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

/// Single source of truth and local persistence for [Preset]s and [Setlist]s
/// (FR-PRE-01..11, Section 6.1–6.3, NFR-REL-02).
///
/// Accepts an optional [SharedPreferences] instance. When `null`, operates
/// safely in-memory (ideal for unit/widget tests).
class PresetLibraryRepository {
  PresetLibraryRepository({
    SharedPreferences? preferences,
    DateTime Function()? clock,
    String Function()? idGenerator,
  }) : _preferences = preferences,
       _clock = clock ?? DateTime.now,
       _idGenerator = idGenerator {
    _loadFromPreferences();
  }

  static const int currentSchemaVersion = 1;
  static const String keyPresets = 'presets_storage_v1';
  static const String keySetlists = 'setlists_storage_v1';

  final SharedPreferences? _preferences;
  final DateTime Function() _clock;
  final String Function()? _idGenerator;

  final StreamController<void> _changesController =
      StreamController<void>.broadcast();

  final List<Preset> _presets = [];
  final List<Setlist> _setlists = [];
  int _idCounter = 0;

  /// Reactive stream emitting whenever presets or setlists change.
  Stream<void> get changes => _changesController.stream;

  /// All saved presets sorted with favorites first, then alphabetically by name
  /// (FR-PRE-04).
  List<Preset> get presets {
    final sorted = List<Preset>.of(_presets)..sort(_comparePresets);
    return List<Preset>.unmodifiable(sorted);
  }

  /// All saved setlists in creation order.
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
    _presets.add(preset);
    await _persistPresets();
    _notifyChanges();
    return preset;
  }

  /// Updates an existing [Preset] and persists the library (FR-PRE-03).
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
    _presets[index] = saved;
    await _persistPresets();
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
    _presets.add(copy);
    await _persistPresets();
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
    _presets[index] = updated;
    await _persistPresets();
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
    final deletedPreset = _presets.removeAt(presetIndex);

    final now = _clock();
    final removedPositions = <String, List<int>>{};
    final affectedSetlists = <Setlist>[];
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
        _setlists[i] = current.removePresetReferences(presetId, updatedAt: now);
      }
    }

    await _persistPresets();
    if (affectedSetlists.isNotEmpty) {
      await _persistSetlists();
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
    final exists = _presets.any((item) => item.id == record.preset.id);
    if (!exists) {
      _presets.add(record.preset);
    }

    final now = _clock();
    var setlistsModified = false;
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
      _setlists[setlistIndex] = current.copyWith(
        presetIds: List<String>.unmodifiable(nextIds),
        updatedAt: now,
      );
      setlistsModified = true;
    }

    await _persistPresets();
    if (setlistsModified) {
      await _persistSetlists();
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
    _setlists.add(setlist);
    await _persistSetlists();
    _notifyChanges();
    return setlist;
  }

  /// Updates an existing [Setlist] and persists the library (FR-PRE-06).
  Future<Setlist> updateSetlist(Setlist updated) async {
    final index = _setlists.indexWhere((item) => item.id == updated.id);
    if (index == -1) {
      throw StateError('Setlist not found: ${updated.id}');
    }
    final trimmedName = updated.name.trim();
    final saved = updated.copyWith(name: trimmedName, updatedAt: _clock());
    _setlists[index] = saved;
    await _persistSetlists();
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
    _setlists.insert(index + 1, copy);
    await _persistSetlists();
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
    _setlists[index] = updated;
    await _persistSetlists();
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
    _setlists[listIndex] = updated;
    await _persistSetlists();
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
    _setlists[listIndex] = updated;
    await _persistSetlists();
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
    _setlists[listIndex] = updated;
    await _persistSetlists();
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

    _setlists[listIndex] = updated;
    await _persistSetlists();
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
    final deleted = _setlists.removeAt(index);

    await _persistSetlists();
    _notifyChanges();
    return DeletedSetlistRecord(setlist: deleted, originalIndex: index);
  }

  /// Restores a previously deleted [Setlist] to its original index.
  Future<void> restoreDeletedSetlist(DeletedSetlistRecord record) async {
    final exists = _setlists.any((item) => item.id == record.setlist.id);
    if (!exists) {
      final targetIndex = record.originalIndex.clamp(0, _setlists.length);
      _setlists.insert(targetIndex, record.setlist);
    }
    await _persistSetlists();
    _notifyChanges();
  }

  Future<void> dispose() async {
    await _changesController.close();
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

  void _loadFromPreferences() {
    final prefs = _preferences;
    if (prefs == null) return;

    final rawPresets = prefs.getString(keyPresets);
    if (rawPresets != null && rawPresets.isNotEmpty) {
      _presets.addAll(_decodeItems(rawPresets, Preset.fromJson));
    }

    final rawSetlists = prefs.getString(keySetlists);
    if (rawSetlists != null && rawSetlists.isNotEmpty) {
      _setlists.addAll(_decodeItems(rawSetlists, Setlist.fromJson));
    }
  }

  List<T> _decodeItems<T>(
    String rawJson,
    T Function(Map<String, Object?>) fromJson,
  ) {
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is! Map<String, Object?>) return const [];
      final rawVersion = decoded['schemaVersion'];
      final schemaVersion = rawVersion is int ? rawVersion : 1;
      if (schemaVersion > currentSchemaVersion) {
        // Attempt forward-compatible read of items array if present.
      }
      final rawItems = decoded['items'];
      if (rawItems is! List<Object?>) return const [];

      final parsed = <T>[];
      for (final entry in rawItems) {
        if (entry is Map<String, Object?>) {
          try {
            parsed.add(fromJson(entry));
          } catch (_) {
            // Skip malformed item without losing the rest of the library.
          }
        }
      }
      return parsed;
    } catch (_) {
      return const [];
    }
  }

  Future<void> _persistPresets() async {
    final prefs = _preferences;
    if (prefs == null) return;
    final payload = jsonEncode({
      'schemaVersion': currentSchemaVersion,
      'items': _presets.map((preset) => preset.toJson()).toList(),
    });
    await prefs.setString(keyPresets, payload);
  }

  Future<void> _persistSetlists() async {
    final prefs = _preferences;
    if (prefs == null) return;
    final payload = jsonEncode({
      'schemaVersion': currentSchemaVersion,
      'items': _setlists.map((setlist) => setlist.toJson()).toList(),
    });
    await prefs.setString(keySetlists, payload);
  }

  void _notifyChanges() {
    if (!_changesController.isClosed) {
      _changesController.add(null);
    }
  }
}

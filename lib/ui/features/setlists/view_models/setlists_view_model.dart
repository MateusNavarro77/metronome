import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/preset_library_repository.dart';
import '../../../../domain/models/preset.dart';
import '../../../../domain/models/setlist.dart';
import '../../metronome/view_models/metronome_view_model.dart';

/// ViewModel for the Setlists screen and Setlist Detail editor (FR-PRE-06..09).
class SetlistsViewModel extends ChangeNotifier {
  SetlistsViewModel({
    required PresetLibraryRepository repository,
    required MetronomeViewModel metronomeViewModel,
  }) : _repository = repository,
       _metronomeViewModel = metronomeViewModel,
       _isPlayingNotifier = ValueNotifier<bool>(metronomeViewModel.isPlaying) {
    _lastActiveSetlistId = _metronomeViewModel.state.activeSetlistId;
    _lastActiveSetlistIndex = _metronomeViewModel.activeSetlistIndex;
    _librarySubscription = _repository.changes.listen((_) {
      notifyListeners();
    });
    _metronomeViewModel.addListener(_onMetronomeChanged);
  }

  final PresetLibraryRepository _repository;
  final MetronomeViewModel _metronomeViewModel;
  final ValueNotifier<bool> _isPlayingNotifier;

  StreamSubscription<void>? _librarySubscription;
  String? _lastActiveSetlistId;
  int _lastActiveSetlistIndex = 0;

  /// Reactive playback flag for subtle live indicators on the active card
  /// without rebuilding the entire setlist screen on beat ticks or play toggles.
  ValueListenable<bool> get isPlayingListenable => _isPlayingNotifier;

  /// All saved setlists.
  List<Setlist> get setlists => _repository.setlists;

  /// All available presets in the library (favorites first) for adding to setlists.
  List<Preset> get availablePresets => _repository.presets;

  /// Identifier of the currently active setlist, if any.
  String? get activeSetlistId => _metronomeViewModel.state.activeSetlistId;

  /// 0-based active song index within the active setlist.
  int get activeSetlistIndex => _metronomeViewModel.activeSetlistIndex;

  /// Retrieves a fresh copy of a setlist by [id].
  Setlist? getSetlistById(String id) => _repository.getSetlistById(id);

  /// Resolves the ordered list of [Preset] objects referenced by [setlist].
  List<Preset> resolvePresetsForSetlist(Setlist setlist) {
    final resolved = <Preset>[];
    for (final presetId in setlist.presetIds) {
      final preset = _repository.getPresetById(presetId);
      if (preset != null) {
        resolved.add(preset);
      }
    }
    return List<Preset>.unmodifiable(resolved);
  }

  /// Creates a new setlist (FR-PRE-06).
  Future<Setlist> createSetlist({
    required String name,
    List<String> presetIds = const [],
  }) {
    return _repository.createSetlist(name: name, presetIds: presetIds);
  }

  /// Renames an existing setlist (FR-PRE-06).
  Future<Setlist> renameSetlist(String setlistId, String newName) {
    return _repository.renameSetlist(setlistId, newName);
  }

  /// Duplicates an existing setlist with [duplicatedName].
  Future<Setlist> duplicateSetlist(
    String setlistId, {
    required String duplicatedName,
  }) {
    return _repository.duplicateSetlist(
      setlistId,
      duplicatedName: duplicatedName,
    );
  }

  /// Deletes a setlist without deleting its referenced presets (FR-PRE-06).
  Future<void> deleteSetlist(String setlistId) {
    return _repository.deleteSetlist(setlistId);
  }

  /// Deletes a setlist and returns a [DeletedSetlistRecord] for lossless Undo.
  Future<DeletedSetlistRecord?> deleteSetlistWithUndo(String setlistId) {
    return _repository.deleteSetlistWithUndo(setlistId);
  }

  /// Restores a previously deleted setlist (and re-activates it if needed).
  Future<void> restoreDeletedSetlist(
    DeletedSetlistRecord record, {
    bool wasActive = false,
    int previousActiveIndex = 0,
  }) async {
    await _repository.restoreDeletedSetlist(record);
    if (wasActive) {
      _metronomeViewModel.activateSetlist(
        record.setlist,
        initialIndex: previousActiveIndex,
      );
    }
  }

  /// Appends [presetId] to [setlistId] (FR-PRE-07).
  Future<Setlist> addPresetToSetlist(String setlistId, String presetId) {
    return _repository.addPresetToSetlist(setlistId, presetId);
  }

  /// Appends multiple [presetIds] to [setlistId] in one batch operation.
  Future<Setlist> addPresetsToSetlist(
    String setlistId,
    List<String> presetIds,
  ) {
    return _repository.addPresetsToSetlist(setlistId, presetIds);
  }

  /// Removes [count] entries starting at [startIndex] from [setlistId] (for Undo).
  Future<Setlist> removePresetRangeFromSetlist(
    String setlistId,
    int startIndex,
    int count,
  ) {
    return _repository.removePresetRangeFromSetlist(
      setlistId,
      startIndex,
      count,
    );
  }

  /// Removes the preset entry at [index] from [setlistId] (FR-PRE-07).
  Future<Setlist> removePresetAt(String setlistId, int index) {
    return _repository.removePresetAtFromSetlist(setlistId, index);
  }

  /// Removes the preset entry at [index] from [setlistId] and returns an undo record.
  Future<RemovedSetlistEntryRecord?> removePresetAtWithUndo(
    String setlistId,
    int index,
  ) {
    return _repository.removePresetAtWithUndo(setlistId, index);
  }

  /// Restores a previously removed preset entry back to its exact index.
  Future<Setlist> restoreRemovedPreset(RemovedSetlistEntryRecord record) {
    return _repository.insertPresetInSetlist(
      record.setlistId,
      record.index,
      record.presetId,
    );
  }

  /// Reorders presets inside [setlistId] (FR-PRE-07).
  Future<Setlist> reorderPresets(String setlistId, int oldIndex, int newIndex) {
    return _repository.reorderSetlistPresets(setlistId, oldIndex, newIndex);
  }

  /// Activates [setlist] starting at [initialIndex] (FR-PRE-08, FR-PRE-09).
  void activateSetlist(Setlist setlist, {int initialIndex = 0}) {
    _metronomeViewModel.activateSetlist(setlist, initialIndex: initialIndex);
  }

  /// Deactivates any active setlist.
  void deactivateSetlist() {
    _metronomeViewModel.deactivateSetlist();
  }

  void _onMetronomeChanged() {
    final playing = _metronomeViewModel.isPlaying;
    if (_isPlayingNotifier.value != playing) {
      _isPlayingNotifier.value = playing;
    }

    final currentSetlistId = activeSetlistId;
    final currentSetlistIndex = activeSetlistIndex;
    if (currentSetlistId == _lastActiveSetlistId &&
        currentSetlistIndex == _lastActiveSetlistIndex) {
      return;
    }
    _lastActiveSetlistId = currentSetlistId;
    _lastActiveSetlistIndex = currentSetlistIndex;
    notifyListeners();
  }

  @override
  void dispose() {
    _librarySubscription?.cancel();
    _metronomeViewModel.removeListener(_onMetronomeChanged);
    _isPlayingNotifier.dispose();
    super.dispose();
  }
}

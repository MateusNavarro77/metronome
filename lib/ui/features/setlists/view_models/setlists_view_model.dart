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
       _metronomeViewModel = metronomeViewModel {
    _librarySubscription = _repository.changes.listen((_) {
      notifyListeners();
    });
    _metronomeViewModel.addListener(_onMetronomeChanged);
  }

  final PresetLibraryRepository _repository;
  final MetronomeViewModel _metronomeViewModel;

  StreamSubscription<void>? _librarySubscription;

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

  /// Deletes a setlist without deleting its referenced presets (FR-PRE-06).
  Future<void> deleteSetlist(String setlistId) {
    return _repository.deleteSetlist(setlistId);
  }

  /// Appends [presetId] to [setlistId] (FR-PRE-07).
  Future<Setlist> addPresetToSetlist(String setlistId, String presetId) {
    return _repository.addPresetToSetlist(setlistId, presetId);
  }

  /// Removes the preset entry at [index] from [setlistId] (FR-PRE-07).
  Future<Setlist> removePresetAt(String setlistId, int index) {
    return _repository.removePresetAtFromSetlist(setlistId, index);
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
    notifyListeners();
  }

  @override
  void dispose() {
    _librarySubscription?.cancel();
    _metronomeViewModel.removeListener(_onMetronomeChanged);
    super.dispose();
  }
}

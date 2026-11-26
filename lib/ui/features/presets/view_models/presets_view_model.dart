import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/preset_library_repository.dart';
import '../../../../domain/models/bpm.dart';
import '../../../../domain/models/preset.dart';
import '../../../../domain/models/setlist.dart';
import '../../../../domain/models/subdivision.dart';
import '../../../../domain/models/time_signature.dart';
import '../../metronome/view_models/metronome_view_model.dart';

/// ViewModel for the Presets screen (FR-PRE-01..05, FR-PRE-10..11).
class PresetsViewModel extends ChangeNotifier {
  PresetsViewModel({
    required PresetLibraryRepository repository,
    required MetronomeViewModel metronomeViewModel,
  }) : _repository = repository,
       _metronomeViewModel = metronomeViewModel,
       _isPlayingNotifier = ValueNotifier<bool>(metronomeViewModel.isPlaying) {
    _lastActivePresetId = _metronomeViewModel.activePresetId;
    _librarySubscription = _repository.changes.listen((_) {
      notifyListeners();
    });
    _metronomeViewModel.addListener(_onMetronomeChanged);
  }

  final PresetLibraryRepository _repository;
  final MetronomeViewModel _metronomeViewModel;
  final ValueNotifier<bool> _isPlayingNotifier;

  StreamSubscription<void>? _librarySubscription;
  String _searchQuery = '';
  bool _favoritesOnly = false;
  String? _lastActivePresetId;

  /// Reactive playback flag for subtle live indicators on the active card
  /// without rebuilding the entire preset list on beat ticks or play toggles.
  ValueListenable<bool> get isPlayingListenable => _isPlayingNotifier;

  /// Current search query entered by the user (FR-PRE-05).
  String get searchQuery => _searchQuery;

  /// Whether the list is filtered to show only favorite presets.
  bool get favoritesOnly => _favoritesOnly;

  /// All presets sorted with favorites first (FR-PRE-04).
  List<Preset> get allPresets => _repository.presets;

  /// All saved setlists so a preset can be added directly to one.
  List<Setlist> get setlists => _repository.setlists;

  /// Number of presets marked as favorite.
  int get favoriteCount =>
      _repository.presets.where((preset) => preset.isFavorite).length;

  /// Filtered presets matching [searchQuery] and [favoritesOnly], with
  /// favorites listed first (FR-PRE-04, FR-PRE-05).
  List<Preset> get filteredPresets {
    final matching = _repository.searchPresets(_searchQuery);
    if (!_favoritesOnly) return matching;
    return List<Preset>.unmodifiable(
      matching.where((preset) => preset.isFavorite),
    );
  }

  /// Identifier of the currently loaded preset, if any.
  String? get activePresetId => _metronomeViewModel.activePresetId;

  /// Current metronome state defaults for pre-populating a new preset.
  Bpm get currentBpm => _metronomeViewModel.state.bpm;
  TimeSignature get currentTimeSignature =>
      _metronomeViewModel.state.timeSignature;
  Subdivision get currentSubdivision => _metronomeViewModel.state.subdivision;
  bool get currentAccentEnabled => _metronomeViewModel.state.isAccentEnabled;

  /// Updates the search query and notifies listeners (FR-PRE-05).
  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();
  }

  /// Toggles filtering by favorites only.
  void setFavoritesOnly(bool value) {
    if (_favoritesOnly == value) return;
    _favoritesOnly = value;
    notifyListeners();
  }

  /// Clears active search query and favorites filter.
  void clearFilters() {
    if (_searchQuery.isEmpty && !_favoritesOnly) return;
    _searchQuery = '';
    _favoritesOnly = false;
    notifyListeners();
  }

  /// Loads [preset] with one tap without leaving the Presets view (FR-PRE-02).
  void loadPreset(Preset preset) {
    _metronomeViewModel.loadPreset(preset);
  }

  /// Creates a new preset (FR-PRE-01, FR-PRE-11).
  Future<Preset> createPreset({
    required String name,
    required Bpm bpm,
    required TimeSignature timeSignature,
    required Subdivision subdivision,
    required bool isAccentEnabled,
    bool isFavorite = false,
    String note = '',
  }) {
    return _repository.createPreset(
      name: name,
      bpm: bpm,
      timeSignature: timeSignature,
      subdivision: subdivision,
      isAccentEnabled: isAccentEnabled,
      isFavorite: isFavorite,
      note: note,
    );
  }

  /// Updates an existing preset (FR-PRE-03).
  Future<Preset> updatePreset(Preset updated) {
    return _repository.updatePreset(updated);
  }

  /// Duplicates the preset identified by [id] with [duplicatedName] (FR-PRE-03).
  Future<Preset> duplicatePreset(String id, {required String duplicatedName}) {
    return _repository.duplicatePreset(id, duplicatedName: duplicatedName);
  }

  /// Toggles favorite status for [id] (FR-PRE-04).
  Future<Preset?> toggleFavorite(String id) {
    return _repository.toggleFavorite(id);
  }

  /// Deletes [id] and removes all references to it from setlists
  /// (FR-PRE-03, Section 6.3).
  Future<void> deletePreset(String id) {
    return _repository.deletePreset(id);
  }

  /// Deletes [id] and returns a [DeletedPresetRecord] so the deletion can be
  /// undone losslessly.
  Future<DeletedPresetRecord?> deletePresetWithUndo(String id) {
    return _repository.deletePresetWithUndo(id);
  }

  /// Restores a deleted preset along with its setlist references and optional
  /// active state.
  Future<void> restoreDeletedPreset(
    DeletedPresetRecord record, {
    bool wasActive = false,
  }) async {
    await _repository.restoreDeletedPreset(record);
    if (wasActive) {
      _metronomeViewModel.loadPreset(record.preset);
    }
  }

  /// Appends [presetId] to [setlistId] and returns the updated setlist.
  Future<Setlist> addPresetToSetlist(String setlistId, String presetId) {
    return _repository.addPresetToSetlist(setlistId, presetId);
  }

  /// Removes the preset entry at [index] from [setlistId] (used for Undo).
  Future<Setlist> removePresetAtFromSetlist(String setlistId, int index) {
    return _repository.removePresetAtFromSetlist(setlistId, index);
  }

  /// Creates a new setlist (optionally pre-populated with [presetIds]).
  Future<Setlist> createSetlist({
    required String name,
    List<String> presetIds = const [],
  }) {
    return _repository.createSetlist(name: name, presetIds: presetIds);
  }

  /// Deletes [setlistId] (used for Undo when a new setlist was created inline).
  Future<void> deleteSetlist(String setlistId) {
    return _repository.deleteSetlist(setlistId);
  }

  /// Returns all setlists referencing [id] so delete flows can inform the user
  /// (FR-PRE-10).
  List<Setlist> setlistsContainingPreset(String id) {
    return _repository.findSetlistsContainingPreset(id);
  }

  void _onMetronomeChanged() {
    final playing = _metronomeViewModel.isPlaying;
    if (_isPlayingNotifier.value != playing) {
      _isPlayingNotifier.value = playing;
    }

    final currentActivePresetId = _metronomeViewModel.activePresetId;
    if (currentActivePresetId == _lastActivePresetId) return;
    _lastActivePresetId = currentActivePresetId;
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

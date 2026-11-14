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
       _metronomeViewModel = metronomeViewModel {
    _librarySubscription = _repository.changes.listen((_) {
      notifyListeners();
    });
    _metronomeViewModel.addListener(_onMetronomeChanged);
  }

  final PresetLibraryRepository _repository;
  final MetronomeViewModel _metronomeViewModel;

  StreamSubscription<void>? _librarySubscription;
  String _searchQuery = '';

  /// Current search query entered by the user (FR-PRE-05).
  String get searchQuery => _searchQuery;

  /// All presets sorted with favorites first (FR-PRE-04).
  List<Preset> get allPresets => _repository.presets;

  /// Filtered presets matching [searchQuery], with favorites listed first
  /// (FR-PRE-04, FR-PRE-05).
  List<Preset> get filteredPresets => _repository.searchPresets(_searchQuery);

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

  /// Duplicates the preset identified by [id] (FR-PRE-03).
  Future<Preset> duplicatePreset(String id) {
    return _repository.duplicatePreset(id);
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

  /// Returns all setlists referencing [id] so delete confirmation can warn the
  /// user (FR-PRE-10).
  List<Setlist> setlistsContainingPreset(String id) {
    return _repository.findSetlistsContainingPreset(id);
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

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/metronome_repository.dart';
import '../../../../data/repositories/preferences_repository.dart';
import '../../../../data/repositories/preset_library_repository.dart';
import '../../../../domain/models/bpm.dart';
import '../../../../domain/models/metronome_state.dart';
import '../../../../domain/models/preset.dart';
import '../../../../domain/models/setlist.dart';
import '../../../../domain/models/subdivision.dart';
import '../../../../domain/models/tempo_marking.dart';
import '../../../../domain/models/time_signature.dart';
import '../../../../domain/use_cases/tap_tempo_calculator.dart';

/// ViewModel for the main Metronome screen following the MVVM pattern.
///
/// Manages UI state, continuous button hold acceleration (FR-BPM-02),
/// monotonic tap tempo calculation (FR-TAP-05), and preset/setlist playback
/// integration (FR-PRE-02, FR-PRE-08, FR-PRE-09).
class MetronomeViewModel extends ChangeNotifier {
  MetronomeViewModel({
    required MetronomeRepository repository,
    PreferencesRepository? preferencesRepository,
    PresetLibraryRepository? presetLibraryRepository,
    TapTempoCalculator? tapTempoCalculator,
    Duration Function()? clock,
  }) : _repository = repository,
       _preferencesRepository = preferencesRepository,
       _presetLibraryRepository = presetLibraryRepository,
       _tapTempoCalculator = tapTempoCalculator ?? TapTempoCalculator(),
       _clock = clock {
    _monotonicWatch.start();
    final persistedAccent = _preferencesRepository?.getAccentEnabled();
    if (persistedAccent != null &&
        persistedAccent != _repository.state.isAccentEnabled) {
      _repository.setAccentEnabled(persistedAccent);
    }
    _stateSubscription = _repository.stateChanges.listen((_) {
      notifyListeners();
    });
    _librarySubscription = _presetLibraryRepository?.changes.listen((_) {
      _onLibraryChanged();
    });
  }

  final MetronomeRepository _repository;
  final PreferencesRepository? _preferencesRepository;
  final PresetLibraryRepository? _presetLibraryRepository;
  final TapTempoCalculator _tapTempoCalculator;
  final Duration Function()? _clock;
  final Stopwatch _monotonicWatch = Stopwatch();

  StreamSubscription<MetronomeState>? _stateSubscription;
  StreamSubscription<void>? _librarySubscription;
  Timer? _holdRepeatTimer;
  int _holdTicks = 0;

  /// Current immutable [MetronomeState] snapshot.
  MetronomeState get state => _repository.state;

  /// Current BPM value (`30..300`).
  int get bpmValue => state.bpm.value;

  /// Current [TempoMarking] (e.g. Allegro, Andante).
  TempoMarking get tempoMarking => state.tempoMarking;

  /// Current [TimeSignature].
  TimeSignature get timeSignature => state.timeSignature;

  /// Current [Subdivision].
  Subdivision get subdivision => state.subdivision;

  /// Whether the metronome is currently playing.
  bool get isPlaying => state.isPlaying;

  /// Whether the accented beat on Beat 1 is enabled.
  bool get isAccentEnabled => state.isAccentEnabled;

  /// Active 0-based beat index within the bar (`0 .. timeSignature.numerator - 1`).
  int get currentBeat => state.currentBeat;

  /// Active 0-based subdivision index within the beat (`0 .. subdivision.pulsesPerBeat - 1`).
  int get currentSubdivision => state.currentSubdivision;

  /// Identifier of the currently loaded [Preset], if any.
  String? get activePresetId => state.activePresetId;

  /// Currently loaded [Preset], if present in the library.
  Preset? get activePreset {
    final id = state.activePresetId;
    if (id == null) return null;
    return _presetLibraryRepository?.getPresetById(id);
  }

  /// Currently active [Setlist], if any (FR-PRE-08).
  Setlist? get activeSetlist {
    final id = state.activeSetlistId;
    if (id == null) return null;
    return _presetLibraryRepository?.getSetlistById(id);
  }

  /// Resolved presets belonging to [activeSetlist], skipping any missing IDs.
  List<Preset> get activeSetlistPresets {
    final setlist = activeSetlist;
    final library = _presetLibraryRepository;
    if (setlist == null || library == null) return const [];

    final resolved = <Preset>[];
    for (final presetId in setlist.presetIds) {
      final preset = library.getPresetById(presetId);
      if (preset != null) {
        resolved.add(preset);
      }
    }
    return List<Preset>.unmodifiable(resolved);
  }

  /// Clamped 0-based index of the current song in [activeSetlistPresets].
  int get activeSetlistIndex {
    final presets = activeSetlistPresets;
    if (presets.isEmpty) return 0;
    return state.activeSetlistIndex.clamp(0, presets.length - 1);
  }

  /// Total number of resolved presets in [activeSetlist].
  int get activeSetlistTotal => activeSetlistPresets.length;

  /// Current [Preset] selected inside [activeSetlist].
  Preset? get currentSetlistPreset {
    final presets = activeSetlistPresets;
    if (presets.isEmpty) return null;
    return presets[activeSetlistIndex];
  }

  /// Position display label such as `'3 of 12'` (FR-PRE-08).
  String get activeSetlistPositionLabel {
    final total = activeSetlistTotal;
    if (total == 0) return '';
    return '${activeSetlistIndex + 1} of $total';
  }

  /// Whether there is a previous item to step to in [activeSetlist].
  bool get canStepPreviousSetlistItem =>
      activeSetlist != null && activeSetlistIndex > 0;

  /// Whether there is a next item to step to in [activeSetlist].
  bool get canStepNextSetlistItem =>
      activeSetlist != null && activeSetlistIndex < activeSetlistTotal - 1;

  /// Whether a bar-synced transition is queued for the next downbeat (FR-PRE-09).
  bool get hasPendingBarTransition => state.hasPendingBarTransition;

  /// Whether preset persistence is wired up in this ViewModel.
  bool get canSavePresets => _presetLibraryRepository != null;

  /// Initializes the audio engine.
  Future<void> initialize() => _repository.initialize();

  /// Sets the BPM to [value] (clamped to `[30, 300]`).
  void setBpm(int value) {
    _repository.setBpm(Bpm.clamped(value));
  }

  /// Adjusts the BPM by [delta] (e.g. `-1`, `+1`, `-5`, `+5`).
  void adjustBpm(int delta) {
    _repository.setBpm(state.bpm.adjust(delta));
  }

  /// Starts continuous BPM adjustment with acceleration while a `-` or `+`
  /// button is held down (FR-BPM-02).
  void startContinuousBpmAdjustment(int direction) {
    stopContinuousBpmAdjustment();
    final stepSign = direction.sign;
    if (stepSign == 0) return;

    _holdTicks = 0;
    _holdRepeatTimer = Timer.periodic(const Duration(milliseconds: 110), (_) {
      _holdTicks++;
      // Accelerate step size the longer the user holds the button
      final magnitude = switch (_holdTicks) {
        < 8 => 1,
        < 18 => 2,
        _ => 5,
      };
      adjustBpm(stepSign * magnitude);
    });
  }

  /// Stops continuous BPM adjustment when the button is released or cancelled.
  void stopContinuousBpmAdjustment() {
    _holdRepeatTimer?.cancel();
    _holdRepeatTimer = null;
    _holdTicks = 0;
  }

  /// Registers a tap on the Tap Tempo button at the exact monotonic touch instant
  /// (FR-TAP-02..05).
  ///
  /// Optionally accepts [timestamp] from `PointerDownEvent.timeStamp`; falls back
  /// to the injected clock or internal monotonic [Stopwatch].
  void registerTapTempo({Duration? timestamp}) {
    final instant = timestamp ?? _clock?.call() ?? _monotonicWatch.elapsed;
    final calculatedBpm = _tapTempoCalculator.registerTap(instant);
    if (calculatedBpm != null) {
      _repository.setBpm(calculatedBpm);
    }
    notifyListeners();
  }

  /// Selects a [TimeSignature] (FR-CMP-01).
  void selectTimeSignature(TimeSignature signature) {
    _repository.setTimeSignature(signature);
  }

  /// Selects a [Subdivision] (FR-SUB-01).
  void selectSubdivision(Subdivision subdivision) {
    _repository.setSubdivision(subdivision);
  }

  /// Sets whether the accented beat is enabled.
  void setAccentEnabled(bool enabled) {
    if (isAccentEnabled == enabled) return;
    _repository.setAccentEnabled(enabled);
    _preferencesRepository?.setAccentEnabled(enabled);
  }

  /// Toggles the accented beat on/off.
  void toggleAccent() {
    setAccentEnabled(!isAccentEnabled);
  }

  /// Toggles play/stop (FR-PLY-01).
  Future<void> togglePlayStop() => _repository.togglePlayStop();

  /// Loads [preset] into the metronome (FR-PRE-02, FR-PRE-09).
  void loadPreset(Preset preset) {
    _repository.applyPreset(preset);
    _preferencesRepository?.setAccentEnabled(preset.isAccentEnabled);
    notifyListeners();
  }

  /// Activates [setlist] starting at [initialIndex] (FR-PRE-08, FR-PRE-09).
  void activateSetlist(Setlist setlist, {int initialIndex = 0}) {
    final library = _presetLibraryRepository;
    if (library == null) return;

    final resolved = <Preset>[];
    for (final presetId in setlist.presetIds) {
      final preset = library.getPresetById(presetId);
      if (preset != null) {
        resolved.add(preset);
      }
    }
    if (resolved.isEmpty) return;

    final targetIndex = initialIndex.clamp(0, resolved.length - 1);
    final preset = resolved[targetIndex];
    _repository.activateSetlist(
      setlistId: setlist.id,
      index: targetIndex,
      preset: preset,
    );
    _preferencesRepository?.setAccentEnabled(preset.isAccentEnabled);
    notifyListeners();
  }

  /// Advances to the next song in [activeSetlist] (FR-PRE-08, FR-PRE-09).
  void nextSetlistItem() {
    if (!canStepNextSetlistItem) return;
    final setlist = activeSetlist!;
    final nextIndex = activeSetlistIndex + 1;
    final preset = activeSetlistPresets[nextIndex];
    _repository.activateSetlist(
      setlistId: setlist.id,
      index: nextIndex,
      preset: preset,
    );
    _preferencesRepository?.setAccentEnabled(preset.isAccentEnabled);
    notifyListeners();
  }

  /// Steps back to the previous song in [activeSetlist] (FR-PRE-08, FR-PRE-09).
  void previousSetlistItem() {
    if (!canStepPreviousSetlistItem) return;
    final setlist = activeSetlist!;
    final prevIndex = activeSetlistIndex - 1;
    final preset = activeSetlistPresets[prevIndex];
    _repository.activateSetlist(
      setlistId: setlist.id,
      index: prevIndex,
      preset: preset,
    );
    _preferencesRepository?.setAccentEnabled(preset.isAccentEnabled);
    notifyListeners();
  }

  /// Deactivates the active setlist while keeping the current tempo/meter.
  void deactivateSetlist() {
    _repository.deactivateSetlist();
    notifyListeners();
  }

  /// Saves a [Preset] using the current metronome parameters by default, or
  /// the provided overrides from the editor sheet (UC-06, FR-PRE-01, FR-PRE-11).
  Future<Preset?> saveCurrentAsPreset({
    required String name,
    String note = '',
    bool isFavorite = false,
    Bpm? bpm,
    TimeSignature? timeSignature,
    Subdivision? subdivision,
    bool? isAccentEnabled,
  }) async {
    final library = _presetLibraryRepository;
    if (library == null) return null;

    final created = await library.createPreset(
      name: name,
      bpm: bpm ?? state.bpm,
      timeSignature: timeSignature ?? state.timeSignature,
      subdivision: subdivision ?? state.subdivision,
      isAccentEnabled: isAccentEnabled ?? state.isAccentEnabled,
      isFavorite: isFavorite,
      note: note,
    );
    _repository.setActivePresetId(created.id);
    return created;
  }

  void _onLibraryChanged() {
    final library = _presetLibraryRepository;
    if (library == null) return;

    final activeSetlistId = state.activeSetlistId;
    if (activeSetlistId != null) {
      final setlist = library.getSetlistById(activeSetlistId);
      if (setlist == null) {
        _repository.deactivateSetlist();
      } else {
        final resolved = activeSetlistPresets;
        if (resolved.isEmpty) {
          _repository.deactivateSetlist();
        } else {
          final clampedIndex = state.activeSetlistIndex.clamp(
            0,
            resolved.length - 1,
          );
          if (clampedIndex != state.activeSetlistIndex) {
            _repository.syncActiveSetlistIndex(
              clampedIndex,
              activePresetId: resolved[clampedIndex].id,
            );
          }
        }
      }
    }

    final presetId = state.activePresetId;
    if (presetId != null && library.getPresetById(presetId) == null) {
      _repository.setActivePresetId(null);
    }

    notifyListeners();
  }

  @override
  void dispose() {
    stopContinuousBpmAdjustment();
    _stateSubscription?.cancel();
    _librarySubscription?.cancel();
    super.dispose();
  }
}

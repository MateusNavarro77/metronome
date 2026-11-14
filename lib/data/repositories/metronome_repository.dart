import 'dart:async';

import '../../domain/models/beat_event.dart';
import '../../domain/models/bpm.dart';
import '../../domain/models/metronome_state.dart';
import '../../domain/models/preset.dart';
import '../../domain/models/subdivision.dart';
import '../../domain/models/time_signature.dart';
import '../services/metronome_engine.dart';

/// Single source of truth for the Metronome state (NFR-MAN-03).
///
/// Consumes [MetronomeEngine] and exposes the current [MetronomeState] as well
/// as a reactive stream of state updates.
class MetronomeRepository {
  MetronomeRepository({
    required MetronomeEngine engine,
    MetronomeState initialState = const MetronomeState(),
  }) : _engine = engine,
       _state = initialState {
    // ignore: prefer_initializing_formals
    _beatSubscription = _engine.beatEvents.listen(_onBeatEvent);
  }

  final MetronomeEngine _engine;
  final StreamController<MetronomeState> _stateController =
      StreamController<MetronomeState>.broadcast();

  StreamSubscription<BeatEvent>? _beatSubscription;
  MetronomeState _state;

  /// Latest immutable [MetronomeState] snapshot.
  MetronomeState get state => _state;

  /// Broadcast stream of [MetronomeState] changes.
  Stream<MetronomeState> get stateChanges => _stateController.stream;

  /// Direct stream of [BeatEvent] pulses from the engine.
  Stream<BeatEvent> get beatEvents => _engine.beatEvents;

  /// Initializes the underlying audio engine.
  Future<void> initialize() => _engine.initialize();

  /// Updates the BPM and notifies the engine without interrupting playback (FR-BPM-04).
  void setBpm(Bpm bpm) {
    if (_state.bpm == bpm) return;
    _engine.updateConfiguration(bpm: bpm);
    _updateState(_state.copyWith(bpm: bpm));
  }

  /// Updates the time signature (FR-CMP-01, FR-CMP-06).
  void setTimeSignature(TimeSignature timeSignature) {
    if (_state.timeSignature == timeSignature) return;
    _engine.updateConfiguration(timeSignature: timeSignature);
    final clampedBeat = _state.currentBeat >= timeSignature.numerator
        ? 0
        : _state.currentBeat;
    _updateState(
      _state.copyWith(timeSignature: timeSignature, currentBeat: clampedBeat),
    );
  }

  /// Updates the active subdivision (FR-SUB-01, FR-SUB-03).
  void setSubdivision(Subdivision subdivision) {
    if (_state.subdivision == subdivision) return;
    _engine.updateConfiguration(subdivision: subdivision);
    _updateState(
      _state.copyWith(subdivision: subdivision, currentSubdivision: 0),
    );
  }

  /// Updates whether the accented beat is enabled.
  void setAccentEnabled(bool enabled) {
    if (_state.isAccentEnabled == enabled) return;
    _engine.updateConfiguration(isAccentEnabled: enabled);
    _updateState(_state.copyWith(isAccentEnabled: enabled));
  }

  /// Applies all parameters of [preset] (FR-PRE-02, FR-PRE-09).
  ///
  /// When stopped, updates the engine configuration immediately. When playing,
  /// updates the UI/domain state immediately and schedules the engine transition
  /// at the start of the next bar without interrupting playback.
  void applyPreset(Preset preset, {String? setlistId, int? setlistIndex}) {
    final nextSetlistId = setlistId ?? _state.activeSetlistId;
    final nextSetlistIndex = setlistIndex ?? _state.activeSetlistIndex;

    if (_state.isPlaying) {
      _engine.scheduleNextBarConfiguration(
        bpm: preset.bpm,
        timeSignature: preset.timeSignature,
        subdivision: preset.subdivision,
        isAccentEnabled: preset.isAccentEnabled,
      );
      _updateState(
        _state.copyWith(
          bpm: preset.bpm,
          timeSignature: preset.timeSignature,
          subdivision: preset.subdivision,
          isAccentEnabled: preset.isAccentEnabled,
          activePresetId: preset.id,
          activeSetlistId: nextSetlistId,
          activeSetlistIndex: nextSetlistIndex,
          hasPendingBarTransition: true,
        ),
      );
      return;
    }

    _engine.updateConfiguration(
      bpm: preset.bpm,
      timeSignature: preset.timeSignature,
      subdivision: preset.subdivision,
      isAccentEnabled: preset.isAccentEnabled,
    );
    _updateState(
      _state.copyWith(
        bpm: preset.bpm,
        timeSignature: preset.timeSignature,
        subdivision: preset.subdivision,
        isAccentEnabled: preset.isAccentEnabled,
        currentBeat: 0,
        currentSubdivision: 0,
        activePresetId: preset.id,
        activeSetlistId: nextSetlistId,
        activeSetlistIndex: nextSetlistIndex,
        hasPendingBarTransition: false,
      ),
    );
  }

  /// Activates [setlistId] at [index] and applies [preset] (FR-PRE-08, FR-PRE-09).
  void activateSetlist({
    required String setlistId,
    required int index,
    required Preset preset,
  }) {
    applyPreset(preset, setlistId: setlistId, setlistIndex: index);
  }

  /// Deactivates any currently active setlist while keeping current tempo/meter.
  void deactivateSetlist() {
    if (_state.activeSetlistId == null) return;
    _updateState(_state.copyWith(clearActiveSetlist: true));
  }

  /// Updates the active preset tracking ID without altering playback parameters.
  void setActivePresetId(String? presetId) {
    if (_state.activePresetId == presetId) return;
    _updateState(
      _state.copyWith(
        activePresetId: presetId,
        clearActivePreset: presetId == null,
      ),
    );
  }

  /// Syncs the active setlist index (e.g. after reordering or deleting items).
  void syncActiveSetlistIndex(int index, {String? activePresetId}) {
    if (_state.activeSetlistId == null) return;
    _updateState(
      _state.copyWith(
        activeSetlistIndex: index,
        activePresetId: activePresetId,
      ),
    );
  }

  /// Starts playback from Beat 1 (FR-PLY-02).
  Future<void> start() async {
    if (_state.isPlaying) return;
    _updateState(
      _state.copyWith(
        isPlaying: true,
        currentBeat: 0,
        currentSubdivision: 0,
        hasPendingBarTransition: false,
      ),
    );
    await _engine.start(
      bpm: _state.bpm,
      timeSignature: _state.timeSignature,
      subdivision: _state.subdivision,
      isAccentEnabled: _state.isAccentEnabled,
    );
  }

  /// Stops playback immediately and resets counter to the first beat (FR-PLY-04).
  Future<void> stop() async {
    if (!_state.isPlaying && !_engine.isPlaying) return;
    await _engine.stop();
    _updateState(
      _state.copyWith(
        isPlaying: false,
        currentBeat: 0,
        currentSubdivision: 0,
        hasPendingBarTransition: false,
        clearLastBeatEvent: true,
      ),
    );
  }

  /// Toggles between playing and stopped states (FR-PLY-01).
  Future<void> togglePlayStop() async {
    if (_state.isPlaying) {
      await stop();
    } else {
      await start();
    }
  }

  void _onBeatEvent(BeatEvent event) {
    if (!_state.isPlaying) return;
    _updateState(
      _state.copyWith(
        currentBeat: event.beatIndex,
        currentSubdivision: event.subdivisionIndex,
        lastBeatEvent: event,
        hasPendingBarTransition: event.isDownbeat
            ? false
            : _state.hasPendingBarTransition,
      ),
    );
  }

  void _updateState(MetronomeState newState) {
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(_state);
    }
  }

  Future<void> dispose() async {
    await _beatSubscription?.cancel();
    await _engine.dispose();
    await _stateController.close();
  }
}

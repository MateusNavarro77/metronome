import 'beat_event.dart';
import 'bpm.dart';
import 'subdivision.dart';
import 'tempo_marking.dart';
import 'time_signature.dart';

/// Immutable snapshot of the metronome's domain state (NFR-MAN-01, NFR-MAN-03).
class const MetronomeState({
  this.bpm = Bpm.initial,
  this.timeSignature = TimeSignature.fourFour,
  this.subdivision = Subdivision.none,
  this.isAccentEnabled = true,
  this.isPlaying = false,
  this.currentBeat = 0,
  this.currentSubdivision = 0,
  this.lastBeatEvent,
  this.activePresetId,
  this.activeSetlistId,
  this.activeSetlistIndex = 0,
  this.hasPendingBarTransition = false,
}) {
  final Bpm bpm;
  final TimeSignature timeSignature;
  final Subdivision subdivision;
  final bool isAccentEnabled;
  final bool isPlaying;

  /// 0-based index of the current beat in the bar (`0 .. timeSignature.numerator - 1`).
  final int currentBeat;

  /// 0-based index of the current subdivision within the beat (`0 .. subdivision.pulsesPerBeat - 1`).
  final int currentSubdivision;

  /// Most recent beat event emitted by the engine while playing, or `null` when stopped.
  final BeatEvent? lastBeatEvent;

  /// Identifier of the currently loaded [Preset], if any.
  final String? activePresetId;

  /// Identifier of the currently active [Setlist], if any (FR-PRE-08).
  final String? activeSetlistId;

  /// 0-based index of the current song within the active setlist.
  final int activeSetlistIndex;

  /// Whether a preset/setlist transition is queued for the start of the next bar (FR-PRE-09).
  final bool hasPendingBarTransition;

  /// Current tempo marking derived from [bpm] (FR-AND-01).
  TempoMarking get tempoMarking => bpm.tempoMarking;

  MetronomeState copyWith({
    Bpm? bpm,
    TimeSignature? timeSignature,
    Subdivision? subdivision,
    bool? isAccentEnabled,
    bool? isPlaying,
    int? currentBeat,
    int? currentSubdivision,
    BeatEvent? lastBeatEvent,
    bool clearLastBeatEvent = false,
    String? activePresetId,
    bool clearActivePreset = false,
    String? activeSetlistId,
    bool clearActiveSetlist = false,
    int? activeSetlistIndex,
    bool? hasPendingBarTransition,
  }) {
    return MetronomeState(
      bpm: bpm ?? this.bpm,
      timeSignature: timeSignature ?? this.timeSignature,
      subdivision: subdivision ?? this.subdivision,
      isAccentEnabled: isAccentEnabled ?? this.isAccentEnabled,
      isPlaying: isPlaying ?? this.isPlaying,
      currentBeat: currentBeat ?? this.currentBeat,
      currentSubdivision: currentSubdivision ?? this.currentSubdivision,
      lastBeatEvent: clearLastBeatEvent
          ? null
          : (lastBeatEvent ?? this.lastBeatEvent),
      activePresetId: clearActivePreset
          ? null
          : (activePresetId ?? this.activePresetId),
      activeSetlistId: clearActiveSetlist
          ? null
          : (activeSetlistId ?? this.activeSetlistId),
      activeSetlistIndex: clearActiveSetlist
          ? (activeSetlistIndex ?? 0)
          : (activeSetlistIndex ?? this.activeSetlistIndex),
      hasPendingBarTransition:
          hasPendingBarTransition ?? this.hasPendingBarTransition,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetronomeState &&
          other.bpm == bpm &&
          other.timeSignature == timeSignature &&
          other.subdivision == subdivision &&
          other.isAccentEnabled == isAccentEnabled &&
          other.isPlaying == isPlaying &&
          other.currentBeat == currentBeat &&
          other.currentSubdivision == currentSubdivision &&
          other.lastBeatEvent == lastBeatEvent &&
          other.activePresetId == activePresetId &&
          other.activeSetlistId == activeSetlistId &&
          other.activeSetlistIndex == activeSetlistIndex &&
          other.hasPendingBarTransition == hasPendingBarTransition);

  @override
  int get hashCode => Object.hash(
    bpm,
    timeSignature,
    subdivision,
    isAccentEnabled,
    isPlaying,
    currentBeat,
    currentSubdivision,
    lastBeatEvent,
    activePresetId,
    activeSetlistId,
    activeSetlistIndex,
    hasPendingBarTransition,
  );
}

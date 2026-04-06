part of 'metronome_bloc.dart';

sealed class MetronomeEvent {}

class MetronomePaused extends MetronomeEvent {}

class MetronomePlayed extends MetronomeEvent {}

class MetronomeBpmChanged extends MetronomeEvent {
  final int bpm;

  MetronomeBpmChanged({required this.bpm});
}

class MetronomeTicked extends MetronomeEvent {
  final Tick tick;

  MetronomeTicked({required this.tick});
}

class MetronomeBpmIncremented extends MetronomeEvent {
  MetronomeBpmIncremented();
}

class MetronomeBpmDecremented extends MetronomeEvent {
  MetronomeBpmDecremented();
}

class MetronomeAccentFirstBeatToggled extends MetronomeEvent {}

class MetronomeBeatsPerBarChanged extends MetronomeEvent {
  final int beatsPerBar;

  MetronomeBeatsPerBarChanged({required this.beatsPerBar});
}

class MetronomeTapped extends MetronomeEvent {}

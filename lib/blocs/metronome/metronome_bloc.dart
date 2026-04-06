import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:metronome/domain/metronome.dart';
import 'package:metronome/domain/tick.dart';
import 'package:metronome/shared/constants.dart';

part 'metronome_event.dart';
part 'metronome_state.dart';

class MetronomeBloc extends Bloc<MetronomeEvent, MetronomeState> {
  final Metronome _metronome;
  late StreamSubscription<Tick> _tickStreamSub;
  final List<DateTime> _tapTimes = [];

  MetronomeBloc({required Metronome metronome})
    : _metronome = metronome,
      super(
        MetronomeState(
          bpm: metronome.bpm,
          isRunning: metronome.isRunning,
          accentOnFirstBeat: false,
          beatsPerBar: metronome.beatsPerBar,
        ),
      ) {
    _tickStreamSub = _metronome.tickStream().listen((tick) {
      add(MetronomeTicked(tick: tick));
    });
    on<MetronomeTicked>((event, emit) {
      emit(state.copyWith(tick: event.tick));
    });
    on<MetronomePlayed>((event, emit) async {
      emit(state.copyWith(isRunning: true));
      await _metronome.start();
    });
    on<MetronomeTapped>((event, emit) {
      final now = DateTime.now();
      if (_tapTimes.isNotEmpty &&
          now.difference(_tapTimes.last).inSeconds >= 2) {
        _tapTimes.clear();
      }
      _tapTimes.add(now);

      if (_tapTimes.length > 5) {
        _tapTimes.removeAt(0);
      }

      if (_tapTimes.length == 5) {
        final totalDuration =
            _tapTimes.last.difference(_tapTimes.first).inMilliseconds;
        final averageIntervalMs = totalDuration / 4;
        final calculatedBpm = (60000 / averageIntervalMs).round();

        final clampedBpm = calculatedBpm.clamp(kMinBpm, kMaxBpm);

        if (_isValidBpmRange(clampedBpm)) {
          _metronome.setBpm(clampedBpm);
          emit(state.copyWith(bpm: clampedBpm));
        }
      }
    });
    on<MetronomePaused>((event, emit) {
      _metronome.stop();
      emit(state.copyWith(isRunning: _metronome.isRunning));
    });
    on<MetronomeBpmChanged>((event, emit) {
      if (_isValidBpmRange(event.bpm)) {
        _metronome.setBpm(event.bpm);
        emit(state.copyWith(bpm: event.bpm));
      }
    });
    on<MetronomeBpmIncremented>((event, emit) {
      final nextBpm = _metronome.bpm + 1;
      if (_isValidBpmRange(nextBpm)) {
        _metronome.setBpm(nextBpm);

        emit(state.copyWith(bpm: nextBpm));
      }
    });
    on<MetronomeBpmDecremented>((event, emit) {
      final nextBpm = _metronome.bpm - 1;
      if (_isValidBpmRange(nextBpm)) {
        _metronome.setBpm(nextBpm);
        emit(state.copyWith(bpm: nextBpm));
      }
    });
    on<MetronomeAccentFirstBeatToggled>((event, emit) {
      final useAccentTick = !state.accentOnFirstBeat;
      _metronome.setUseAccentTick(useAccentTick);
      emit(state.copyWith(accentOnFirstBeat: useAccentTick));
    });
    on<MetronomeBeatsPerBarChanged>((event, emit) {
      _metronome.setBeatsPerBar(event.beatsPerBar);
      emit(state.copyWith(beatsPerBar: event.beatsPerBar));
    });
  }
  @override
  Future<void> close() {
    _tickStreamSub.cancel();
    return super.close();
  }

  bool _isValidBpmRange(int bpm) {
    return kMinBpm <= bpm && bpm <= kMaxBpm;
  }
}

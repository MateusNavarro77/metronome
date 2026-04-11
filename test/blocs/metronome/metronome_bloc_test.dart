import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metronome/blocs/metronome/metronome_bloc.dart';
import 'package:metronome/domain/metronome.dart';
import 'package:metronome/domain/tick.dart';
import 'package:mocktail/mocktail.dart';

class MockMetronome extends Mock implements Metronome {}

Matcher isMetronomeState({
  int? bpm,
  dynamic tick = anything,
  bool? isRunning,
  bool? accentOnFirstBeat,
  int? beatsPerBar,
}) {
  var matcher = isA<MetronomeState>();
  if (bpm != null) matcher = matcher.having((s) => s.bpm, 'bpm', bpm);
  if (tick != anything) matcher = matcher.having((s) => s.tick, 'tick', tick);
  if (isRunning != null) matcher = matcher.having((s) => s.isRunning, 'isRunning', isRunning);
  if (accentOnFirstBeat != null) matcher = matcher.having((s) => s.accentOnFirstBeat, 'accentOnFirstBeat', accentOnFirstBeat);
  if (beatsPerBar != null) matcher = matcher.having((s) => s.beatsPerBar, 'beatsPerBar', beatsPerBar);
  return matcher;
}

void main() {
  late MockMetronome mockMetronome;
  late StreamController<Tick> tickStreamController;

  setUp(() {
    mockMetronome = MockMetronome();
    tickStreamController = StreamController<Tick>.broadcast();

    // Default implementations for mock that are accessed in the constructor or during normal stream events
    when(() => mockMetronome.bpm).thenReturn(120);
    when(() => mockMetronome.isRunning).thenReturn(false);
    when(() => mockMetronome.beatsPerBar).thenReturn(4);
    when(() => mockMetronome.tickStream())
        .thenAnswer((_) => tickStreamController.stream);
  });

  tearDown(() {
    tickStreamController.close();
  });

  group('MetronomeBloc', () {
    test('initial state is correct', () {
      final bloc = MetronomeBloc(metronome: mockMetronome);
      expect(
        bloc.state,
        isMetronomeState(
          bpm: 120,
          isRunning: false,
          accentOnFirstBeat: false,
          beatsPerBar: 4,
          tick: null,
        ),
      );
      bloc.close();
    });

    blocTest<MetronomeBloc, MetronomeState>(
      'emits state with new tick when MetronomeTicked is added',
      build: () => MetronomeBloc(metronome: mockMetronome),
      act: (bloc) {
        tickStreamController.add(const RegularTick(barIndex: 0));
      },
      expect: () => [
        isMetronomeState(
          bpm: 120,
          isRunning: false,
          accentOnFirstBeat: false,
          beatsPerBar: 4,
          tick: isA<RegularTick>().having((t) => t.barIndex, 'barIndex', 0),
        ),
      ],
    );

    blocTest<MetronomeBloc, MetronomeState>(
      'emits [isRunning: true] when MetronomePlayed is added and calls start()',
      build: () {
        when(() => mockMetronome.start()).thenAnswer((_) async {});
        return MetronomeBloc(metronome: mockMetronome);
      },
      act: (bloc) => bloc.add(MetronomePlayed()),
      expect: () => [
        isMetronomeState(
          bpm: 120,
          isRunning: true,
          accentOnFirstBeat: false,
          beatsPerBar: 4,
          tick: null,
        ),
      ],
      verify: (_) {
        verify(() => mockMetronome.start()).called(1);
      },
    );

    blocTest<MetronomeBloc, MetronomeState>(
      'emits [isRunning: false] when MetronomePaused is added and calls stop()',
      build: () {
        when(() => mockMetronome.stop()).thenReturn(null);
        when(() => mockMetronome.isRunning).thenReturn(false);
        return MetronomeBloc(metronome: mockMetronome);
      },
      seed: () => MetronomeState(
        bpm: 120,
        isRunning: true,
        accentOnFirstBeat: false,
        beatsPerBar: 4,
      ),
      act: (bloc) => bloc.add(MetronomePaused()),
      expect: () => [
        isMetronomeState(
          bpm: 120,
          isRunning: false,
          accentOnFirstBeat: false,
          beatsPerBar: 4,
          tick: null,
        ),
      ],
      verify: (_) {
        verify(() => mockMetronome.stop()).called(1);
      },
    );

    blocTest<MetronomeBloc, MetronomeState>(
      'emits [bpm: 140] when MetronomeBpmChanged is added with valid bpm',
      build: () {
        when(() => mockMetronome.setBpm(140)).thenReturn(null);
        return MetronomeBloc(metronome: mockMetronome);
      },
      act: (bloc) => bloc.add(MetronomeBpmChanged(bpm: 140)),
      expect: () => [
        isMetronomeState(
          bpm: 140,
          isRunning: false,
          accentOnFirstBeat: false,
          beatsPerBar: 4,
          tick: null,
        ),
      ],
      verify: (_) {
        verify(() => mockMetronome.setBpm(140)).called(1);
      },
    );

    blocTest<MetronomeBloc, MetronomeState>(
      'does not emit when MetronomeBpmChanged is added with invalid bpm (too high)',
      build: () => MetronomeBloc(metronome: mockMetronome),
      act: (bloc) => bloc.add(MetronomeBpmChanged(bpm: 9999)),
      expect: () => [],
      verify: (_) {
        verifyNever(() => mockMetronome.setBpm(any()));
      },
    );

    blocTest<MetronomeBloc, MetronomeState>(
      'emits [bpm: 121] when MetronomeBpmIncremented is added',
      build: () {
        when(() => mockMetronome.setBpm(121)).thenReturn(null);
        return MetronomeBloc(metronome: mockMetronome);
      },
      act: (bloc) => bloc.add(MetronomeBpmIncremented()),
      expect: () => [
        isMetronomeState(
          bpm: 121,
          isRunning: false,
          accentOnFirstBeat: false,
          beatsPerBar: 4,
          tick: null,
        ),
      ],
      verify: (_) {
        verify(() => mockMetronome.setBpm(121)).called(1);
      },
    );

    blocTest<MetronomeBloc, MetronomeState>(
      'emits [bpm: 119] when MetronomeBpmDecremented is added',
      build: () {
        when(() => mockMetronome.setBpm(119)).thenReturn(null);
        return MetronomeBloc(metronome: mockMetronome);
      },
      act: (bloc) => bloc.add(MetronomeBpmDecremented()),
      expect: () => [
        isMetronomeState(
          bpm: 119,
          isRunning: false,
          accentOnFirstBeat: false,
          beatsPerBar: 4,
          tick: null,
        ),
      ],
      verify: (_) {
        verify(() => mockMetronome.setBpm(119)).called(1);
      },
    );

    blocTest<MetronomeBloc, MetronomeState>(
      'emits [accentOnFirstBeat: true] when MetronomeAccentFirstBeatToggled is added',
      build: () {
        when(() => mockMetronome.setUseAccentTick(true)).thenReturn(null);
        return MetronomeBloc(metronome: mockMetronome);
      },
      act: (bloc) => bloc.add(MetronomeAccentFirstBeatToggled()),
      expect: () => [
        isMetronomeState(
          bpm: 120,
          isRunning: false,
          accentOnFirstBeat: true,
          beatsPerBar: 4,
          tick: null,
        ),
      ],
      verify: (_) {
        verify(() => mockMetronome.setUseAccentTick(true)).called(1);
      },
    );

    blocTest<MetronomeBloc, MetronomeState>(
      'emits [beatsPerBar: 3] when MetronomeBeatsPerBarChanged is added',
      build: () {
        when(() => mockMetronome.setBeatsPerBar(3)).thenReturn(null);
        return MetronomeBloc(metronome: mockMetronome);
      },
      act: (bloc) => bloc.add(MetronomeBeatsPerBarChanged(beatsPerBar: 3)),
      expect: () => [
        isMetronomeState(
          bpm: 120,
          isRunning: false,
          accentOnFirstBeat: false,
          beatsPerBar: 3,
          tick: null,
        ),
      ],
      verify: (_) {
        verify(() => mockMetronome.setBeatsPerBar(3)).called(1);
      },
    );

    blocTest<MetronomeBloc, MetronomeState>(
      'MetronomeTapped calculates BPM correctly after 5 rapid taps',
      build: () {
        when(() => mockMetronome.setBpm(any())).thenReturn(null);
        return MetronomeBloc(metronome: mockMetronome);
      },
      act: (bloc) async {
        bloc.add(MetronomeTapped());
        await Future.delayed(const Duration(milliseconds: 200));
        bloc.add(MetronomeTapped());
        await Future.delayed(const Duration(milliseconds: 200));
        bloc.add(MetronomeTapped());
        await Future.delayed(const Duration(milliseconds: 200));
        bloc.add(MetronomeTapped());
        await Future.delayed(const Duration(milliseconds: 200));
        bloc.add(MetronomeTapped());
      },
      expect: () => [
        isA<MetronomeState>().having(
          (s) => s.bpm,
          'bpm',
          allOf(greaterThanOrEqualTo(250), lessThanOrEqualTo(350)),
        ),
      ],
      verify: (_) {
        verify(() => mockMetronome.setBpm(any())).called(1);
      },
      wait: const Duration(seconds: 2),
    );
  });
}

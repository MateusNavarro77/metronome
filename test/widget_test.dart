import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metronome/data/services/simulated_metronome_engine.dart';
import 'package:metronome/main.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets(
    'MetronomeApp renders initial 120 BPM in 4/4 and responds to controls',
    (WidgetTester tester) async {
      final simulatedEngine = SimulatedMetronomeEngine();

      await tester.pumpWidget(MetronomeApp(engineOverride: simulatedEngine));

      // Verify initial state (UI-01, UI-08): 120 BPM, ALLEGRO, 4/4, STOPPED
      expect(find.byKey(const Key('bpm_value_text')), findsOneWidget);
      expect(find.text('120'), findsOneWidget);
      expect(find.text('ALLEGRO'), findsOneWidget);
      expect(find.text('STOPPED'), findsOneWidget);
      expect(find.text('PLAY'), findsOneWidget);

      // Tap '+' button to increment BPM to 121 (FR-BPM-02)
      await tester.tap(find.byKey(const Key('bpm_increment_button')));
      await tester.pump();
      expect(find.text('121'), findsOneWidget);

      // Tap '-' button twice to decrement BPM to 119 -> MODERATO (FR-AND-02)
      await tester.tap(find.byKey(const Key('bpm_decrement_button')));
      await tester.tap(find.byKey(const Key('bpm_decrement_button')));
      await tester.pump();
      expect(find.text('119'), findsOneWidget);
      expect(find.text('MODERATO'), findsOneWidget);

      // Select 6/8 time signature (FR-CMP-01)
      await tester.tap(find.byKey(const Key('time_sig_6/8')));
      await tester.pump();
      // Beat indicator now shows 6 beat capsules (numbers 1..6)
      expect(find.text('6'), findsOneWidget);

      // Select Triplets subdivision (FR-SUB-01, FR-SUB-04)
      await tester.tap(find.byKey(const Key('subdivision_triplet')));
      await tester.pump();
      expect(find.textContaining('Triplets'), findsOneWidget);

      // Tap Play/Stop button to start playback (FR-PLY-01..03)
      await tester.tap(find.byKey(const Key('play_stop_button')));
      await tester.pump();
      check(simulatedEngine.isPlaying).isTrue();
      expect(find.text('PLAYING'), findsOneWidget);
      expect(find.text('STOP'), findsOneWidget);

      // Tap Play/Stop button again to stop playback (FR-PLY-04)
      await tester.tap(find.byKey(const Key('play_stop_button')));
      await tester.pump();
      check(simulatedEngine.isPlaying).isFalse();
      expect(find.text('STOPPED'), findsOneWidget);
    },
  );
}

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

      // Verify Accent toggle is present and toggles between ON and OFF
      expect(find.byKey(const Key('accent_toggle_button')), findsOneWidget);
      expect(find.text('ACCENT ON'), findsOneWidget);
      await tester.tap(find.byKey(const Key('accent_toggle_button')));
      await tester.pump();
      expect(find.text('ACCENT OFF'), findsOneWidget);
      await tester.tap(find.byKey(const Key('accent_toggle_button')));
      await tester.pump();
      expect(find.text('ACCENT ON'), findsOneWidget);

      // Tap '-' button twice to decrement BPM to 119 -> MODERATO (FR-AND-02)
      await tester.tap(find.byKey(const Key('bpm_decrement_button')));
      await tester.tap(find.byKey(const Key('bpm_decrement_button')));
      await tester.pump();
      expect(find.text('119'), findsOneWidget);
      expect(find.text('MODERATO'), findsOneWidget);

      // Select 6/8 time signature via the Time Signature bottom sheet (FR-CMP-01)
      expect(find.text('4/4'), findsOneWidget);
      await tester.tap(find.byKey(const Key('time_signature_selector_button')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('time_signature_bottom_sheet')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('time_sig_6/8')));
      await tester.pumpAndSettle();
      // Sheet auto-closes on preset tap and Beat indicator shows 6 beat capsules
      expect(
        find.byKey(const Key('time_signature_bottom_sheet')),
        findsNothing,
      );
      expect(find.text('6/8'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);

      // Test custom numerator & denominator inside Time Signature bottom sheet (FR-CMP-03)
      await tester.tap(find.byKey(const Key('time_signature_selector_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('custom_numerator_increment')));
      await tester.pump();
      // Sheet stays open while adjusting custom numerator/denominator (7/8)
      expect(
        find.byKey(const Key('time_signature_bottom_sheet')),
        findsOneWidget,
      );
      expect(find.text('7/8'), findsWidgets);
      await tester.tap(find.byKey(const Key('custom_denominator_4')));
      await tester.pump();
      expect(find.text('7/4'), findsWidgets);

      // Dismiss bottom sheet by tapping outside (barrier)
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('time_signature_bottom_sheet')),
        findsNothing,
      );
      expect(find.text('7/4'), findsOneWidget);

      // Select Triplets subdivision via Subdivision bottom sheet (FR-SUB-01, FR-SUB-04)
      await tester.tap(find.byKey(const Key('subdivision_selector_button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('subdivision_bottom_sheet')), findsOneWidget);
      await tester.tap(find.byKey(const Key('subdivision_triplet')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('subdivision_bottom_sheet')), findsNothing);
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

      // Open Preferences via settings button in header bar
      await tester.tap(find.byKey(const Key('settings_button')));
      await tester.pumpAndSettle();

      expect(find.text('PREFERENCES'), findsOneWidget);
      expect(find.text('APPEARANCE'), findsOneWidget);

      // Switch to Light theme
      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();

      // Return to Metronome view via navigation
      await tester.tap(find.text('Metronome'));
      await tester.pumpAndSettle();

      expect(find.text('METRONOME'), findsOneWidget);
    },
  );
}

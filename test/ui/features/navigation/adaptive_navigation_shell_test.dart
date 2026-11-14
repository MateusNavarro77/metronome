import 'package:checks/checks.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metronome/data/repositories/metronome_repository.dart';
import 'package:metronome/data/repositories/preferences_repository.dart';
import 'package:metronome/data/services/simulated_metronome_engine.dart';
import 'package:metronome/ui/core/theme/sonic_theme.dart';
import 'package:metronome/ui/features/metronome/view_models/metronome_view_model.dart';
import 'package:metronome/ui/features/navigation/views/adaptive_navigation_shell.dart';
import 'package:metronome/ui/features/preferences/view_models/preferences_view_model.dart';
import 'package:provider/provider.dart';

Widget _buildTestApp({
  required MetronomeViewModel metronomeViewModel,
  required PreferencesViewModel preferencesViewModel,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<MetronomeViewModel>.value(
        value: metronomeViewModel,
      ),
      ChangeNotifierProvider<PreferencesViewModel>.value(
        value: preferencesViewModel,
      ),
    ],
    child: MaterialApp(
      theme: SonicTheme.darkTheme,
      home: AdaptiveNavigationShell(metronomeViewModel: metronomeViewModel),
    ),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('AdaptiveNavigationShell', () {
    late SimulatedMetronomeEngine engine;
    late MetronomeRepository metronomeRepo;
    late MetronomeViewModel metronomeViewModel;
    late PreferencesRepository preferencesRepo;
    late PreferencesViewModel preferencesViewModel;

    setUp(() {
      engine = SimulatedMetronomeEngine();
      metronomeRepo = MetronomeRepository(engine: engine);
      metronomeViewModel = MetronomeViewModel(repository: metronomeRepo);
      preferencesRepo = PreferencesRepository();
      preferencesViewModel = PreferencesViewModel(repository: preferencesRepo);
    });

    tearDown(() {
      metronomeViewModel.dispose();
      metronomeRepo.dispose();
      engine.dispose();
      preferencesViewModel.dispose();
    });

    testWidgets(
      'renders NavigationBar in portrait mode (<= 600 width) with 4 destinations',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          _buildTestApp(
            metronomeViewModel: metronomeViewModel,
            preferencesViewModel: preferencesViewModel,
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('adaptive_navigation_bar')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('adaptive_navigation_rail')), findsNothing);

        // Verify initial screen is Metronome
        expect(find.text('METRONOME'), findsOneWidget);
        expect(find.text('120'), findsOneWidget);

        // Switch to Presets
        await tester.tap(find.byKey(const Key('nav_destination_presets')));
        await tester.pumpAndSettle();
        expect(find.text('PRESETS'), findsOneWidget);
        expect(find.text('Preset Library'), findsOneWidget);
        expect(find.text('One-Tap Recall (FR-PRE-02)'), findsOneWidget);

        // Switch to Setlists
        await tester.tap(find.byKey(const Key('nav_destination_setlists')));
        await tester.pumpAndSettle();
        expect(find.text('SETLISTS'), findsOneWidget);
        expect(find.text('Live Setlists'), findsOneWidget);
        expect(find.text('Bar-Synced Transitions (FR-PRE-09)'), findsOneWidget);

        // Switch to Settings
        await tester.tap(find.byKey(const Key('nav_destination_settings')));
        await tester.pumpAndSettle();
        expect(find.text('PREFERENCES'), findsOneWidget);
        expect(find.text('APPEARANCE'), findsOneWidget);

        // Switch back to Metronome
        await tester.tap(find.byKey(const Key('nav_destination_metronome')));
        await tester.pumpAndSettle();
        expect(find.text('METRONOME'), findsOneWidget);
      },
    );

    testWidgets('renders NavigationRail in landscape orientation', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(844, 390);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _buildTestApp(
          metronomeViewModel: metronomeViewModel,
          preferencesViewModel: preferencesViewModel,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('adaptive_navigation_rail')), findsOneWidget);
      expect(find.byKey(const Key('adaptive_navigation_bar')), findsNothing);

      // Navigate to Presets via rail
      await tester.tap(find.byKey(const Key('rail_destination_presets')));
      await tester.pumpAndSettle();
      expect(find.text('PRESETS'), findsOneWidget);

      // Navigate to Setlists via rail
      await tester.tap(find.byKey(const Key('rail_destination_setlists')));
      await tester.pumpAndSettle();
      expect(find.text('SETLISTS'), findsOneWidget);
    });

    testWidgets(
      'renders NavigationRail in wide screen portrait (width > 600)',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 1024);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          _buildTestApp(
            metronomeViewModel: metronomeViewModel,
            preferencesViewModel: preferencesViewModel,
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('adaptive_navigation_rail')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('adaptive_navigation_bar')), findsNothing);
      },
    );

    testWidgets('playback persists uninterrupted while switching tabs', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _buildTestApp(
          metronomeViewModel: metronomeViewModel,
          preferencesViewModel: preferencesViewModel,
        ),
      );
      await tester.pumpAndSettle();

      // Start playing
      await tester.tap(find.byKey(const Key('play_stop_button')));
      await tester.pump();
      check(engine.isPlaying).isTrue();

      // Switch to Presets
      await tester.tap(find.byKey(const Key('nav_destination_presets')));
      await tester.pumpAndSettle();

      // Engine is still playing!
      check(engine.isPlaying).isTrue();

      // Switch to Setlists
      await tester.tap(find.byKey(const Key('nav_destination_setlists')));
      await tester.pumpAndSettle();
      check(engine.isPlaying).isTrue();

      // Return to Metronome
      await tester.tap(find.byKey(const Key('nav_destination_metronome')));
      await tester.pumpAndSettle();

      check(engine.isPlaying).isTrue();
    });
  });
}

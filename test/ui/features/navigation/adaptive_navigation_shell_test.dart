import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart'
    hide CornerRounding, RoundedPolygon;
import 'package:metronome/data/repositories/metronome_repository.dart';
import 'package:metronome/data/repositories/preferences_repository.dart';
import 'package:metronome/data/repositories/preset_library_repository.dart';
import 'package:metronome/data/services/simulated_metronome_engine.dart';
import 'package:metronome/l10n/app_localizations.dart';
import 'package:metronome/ui/core/l10n/l10n_extensions.dart';
import 'package:metronome/ui/core/theme/app_theme.dart';
import 'package:metronome/ui/features/metronome/view_models/metronome_view_model.dart';
import 'package:metronome/ui/features/navigation/views/adaptive_navigation_shell.dart';
import 'package:metronome/ui/features/preferences/view_models/preferences_view_model.dart';
import 'package:metronome/ui/features/preferences/views/preferences_view.dart';
import 'package:metronome/ui/features/presets/view_models/presets_view_model.dart';
import 'package:metronome/ui/features/setlists/view_models/setlists_view_model.dart';
import 'package:provider/provider.dart';

class _ShellTestHarness {
  _ShellTestHarness._({
    required this.engine,
    required this.metronomeRepo,
    required this.libraryRepo,
    required this.metronomeViewModel,
    required this.preferencesRepo,
    required this.preferencesViewModel,
    required this.presetsViewModel,
    required this.setlistsViewModel,
  });

  factory _ShellTestHarness.create() {
    final engine = SimulatedMetronomeEngine();
    final metronomeRepo = MetronomeRepository(engine: engine);
    final libraryRepo = PresetLibraryRepository();
    final metronomeViewModel = MetronomeViewModel(
      repository: metronomeRepo,
      presetLibraryRepository: libraryRepo,
    );
    final preferencesRepo = PreferencesRepository();
    final preferencesViewModel = PreferencesViewModel(
      repository: preferencesRepo,
    );
    final presetsViewModel = PresetsViewModel(
      repository: libraryRepo,
      metronomeViewModel: metronomeViewModel,
    );
    final setlistsViewModel = SetlistsViewModel(
      repository: libraryRepo,
      metronomeViewModel: metronomeViewModel,
    );
    return _ShellTestHarness._(
      engine: engine,
      metronomeRepo: metronomeRepo,
      libraryRepo: libraryRepo,
      metronomeViewModel: metronomeViewModel,
      preferencesRepo: preferencesRepo,
      preferencesViewModel: preferencesViewModel,
      presetsViewModel: presetsViewModel,
      setlistsViewModel: setlistsViewModel,
    );
  }

  final SimulatedMetronomeEngine engine;
  final MetronomeRepository metronomeRepo;
  final PresetLibraryRepository libraryRepo;
  final MetronomeViewModel metronomeViewModel;
  final PreferencesRepository preferencesRepo;
  final PreferencesViewModel preferencesViewModel;
  final PresetsViewModel presetsViewModel;
  final SetlistsViewModel setlistsViewModel;

  Widget buildApp() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MetronomeViewModel>.value(
          value: metronomeViewModel,
        ),
        ChangeNotifierProvider<PreferencesViewModel>.value(
          value: preferencesViewModel,
        ),
        ChangeNotifierProvider<PresetsViewModel>.value(value: presetsViewModel),
        ChangeNotifierProvider<SetlistsViewModel>.value(
          value: setlistsViewModel,
        ),
      ],
      child: M3ETheme(
        data: AppTheme.darkThemeData,
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AdaptiveNavigationShell(metronomeViewModel: metronomeViewModel),
        ),
      ),
    );
  }

  Future<void> dispose() async {
    setlistsViewModel.dispose();
    presetsViewModel.dispose();
    metronomeViewModel.dispose();
    await libraryRepo.dispose();
    await metronomeRepo.dispose();
    await engine.dispose();
    preferencesViewModel.dispose();
  }
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('AdaptiveNavigationShell', () {
    testWidgets(
      'renders floating M3EToolbar with Play/Stop FAB in portrait mode (<= 600 width) and switches 4 destinations',
      (WidgetTester tester) async {
        final harness = _ShellTestHarness.create();
        addTearDown(harness.dispose);

        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(harness.buildApp());
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('adaptive_navigation_toolbar')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('toolbar_play_stop_fab')), findsOneWidget);
        expect(find.byKey(const Key('adaptive_navigation_rail')), findsNothing);

        // Verify initial screen is Metronome
        expect(find.text('Metronome'), findsWidgets);
        expect(find.text('120'), findsOneWidget);

        // Switch to Presets
        await tester.tap(find.bySemanticsLabel('Presets'));
        await tester.pumpAndSettle();
        expect(find.text('Presets'), findsWidgets);
        expect(find.text('No presets saved yet'), findsOneWidget);

        // Switch to Setlists
        await tester.tap(find.bySemanticsLabel('Setlists'));
        await tester.pumpAndSettle();
        expect(find.text('Setlists'), findsWidgets);
        expect(find.text('No setlists yet'), findsOneWidget);

        // Switch to Settings
        await tester.tap(find.bySemanticsLabel('Settings'));
        await tester.pumpAndSettle();
        expect(find.text('Preferences'), findsOneWidget);
        expect(find.text('Appearance'), findsOneWidget);

        // Switch back to Metronome
        await tester.tap(find.bySemanticsLabel('Metronome'));
        await tester.pumpAndSettle();
        expect(find.text('Metronome'), findsWidgets);

        await tester.runAsync(() => GoogleFonts.pendingFonts());
        await tester.pump();
      },
    );

    testWidgets(
      'mobile floating toolbar fits 360dp width without overflow across destinations',
      (WidgetTester tester) async {
        final harness = _ShellTestHarness.create();
        addTearDown(harness.dispose);

        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(harness.buildApp());
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('adaptive_navigation_toolbar')),
          findsOneWidget,
        );
        await tester.tap(find.bySemanticsLabel('Setlists'));
        await tester.pumpAndSettle();
        expect(find.text('Setlists'), findsWidgets);
      },
    );

    testWidgets(
      'mobile toolbar Play/Stop FAB toggles playback from any screen and updates icon and color',
      (WidgetTester tester) async {
        final harness = _ShellTestHarness.create();
        addTearDown(harness.dispose);

        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(harness.buildApp());
        await tester.pumpAndSettle();

        // Stopped initially
        check(harness.engine.isPlaying).isFalse();
        expect(
          tester
              .widget<M3EFab>(find.byKey(const Key('toolbar_play_stop_fab')))
              .color,
          M3EFabColor.primary,
        );
        expect(
          tester
              .widget<Icon>(find.byKey(const Key('toolbar_play_stop_fab_icon')))
              .icon,
          Icons.play_arrow_rounded,
        );

        // Navigate to Presets tab and start playback via toolbar FAB
        await tester.tap(find.bySemanticsLabel('Presets'));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('toolbar_play_stop_fab')));
        await tester.pumpAndSettle();
        check(harness.engine.isPlaying).isTrue();
        expect(
          tester
              .widget<M3EFab>(find.byKey(const Key('toolbar_play_stop_fab')))
              .color,
          M3EFabColor.tertiary,
        );
        expect(
          tester
              .widget<Icon>(find.byKey(const Key('toolbar_play_stop_fab_icon')))
              .icon,
          Icons.stop_rounded,
        );

        // Navigate to Settings tab and stop playback via toolbar FAB
        await tester.tap(find.bySemanticsLabel('Settings'));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('toolbar_play_stop_fab')));
        await tester.pumpAndSettle();
        check(harness.engine.isPlaying).isFalse();
        expect(
          tester
              .widget<M3EFab>(find.byKey(const Key('toolbar_play_stop_fab')))
              .color,
          M3EFabColor.primary,
        );
        expect(
          tester
              .widget<Icon>(find.byKey(const Key('toolbar_play_stop_fab_icon')))
              .icon,
          Icons.play_arrow_rounded,
        );
      },
    );

    testWidgets(
      'renders NavigationRail with Play/Stop FAB in landscape orientation',
      (WidgetTester tester) async {
        final harness = _ShellTestHarness.create();
        addTearDown(harness.dispose);

        tester.view.physicalSize = const Size(844, 390);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(harness.buildApp());
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('adaptive_navigation_rail')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('adaptive_navigation_toolbar')),
          findsNothing,
        );
        expect(
          find.byKey(const Key('rail_play_stop_fab_icon')),
          findsOneWidget,
        );

        // Navigate to Presets via rail
        await tester.tap(find.byKey(const Key('rail_destination_presets')));
        await tester.pumpAndSettle();
        expect(find.text('Presets'), findsWidgets);

        // Toggle play via rail FAB while on Presets
        await tester.tap(find.byKey(const Key('rail_play_stop_fab_icon')));
        await tester.pumpAndSettle();
        check(harness.engine.isPlaying).isTrue();
        expect(
          tester
              .widget<Icon>(find.byKey(const Key('rail_play_stop_fab_icon')))
              .icon,
          Icons.stop_rounded,
        );

        // Navigate to Setlists via rail and stop via rail FAB
        await tester.tap(find.byKey(const Key('rail_destination_setlists')));
        await tester.pumpAndSettle();
        expect(find.text('Setlists'), findsWidgets);

        await tester.tap(find.byKey(const Key('rail_play_stop_fab_icon')));
        await tester.pumpAndSettle();
        check(harness.engine.isPlaying).isFalse();
        expect(
          tester
              .widget<Icon>(find.byKey(const Key('rail_play_stop_fab_icon')))
              .icon,
          Icons.play_arrow_rounded,
        );
      },
    );

    testWidgets(
      'renders NavigationRail with Play/Stop FAB in wide screen portrait (width > 600)',
      (WidgetTester tester) async {
        final harness = _ShellTestHarness.create();
        addTearDown(harness.dispose);

        tester.view.physicalSize = const Size(800, 1024);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(harness.buildApp());
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('adaptive_navigation_rail')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('adaptive_navigation_toolbar')),
          findsNothing,
        );
        expect(
          find.byKey(const Key('rail_play_stop_fab_icon')),
          findsOneWidget,
        );
      },
    );

    testWidgets('playback persists uninterrupted while switching tabs', (
      WidgetTester tester,
    ) async {
      final harness = _ShellTestHarness.create();
      addTearDown(harness.dispose);

      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      // Start playing
      await tester.tap(find.byKey(const Key('play_stop_button')));
      await tester.pump();
      check(harness.engine.isPlaying).isTrue();

      // Switch to Presets
      await tester.tap(find.bySemanticsLabel('Presets'));
      await tester.pumpAndSettle();

      // Engine is still playing!
      check(harness.engine.isPlaying).isTrue();

      // Switch to Setlists
      await tester.tap(find.bySemanticsLabel('Setlists'));
      await tester.pumpAndSettle();
      check(harness.engine.isPlaying).isTrue();

      // Return to Metronome
      await tester.tap(find.bySemanticsLabel('Metronome'));
      await tester.pumpAndSettle();

      check(harness.engine.isPlaying).isTrue();
    });

    testWidgets(
      'floating toolbar extends over scrollable content without clipping and keeps last item reachable',
      (WidgetTester tester) async {
        final harness = _ShellTestHarness.create();
        addTearDown(harness.dispose);

        tester.view.physicalSize = const Size(390, 700);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(harness.buildApp());
        await tester.pumpAndSettle();

        // Outer shell Scaffold extends body behind the floating toolbar
        final shellScaffold = tester.widget<Scaffold>(
          find
              .descendant(
                of: find.byType(AdaptiveNavigationShell),
                matching: find.byType(Scaffold),
              )
              .first,
        );
        check(shellScaffold.extendBody).isTrue();

        // Switch to Settings (scrollable PreferencesView)
        await tester.tap(find.bySemanticsLabel('Settings'));
        await tester.pumpAndSettle();

        final scrollViewFinder = find.descendant(
          of: find.byType(PreferencesView),
          matching: find.byType(SingleChildScrollView),
        );
        final scrollViewRect = tester.getRect(scrollViewFinder);
        final toolbarRect = tester.getRect(
          find.byKey(const Key('adaptive_navigation_toolbar')),
        );

        // Scrollable viewport extends behind the floating toolbar to screen bottom
        check(scrollViewRect.bottom).equals(700.0);
        check(scrollViewRect.bottom > toolbarRect.top).isTrue();

        // Scrolling to the end clears the last card above the floating toolbar
        final scrollable = tester.state<ScrollableState>(
          find.descendant(
            of: scrollViewFinder,
            matching: find.byType(Scrollable),
          ),
        );
        scrollable.position.jumpTo(scrollable.position.maxScrollExtent);
        await tester.pumpAndSettle();

        final lastCardRect = tester.getRect(
          find.byKey(const Key('background_playback_section_card')),
        );
        check(lastCardRect.bottom <= toolbarRect.top).isTrue();
      },
    );
  });
}

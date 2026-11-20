import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:metronome/data/repositories/metronome_repository.dart';
import 'package:metronome/data/repositories/preferences_repository.dart';
import 'package:metronome/data/services/simulated_metronome_engine.dart';
import 'package:metronome/domain/models/app_theme_mode.dart';
import 'package:metronome/domain/models/metronome_sound.dart';
import 'package:metronome/ui/core/theme/app_theme.dart';
import 'package:metronome/ui/features/preferences/view_models/preferences_view_model.dart';
import 'package:metronome/ui/features/preferences/views/preferences_view.dart';
import 'package:provider/provider.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('PreferencesView', () {
    testWidgets(
      'renders section titles outside cards and updates appearance & sounds',
      (WidgetTester tester) async {
        final repo = PreferencesRepository(preferences: null);
        final engine = SimulatedMetronomeEngine();
        final metronomeRepo = MetronomeRepository(engine: engine);
        final viewModel = PreferencesViewModel(
          repository: repo,
          metronomeRepository: metronomeRepo,
        );

        await tester.pumpWidget(
          ChangeNotifierProvider<PreferencesViewModel>.value(
            value: viewModel,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              home: const PreferencesView(),
            ),
          ),
        );

        // Screen header & section headers outside their respective cards
        expect(find.text('PREFERENCES'), findsOneWidget);
        expect(find.text('APPEARANCE'), findsOneWidget);
        expect(find.text('SOUNDS & VOLUMES'), findsOneWidget);

        expect(
          find.descendant(
            of: find.byKey(const Key('appearance_section_card')),
            matching: find.text('APPEARANCE'),
          ),
          findsNothing,
        );
        expect(
          find.descendant(
            of: find.byKey(const Key('appearance_section_card')),
            matching: find.byIcon(Icons.palette_outlined),
          ),
          findsNothing,
        );
        expect(
          find.descendant(
            of: find.byKey(const Key('sounds_section_card')),
            matching: find.text('SOUNDS & VOLUMES'),
          ),
          findsNothing,
        );
        expect(
          find.descendant(
            of: find.byKey(const Key('sounds_section_card')),
            matching: find.byIcon(Icons.equalizer_rounded),
          ),
          findsNothing,
        );
        expect(
          find.descendant(
            of: find.byKey(const Key('sounds_section_header')),
            matching: find.byIcon(Icons.equalizer_rounded),
          ),
          findsOneWidget,
        );

        // Switch theme mode
        expect(
          find.byKey(const Key('theme_mode_segmented_button')),
          findsOneWidget,
        );
        await tester.tap(find.text('Light'));
        await tester.pumpAndSettle();
        check(viewModel.themeMode).equals(AppThemeMode.light);

        await tester.tap(find.text('Dark'));
        await tester.pumpAndSettle();
        check(viewModel.themeMode).equals(AppThemeMode.dark);

        // Verify all 4 timbres are shown inside Sounds section and tapping triggers preview
        for (final sound in MetronomeSound.values) {
          expect(find.byKey(Key('sound_option_${sound.id}')), findsOneWidget);
          expect(find.text(sound.label), findsOneWidget);
        }

        final woodBlockFinder = find.byKey(
          const Key('sound_option_wood_block'),
        );
        await tester.ensureVisible(woodBlockFinder);
        await tester.tap(woodBlockFinder);
        await tester.pumpAndSettle();

        check(viewModel.selectedSound).equals(MetronomeSound.woodBlock);
        check(engine.previewedSounds).length.equals(1);
        check(engine.previewedSounds.first.sound)
            .equals(MetronomeSound.woodBlock);

        // Verify volume sliders & labels
        expect(
          find.byKey(const Key('sound_strong_volume_slider')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('sound_weak_volume_slider')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('sound_subdivision_volume_slider')),
          findsOneWidget,
        );
        expect(find.text('100%'), findsOneWidget);
        expect(find.text('65%'), findsOneWidget);
        expect(find.text('35%'), findsOneWidget);

        // Drag strong beat slider toward minimum
        final strongSlider = find.byKey(
          const Key('sound_strong_volume_slider'),
        );
        await tester.ensureVisible(strongSlider);
        await tester.drag(strongSlider, const Offset(-300, 0));
        await tester.pumpAndSettle();
        check(viewModel.strongVolume).isLessThan(100);

        final savedStrongBeforeMute = viewModel.strongVolume;

        // Toggle mute switch on and verify saved volume value is preserved
        final muteSwitch = find.byKey(const Key('sound_mute_switch'));
        await tester.ensureVisible(muteSwitch);
        await tester.tap(muteSwitch);
        await tester.pumpAndSettle();
        check(viewModel.isMuted).isTrue();
        check(viewModel.strongVolume).equals(savedStrongBeforeMute);

        await tester.runAsync(() => GoogleFonts.pendingFonts());
        await tester.pump();
      },
    );

    testWidgets(
      'scrolls cleanly on compact landscape viewport without overflow',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 360);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final repo = PreferencesRepository(preferences: null);
        final viewModel = PreferencesViewModel(repository: repo);

        await tester.pumpWidget(
          ChangeNotifierProvider<PreferencesViewModel>.value(
            value: viewModel,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const PreferencesView(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        await tester.ensureVisible(
          find.byKey(const Key('sound_subdivision_volume_slider')),
        );
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('sound_subdivision_volume_slider')),
          findsOneWidget,
        );
      },
    );

    testWidgets('back button pops the screen', (WidgetTester tester) async {
      final repo = PreferencesRepository(preferences: null);
      final viewModel = PreferencesViewModel(repository: repo);

      await tester.pumpWidget(
        ChangeNotifierProvider<PreferencesViewModel>.value(
          value: viewModel,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const PreferencesView(),
                      ),
                    );
                  },
                  child: const Text('Open Settings'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Settings'));
      await tester.pumpAndSettle();

      expect(find.text('PREFERENCES'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byKey(const Key('preferences_back_button')));
      await tester.pumpAndSettle();

      expect(find.text('PREFERENCES'), findsNothing);
      expect(find.text('Open Settings'), findsOneWidget);
    });
  });
}

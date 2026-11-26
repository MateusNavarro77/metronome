import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart'
    hide CornerRounding, RoundedPolygon;
import 'package:metronome/data/repositories/metronome_repository.dart';
import 'package:metronome/data/repositories/preset_library_repository.dart';
import 'package:metronome/data/services/simulated_metronome_engine.dart';
import 'package:metronome/domain/models/bpm.dart';
import 'package:metronome/domain/models/subdivision.dart';
import 'package:metronome/domain/models/time_signature.dart';
import 'package:metronome/l10n/app_localizations.dart';
import 'package:metronome/ui/core/l10n/l10n_extensions.dart';
import 'package:metronome/ui/core/theme/app_theme.dart';
import 'package:metronome/ui/core/widgets/app_snackbar.dart';
import 'package:metronome/ui/features/metronome/view_models/metronome_view_model.dart';
import 'package:metronome/ui/features/presets/view_models/presets_view_model.dart';
import 'package:metronome/ui/features/presets/views/presets_view.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('PresetsView widget tests (FR-PRE-01..05, FR-PRE-10..11)', () {
    late SimulatedMetronomeEngine engine;
    late MetronomeRepository metronomeRepo;
    late PresetLibraryRepository libraryRepo;
    late MetronomeViewModel metronomeVm;
    late PresetsViewModel presetsVm;

    setUp(() {
      engine = SimulatedMetronomeEngine();
      metronomeRepo = MetronomeRepository(engine: engine);
      libraryRepo = PresetLibraryRepository();
      metronomeVm = MetronomeViewModel(
        repository: metronomeRepo,
        presetLibraryRepository: libraryRepo,
      );
      presetsVm = PresetsViewModel(
        repository: libraryRepo,
        metronomeViewModel: metronomeVm,
      );
    });

    tearDown(() async {
      dismissAppSnackbar(immediate: true);
      presetsVm.dispose();
      metronomeVm.dispose();
      await libraryRepo.dispose();
      await metronomeRepo.dispose();
    });

    Widget buildTestApp({Locale? locale, VoidCallback? onNavigateToMetronome}) {
      return M3ETheme(
        data: AppTheme.darkThemeData,
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          locale: locale,
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PresetsView(
            viewModel: presetsVm,
            onNavigateToMetronome: onNavigateToMetronome,
          ),
        ),
      );
    }

    testWidgets(
      'creates a preset via editor sheet with validation, note, and favorite toggle',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        expect(find.text('No presets saved yet'), findsOneWidget);

        await tester.tap(find.byKey(const Key('create_preset_button')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('preset_editor_sheet')), findsOneWidget);

        // Saving with blank name shows validation error (UI-07)
        await tester.ensureVisible(
          find.byKey(const Key('preset_editor_save_button')),
        );
        await tester.tap(find.byKey(const Key('preset_editor_save_button')));
        await tester.pumpAndSettle();
        expect(find.text('Enter a preset name to save.'), findsOneWidget);

        // Fill name, note, favorite, BPM, time signature, subdivision
        await tester.ensureVisible(find.byKey(const Key('preset_name_input')));
        await tester.enterText(
          find.byKey(const Key('preset_name_input')),
          'Stage Opener',
        );
        await tester.ensureVisible(find.byKey(const Key('preset_note_input')));
        await tester.enterText(
          find.byKey(const Key('preset_note_input')),
          '4 bar count-in',
        );
        await tester.ensureVisible(
          find.byKey(const Key('preset_editor_favorite_toggle')),
        );
        await tester.tap(
          find.byKey(const Key('preset_editor_favorite_toggle')),
        );
        await tester.ensureVisible(
          find.byKey(const Key('preset_editor_bpm_increment')),
        );
        await tester.tap(find.byKey(const Key('preset_editor_bpm_increment')));
        await tester.ensureVisible(
          find.byKey(const Key('preset_editor_time_sig_6/8')),
        );
        await tester.tap(find.byKey(const Key('preset_editor_time_sig_6/8')));
        await tester.ensureVisible(
          find.byKey(const Key('preset_editor_subdivision_triplet')),
        );
        await tester.tap(
          find.byKey(const Key('preset_editor_subdivision_triplet')),
        );

        await tester.ensureVisible(
          find.byKey(const Key('preset_editor_save_button')),
        );
        await tester.tap(find.byKey(const Key('preset_editor_save_button')));
        await tester.pumpAndSettle();

        check(libraryRepo.presets).length.equals(1);
        final created = libraryRepo.presets.first;
        check(created.name).equals('Stage Opener');
        check(created.note).equals('4 bar count-in');
        check(created.isFavorite).isTrue();
        check(created.bpm).equals(const Bpm(121));
        check(created.timeSignature).equals(TimeSignature.sixEight);
        check(created.subdivision).equals(Subdivision.triplet);

        expect(find.text('Stage Opener'), findsOneWidget);
        expect(find.text('4 bar count-in'), findsOneWidget);

        await tester.runAsync(() => GoogleFonts.pendingFonts());
        await tester.pump();
      },
    );

    testWidgets(
      'loads preset with snackbar shortcut, filters by search and favorites chip, and supports overflow menu edit, duplicate, add-to-setlist, and immediate delete with lossless undo',
      (WidgetTester tester) async {
        final alpha = await libraryRepo.createPreset(
          name: 'Alpha Rock',
          bpm: const Bpm(132),
          timeSignature: TimeSignature.fourFour,
          subdivision: Subdivision.eighth,
          isAccentEnabled: true,
        );
        final beta = await libraryRepo.createPreset(
          name: 'Beta Jazz',
          bpm: const Bpm(168),
          timeSignature: TimeSignature.threeFour,
          subdivision: Subdivision.triplet,
          isAccentEnabled: false,
          note: 'Swing feel',
        );
        final setlist = await libraryRepo.createSetlist(
          name: 'Friday Set',
          presetIds: [alpha.id, beta.id],
        );

        var navigatedToMetronome = false;
        await tester.pumpWidget(
          buildTestApp(
            onNavigateToMetronome: () => navigatedToMetronome = true,
          ),
        );
        await tester.pumpAndSettle();

        // Inactive preset cards use elevated variant
        check(
          tester
              .widget<M3ECard>(find.byKey(Key('preset_card_${alpha.id}')))
              .variant,
        ).equals(M3ECardVariant.elevated);
        check(
          tester
              .widget<M3ECard>(find.byKey(Key('preset_card_${beta.id}')))
              .variant,
        ).equals(M3ECardVariant.elevated);

        // One-tap load Beta Jazz (FR-PRE-02) + snackbar shortcut to Metronome
        await tester.tap(find.byKey(Key('preset_card_${beta.id}')));
        await tester.pumpAndSettle();
        check(metronomeVm.bpmValue).equals(168);
        check(metronomeVm.timeSignature).equals(TimeSignature.threeFour);
        check(metronomeVm.subdivision).equals(Subdivision.triplet);
        check(metronomeVm.isAccentEnabled).isFalse();
        expect(
          find.byKey(Key('preset_active_badge_${beta.id}')),
          findsOneWidget,
        );
        expect(find.text('Active'), findsOneWidget);
        expect(find.text('Loaded "Beta Jazz"'), findsOneWidget);
        await tester.tap(find.text('Metronome'));
        await tester.pumpAndSettle();
        check(navigatedToMetronome).isTrue();
        check(
          tester
              .widget<M3ECard>(find.byKey(Key('preset_card_${beta.id}')))
              .variant,
        ).equals(M3ECardVariant.filled);

        // Favorites filter chip when 0 favorites shows empty-favorites card
        await tester.tap(
          find.byKey(const Key('presets_filter_favorites_chip')),
        );
        await tester.pumpAndSettle();
        expect(find.text('No favorite presets yet'), findsOneWidget);
        await tester.tap(find.byKey(const Key('presets_filter_all_chip')));
        await tester.pumpAndSettle();

        // Favorite Beta Jazz -> moves before Alpha Rock (FR-PRE-04)
        await tester.tap(find.byKey(Key('preset_favorite_button_${beta.id}')));
        await tester.pumpAndSettle();
        final betaTop = tester.getTopLeft(
          find.byKey(Key('preset_card_${beta.id}')),
        );
        final alphaTop = tester.getTopLeft(
          find.byKey(Key('preset_card_${alpha.id}')),
        );
        check(betaTop.dy < alphaTop.dy).isTrue();

        // Favorites filter chip now shows only Beta Jazz
        await tester.tap(
          find.byKey(const Key('presets_filter_favorites_chip')),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(Key('preset_card_${beta.id}')), findsOneWidget);
        expect(find.byKey(Key('preset_card_${alpha.id}')), findsNothing);
        await tester.tap(find.byKey(const Key('presets_filter_all_chip')));
        await tester.pumpAndSettle();

        // Search by name (FR-PRE-05)
        await tester.enterText(
          find.byKey(const Key('presets_search_field')),
          'rock',
        );
        await tester.pumpAndSettle();
        expect(find.byKey(Key('preset_card_${alpha.id}')), findsOneWidget);
        expect(find.byKey(Key('preset_card_${beta.id}')), findsNothing);

        await tester.tap(find.byKey(const Key('presets_search_clear_button')));
        await tester.pumpAndSettle();
        expect(find.byKey(Key('preset_card_${beta.id}')), findsOneWidget);

        // Overflow menu: Duplicate Alpha Rock + Undo
        await tester.tap(find.byKey(Key('preset_menu_button_${alpha.id}')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Duplicate'));
        await tester.pumpAndSettle();
        expect(find.text('Alpha Rock (Copy)'), findsOneWidget);
        expect(find.text('Duplicated "Alpha Rock (Copy)"'), findsOneWidget);
        await tester.tap(find.text('Undo'));
        await tester.pumpAndSettle();
        expect(find.text('Alpha Rock (Copy)'), findsNothing);

        // Overflow menu: Add Alpha Rock to Friday Set + Undo
        await tester.tap(find.byKey(Key('preset_menu_button_${alpha.id}')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Add to setlist'));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('select_setlist_for_preset_sheet')),
          findsOneWidget,
        );
        await tester.tap(find.byKey(Key('pick_setlist_option_${setlist.id}')));
        await tester.pumpAndSettle();
        check(libraryRepo.getSetlistById(setlist.id)?.presetIds)
            .isNotNull()
            .deepEquals([alpha.id, beta.id, alpha.id]);
        await tester.tap(find.text('Undo'));
        await tester.pumpAndSettle();
        check(libraryRepo.getSetlistById(setlist.id)?.presetIds)
            .isNotNull()
            .deepEquals([alpha.id, beta.id]);

        // Overflow menu: Edit Alpha Rock
        await tester.tap(find.byKey(Key('preset_menu_button_${alpha.id}')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Edit'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('preset_name_input')),
          'Alpha Anthem',
        );
        await tester.ensureVisible(
          find.byKey(const Key('preset_editor_save_button')),
        );
        await tester.tap(find.byKey(const Key('preset_editor_save_button')));
        await tester.pumpAndSettle();
        expect(find.text('Alpha Anthem'), findsOneWidget);

        // Overflow menu: Immediate delete with setlist warning in snackbar + lossless Undo
        await tester.tap(find.byKey(Key('preset_menu_button_${alpha.id}')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        check(libraryRepo.getPresetById(alpha.id)).isNull();
        check(libraryRepo.getSetlistById(setlist.id)?.presetIds)
            .isNotNull()
            .deepEquals([beta.id]);
        expect(
          find.text('Deleted "Alpha Anthem" (removed from 1 setlist)'),
          findsOneWidget,
        );

        // Tap Undo -> restores preset AND its exact index in Friday Set
        await tester.tap(find.text('Undo'));
        await tester.pumpAndSettle();
        check(libraryRepo.getPresetById(alpha.id)).isNotNull();
        check(libraryRepo.getSetlistById(setlist.id)?.presetIds)
            .isNotNull()
            .deepEquals([alpha.id, beta.id]);
      },
    );

    testWidgets(
      'supports Gmail-style swipe right to favorite, swipe left to delete with undo, and long-press action sheet',
      (WidgetTester tester) async {
        final groove = await libraryRepo.createPreset(
          name: 'Pocket Groove',
          bpm: const Bpm(108),
          timeSignature: TimeSignature.fourFour,
          subdivision: Subdivision.eighth,
          isAccentEnabled: true,
        );

        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // Swipe right -> toggles favorite and springs back
        check(libraryRepo.getPresetById(groove.id)?.isFavorite).equals(false);
        await tester.drag(
          find.byKey(Key('preset_card_${groove.id}')),
          const Offset(320, 0),
        );
        await tester.pumpAndSettle();
        check(libraryRepo.getPresetById(groove.id)?.isFavorite).equals(true);
        expect(find.byKey(Key('preset_card_${groove.id}')), findsOneWidget);

        // Long-press opens thumb-zone action sheet
        await tester.longPress(find.byKey(Key('preset_card_${groove.id}')));
        await tester.pumpAndSettle();
        expect(
          find.byKey(Key('preset_action_sheet_${groove.id}')),
          findsOneWidget,
        );
        await tester.tap(find.byKey(Key('preset_sheet_favorite_${groove.id}')));
        await tester.pumpAndSettle();
        check(libraryRepo.getPresetById(groove.id)?.isFavorite).equals(false);

        // Swipe left -> deletes immediately with Undo snackbar
        await tester.drag(
          find.byKey(Key('preset_card_${groove.id}')),
          const Offset(-360, 0),
        );
        await tester.pumpAndSettle();
        check(libraryRepo.getPresetById(groove.id)).isNull();
        expect(find.text('Deleted "Pocket Groove"'), findsOneWidget);

        // Tap Undo -> restores card
        await tester.tap(find.text('Undo'));
        await tester.pumpAndSettle();
        check(libraryRepo.getPresetById(groove.id)).isNotNull();
        expect(find.byKey(Key('preset_card_${groove.id}')), findsOneWidget);
      },
    );

    test('PresetsViewModel ignores beat tick updates and notifies on active preset changes while tracking playback via isPlayingListenable', () async {
      final presetOne = await libraryRepo.createPreset(
        name: 'Stage Opener',
        bpm: const Bpm(128),
        timeSignature: TimeSignature.fourFour,
        subdivision: Subdivision.none,
        isAccentEnabled: true,
      );
      final presetTwo = await libraryRepo.createPreset(
        name: 'Encore',
        bpm: const Bpm(140),
        timeSignature: TimeSignature.fourFour,
        subdivision: Subdivision.none,
        isAccentEnabled: true,
      );
      await Future<void>.delayed(Duration.zero);

      var notifications = 0;
      presetsVm.addListener(() => notifications++);

      check(presetsVm.isPlayingListenable.value).isFalse();
      metronomeVm.togglePlayStop();
      await Future<void>.delayed(Duration.zero);
      check(notifications).equals(0);
      check(presetsVm.isPlayingListenable.value).isTrue();

      engine.advancePulses(3);
      await Future<void>.delayed(Duration.zero);
      check(notifications).equals(0);

      presetsVm.loadPreset(presetOne);
      await Future<void>.delayed(Duration.zero);
      check(notifications).equals(1);

      presetsVm.loadPreset(presetTwo);
      await Future<void>.delayed(Duration.zero);
      check(notifications).equals(2);
    });

    testWidgets(
      'displays localized untitled fallback and duplicates with Portuguese suffix via menu',
      (WidgetTester tester) async {
        final untitled = await libraryRepo.createPreset(
          name: '',
          bpm: const Bpm(120),
          timeSignature: TimeSignature.fourFour,
          subdivision: Subdivision.none,
          isAccentEnabled: true,
        );
        final rock = await libraryRepo.createPreset(
          name: 'Alpha Rock',
          bpm: const Bpm(128),
          timeSignature: TimeSignature.fourFour,
          subdivision: Subdivision.eighth,
          isAccentEnabled: true,
        );

        await tester.pumpWidget(buildTestApp(locale: const Locale('pt')));
        await tester.pumpAndSettle();

        expect(find.text('Preset sem título'), findsOneWidget);
        expect(find.text('♫ Colcheias'), findsOneWidget);

        await tester.tap(find.byKey(Key('preset_menu_button_${rock.id}')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Duplicar'));
        await tester.pumpAndSettle();

        expect(find.text('Alpha Rock (Cópia)'), findsOneWidget);
        expect(libraryRepo.getPresetById(untitled.id)?.name, '');
      },
    );
  });
}

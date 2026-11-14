import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:metronome/data/repositories/metronome_repository.dart';
import 'package:metronome/data/repositories/preset_library_repository.dart';
import 'package:metronome/data/services/simulated_metronome_engine.dart';
import 'package:metronome/domain/models/bpm.dart';
import 'package:metronome/domain/models/subdivision.dart';
import 'package:metronome/domain/models/time_signature.dart';
import 'package:metronome/ui/core/theme/sonic_theme.dart';
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
      presetsVm.dispose();
      metronomeVm.dispose();
      await libraryRepo.dispose();
      await metronomeRepo.dispose();
    });

    Widget buildTestApp() {
      return MaterialApp(
        theme: SonicTheme.darkTheme,
        home: PresetsView(viewModel: presetsVm),
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
      'one-tap loads preset, sorts favorites first, filters via search, edits, duplicates, and warns on delete when in setlist',
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
        await libraryRepo.createSetlist(
          name: 'Friday Set',
          presetIds: [alpha.id, beta.id],
        );

        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // One-tap load Beta Jazz (FR-PRE-02)
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

        // Duplicate Alpha Rock (FR-PRE-03)
        await tester.tap(
          find.byKey(Key('preset_duplicate_button_${alpha.id}')),
        );
        await tester.pumpAndSettle();
        expect(find.text('Alpha Rock (Copy)'), findsOneWidget);

        // Edit Alpha Rock
        await tester.tap(find.byKey(Key('preset_edit_button_${alpha.id}')));
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

        // Delete Alpha Anthem -> shows confirmation dialog with Friday Set warning (FR-PRE-10)
        await tester.tap(find.byKey(Key('preset_delete_button_${alpha.id}')));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('delete_preset_confirm_dialog')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('delete_preset_setlist_warning')),
          findsOneWidget,
        );
        expect(find.textContaining('Friday Set'), findsWidgets);

        await tester.tap(find.byKey(const Key('confirm_delete_preset_button')));
        await tester.pumpAndSettle();

        check(libraryRepo.getPresetById(alpha.id)).isNull();
        // Setlist reference automatically cleaned up (Section 6.3)
        check(libraryRepo.setlists.first.presetIds).deepEquals([beta.id]);
      },
    );
  });
}

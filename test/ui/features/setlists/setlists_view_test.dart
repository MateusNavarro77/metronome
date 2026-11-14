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
import 'package:metronome/ui/features/metronome/views/metronome_view.dart';
import 'package:metronome/ui/features/setlists/view_models/setlists_view_model.dart';
import 'package:metronome/ui/features/setlists/views/setlists_view.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group(
    'SetlistsView & ActiveSetlistStepperBar widget tests (FR-PRE-06..09)',
    () {
      ({
        SimulatedMetronomeEngine engine,
        MetronomeRepository metronomeRepo,
        PresetLibraryRepository libraryRepo,
        MetronomeViewModel metronomeVm,
        SetlistsViewModel setlistsVm,
      })
      createHarness() {
        final engine = SimulatedMetronomeEngine();
        final metronomeRepo = MetronomeRepository(engine: engine);
        final libraryRepo = PresetLibraryRepository();
        final metronomeVm = MetronomeViewModel(
          repository: metronomeRepo,
          presetLibraryRepository: libraryRepo,
        );
        final setlistsVm = SetlistsViewModel(
          repository: libraryRepo,
          metronomeViewModel: metronomeVm,
        );
        addTearDown(() async {
          setlistsVm.dispose();
          metronomeVm.dispose();
          await libraryRepo.dispose();
          await metronomeRepo.dispose();
        });
        return (
          engine: engine,
          metronomeRepo: metronomeRepo,
          libraryRepo: libraryRepo,
          metronomeVm: metronomeVm,
          setlistsVm: setlistsVm,
        );
      }

      testWidgets(
        'creates setlist, adds presets, reorders via drag, removes, renames, activates, and deletes',
        (WidgetTester tester) async {
          final (
            :libraryRepo,
            :metronomeVm,
            :setlistsVm,
            engine: _,
            metronomeRepo: _,
          ) = createHarness();
          final p1 = await libraryRepo.createPreset(
            name: 'Song A',
            bpm: const Bpm(100),
            timeSignature: TimeSignature.fourFour,
            subdivision: Subdivision.none,
            isAccentEnabled: true,
          );
          final p2 = await libraryRepo.createPreset(
            name: 'Song B',
            bpm: const Bpm(142),
            timeSignature: TimeSignature.sixEight,
            subdivision: Subdivision.eighth,
            isAccentEnabled: true,
          );

          await tester.pumpWidget(
            MaterialApp(
              theme: SonicTheme.darkTheme,
              home: SetlistsView(viewModel: setlistsVm),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('No setlists yet'), findsOneWidget);

          // Create a setlist -> opens SetlistDetailSheet
          await tester.tap(find.byKey(const Key('create_setlist_button')));
          await tester.pumpAndSettle();
          await tester.enterText(
            find.byKey(const Key('setlist_name_input')),
            'Sunday Gig',
          );
          await tester.tap(find.byKey(const Key('setlist_name_save_button')));
          await tester.pumpAndSettle();

          check(libraryRepo.setlists).length.equals(1);
          final setlistId = libraryRepo.setlists.first.id;
          expect(
            find.byKey(Key('setlist_detail_sheet_$setlistId')),
            findsOneWidget,
          );

          // Add Song A and Song B
          await tester.tap(find.byKey(const Key('setlist_add_preset_button')));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(Key('add_preset_picker_item_${p1.id}')));
          await tester.pumpAndSettle();

          await tester.tap(find.byKey(const Key('setlist_add_preset_button')));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(Key('add_preset_picker_item_${p2.id}')));
          await tester.pumpAndSettle();

          check(libraryRepo.getSetlistById(setlistId)?.presetIds)
              .isNotNull()
              .deepEquals([p1.id, p2.id]);

          // Drag Song B (index 1) above Song A (index 0) via drag handle
          final dragHandle = find.byKey(const Key('setlist_item_drag_1'));
          final row0Center = tester.getCenter(
            find.byKey(const Key('setlist_item_tap_0')),
          );
          final dragStart = tester.getCenter(dragHandle);
          await tester.timedDragFrom(
            dragStart,
            Offset(0, row0Center.dy - dragStart.dy - 12),
            const Duration(milliseconds: 400),
          );
          await tester.pumpAndSettle();

          check(libraryRepo.getSetlistById(setlistId)?.presetIds)
              .isNotNull()
              .deepEquals([p2.id, p1.id]);

          // Tap item 1 (Song A) to activate setlist at index 1 and close sheet
          await tester.tap(find.byKey(const Key('setlist_item_tap_1')));
          await tester.pumpAndSettle();

          check(metronomeVm.state.activeSetlistId).equals(setlistId);
          check(metronomeVm.activeSetlistIndex).equals(1);
          check(metronomeVm.bpmValue).equals(100);

          // Reopen detail sheet, remove first item (Song B), close sheet
          await tester.tap(find.byKey(Key('setlist_card_$setlistId')));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('setlist_item_remove_0')));
          await tester.pumpAndSettle();
          check(libraryRepo.getSetlistById(setlistId)?.presetIds)
              .isNotNull()
              .deepEquals([p1.id]);

          // Dismiss sheet
          await tester.tapAt(const Offset(10, 10));
          await tester.pumpAndSettle();

          // Rename setlist (FR-PRE-06)
          await tester.tap(find.byKey(Key('setlist_rename_button_$setlistId')));
          await tester.pumpAndSettle();
          await tester.enterText(
            find.byKey(const Key('setlist_name_input')),
            'Main Stage',
          );
          await tester.tap(find.byKey(const Key('setlist_name_save_button')));
          await tester.pumpAndSettle();
          expect(find.text('Main Stage'), findsOneWidget);

          // Quick activate from card button
          await tester.tap(
            find.byKey(Key('setlist_activate_button_$setlistId')),
          );
          await tester.pumpAndSettle();
          check(metronomeVm.activeSetlistIndex).equals(0);

          // Delete setlist with confirmation dialog
          await tester.tap(find.byKey(Key('setlist_delete_button_$setlistId')));
          await tester.pumpAndSettle();
          expect(
            find.byKey(const Key('delete_setlist_confirm_dialog')),
            findsOneWidget,
          );
          await tester.tap(
            find.byKey(const Key('confirm_delete_setlist_button')),
          );
          await tester.pumpAndSettle();

          check(libraryRepo.setlists).isEmpty();
          check(metronomeVm.activeSetlist).isNull();

          await tester.runAsync(() => GoogleFonts.pendingFonts());
          await tester.pump();
        },
      );

      testWidgets(
        'MetronomeView displays ActiveSetlistStepperBar with prev/next, bar-synced indicator, and Save Preset CTA',
        (WidgetTester tester) async {
          final (
            :engine,
            :libraryRepo,
            :metronomeVm,
            metronomeRepo: _,
            setlistsVm: _,
          ) = createHarness();
          final p1 = await libraryRepo.createPreset(
            name: 'First Song',
            bpm: const Bpm(112),
            timeSignature: TimeSignature.fourFour,
            subdivision: Subdivision.none,
            isAccentEnabled: true,
            note: 'Click only',
          );
          final p2 = await libraryRepo.createPreset(
            name: 'Second Song',
            bpm: const Bpm(150),
            timeSignature: TimeSignature.threeFour,
            subdivision: Subdivision.eighth,
            isAccentEnabled: true,
            note: 'Cue bridge',
          );
          final setlist = await libraryRepo.createSetlist(
            name: 'Live Set',
            presetIds: [p1.id, p2.id],
          );

          await tester.pumpWidget(
            MaterialApp(
              theme: SonicTheme.darkTheme,
              home: MetronomeView(viewModel: metronomeVm),
            ),
          );
          await tester.pumpAndSettle();

          // No setlist active initially
          expect(
            find.byKey(const Key('active_setlist_stepper_bar')),
            findsNothing,
          );
          expect(
            find.byKey(const Key('save_preset_header_button')),
            findsOneWidget,
          );

          // Save current state as preset via header CTA (UC-06)
          await tester.tap(find.byKey(const Key('save_preset_header_button')));
          await tester.pumpAndSettle();
          await tester.enterText(
            find.byKey(const Key('preset_name_input')),
            'Quick Save',
          );
          await tester.ensureVisible(
            find.byKey(const Key('preset_editor_save_button')),
          );
          await tester.tap(find.byKey(const Key('preset_editor_save_button')));
          await tester.pumpAndSettle();
          check(libraryRepo.presets.any((p) => p.name == 'Quick Save'))
              .isTrue();

          // Dismiss the 2s save confirmation SnackBar so it does not overlay
          // the bottom stepper bar.
          await tester.pump(const Duration(seconds: 3));
          await tester.pumpAndSettle();

          // Activate setlist
          metronomeVm.activateSetlist(setlist);
          await tester.pumpAndSettle();

          expect(
            find.byKey(const Key('active_setlist_stepper_bar')),
            findsOneWidget,
          );
          expect(
            find.byKey(const Key('active_setlist_preset_name')),
            findsOneWidget,
          );
          expect(find.text('First Song'), findsOneWidget);
          expect(find.text('Click only'), findsOneWidget);
          expect(find.text('1 of 2'), findsOneWidget);
          expect(find.text('112'), findsOneWidget);

          // Start playing, then step Next -> shows NEXT BAR pending badge until downbeat
          await tester.ensureVisible(find.byKey(const Key('play_stop_button')));
          await tester.tap(find.byKey(const Key('play_stop_button')));
          await tester.pumpAndSettle();
          check(metronomeVm.isPlaying).isTrue();

          await tester.ensureVisible(
            find.byKey(const Key('setlist_next_button')),
          );
          await tester.tap(find.byKey(const Key('setlist_next_button')));
          await tester.pumpAndSettle();
          check(metronomeVm.activeSetlistIndex).equals(1);

          expect(find.text('Second Song'), findsOneWidget);
          expect(find.text('2 of 2'), findsOneWidget);
          expect(find.text('150'), findsOneWidget);
          expect(
            find.byKey(const Key('setlist_pending_transition_badge')),
            findsOneWidget,
          );
          check(engine.bpm).equals(const Bpm(112));

          // Finish remaining 3 beats of the 4/4 bar -> transitions at Beat 1
          engine.advancePulses(4);
          await tester.pump(Duration.zero);
          await tester.pumpAndSettle();

          check(engine.bpm).equals(const Bpm(150));
          check(engine.timeSignature).equals(TimeSignature.threeFour);
          check(metronomeVm.hasPendingBarTransition).isFalse();
          expect(
            find.byKey(const Key('setlist_pending_transition_badge')),
            findsNothing,
          );

          // Deactivate setlist
          await tester.ensureVisible(
            find.byKey(const Key('setlist_deactivate_button')),
          );
          await tester.tap(find.byKey(const Key('setlist_deactivate_button')));
          await tester.pumpAndSettle();
          expect(
            find.byKey(const Key('active_setlist_stepper_bar')),
            findsNothing,
          );

          await tester.runAsync(() => GoogleFonts.pendingFonts());
          await tester.pump();
        },
      );
    },
  );
}

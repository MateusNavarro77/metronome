import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:metronome/domain/models/bpm.dart';
import 'package:metronome/domain/models/subdivision.dart';
import 'package:metronome/domain/models/time_signature.dart';
import 'package:metronome/l10n/app_localizations.dart';
import 'package:metronome/ui/core/l10n/l10n_extensions.dart';
import 'package:metronome/ui/core/theme/app_theme.dart';
import 'package:metronome/ui/features/presets/views/widgets/preset_editor_sheet.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('PresetEditorSheet widget tests', () {
    testWidgets(
      'drag handle remains pinned at top of sheet when scrolled down',
      (tester) async {
        tester.view.physicalSize = const Size(400, 600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            localizationsDelegates: appLocalizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Builder(
                builder: (context) => Center(
                  child: FilledButton(
                    onPressed: () => showPresetEditorSheet(
                      context,
                      initialBpm: Bpm(120),
                      initialTimeSignature: TimeSignature.fourFour,
                      initialSubdivision: Subdivision.none,
                      initialAccentEnabled: true,
                    ),
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        final handleFinder = find.byKey(const Key('preset_editor_drag_handle'));
        final sheetFinder = find.byKey(const Key('preset_editor_sheet'));

        expect(handleFinder, findsOneWidget);
        expect(sheetFinder, findsOneWidget);
        expect(find.byType(BackdropFilter), findsNothing);
        // Ensure the drag handle is inside the styled sheet container.
        expect(
          find.descendant(of: sheetFinder, matching: handleFinder),
          findsOneWidget,
        );

        final initialHandleTopLeft = tester.getTopLeft(handleFinder);
        final initialNameTopLeft = tester.getTopLeft(
          find.byKey(const Key('preset_name_input')),
        );

        // Scroll down to the bottom action button.
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -400),
        );
        await tester.pumpAndSettle();

        // Scrollable content moved upward.
        final scrolledNameTopLeft = tester.getTopLeft(
          find.byKey(const Key('preset_name_input')),
        );
        check(scrolledNameTopLeft.dy).isLessThan(initialNameTopLeft.dy);

        // Drag handle remained pinned at the exact same position.
        final scrolledHandleTopLeft = tester.getTopLeft(handleFinder);
        check(scrolledHandleTopLeft.dy).equals(initialHandleTopLeft.dy);
        expect(handleFinder, findsOneWidget);

        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pumpAndSettle();
      },
    );
  });
}

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metronome/data/repositories/preferences_repository.dart';
import 'package:metronome/domain/models/app_theme_mode.dart';
import 'package:metronome/ui/core/theme/sonic_theme.dart';
import 'package:metronome/ui/features/preferences/view_models/preferences_view_model.dart';
import 'package:metronome/ui/features/preferences/views/preferences_view.dart';
import 'package:provider/provider.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('PreferencesView', () {
    testWidgets('renders appearance options and switches theme mode', (
      WidgetTester tester,
    ) async {
      final repo = PreferencesRepository(preferences: null);
      final viewModel = PreferencesViewModel(repository: repo);

      await tester.pumpWidget(
        ChangeNotifierProvider<PreferencesViewModel>.value(
          value: viewModel,
          child: MaterialApp(
            theme: SonicTheme.lightTheme,
            darkTheme: SonicTheme.darkTheme,
            home: const PreferencesView(),
          ),
        ),
      );

      // Verify title and segmented button exist
      expect(find.text('PREFERENCES'), findsOneWidget);
      expect(find.text('APPEARANCE'), findsOneWidget);
      expect(
        find.byKey(const Key('theme_mode_segmented_button')),
        findsOneWidget,
      );
      expect(find.text('System'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);

      // Tap 'Light' button segment
      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();

      check(viewModel.themeMode).equals(AppThemeMode.light);

      // Tap 'Dark' button segment
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      check(viewModel.themeMode).equals(AppThemeMode.dark);
    });

    testWidgets('back button pops the screen', (WidgetTester tester) async {
      final repo = PreferencesRepository(preferences: null);
      final viewModel = PreferencesViewModel(repository: repo);

      await tester.pumpWidget(
        ChangeNotifierProvider<PreferencesViewModel>.value(
          value: viewModel,
          child: MaterialApp(
            theme: SonicTheme.darkTheme,
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

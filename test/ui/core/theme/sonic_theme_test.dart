import 'package:checks/checks.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metronome/ui/core/theme/sonic_theme.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('SonicTheme', () {
    test('darkTheme has dark brightness and SonicColorsExtension.dark', () {
      final theme = SonicTheme.darkTheme;
      check(theme.brightness).equals(Brightness.dark);

      final extension = theme.extension<SonicColorsExtension>();
      check(extension).isNotNull();
      check(extension!.primaryAccent).equals(const Color(0xFF00FF41));
      check(extension.surfaceLowest).equals(const Color(0xFF0E0E0E));
    });

    test('lightTheme has light brightness and SonicColorsExtension.light', () {
      final theme = SonicTheme.lightTheme;
      check(theme.brightness).equals(Brightness.light);

      final extension = theme.extension<SonicColorsExtension>();
      check(extension).isNotNull();
      check(extension!.primaryAccent).equals(const Color(0xFF00B834));
      check(extension.surfaceLowest).equals(const Color(0xFFF7F7F6));
    });

    test('SonicColorsExtension lerp smoothly interpolates colors', () {
      const dark = SonicColorsExtension.dark;
      const light = SonicColorsExtension.light;

      final lerped = dark.lerp(light, 0.5);
      check(lerped.primaryAccent).isNotNull();
      check(lerped.surfaceLowest).isNotNull();
    });

    testWidgets('BuildContext extension provides colors and dimens', (
      WidgetTester tester,
    ) async {
      late SonicColorsExtension colors;
      late SonicDimens dimens;

      await tester.pumpWidget(
        MaterialApp(
          theme: SonicTheme.lightTheme,
          home: Builder(
            builder: (context) {
              colors = context.colors;
              dimens = context.dimens;
              return const SizedBox();
            },
          ),
        ),
      );

      check(colors.primaryAccent).equals(const Color(0xFF00B834));
      check(dimens.spaceMd).equals(16.0);
    });
  });
}

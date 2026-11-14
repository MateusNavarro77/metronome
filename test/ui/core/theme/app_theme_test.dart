import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart'
    hide CornerRounding, RoundedPolygon;
import 'package:metronome/ui/core/theme/app_theme.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  group('AppTheme', () {
    test('exposes seed color 0xFF00FF41', () {
      check(AppTheme.seedColor).equals(const Color(0xFF00FF41));
    });

    test('builds light and dark M3EThemeData with matching brightness', () {
      final light = AppTheme.lightThemeData;
      final dark = AppTheme.darkThemeData;

      check(light.brightness).equals(Brightness.light);
      check(dark.brightness).equals(Brightness.dark);
    });

    test(
      'builds light and dark Flutter ThemeData with Comfortaa typography',
      () {
        final light = AppTheme.lightTheme;
        final dark = AppTheme.darkTheme;

        check(light.brightness).equals(Brightness.light);
        check(dark.brightness).equals(Brightness.dark);
        check(light.textTheme.bodyMedium?.fontFamily)
            .isNotNull()
            .contains('Comfortaa');
        check(dark.textTheme.bodyMedium?.fontFamily)
            .isNotNull()
            .contains('Comfortaa');
      },
    );

    test('exposes MetronomeDimens defaults', () {
      check(MetronomeDimens.instance.spaceMd).equals(16.0);
    });

    testWidgets(
      'MetronomeContextTheme resolves m3e, dimens, theme, colorScheme, and textTheme inside M3EMaterialApp',
      (tester) async {
        late M3EThemeData resolvedM3E;
        late MetronomeDimens resolvedDimens;
        late ThemeData resolvedTheme;
        late ColorScheme resolvedColorScheme;
        late TextTheme resolvedTextTheme;

        await tester.pumpWidget(
          M3EMaterialApp(
            data: AppTheme.lightThemeData,
            home: Builder(
              builder: (context) {
                resolvedM3E = context.m3e;
                resolvedDimens = context.dimens;
                resolvedTheme = context.theme;
                resolvedColorScheme = context.colorScheme;
                resolvedTextTheme = context.textTheme;
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        check(resolvedM3E.brightness).equals(Brightness.light);
        check(resolvedDimens).equals(MetronomeDimens.instance);
        check(resolvedTheme.brightness).equals(Brightness.light);
        check(resolvedColorScheme.brightness).equals(Brightness.light);
        check(resolvedTextTheme.bodyMedium?.fontFamily).isNotNull();
      },
    );
  });
}

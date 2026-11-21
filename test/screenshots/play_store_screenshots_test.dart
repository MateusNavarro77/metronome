@Tags(['screenshots'])
library;

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:metronome/data/services/simulated_metronome_engine.dart';
import 'package:metronome/domain/models/app_language.dart';
import 'package:metronome/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

Directory? _findMaterialFontsDir() {
  final envRoot = Platform.environment['FLUTTER_ROOT'];
  if (envRoot != null && envRoot.isNotEmpty) {
    final candidate = Directory('$envRoot/bin/cache/artifacts/material_fonts');
    if (candidate.existsSync()) {
      return candidate;
    }
  }

  var current = File(Platform.resolvedExecutable).parent;
  for (var i = 0; i < 10; i++) {
    final candidate = Directory(
      '${current.path}/bin/cache/artifacts/material_fonts',
    );
    if (candidate.existsSync()) {
      return candidate;
    }
    final parent = current.parent;
    if (parent.path == current.path) {
      break;
    }
    current = parent;
  }
  return null;
}

File? _findSymbolFallbackFont() {
  const candidates = [
    '/System/Library/Fonts/Apple Symbols.ttf',
    '/System/Library/Fonts/Supplemental/Arial Unicode.ttf',
    '/usr/share/fonts/truetype/noto/NotoSansSymbols2-Regular.ttf',
    '/usr/share/fonts/truetype/noto/NotoSansSymbols-Regular.ttf',
    '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
  ];
  for (final path in candidates) {
    final file = File(path);
    if (file.existsSync()) {
      return file;
    }
  }
  return null;
}

Future<void> _loadFontFiles(String family, List<File> files) async {
  final existing = files.where((f) => f.existsSync()).toList();
  if (existing.isEmpty) {
    return;
  }
  final loader = FontLoader(family);
  for (final file in existing) {
    final bytes = await file.readAsBytes();
    loader.addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

Future<void> _loadTestFonts() async {
  final materialFontsDir = _findMaterialFontsDir();
  if (materialFontsDir != null) {
    await _loadFontFiles('MaterialIcons', [
      File('${materialFontsDir.path}/MaterialIcons-Regular.otf'),
    ]);
    await _loadFontFiles('Roboto', [
      File('${materialFontsDir.path}/Roboto-Light.ttf'),
      File('${materialFontsDir.path}/Roboto-Regular.ttf'),
      File('${materialFontsDir.path}/Roboto-Medium.ttf'),
      File('${materialFontsDir.path}/Roboto-Bold.ttf'),
    ]);
  }

  final symbolFallback = _findSymbolFallbackFont();
  if (symbolFallback != null) {
    // GoogleFonts resolves Comfortaa_<variant> for normal glyphs and falls back
    // to 'Comfortaa' for missing musical note symbols (♩, ♫, ♪, ♬).
    await _loadFontFiles('Comfortaa', [symbolFallback]);
  }
}

Future<void> _capturePhoneScreenshotsForLocale(
  WidgetTester tester, {
  required AppLanguage language,
  required String storeLocale,
}) async {
  SharedPreferences.setMockInitialValues({'app_language': language.code});
  final preferences = await SharedPreferences.getInstance();
  final simulatedEngine = SimulatedMetronomeEngine();

  // Pixel phone resolution: ~411x914 logical * 2.625 DPR = 1080x2400 px
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    MetronomeApp(
      key: ValueKey('screenshot_app_${language.code}'),
      engineOverride: simulatedEngine,
      preferences: preferences,
    ),
  );
  await tester.runAsync(() => GoogleFonts.pendingFonts());
  await tester.pumpAndSettle();

  final basePath =
      '../../android/fastlane/metadata/android/$storeLocale/images/phoneScreenshots';

  // 1. Metronome main screen
  await expectLater(
    find.byType(MetronomeApp),
    matchesGoldenFile('$basePath/01_metronome.png'),
  );

  // 2. Presets screen
  await tester.tap(find.byKey(const Key('nav_destination_presets')));
  await tester.pumpAndSettle();
  await tester.runAsync(() => GoogleFonts.pendingFonts());
  await tester.pumpAndSettle();
  await expectLater(
    find.byType(MetronomeApp),
    matchesGoldenFile('$basePath/02_presets.png'),
  );

  // 3. Setlists screen
  await tester.tap(find.byKey(const Key('nav_destination_setlists')));
  await tester.pumpAndSettle();
  await tester.runAsync(() => GoogleFonts.pendingFonts());
  await tester.pumpAndSettle();
  await expectLater(
    find.byType(MetronomeApp),
    matchesGoldenFile('$basePath/03_setlists.png'),
  );

  // 4. Preferences screen
  await tester.tap(find.byKey(const Key('nav_destination_settings')));
  await tester.pumpAndSettle();
  await tester.runAsync(() => GoogleFonts.pendingFonts());
  await tester.pumpAndSettle();
  await expectLater(
    find.byType(MetronomeApp),
    matchesGoldenFile('$basePath/04_preferences.png'),
  );
}

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  const screenshotLocales = <(AppLanguage, String)>[
    (AppLanguage.english, 'en-US'),
    (AppLanguage.portuguese, 'pt-BR'),
  ];

  for (final (language, storeLocale) in screenshotLocales) {
    testWidgets('Generate Play Store phone screenshots ($storeLocale)', (
      WidgetTester tester,
    ) async {
      await tester.runAsync(_loadTestFonts);
      await _capturePhoneScreenshotsForLocale(
        tester,
        language: language,
        storeLocale: storeLocale,
      );
    });
  }
}

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

typedef _ScreenshotDeviceProfile = ({
  String folder,
  Size physicalSize,
  double devicePixelRatio,
});

const _deviceProfiles = <_ScreenshotDeviceProfile>[
  (
    folder: 'phoneScreenshots',
    physicalSize: Size(1080, 2400),
    devicePixelRatio: 2.625,
  ),
  (
    folder: 'sevenInchScreenshots',
    physicalSize: Size(1200, 1920),
    devicePixelRatio: 1.5,
  ),
  (
    folder: 'tenInchScreenshots',
    physicalSize: Size(2560, 1600),
    devicePixelRatio: 2.0,
  ),
];

Future<void> _tapNavDestination(WidgetTester tester, String section) async {
  final railFinder = find.byKey(Key('rail_destination_$section'));
  if (railFinder.evaluate().isNotEmpty) {
    await tester.tap(railFinder);
  } else {
    final icon = switch (section) {
      'metronome' => Icons.speed_outlined,
      'presets' => Icons.tune_outlined,
      'setlists' => Icons.queue_music_outlined,
      'settings' => Icons.settings_outlined,
      _ => throw ArgumentError('Unknown navigation section: $section'),
    };
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('adaptive_navigation_toolbar')),
        matching: find.byIcon(icon),
      ),
    );
  }
  await tester.pumpAndSettle();
  await tester.runAsync(() => GoogleFonts.pendingFonts());
  await tester.pumpAndSettle();
}

Future<void> _captureScreenshotsForLocaleAndProfile(
  WidgetTester tester, {
  required AppLanguage language,
  required String storeLocale,
  required _ScreenshotDeviceProfile profile,
}) async {
  SharedPreferences.setMockInitialValues({'app_language': language.code});
  final preferences = await SharedPreferences.getInstance();
  final simulatedEngine = SimulatedMetronomeEngine();

  tester.view.physicalSize = profile.physicalSize;
  tester.view.devicePixelRatio = profile.devicePixelRatio;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    MetronomeApp(
      key: ValueKey('screenshot_app_${language.code}_${profile.folder}'),
      engineOverride: simulatedEngine,
      preferences: preferences,
    ),
  );
  await tester.runAsync(() => GoogleFonts.pendingFonts());
  await tester.pumpAndSettle();

  final basePath =
      '../../android/fastlane/metadata/android/$storeLocale/images/${profile.folder}';

  // 1. Metronome main screen
  await expectLater(
    find.byType(MetronomeApp),
    matchesGoldenFile('$basePath/01_metronome.png'),
  );

  // 2. Presets screen
  await _tapNavDestination(tester, 'presets');
  await expectLater(
    find.byType(MetronomeApp),
    matchesGoldenFile('$basePath/02_presets.png'),
  );

  // 3. Setlists screen
  await _tapNavDestination(tester, 'setlists');
  await expectLater(
    find.byType(MetronomeApp),
    matchesGoldenFile('$basePath/03_setlists.png'),
  );

  // 4. Preferences screen
  await _tapNavDestination(tester, 'settings');
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
    for (final profile in _deviceProfiles) {
      testWidgets(
        'Generate Play Store ${profile.folder} screenshots ($storeLocale)',
        (WidgetTester tester) async {
          await tester.runAsync(_loadTestFonts);
          await _captureScreenshotsForLocaleAndProfile(
            tester,
            language: language,
            storeLocale: storeLocale,
            profile: profile,
          );
        },
      );
    }
  }
}

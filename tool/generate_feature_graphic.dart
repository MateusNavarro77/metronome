import 'dart:io';

import 'generate_logo.dart';

/// Generates localized Play Store feature graphics (1024x500) without
/// bottom feature pills, matching the Material 3 Expressive metronome logo.
///
/// Usage:
///   dart --packages=.empty_pkg.json tool/generate_feature_graphic.dart
Future<void> main() async {
  final tempDir = await Directory.systemTemp.createTemp('metronome_fg_');

  try {
    const locales = <({String storeLocale, String title, String subtitle})>[
      (
        storeLocale: 'en-US',
        title: 'Metronome',
        subtitle: 'Simple. Clean. Precise.',
      ),
      (
        storeLocale: 'pt-BR',
        title: 'Metrônomo',
        subtitle: 'Simples. Limpo. Preciso.',
      ),
    ];

    for (final locale in locales) {
      final outPath =
          'android/fastlane/metadata/android/${locale.storeLocale}/images/featureGraphic.png';
      await _generateFeatureGraphic(
        tempDir: tempDir.path,
        outputPath: outPath,
        title: locale.title,
        subtitle: locale.subtitle,
      );
    }

    stdout.writeln('Updated featureGraphic.png for en-US and pt-BR.');
  } finally {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  }
}

Future<void> _generateFeatureGraphic({
  required String tempDir,
  required String outputPath,
  required String title,
  required String subtitle,
}) async {
  final baseSvgPath = '$tempDir/feature_base.svg';
  await File(baseSvgPath).writeAsString(_buildFeatureGraphicBaseSvg());

  await File(outputPath).parent.create(recursive: true);

  final result = await Process.run('magick', [
    '-density',
    '96',
    baseSvgPath,
    '-resize',
    '1024x500!',
    '-font',
    'assets/google_fonts/Comfortaa-SemiBold.ttf',
    '-pointsize',
    '66',
    '-fill',
    '#151D15',
    '-annotate',
    '+348+270',
    title,
    '-font',
    'assets/google_fonts/Comfortaa-Regular.ttf',
    '-pointsize',
    '30',
    '-fill',
    '#354335',
    '-annotate',
    '+348+328',
    subtitle,
    '-alpha',
    'remove',
    '-alpha',
    'off',
    outputPath,
  ]);

  if (result.exitCode != 0) {
    throw ProcessException(
      'magick',
      [baseSvgPath, outputPath],
      '${result.stderr}',
      result.exitCode,
    );
  }
}

String _buildFeatureGraphicBaseSvg() {
  const w = 1024.0;
  const h = 500.0;
  const cardX = 72.0;
  const cardY = 142.0;
  const cardSize = 216.0;
  const cardRx = 46.0;

  final innerLogo = buildMetronomeGroupSvg(size: cardSize, monochrome: false);

  final buf = StringBuffer()
    ..writeln(
      '<svg xmlns="http://www.w3.org/2000/svg" '
      'viewBox="0 0 ${w.toInt()} ${h.toInt()}" '
      'width="${w.toInt()}" height="${h.toInt()}">',
    )
    // Background.
    ..writeln(
      '  <rect x="0" y="0" width="${w.toInt()}" height="${h.toInt()}" '
      'fill="$logoBackgroundColor" />',
    )
    // Top-right soft mint decorative circle.
    ..writeln(
      '  <circle cx="945" cy="90" r="205" fill="#C9F5C4" fill-opacity="0.72" />',
    )
    // Bottom-left subtle decorative circle.
    ..writeln(
      '  <circle cx="68" cy="472" r="145" fill="#E3EFE0" fill-opacity="0.85" />',
    )
    // Soft elevation layers under the icon card.
    ..writeln(
      '  <rect x="$cardX" y="${cardY + 14}" '
      'width="$cardSize" height="$cardSize" rx="$cardRx" '
      'fill="#000000" fill-opacity="0.05" />',
    )
    ..writeln(
      '  <rect x="$cardX" y="${cardY + 6}" '
      'width="$cardSize" height="$cardSize" rx="$cardRx" '
      'fill="#000000" fill-opacity="0.06" />',
    )
    // Squircle icon card.
    ..writeln(
      '  <rect x="$cardX" y="$cardY" '
      'width="$cardSize" height="$cardSize" rx="$cardRx" '
      'fill="$logoBackgroundColor" stroke="#D8E3D5" stroke-width="1.5" />',
    )
    // New metronome logo centered inside card.
    ..writeln('  <g transform="translate($cardX, $cardY)">')
    ..writeln(innerLogo)
    ..writeln('  </g>')
    // 4-beat pill container vertically balanced with title & subtitle.
    ..writeln(
      '  <rect x="348" y="148" width="228" height="40" rx="20" '
      'fill="#F8FCF6" stroke="#CBD6C8" stroke-width="1.5" />',
    )
    ..writeln(
      '  <rect x="360" y="158" width="46" height="20" rx="10" '
      'fill="$logoPrimaryStrokeColor" />',
    )
    ..writeln(
      '  <rect x="414" y="158" width="46" height="20" rx="10" fill="#DDE3DB" />',
    )
    ..writeln(
      '  <rect x="468" y="158" width="46" height="20" rx="10" fill="#DDE3DB" />',
    )
    ..writeln(
      '  <rect x="522" y="158" width="46" height="20" rx="10" fill="#DDE3DB" />',
    )
    ..writeln('</svg>');

  return buf.toString();
}

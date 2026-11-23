import 'dart:io';
import 'dart:math' as math;

/// Generates the Material 3 Expressive geometric metronome logo and applies
/// it across Android, iOS, macOS, Web, Windows, Fastlane, and README assets.
///
/// Usage:
///   dart --packages=.empty_pkg.json tool/generate_logo.dart
Future<void> main(List<String> args) async {
  final tempDir = await Directory.systemTemp.createTemp('metronome_logo_');

  try {
    await _generateAllPlatformIcons(tempDir.path);
    stdout.writeln('Applied new metronome logo across all platforms.');
  } finally {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  }
}

const logoBackgroundColor = '#F4FAF2';
const logoPrimaryStrokeColor = '#1F4B23';
const logoAccentMintColor = '#A7F3A0';
const logoBodyFillColor = '#FFFFFF';

Future<void> _generateAllPlatformIcons(String tempDir) async {
  final fullSquareSvg = buildMetronomeSvg(
    size: 1024,
    includeBackground: true,
    adaptiveSafeZone: false,
    monochrome: false,
  );
  final maskableSvg = buildMetronomeSvg(
    size: 1024,
    includeBackground: true,
    adaptiveSafeZone: true,
    monochrome: false,
  );
  final adaptiveFgSvg = buildMetronomeSvg(
    size: 1024,
    includeBackground: false,
    adaptiveSafeZone: true,
    monochrome: false,
  );
  final monochromeSvg = buildMetronomeSvg(
    size: 1024,
    includeBackground: false,
    adaptiveSafeZone: true,
    monochrome: true,
  );
  final squircleSvg = buildSquircleLogoSvg(size: 1024);
  final macOsSquircleSvg = buildSquircleLogoSvg(
    size: 1024,
    cardInsetRatio: 0.095,
    cardRadiusRatio: 0.225,
  );
  final solidBgSvg = buildSolidBackgroundSvg(size: 1024);

  final fullSquareSvgPath = '$tempDir/full_square.svg';
  final maskableSvgPath = '$tempDir/maskable.svg';
  final adaptiveFgSvgPath = '$tempDir/adaptive_fg.svg';
  final monochromeSvgPath = '$tempDir/monochrome.svg';
  final squircleSvgPath = '$tempDir/squircle.svg';
  final macOsSquircleSvgPath = '$tempDir/macos_squircle.svg';
  final solidBgSvgPath = '$tempDir/solid_bg.svg';

  await Future.wait([
    File(fullSquareSvgPath).writeAsString(fullSquareSvg),
    File(maskableSvgPath).writeAsString(maskableSvg),
    File(adaptiveFgSvgPath).writeAsString(adaptiveFgSvg),
    File(monochromeSvgPath).writeAsString(monochromeSvg),
    File(squircleSvgPath).writeAsString(squircleSvg),
    File(macOsSquircleSvgPath).writeAsString(macOsSquircleSvg),
    File(solidBgSvgPath).writeAsString(solidBgSvg),
  ]);

  // 1. Fastlane store icons (512x512, opaque) & README logo (512x512, opaque).
  for (final path in [
    'android/fastlane/metadata/android/en-US/images/icon.png',
    'android/fastlane/metadata/android/pt-BR/images/icon.png',
    'readme-assets/app_logo.png',
  ]) {
    await _renderSvgToPng(
      svgPath: fullSquareSvgPath,
      pngPath: path,
      sizePx: 512,
      opaqueBackground: logoBackgroundColor,
    );
  }

  // 2. Android adaptive & legacy mipmap icons.
  const androidDensities = <String, ({int legacy, int adaptive})>{
    'mipmap-mdpi': (legacy: 48, adaptive: 108),
    'mipmap-hdpi': (legacy: 72, adaptive: 162),
    'mipmap-xhdpi': (legacy: 96, adaptive: 216),
    'mipmap-xxhdpi': (legacy: 144, adaptive: 324),
    'mipmap-xxxhdpi': (legacy: 192, adaptive: 432),
  };

  for (final entry in androidDensities.entries) {
    final resDir = 'android/app/src/main/res/${entry.key}';
    final sizes = entry.value;

    await _renderSvgToPng(
      svgPath: squircleSvgPath,
      pngPath: '$resDir/ic_launcher.png',
      sizePx: sizes.legacy,
    );
    await _renderSvgToPng(
      svgPath: solidBgSvgPath,
      pngPath: '$resDir/ic_launcher_background.png',
      sizePx: sizes.adaptive,
      opaqueBackground: logoBackgroundColor,
    );
    await _renderSvgToPng(
      svgPath: adaptiveFgSvgPath,
      pngPath: '$resDir/ic_launcher_foreground.png',
      sizePx: sizes.adaptive,
    );
    await _renderSvgToPng(
      svgPath: monochromeSvgPath,
      pngPath: '$resDir/ic_launcher_monochrome.png',
      sizePx: sizes.adaptive,
    );
  }

  // 3. iOS AppIcon.appiconset (all icons must be opaque with no alpha channel).
  const iosIcons = <String, int>{
    'Icon-App-20x20@1x.png': 20,
    'Icon-App-20x20@2x.png': 40,
    'Icon-App-20x20@3x.png': 60,
    'Icon-App-29x29@1x.png': 29,
    'Icon-App-29x29@2x.png': 58,
    'Icon-App-29x29@3x.png': 87,
    'Icon-App-40x40@1x.png': 40,
    'Icon-App-40x40@2x.png': 80,
    'Icon-App-40x40@3x.png': 120,
    'Icon-App-60x60@2x.png': 120,
    'Icon-App-60x60@3x.png': 180,
    'Icon-App-76x76@1x.png': 76,
    'Icon-App-76x76@2x.png': 152,
    'Icon-App-83.5x83.5@2x.png': 167,
    'Icon-App-1024x1024@1x.png': 1024,
  };

  for (final entry in iosIcons.entries) {
    await _renderSvgToPng(
      svgPath: fullSquareSvgPath,
      pngPath: 'ios/Runner/Assets.xcassets/AppIcon.appiconset/${entry.key}',
      sizePx: entry.value,
      opaqueBackground: logoBackgroundColor,
    );
  }

  // 4. macOS AppIcon.appiconset (squircle with transparent corners).
  const macOsIcons = <String, int>{
    'app_icon_16.png': 16,
    'app_icon_32.png': 32,
    'app_icon_64.png': 64,
    'app_icon_128.png': 128,
    'app_icon_256.png': 256,
    'app_icon_512.png': 512,
    'app_icon_1024.png': 1024,
  };

  for (final entry in macOsIcons.entries) {
    await _renderSvgToPng(
      svgPath: macOsSquircleSvgPath,
      pngPath: 'macos/Runner/Assets.xcassets/AppIcon.appiconset/${entry.key}',
      sizePx: entry.value,
    );
  }

  // 5. Web icons & favicon.
  await _renderSvgToPng(
    svgPath: squircleSvgPath,
    pngPath: 'web/favicon.png',
    sizePx: 32,
  );
  await _renderSvgToPng(
    svgPath: squircleSvgPath,
    pngPath: 'web/icons/Icon-192.png',
    sizePx: 192,
  );
  await _renderSvgToPng(
    svgPath: squircleSvgPath,
    pngPath: 'web/icons/Icon-512.png',
    sizePx: 512,
  );
  await _renderSvgToPng(
    svgPath: maskableSvgPath,
    pngPath: 'web/icons/Icon-maskable-192.png',
    sizePx: 192,
    opaqueBackground: logoBackgroundColor,
  );
  await _renderSvgToPng(
    svgPath: maskableSvgPath,
    pngPath: 'web/icons/Icon-maskable-512.png',
    sizePx: 512,
    opaqueBackground: logoBackgroundColor,
  );

  // 6. Windows multi-resolution ICO.
  await _renderSvgToIco(
    svgPath: squircleSvgPath,
    icoPath: 'windows/runner/resources/app_icon.ico',
    tempDir: tempDir,
  );
}

Future<void> _renderSvgToPng({
  required String svgPath,
  required String pngPath,
  required int sizePx,
  String? opaqueBackground,
}) async {
  await File(pngPath).parent.create(recursive: true);
  final args = <String>[
    '-background',
    opaqueBackground ?? 'none',
    '-density',
    '300',
    svgPath,
    '-resize',
    '${sizePx}x$sizePx',
    if (opaqueBackground != null) ...['-alpha', 'remove', '-alpha', 'off'],
    pngPath,
  ];
  await _runMagick(args);
}

Future<void> _renderSvgToIco({
  required String svgPath,
  required String icoPath,
  required String tempDir,
}) async {
  final masterPng = '$tempDir/win_master_256.png';
  await _renderSvgToPng(svgPath: svgPath, pngPath: masterPng, sizePx: 256);
  await _runMagick([
    masterPng,
    '-define',
    'icon:auto-resize=256,48,32,16',
    icoPath,
  ]);
}

Future<void> _runMagick(List<String> args) async {
  final result = await Process.run('magick', args);
  if (result.exitCode != 0) {
    throw ProcessException('magick', args, '${result.stderr}', result.exitCode);
  }
}

/// Builds a solid background SVG matching [logoBackgroundColor].
String buildSolidBackgroundSvg({required double size}) {
  return '<svg xmlns="http://www.w3.org/2000/svg" '
      'viewBox="0 0 ${_f(size)} ${_f(size)}" '
      'width="${size.toInt()}" height="${size.toInt()}">\n'
      '  <rect x="0" y="0" width="${_f(size)}" height="${_f(size)}" '
      'fill="$logoBackgroundColor" />\n'
      '</svg>\n';
}

/// Builds a rounded squircle icon SVG with subtle soft shadow.
String buildSquircleLogoSvg({
  required double size,
  double cardInsetRatio = 0.06,
  double cardRadiusRatio = 0.20,
}) {
  final inset = size * cardInsetRatio;
  final cardSize = size - inset * 2;
  final rx = cardSize * cardRadiusRatio;

  final innerScale = cardSize / size;
  final innerGroup = buildMetronomeGroupSvg(size: size, monochrome: false);

  final buf = StringBuffer()
    ..writeln(
      '<svg xmlns="http://www.w3.org/2000/svg" '
      'viewBox="0 0 ${_f(size)} ${_f(size)}" '
      'width="${size.toInt()}" height="${size.toInt()}">',
    )
    // Layered soft shadows for clean elevation without SVG filter issues.
    ..writeln(
      '  <rect x="${_f(inset)}" y="${_f(inset + size * 0.018)}" '
      'width="${_f(cardSize)}" height="${_f(cardSize)}" rx="${_f(rx)}" '
      'fill="#000000" fill-opacity="0.06" />',
    )
    ..writeln(
      '  <rect x="${_f(inset)}" y="${_f(inset + size * 0.008)}" '
      'width="${_f(cardSize)}" height="${_f(cardSize)}" rx="${_f(rx)}" '
      'fill="#000000" fill-opacity="0.08" />',
    )
    // Squircle card body.
    ..writeln(
      '  <rect x="${_f(inset)}" y="${_f(inset)}" '
      'width="${_f(cardSize)}" height="${_f(cardSize)}" rx="${_f(rx)}" '
      'fill="$logoBackgroundColor" stroke="#D8E3D5" stroke-width="${_f(size * 0.004)}" />',
    )
    // Scaled metronome artwork centered in card.
    ..writeln(
      '  <g transform="translate(${_f(inset)}, ${_f(inset)}) scale(${_f(innerScale)})">',
    )
    ..writeln(innerGroup)
    ..writeln('  </g>')
    ..writeln('</svg>');
  return buf.toString();
}

/// Builds a full square SVG containing the metronome mark.
String buildMetronomeSvg({
  required double size,
  required bool includeBackground,
  required bool adaptiveSafeZone,
  required bool monochrome,
}) {
  final buf = StringBuffer()
    ..writeln(
      '<svg xmlns="http://www.w3.org/2000/svg" '
      'viewBox="0 0 ${_f(size)} ${_f(size)}" '
      'width="${size.toInt()}" height="${size.toInt()}">',
    );

  if (includeBackground && !monochrome) {
    buf.writeln(
      '  <rect x="0" y="0" width="${_f(size)}" height="${_f(size)}" '
      'fill="$logoBackgroundColor" />',
    );
  }

  if (adaptiveSafeZone) {
    const scale = 0.72;
    final tx = size * (1 - scale) / 2;
    final ty = size * (1 - scale) / 2;
    buf.writeln(
      '  <g transform="translate(${_f(tx)}, ${_f(ty)}) scale($scale)">',
    );
  } else {
    buf.writeln('  <g>');
  }

  buf.writeln(buildMetronomeGroupSvg(size: size, monochrome: monochrome));
  buf.writeln('  </g>');
  buf.writeln('</svg>');
  return buf.toString();
}

/// Returns the inner `<g>` SVG elements (including `<defs>`) for the
/// metronome vector mark in a `0..size` coordinate space.
String buildMetronomeGroupSvg({
  required double size,
  required bool monochrome,
}) {
  final w = size;
  final h = size;
  final stroke = monochrome ? '#000000' : logoPrimaryStrokeColor;
  final mint = monochrome ? '#000000' : logoAccentMintColor;
  final strokeW = w * 0.036;
  final thinStrokeW = w * 0.028;

  final bodyPath = _roundedTrapezoidPath(
    topLeft: _Pt(w * 0.415, h * 0.20),
    topRight: _Pt(w * 0.585, h * 0.20),
    bottomRight: _Pt(w * 0.745, h * 0.80),
    bottomLeft: _Pt(w * 0.255, h * 0.80),
    radius: w * 0.042,
  );

  final innerWindowPath = _roundedTrapezoidPath(
    topLeft: _Pt(w * 0.448, h * 0.262),
    topRight: _Pt(w * 0.552, h * 0.262),
    bottomRight: _Pt(w * 0.652, h * 0.635),
    bottomLeft: _Pt(w * 0.348, h * 0.635),
    radius: w * 0.018,
  );

  final capPath =
      'M ${_f(w * 0.415)},${_f(h * 0.20)} '
      'L ${_f(w * 0.486)},${_f(h * 0.142)} '
      'Q ${_f(w * 0.50)},${_f(h * 0.130)} ${_f(w * 0.514)},${_f(h * 0.142)} '
      'L ${_f(w * 0.585)},${_f(h * 0.20)} Z';

  final pivot = _Pt(w * 0.50, h * 0.635);
  final tip = _Pt(w * 0.715, h * 0.245);
  final weightCenter = _Pt.lerp(pivot, tip, 0.48);
  final angleDeg =
      math.atan2(tip.y - pivot.y, tip.x - pivot.x) * 180.0 / math.pi + 90.0;

  final dir = tip - pivot;
  final len = dir.length;
  final unit = _Pt(dir.x / len, dir.y / len);
  final normal = _Pt(unit.y, -unit.x);
  final offsetOut = _Pt(normal.x * w * 0.062, normal.y * w * 0.062);

  final dash1Start = _Pt.lerp(pivot, tip, 0.76) + offsetOut;
  final dash1End = _Pt.lerp(pivot, tip, 0.87) + offsetOut;
  final dash2Start = _Pt.lerp(pivot, tip, 0.92) + offsetOut;
  final dash2End = _Pt.lerp(pivot, tip, 0.97) + offsetOut;

  final clipId = monochrome ? 'bodyClipMono' : 'bodyClipColor';

  final buf = StringBuffer()
    ..writeln('    <defs>')
    ..writeln('      <clipPath id="$clipId">')
    ..writeln('        <path d="$bodyPath" />')
    ..writeln('      </clipPath>')
    ..writeln('    </defs>');

  // 1. Winding key on right side of base.
  if (!monochrome) {
    buf.writeln(
      '    <rect x="${_f(w * 0.72)}" y="${_f(h * 0.675)}" '
      'width="${_f(w * 0.075)}" height="${_f(h * 0.065)}" '
      'rx="${_f(w * 0.022)}" fill="$mint" />',
    );
  } else {
    buf.writeln(
      '    <rect x="${_f(w * 0.72)}" y="${_f(h * 0.675)}" '
      'width="${_f(w * 0.075)}" height="${_f(h * 0.065)}" '
      'rx="${_f(w * 0.022)}" fill="none" stroke="$stroke" '
      'stroke-width="${_f(w * 0.026)}" />',
    );
  }

  // 2. Feet under the base.
  for (final x in [w * 0.285, w * 0.625]) {
    buf.writeln(
      '    <rect x="${_f(x)}" y="${_f(h * 0.79)}" '
      'width="${_f(w * 0.09)}" height="${_f(h * 0.06)}" '
      'rx="${_f(w * 0.024)}" '
      'fill="${monochrome ? 'none' : mint}" '
      'stroke="$stroke" stroke-width="${_f(strokeW)}" stroke-linejoin="round" />',
    );
  }

  // 3. Main body fill & mint base band.
  if (!monochrome) {
    buf.writeln('    <path d="$bodyPath" fill="$logoBodyFillColor" />');
    buf.writeln(
      '    <rect x="0" y="${_f(h * 0.735)}" width="${_f(w)}" height="${_f(h * 0.08)}" '
      'fill="$mint" clip-path="url(#$clipId)" />',
    );
  }

  // 4. Top apex cap.
  buf.writeln(
    '    <path d="$capPath" fill="${monochrome ? 'none' : mint}" '
    'stroke="$stroke" stroke-width="${_f(strokeW)}" '
    'stroke-linecap="round" stroke-linejoin="round" />',
  );

  // Main body outline.
  buf.writeln(
    '    <path d="$bodyPath" fill="none" stroke="$stroke" '
    'stroke-width="${_f(strokeW)}" stroke-linecap="round" stroke-linejoin="round" />',
  );

  // 5. Inner window trapezoid.
  buf.writeln(
    '    <path d="$innerWindowPath" fill="none" stroke="$stroke" '
    'stroke-width="${_f(thinStrokeW)}" stroke-linecap="round" stroke-linejoin="round" />',
  );

  // 6. Horizontal base divider.
  buf.writeln(
    '    <line x1="${_f(w * 0.295)}" y1="${_f(h * 0.635)}" '
    'x2="${_f(w * 0.705)}" y2="${_f(h * 0.635)}" '
    'stroke="$stroke" stroke-width="${_f(thinStrokeW)}" stroke-linecap="round" />',
  );

  // 7. Center vertical scale rod.
  buf.writeln(
    '    <line x1="${_f(w * 0.50)}" y1="${_f(h * 0.262)}" '
    'x2="${_f(w * 0.50)}" y2="${_f(h * 0.605)}" '
    'stroke="$stroke" stroke-width="${_f(w * 0.026)}" stroke-linecap="round" />',
  );

  // 8. Pendulum arm (with subtle halo in color mode).
  if (!monochrome) {
    buf.writeln(
      '    <line x1="${_f(pivot.x)}" y1="${_f(pivot.y)}" '
      'x2="${_f(tip.x)}" y2="${_f(tip.y)}" '
      'stroke="$logoBackgroundColor" stroke-width="${_f(w * 0.062)}" stroke-linecap="round" />',
    );
  }
  buf.writeln(
    '    <line x1="${_f(pivot.x)}" y1="${_f(pivot.y)}" '
    'x2="${_f(tip.x)}" y2="${_f(tip.y)}" '
    'stroke="$stroke" stroke-width="${_f(w * 0.030)}" stroke-linecap="round" />',
  );

  // 9. Pendulum weight pill.
  buf.writeln(
    '    <g transform="translate(${_f(weightCenter.x)}, ${_f(weightCenter.y)}) rotate(${_f(angleDeg)})">',
  );
  if (!monochrome) {
    buf.writeln(
      '      <rect x="${_f(-w * 0.060)}" y="${_f(-w * 0.0735)}" '
      'width="${_f(w * 0.120)}" height="${_f(w * 0.147)}" '
      'rx="${_f(w * 0.040)}" fill="$logoBackgroundColor" />',
    );
  }
  buf.writeln(
    '      <rect x="${_f(-w * 0.044)}" y="${_f(-w * 0.0575)}" '
    'width="${_f(w * 0.088)}" height="${_f(w * 0.115)}" '
    'rx="${_f(w * 0.030)}" fill="$stroke" />',
  );
  if (!monochrome) {
    buf.writeln(
      '      <circle cx="0" cy="0" r="${_f(w * 0.014)}" fill="$mint" />',
    );
  }
  buf.writeln('    </g>');

  // 10. Dynamic rhythm motion capsules.
  for (final pair in [(dash1Start, dash1End), (dash2Start, dash2End)]) {
    buf.writeln(
      '    <line x1="${_f(pair.$1.x)}" y1="${_f(pair.$1.y)}" '
      'x2="${_f(pair.$2.x)}" y2="${_f(pair.$2.y)}" '
      'stroke="$mint" stroke-width="${_f(w * 0.022)}" stroke-linecap="round" />',
    );
  }

  return buf.toString();
}

String _roundedTrapezoidPath({
  required _Pt topLeft,
  required _Pt topRight,
  required _Pt bottomRight,
  required _Pt bottomLeft,
  required double radius,
}) {
  final pts = [topLeft, topRight, bottomRight, bottomLeft];
  final buf = StringBuffer();

  for (var i = 0; i < pts.length; i++) {
    final prev = pts[(i - 1 + pts.length) % pts.length];
    final curr = pts[i];
    final next = pts[(i + 1) % pts.length];

    final vPrev = prev - curr;
    final vNext = next - curr;
    final dPrev = vPrev.length;
    final dNext = vNext.length;

    final r = math.min(radius, math.min(dPrev, dNext) * 0.45);
    final pStart = curr + _Pt(vPrev.x / dPrev * r, vPrev.y / dPrev * r);
    final pEnd = curr + _Pt(vNext.x / dNext * r, vNext.y / dNext * r);

    if (i == 0) {
      buf.write('M ${_f(pStart.x)},${_f(pStart.y)} ');
    } else {
      buf.write('L ${_f(pStart.x)},${_f(pStart.y)} ');
    }
    buf.write('Q ${_f(curr.x)},${_f(curr.y)} ${_f(pEnd.x)},${_f(pEnd.y)} ');
  }

  buf.write('Z');
  return buf.toString();
}

String _f(double value) => value.toStringAsFixed(2);

class _Pt {
  const _Pt(this.x, this.y);
  final double x;
  final double y;

  double get length => math.sqrt(x * x + y * y);

  _Pt operator +(_Pt other) => _Pt(x + other.x, y + other.y);
  _Pt operator -(_Pt other) => _Pt(x - other.x, y - other.y);

  static _Pt lerp(_Pt a, _Pt b, double t) =>
      _Pt(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t);
}

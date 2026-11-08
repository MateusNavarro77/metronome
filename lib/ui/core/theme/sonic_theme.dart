import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Color tokens from `DESIGN.md` ("The Sonic Architect").
abstract final class SonicColors {
  /// Primary Neon Green (`#00FF41`) — Active states, Play button, kinetic accents, pulse beacons.
  static const Color primaryNeon = Color(0xFF00FF41);

  /// Primary Container (`#003907`) — Deep green underlayer, high-contrast icon fills.
  static const Color primaryContainer = Color(0xFF003907);

  /// Secondary soft green (`#9BD592`) — Secondary accents and medium beat highlights.
  static const Color secondaryGreen = Color(0xFF9BD592);

  /// Base Layer (`#0E0E0E`) — Deep Matte Black canvas floor.
  static const Color surfaceLowest = Color(0xFF0E0E0E);

  /// Section Layer (`#131313`) — Default background for section plates & rhythm containers.
  static const Color surfaceLow = Color(0xFF131313);

  /// Container Layer (`#201F1F`) — Intermediate elevated surface.
  static const Color surfaceContainer = Color(0xFF201F1F);

  /// Interaction Layer (`#2A2A2A`) — Secondary buttons and card-like containers.
  static const Color surfaceHigh = Color(0xFF2A2A2A);

  /// Highest Surface (`#363636`) — Inactive chips, toggle tracks, active selection backgrounds.
  static const Color surfaceHighest = Color(0xFF363636);

  /// Primary Typography & Icons (`#FFFFFF`).
  static const Color onSurfacePrimary = Color(0xFFFFFFFF);

  /// Muted Labels, secondary info, subdivision markers (`#888888`).
  static const Color onSurfaceMuted = Color(0xFF888888);

  /// Subtle ghost border (`rgba(255, 255, 255, 0.08)`) when identical surfaces need separation.
  static const Color ghostBorder = Color(0x14FFFFFF);

  /// Active neon ghost border (`rgba(0, 255, 65, 0.35)`).
  static const Color neonGhostBorder = Color(0x5900FF41);

  /// Radial glow behind the hero BPM (`rgba(0, 255, 65, 0.08)`).
  static const Color radialGlow = Color(0x1400FF41);

  /// Pulse button ambient glow (`rgba(0, 255, 65, 0.45)`).
  static const Color pulseGlow = Color(0x7300FF41);

  /// Error color (`#FFB4AB`).
  static const Color error = Color(0xFFFFB4AB);
}

/// Spacing & border radius tokens from `DESIGN.md`.
abstract final class SonicDimens {
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;
  static const double spaceXl = 40.0;

  static const double radiusSm = 8.0;
  static const double radiusDefault = 16.0;
  static const double radiusMd = 24.0;
  static const double radiusLg = 32.0;
  static const double radiusXl = 48.0;
  static const double radiusFull = 9999.0;

  static const double minTouchTarget = 48.0;
  static const double pulseButtonSize = 80.0;
}

/// Typography and ThemeData builder for "The Sonic Architect" (`DESIGN.md`).
abstract final class SonicTheme {
  static TextStyle _comfortaa({
    required double fontSize,
    required FontWeight fontWeight,
    required double height,
    double letterSpacing = 0.0,
    Color color = SonicColors.onSurfacePrimary,
  }) {
    return GoogleFonts.comfortaa(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  /// Display-LG (Hero BPM value: 64px / 4.0rem, weight 700, tracking -0.04em).
  static TextStyle get displayLg => _comfortaa(
    fontSize: 64,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: -2.5,
  );

  /// Headline-MD (Section headers / Time Signature: 28px / 1.75rem, weight 600).
  static TextStyle get headlineMd => _comfortaa(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.28,
    letterSpacing: -0.5,
  );

  /// Title-SM (Menu items / Modal titles: 16px / 1.0rem, weight 500).
  static TextStyle get titleSm => _comfortaa(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  /// Body-MD (Supporting text / Tempo Marking names: 14px / 0.875rem, weight 400).
  static TextStyle get bodyMd => _comfortaa(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.14,
  );

  /// Label-MD (All-caps metadata/labels: 12px / 0.75rem, weight 600, tracking 0.12em).
  static TextStyle get labelMd => _comfortaa(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: 1.44,
    color: SonicColors.onSurfaceMuted,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: SonicColors.surfaceLowest,
      fontFamily: GoogleFonts.comfortaa().fontFamily,
      colorScheme: const ColorScheme.dark(
        surface: SonicColors.surfaceLow,
        onSurface: SonicColors.onSurfacePrimary,
        primary: SonicColors.primaryNeon,
        onPrimary: SonicColors.primaryContainer,
        primaryContainer: SonicColors.primaryContainer,
        onPrimaryContainer: SonicColors.primaryNeon,
        secondary: SonicColors.secondaryGreen,
        onSecondary: SonicColors.primaryContainer,
        error: SonicColors.error,
      ),
      textTheme: TextTheme(
        displayLarge: displayLg,
        headlineMedium: headlineMd,
        titleSmall: titleSm,
        bodyMedium: bodyMd,
        labelMedium: labelMd,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: SonicColors.primaryNeon,
        inactiveTrackColor: SonicColors.surfaceHigh,
        thumbColor: SonicColors.primaryNeon,
        overlayColor: SonicColors.radialGlow,
        trackHeight: 6.0,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
      ),
    );
  }
}

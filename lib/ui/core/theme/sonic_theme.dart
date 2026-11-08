import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Semantic color tokens implementing [ThemeExtension] for dynamic theming
/// across Light and Dark editions of "The Sonic Architect".
@immutable
class SonicColorsExtension extends ThemeExtension<SonicColorsExtension> {
  const SonicColorsExtension({
    required this.primaryAccent,
    required this.onPrimaryAccent,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondaryAccent,
    required this.surfaceLowest,
    required this.surfaceLow,
    required this.surfaceContainer,
    required this.surfaceHigh,
    required this.surfaceHighest,
    required this.onSurfacePrimary,
    required this.onSurfaceMuted,
    required this.ghostBorder,
    required this.neonGhostBorder,
    required this.radialGlow,
    required this.radialGlowDownbeat,
    required this.pulseGlow,
    required this.pulseGlowIdle,
    required this.error,
  });

  /// Primary Accent — active play state, kinetic highlights, pulse beacons.
  final Color primaryAccent;

  /// Foreground color on [primaryAccent] (e.g. icon/text on Play button).
  final Color onPrimaryAccent;

  /// Primary Container — active capsule background, contrast backing.
  final Color primaryContainer;

  /// On Primary Container — foreground element on primary container.
  final Color onPrimaryContainer;

  /// Secondary Accent — medium beat accents, secondary markers.
  final Color secondaryAccent;

  /// Base Canvas Floor (`surfaceLowest`).
  final Color surfaceLowest;

  /// Section Layer Plates (`surfaceLow`).
  final Color surfaceLow;

  /// Elevated Content Containers (`surfaceContainer`).
  final Color surfaceContainer;

  /// Interaction Layer (`surfaceHigh`) — secondary buttons, inactive cards.
  final Color surfaceHigh;

  /// Highest Surface (`surfaceHighest`) — inactive chips, active selections.
  final Color surfaceHighest;

  /// Primary Typography & Iconography.
  final Color onSurfacePrimary;

  /// Muted Text, Labels, Secondary metadata.
  final Color onSurfaceMuted;

  /// Subtle ghost outline for identical surface separation.
  final Color ghostBorder;

  /// Active selection ghost border ring.
  final Color neonGhostBorder;

  /// Ambient glow behind the tempo hero indicator.
  final Color radialGlow;

  /// Enhanced flash radial glow on downbeats.
  final Color radialGlowDownbeat;

  /// Ambient glow around the active Pulse (Play) button.
  final Color pulseGlow;

  /// Resting subtle glow around the stopped Pulse (Play) button.
  final Color pulseGlowIdle;

  /// Error & warning accent.
  final Color error;

  /// Dark theme token instance (`specs/DESIGN_DARK.md`).
  static const dark = SonicColorsExtension(
    primaryAccent: Color(0xFF00FF41),
    onPrimaryAccent: Color(0xFF003907),
    primaryContainer: Color(0xFF003907),
    onPrimaryContainer: Color(0xFF00FF41),
    secondaryAccent: Color(0xFF9BD592),
    surfaceLowest: Color(0xFF0E0E0E),
    surfaceLow: Color(0xFF131313),
    surfaceContainer: Color(0xFF201F1F),
    surfaceHigh: Color(0xFF2A2A2A),
    surfaceHighest: Color(0xFF363636),
    onSurfacePrimary: Color(0xFFFFFFFF),
    onSurfaceMuted: Color(0xFF888888),
    ghostBorder: Color(0x14FFFFFF),
    neonGhostBorder: Color(0x5900FF41),
    radialGlow: Color(0x1400FF41),
    radialGlowDownbeat: Color(0x2800FF41),
    pulseGlow: Color(0x7300FF41),
    pulseGlowIdle: Color(0x3300FF41),
    error: Color(0xFFFFB4AB),
  );

  /// Light theme token instance (`specs/DESIGN_LIGHT.md`).
  static const light = SonicColorsExtension(
    primaryAccent: Color(0xFF00B834),
    onPrimaryAccent: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFDCF7DF),
    onPrimaryContainer: Color(0xFF004D14),
    secondaryAccent: Color(0xFF2E7D32),
    surfaceLowest: Color(0xFFF7F7F6),
    surfaceLow: Color(0xFFFFFFFF),
    surfaceContainer: Color(0xFFEAEAE8),
    surfaceHigh: Color(0xFFE0E0DD),
    surfaceHighest: Color(0xFFD5D5D1),
    onSurfacePrimary: Color(0xFF121212),
    onSurfaceMuted: Color(0xFF6C6C68),
    ghostBorder: Color(0x14000000),
    neonGhostBorder: Color(0x5900B834),
    radialGlow: Color(0x1A00B834),
    radialGlowDownbeat: Color(0x3300B834),
    pulseGlow: Color(0x4D00B834),
    pulseGlowIdle: Color(0x2600B834),
    error: Color(0xFFBA1A1A),
  );

  @override
  SonicColorsExtension copyWith({
    Color? primaryAccent,
    Color? onPrimaryAccent,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? secondaryAccent,
    Color? surfaceLowest,
    Color? surfaceLow,
    Color? surfaceContainer,
    Color? surfaceHigh,
    Color? surfaceHighest,
    Color? onSurfacePrimary,
    Color? onSurfaceMuted,
    Color? ghostBorder,
    Color? neonGhostBorder,
    Color? radialGlow,
    Color? radialGlowDownbeat,
    Color? pulseGlow,
    Color? pulseGlowIdle,
    Color? error,
  }) {
    return SonicColorsExtension(
      primaryAccent: primaryAccent ?? this.primaryAccent,
      onPrimaryAccent: onPrimaryAccent ?? this.onPrimaryAccent,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      secondaryAccent: secondaryAccent ?? this.secondaryAccent,
      surfaceLowest: surfaceLowest ?? this.surfaceLowest,
      surfaceLow: surfaceLow ?? this.surfaceLow,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      surfaceHigh: surfaceHigh ?? this.surfaceHigh,
      surfaceHighest: surfaceHighest ?? this.surfaceHighest,
      onSurfacePrimary: onSurfacePrimary ?? this.onSurfacePrimary,
      onSurfaceMuted: onSurfaceMuted ?? this.onSurfaceMuted,
      ghostBorder: ghostBorder ?? this.ghostBorder,
      neonGhostBorder: neonGhostBorder ?? this.neonGhostBorder,
      radialGlow: radialGlow ?? this.radialGlow,
      radialGlowDownbeat: radialGlowDownbeat ?? this.radialGlowDownbeat,
      pulseGlow: pulseGlow ?? this.pulseGlow,
      pulseGlowIdle: pulseGlowIdle ?? this.pulseGlowIdle,
      error: error ?? this.error,
    );
  }

  @override
  SonicColorsExtension lerp(
    ThemeExtension<SonicColorsExtension>? other,
    double t,
  ) {
    if (other is! SonicColorsExtension) return this;
    return SonicColorsExtension(
      primaryAccent: Color.lerp(primaryAccent, other.primaryAccent, t)!,
      onPrimaryAccent: Color.lerp(onPrimaryAccent, other.onPrimaryAccent, t)!,
      primaryContainer: Color.lerp(
        primaryContainer,
        other.primaryContainer,
        t,
      )!,
      onPrimaryContainer: Color.lerp(
        onPrimaryContainer,
        other.onPrimaryContainer,
        t,
      )!,
      secondaryAccent: Color.lerp(secondaryAccent, other.secondaryAccent, t)!,
      surfaceLowest: Color.lerp(surfaceLowest, other.surfaceLowest, t)!,
      surfaceLow: Color.lerp(surfaceLow, other.surfaceLow, t)!,
      surfaceContainer: Color.lerp(
        surfaceContainer,
        other.surfaceContainer,
        t,
      )!,
      surfaceHigh: Color.lerp(surfaceHigh, other.surfaceHigh, t)!,
      surfaceHighest: Color.lerp(surfaceHighest, other.surfaceHighest, t)!,
      onSurfacePrimary: Color.lerp(
        onSurfacePrimary,
        other.onSurfacePrimary,
        t,
      )!,
      onSurfaceMuted: Color.lerp(onSurfaceMuted, other.onSurfaceMuted, t)!,
      ghostBorder: Color.lerp(ghostBorder, other.ghostBorder, t)!,
      neonGhostBorder: Color.lerp(neonGhostBorder, other.neonGhostBorder, t)!,
      radialGlow: Color.lerp(radialGlow, other.radialGlow, t)!,
      radialGlowDownbeat: Color.lerp(
        radialGlowDownbeat,
        other.radialGlowDownbeat,
        t,
      )!,
      pulseGlow: Color.lerp(pulseGlow, other.pulseGlow, t)!,
      pulseGlowIdle: Color.lerp(pulseGlowIdle, other.pulseGlowIdle, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }
}

/// Spacing, border radius, and component measure tokens from "The Sonic Architect".
class SonicDimens {
  const SonicDimens();

  // Spacing
  final double spaceXs = 4.0;
  final double spaceSm = 8.0;
  final double spaceSmPlus2 = 10.0;
  final double spaceSmPlus4 = 12.0;
  final double spaceMd = 16.0;
  final double spaceLg = 24.0;
  final double spaceXl = 40.0;

  // Border Radii
  final double radiusSm = 8.0;
  final double radiusDefault = 16.0;
  final double radiusMd = 24.0;
  final double radiusLg = 32.0;
  final double radiusXl = 48.0;
  final double radiusFull = 9999.0;

  // Component Metrics & Touch Targets
  final double minTouchTarget = 48.0;
  final double pulseButtonSize = 80.0;
  final double pulseButtonSizeCompact = 72.0;
  final double tapTempoHeight = 68.0;
  final double tapTempoHeightCompact = 56.0;
  final double stepperButtonSize = 56.0;
  final double stepperIconSize = 28.0;
  final double badgeDotSize = 8.0;
  final double badgeSpacing = 6.0;
  final double sliderTrackHeight = 6.0;
  final double sliderThumbRadius = 10.0;
  final double maxContentWidth = 560.0;
  final double wideBreakpoint = 680.0;
  final double compactHeightBreakpoint = 680.0;
  final double beatPillContainerHeight = 40.0;
  final double beatCapsuleActiveDownbeat = 38.0;
  final double beatCapsuleInactiveDownbeat = 32.0;
  final double beatCapsuleActiveRegular = 28.0;
  final double beatCapsuleInactiveRegular = 22.0;
  final double subdivisionPulseActiveWidth = 14.0;
  final double subdivisionPulseInactiveWidth = 8.0;
  final double subdivisionPulseHeight = 6.0;

  static const SonicDimens instance = SonicDimens();
}

/// Helper BuildContext extension for effortless typed access to tokens, colors,
/// text themes, and dimensions.
extension SonicContextTheme on BuildContext {
  /// Custom semantic colors for the active theme (`light` or `dark`).
  SonicColorsExtension get colors =>
      Theme.of(this).extension<SonicColorsExtension>() ??
      SonicColorsExtension.dark;

  /// Spatial, radius, and sizing tokens.
  SonicDimens get dimens => SonicDimens.instance;

  /// Current [ThemeData].
  ThemeData get theme => Theme.of(this);

  /// Current [ColorScheme].
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Current [TextTheme].
  TextTheme get textTheme => Theme.of(this).textTheme;
}

/// ThemeData builder for "The Sonic Architect" Light & Dark editions.
abstract final class SonicTheme {
  static TextStyle _comfortaa({
    required double fontSize,
    required FontWeight fontWeight,
    required double height,
    double letterSpacing = 0.0,
    required Color color,
  }) {
    return GoogleFonts.comfortaa(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  /// Dark Theme builder (`specs/DESIGN_DARK.md`).
  static ThemeData get darkTheme {
    const c = SonicColorsExtension.dark;
    final baseFontFamily = GoogleFonts.comfortaa().fontFamily;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: c.surfaceLowest,
      fontFamily: baseFontFamily,
      extensions: const <ThemeExtension<dynamic>>[c],
      colorScheme: ColorScheme.dark(
        surface: c.surfaceLow,
        onSurface: c.onSurfacePrimary,
        primary: c.primaryAccent,
        onPrimary: c.primaryContainer,
        primaryContainer: c.primaryContainer,
        onPrimaryContainer: c.primaryAccent,
        secondary: c.secondaryAccent,
        onSecondary: c.primaryContainer,
        error: c.error,
      ),
      textTheme: TextTheme(
        displayLarge: _comfortaa(
          fontSize: 64,
          fontWeight: FontWeight.w700,
          height: 1.0,
          letterSpacing: -2.5,
          color: c.onSurfacePrimary,
        ),
        headlineMedium: _comfortaa(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          height: 1.28,
          letterSpacing: -0.5,
          color: c.onSurfacePrimary,
        ),
        titleSmall: _comfortaa(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.5,
          color: c.onSurfacePrimary,
        ),
        bodyMedium: _comfortaa(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
          letterSpacing: 0.14,
          color: c.onSurfacePrimary,
        ),
        labelMedium: _comfortaa(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.33,
          letterSpacing: 1.44,
          color: c.onSurfaceMuted,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: c.primaryAccent,
        inactiveTrackColor: c.surfaceHigh,
        thumbColor: c.primaryAccent,
        overlayColor: c.radialGlow,
        trackHeight: SonicDimens.instance.sliderTrackHeight,
        thumbShape: RoundSliderThumbShape(
          enabledThumbRadius: SonicDimens.instance.sliderThumbRadius,
        ),
      ),
    );
  }

  /// Light Theme builder (`specs/DESIGN_LIGHT.md`).
  static ThemeData get lightTheme {
    const c = SonicColorsExtension.light;
    final baseFontFamily = GoogleFonts.comfortaa().fontFamily;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: c.surfaceLowest,
      fontFamily: baseFontFamily,
      extensions: const <ThemeExtension<dynamic>>[c],
      colorScheme: ColorScheme.light(
        surface: c.surfaceLow,
        onSurface: c.onSurfacePrimary,
        primary: c.primaryAccent,
        onPrimary: Colors.white,
        primaryContainer: c.primaryContainer,
        onPrimaryContainer: c.onPrimaryContainer,
        secondary: c.secondaryAccent,
        onSecondary: Colors.white,
        error: c.error,
      ),
      textTheme: TextTheme(
        displayLarge: _comfortaa(
          fontSize: 64,
          fontWeight: FontWeight.w700,
          height: 1.0,
          letterSpacing: -2.5,
          color: c.onSurfacePrimary,
        ),
        headlineMedium: _comfortaa(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          height: 1.28,
          letterSpacing: -0.5,
          color: c.onSurfacePrimary,
        ),
        titleSmall: _comfortaa(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.5,
          color: c.onSurfacePrimary,
        ),
        bodyMedium: _comfortaa(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
          letterSpacing: 0.14,
          color: c.onSurfacePrimary,
        ),
        labelMedium: _comfortaa(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.33,
          letterSpacing: 1.44,
          color: c.onSurfaceMuted,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: c.primaryAccent,
        inactiveTrackColor: c.surfaceHigh,
        thumbColor: c.primaryAccent,
        overlayColor: c.radialGlow,
        trackHeight: SonicDimens.instance.sliderTrackHeight,
        thumbShape: RoundSliderThumbShape(
          enabledThumbRadius: SonicDimens.instance.sliderThumbRadius,
        ),
      ),
    );
  }
}

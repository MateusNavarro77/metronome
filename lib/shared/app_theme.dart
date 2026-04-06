import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metronome/shared/theme_colors.dart';

/// Centralized theme construction following the "Sonic Architect" design system.
///
/// Provides [darkTheme] and [lightTheme] as complete [ThemeData] objects
/// that encode every specification from DESIGN.md.
abstract class AppTheme {
  // ───────────────────────────────────────────────
  //  DARK THEME
  // ───────────────────────────────────────────────

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: ThemeColors.neonGreen,
      onPrimary: ThemeColors.deepGreen,
      secondary: ThemeColors.neonGreen,
      onSecondary: ThemeColors.deepGreen,
      error: const Color(0xFFCF6679),
      onError: Colors.black,
      surface: ThemeColors.surfaceLow,
      onSurface: ThemeColors.onSurface,
      onSurfaceVariant: ThemeColors.onSurfaceMuted,
      surfaceContainerLowest: ThemeColors.surfaceLowest,
      surfaceContainerLow: ThemeColors.surfaceLow,
      surfaceContainerHigh: ThemeColors.surfaceHigh,
      surfaceContainerHighest: const Color(0xFF363636),
      outline: Colors.white.withValues(alpha: 0.15),
      outlineVariant: Colors.white.withValues(alpha: 0.08),
    );

    return _buildTheme(colorScheme);
  }

  // ───────────────────────────────────────────────
  //  LIGHT THEME
  // ───────────────────────────────────────────────

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: ThemeColors.lightPrimary,
      onPrimary: Colors.white,
      secondary: ThemeColors.lightPrimary,
      onSecondary: Colors.white,
      error: const Color(0xFFB00020),
      onError: Colors.white,
      surface: ThemeColors.lightSurface,
      onSurface: ThemeColors.lightOnSurface,
      onSurfaceVariant: ThemeColors.lightOnSurfaceMuted,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: ThemeColors.lightSurfaceLow,
      surfaceContainerHigh: ThemeColors.lightSurfaceHigh,
      surfaceContainerHighest: const Color(0xFFD6D6D6),
      outline: Colors.black.withValues(alpha: 0.12),
      outlineVariant: Colors.black.withValues(alpha: 0.06),
    );

    return _buildTheme(colorScheme);
  }

  // ───────────────────────────────────────────────
  //  SHARED BUILDER
  // ───────────────────────────────────────────────

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final bool isDark = colorScheme.brightness == Brightness.dark;
    final textTheme = _buildTextTheme(colorScheme);

    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme,

      // ── App Bar ──
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.headlineMedium,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),

      // ── No-Line Rule: transparent dividers ──
      dividerColor: Colors.transparent,
      dividerTheme: const DividerThemeData(color: Colors.transparent),

      // ── FAB ("Pulse Button") ──
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: const StadiumBorder(),
      ),

      // ── Icon Buttons ──
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(
            colorScheme.surfaceContainerHigh,
          ),
          foregroundColor: WidgetStatePropertyAll(colorScheme.onSurface),
          shape: const WidgetStatePropertyAll(CircleBorder()),
          padding: const WidgetStatePropertyAll(EdgeInsets.all(12)),
        ),
      ),

      // ── Slider ──
      sliderTheme: SliderThemeData(
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.surfaceContainerHigh,
        thumbColor: colorScheme.primary,
        overlayColor: colorScheme.primary.withValues(alpha: 0.12),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
      ),

      // ── Switch ──
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.onSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary.withValues(alpha: 0.4);
          }
          return colorScheme.surfaceContainerHigh;
        }),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),

      // ── Bottom Sheet (Glassmorphism) ──
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor:
            isDark
                ? colorScheme.surfaceContainerHigh.withValues(alpha: 0.85)
                : colorScheme.surfaceContainerLow.withValues(alpha: 0.92),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        elevation: 0,
        modalBarrierColor: Colors.black.withValues(alpha: 0.5),
      ),

      // ── Card (Monolithic Surfaces) ──
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerHigh,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // ── Tooltip ──
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyle(color: colorScheme.onSurface, fontSize: 12),
      ),
    );
  }

  // ───────────────────────────────────────────────
  //  TYPOGRAPHY
  // ───────────────────────────────────────────────

  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    final spaceGrotesk = GoogleFonts.spaceGroteskTextTheme();
    final inter = GoogleFonts.interTextTheme();

    return TextTheme(
      // Display — BPM Value (hero element)
      displayLarge: spaceGrotesk.displayLarge!.copyWith(
        fontSize: 56,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
        height: 1.1,
      ),

      // Headline — Section Headers
      headlineMedium: spaceGrotesk.headlineMedium!.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),

      // Title — Menu Items / Modal Titles
      titleSmall: inter.titleSmall!.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),

      // Body — Supporting Text
      bodyMedium: inter.bodyMedium!.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      bodySmall: inter.bodySmall!.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurfaceVariant,
      ),

      // Label — Uppercase metadata/labels
      labelMedium: spaceGrotesk.labelMedium!.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurfaceVariant,
        letterSpacing: 1.5,
      ),
      labelSmall: spaceGrotesk.labelSmall!.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurfaceVariant,
        letterSpacing: 1.2,
      ),
    );
  }
}

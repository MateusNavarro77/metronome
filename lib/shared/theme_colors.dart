import 'package:flutter/material.dart';

/// Raw design-system color constants from DESIGN.md ("The Sonic Architect").
///
/// Use these for direct color references in glow effects, shadow tints,
/// and other places where [Theme.of(context)] isn't ergonomic.
/// For standard widget styling, prefer [Theme.of(context).colorScheme].
abstract class ThemeColors {
  // ─── Core Brand Palette (Dark) ───
  static const Color neonGreen = Color(0xFF00FF41);
  static const Color deepGreen = Color(0xFF003907);
  static const Color surfaceLowest = Color(0xFF0E0E0E);
  static const Color surfaceLow = Color(0xFF131313);
  static const Color surfaceHigh = Color(0xFF2A2A2A);
  static const Color onSurface = Color(0xFFFFFFFF);
  static const Color onSurfaceMuted = Color(0xFF888888);

  // ─── Core Brand Palette (Light) ───
  static const Color lightPrimary = Color(0xFF00C234);
  static const Color lightSurface = Color(0xFFF5F5F5);
  static const Color lightSurfaceLow = Color(0xFFEDEDED);
  static const Color lightSurfaceHigh = Color(0xFFE0E0E0);
  static const Color lightOnSurface = Color(0xFF1A1A1A);
  static const Color lightOnSurfaceMuted = Color(0xFF6B6B6B);
}

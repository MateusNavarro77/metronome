import 'package:google_fonts/google_fonts.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart'
    hide CornerRounding, RoundedPolygon;

/// Metronome-specific layout metrics, breakpoints, and shared spacing/radius
/// constants used alongside [M3EThemeData].
class MetronomeDimens {
  const MetronomeDimens();

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
  final double pulseButtonSize = 96.0;
  final double pulseButtonSizeCompact = 80.0;
  final double tapTempoHeight = 96.0;
  final double tapTempoHeightCompact = 80.0;
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

  static const MetronomeDimens instance = MetronomeDimens();
}

/// Helper [BuildContext] extension for typed access to Material 3 Expressive
/// theme tokens, standard [ColorScheme] / [TextTheme], and [MetronomeDimens].
extension MetronomeContextTheme on BuildContext {
  /// Nearest [M3EThemeData] tokens.
  M3EThemeData get m3e => M3ETheme.of(this);

  /// Metronome-specific layout, radius, and sizing tokens.
  MetronomeDimens get dimens => MetronomeDimens.instance;

  /// Current [ThemeData].
  ThemeData get theme => Theme.of(this);

  /// Current [ColorScheme].
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Current [TextTheme].
  TextTheme get textTheme => Theme.of(this).textTheme;
}

/// Material 3 Expressive theme builder for the Metronome app.
abstract final class AppTheme {
  /// Baseline seed color (`#6750A4`).
  static const Color seedColor = Color(0xFF6750A4);

  static M3ETypography _buildComfortaaTypography() {
    final baseline = M3ETypeScale.fromTextTheme(
      GoogleFonts.comfortaaTextTheme(M3ETypeScale.baseline().toTextTheme()),
    );
    final emphasized = M3ETypeScale.fromTextTheme(
      GoogleFonts.comfortaaTextTheme(M3ETypeScale.emphasized().toTextTheme()),
    );
    return M3ETypography(baseline: baseline, emphasized: emphasized);
  }

  /// Light [M3EThemeData] seeded from [seedColor] with Comfortaa typography.
  static M3EThemeData get lightThemeData =>
      M3EThemeData.light(seedColor: seedColor)
          .copyWith(typography: _buildComfortaaTypography());

  /// Dark [M3EThemeData] seeded from [seedColor] with Comfortaa typography.
  static M3EThemeData get darkThemeData =>
      M3EThemeData.dark(seedColor: seedColor)
          .copyWith(typography: _buildComfortaaTypography());

  /// Material [ThemeData] projection of [lightThemeData].
  static ThemeData get lightTheme => lightThemeData.toThemeData();

  /// Material [ThemeData] projection of [darkThemeData].
  static ThemeData get darkTheme => darkThemeData.toThemeData();
}

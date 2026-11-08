/// Domain representation of available application theme modes (specs/DESIGN_DARK.md, specs/DESIGN_LIGHT.md).
///
/// Kept as pure Dart with zero Flutter dependencies (NFR-MAN-01).
enum AppThemeMode {
  system,
  light,
  dark;

  /// Human-readable display label.
  String get label {
    switch (this) {
      case AppThemeMode.system:
        return 'System';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
    }
  }
}

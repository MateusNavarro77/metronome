/// Domain representation of supported application language preferences.
///
/// Kept as pure Dart with zero Flutter dependencies (NFR-MAN-01).
enum const AppLanguage(final String code) {
  system('system'),
  english('en'),
  portuguese('pt');

  /// Resolves an [AppLanguage] from its persisted [code], defaulting to
  /// [AppLanguage.system].
  static AppLanguage fromCode(String? code) {
    return switch (code) {
      'en' => AppLanguage.english,
      'pt' => AppLanguage.portuguese,
      _ => AppLanguage.system,
    };
  }
}

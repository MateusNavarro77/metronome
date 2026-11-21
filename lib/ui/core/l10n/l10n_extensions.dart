import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' show GlobalMaterialLocalizations;

import '../../../domain/models/app_language.dart';
import '../../../domain/models/app_theme_mode.dart';
import '../../../domain/models/metronome_sound.dart';
import '../../../domain/models/preset.dart';
import '../../../domain/models/setlist.dart';
import '../../../domain/models/subdivision.dart';
import '../../../domain/models/time_signature.dart';
import '../../../l10n/app_localizations.dart';

/// Combined localization delegates for [AppLocalizations] and `material_ui`.
///
/// `material_ui` defines its own [GlobalMaterialLocalizations.delegates] for
/// `MaterialLocalizations` and `CupertinoLocalizations` in Flutter 3.50+.
const List<LocalizationsDelegate<dynamic>> appLocalizationsDelegates = [
  AppLocalizations.delegate,
  ...GlobalMaterialLocalizations.delegates,
];

/// Convenient typed [AppLocalizations] lookup on [BuildContext].
extension L10nBuildContext on BuildContext {
  /// Nearest [AppLocalizations] instance for the active locale.
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Localized display labels for [AppThemeMode].
extension AppThemeModeL10n on AppThemeMode {
  String localizedLabel(AppLocalizations l10n) {
    return switch (this) {
      AppThemeMode.system => l10n.themeModeSystem,
      AppThemeMode.light => l10n.themeModeLight,
      AppThemeMode.dark => l10n.themeModeDark,
    };
  }
}

/// Localized display labels for [AppLanguage].
extension AppLanguageL10n on AppLanguage {
  String localizedLabel(AppLocalizations l10n) {
    return switch (this) {
      AppLanguage.system => l10n.languageSystem,
      AppLanguage.english => l10n.languageEnglish,
      AppLanguage.portuguese => l10n.languagePortuguese,
    };
  }
}

/// Localized display labels and accessible descriptions for [MetronomeSound].
extension MetronomeSoundL10n on MetronomeSound {
  String localizedLabel(AppLocalizations l10n) {
    return switch (this) {
      MetronomeSound.click => l10n.soundClickLabel,
      MetronomeSound.woodBlock => l10n.soundWoodBlockLabel,
      MetronomeSound.beep => l10n.soundBeepLabel,
      MetronomeSound.drums => l10n.soundDrumsLabel,
    };
  }

  String localizedDescription(AppLocalizations l10n) {
    return switch (this) {
      MetronomeSound.click => l10n.soundClickDescription,
      MetronomeSound.woodBlock => l10n.soundWoodBlockDescription,
      MetronomeSound.beep => l10n.soundBeepDescription,
      MetronomeSound.drums => l10n.soundDrumsDescription,
    };
  }
}

/// Localized display labels for [Subdivision].
extension SubdivisionL10n on Subdivision {
  String localizedLabel(AppLocalizations l10n) {
    return switch (this) {
      Subdivision.none => l10n.subdivisionQuarter,
      Subdivision.eighth => l10n.subdivisionEighths,
      Subdivision.triplet => l10n.subdivisionTriplets,
      Subdivision.sixteenth => l10n.subdivisionSixteenths,
    };
  }
}

/// Localized display labels for [BeatAccent].
extension BeatAccentL10n on BeatAccent {
  String localizedLabel(AppLocalizations l10n) {
    return switch (this) {
      BeatAccent.strong => l10n.beatAccentStrong,
      BeatAccent.medium => l10n.beatAccentMedium,
      BeatAccent.weak => l10n.beatAccentWeak,
      BeatAccent.subdivision => l10n.beatAccentSubdivision,
    };
  }
}

/// Localized display name helpers for [Preset].
extension PresetL10n on Preset {
  String displayName(AppLocalizations l10n) =>
      name.isEmpty ? l10n.untitledPreset : name;
}

/// Localized display name helpers for [Setlist].
extension SetlistL10n on Setlist {
  String displayName(AppLocalizations l10n) =>
      name.isEmpty ? l10n.untitledSetlist : name;
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Metronome';

  @override
  String get navMetronome => 'Metronome';

  @override
  String get navPresets => 'Presets';

  @override
  String get navSetlists => 'Setlists';

  @override
  String get navSettings => 'Settings';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get create => 'Create';

  @override
  String get delete => 'Delete';

  @override
  String get activeBadge => 'ACTIVE';

  @override
  String get bpmUnit => 'BPM';

  @override
  String get untitledPreset => 'Untitled Preset';

  @override
  String get untitledSetlist => 'Untitled Setlist';

  @override
  String presetCopyName(String originalName) {
    return '$originalName (Copy)';
  }

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get soundClickLabel => 'Click';

  @override
  String get soundClickDescription => 'Crisp studio precision click';

  @override
  String get soundWoodBlockLabel => 'Wood Block';

  @override
  String get soundWoodBlockDescription => 'Warm resonant wooden block';

  @override
  String get soundBeepLabel => 'Beep';

  @override
  String get soundBeepDescription => 'Clear digital metronome tone';

  @override
  String get soundDrumsLabel => 'Drums';

  @override
  String get soundDrumsDescription => 'Acoustic kick, rim & hi-hat';

  @override
  String get subdivisionQuarter => 'Quarter';

  @override
  String get subdivisionEighths => 'Eighths';

  @override
  String get subdivisionTriplets => 'Triplets';

  @override
  String get subdivisionSixteenths => 'Sixteenths';

  @override
  String pulsesPerBeat(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pulses per beat',
      one: '1 pulse per beat',
    );
    return '$_temp0';
  }

  @override
  String subdivisionOptionSemantics(String label, int count) {
    return 'Subdivision $label ($count per beat)';
  }

  @override
  String get beatAccentStrong => 'Strong';

  @override
  String get beatAccentMedium => 'Medium';

  @override
  String get beatAccentWeak => 'Weak';

  @override
  String get beatAccentSubdivision => 'Subdivision';

  @override
  String get metronomeHeader => 'METRONOME';

  @override
  String get savePresetAction => 'Save Preset';

  @override
  String savedPresetSnackbar(String name) {
    return 'Saved preset \"$name\"';
  }

  @override
  String beatIndicatorPlayingSemantics(int beat, int total) {
    return 'Beat $beat of $total';
  }

  @override
  String beatIndicatorStoppedSemantics(int beatCount) {
    String _temp0 = intl.Intl.pluralLogic(
      beatCount,
      locale: localeName,
      other: '$beatCount beats',
      one: '1 beat',
    );
    return 'Pulse indicator stopped, $_temp0 per bar';
  }

  @override
  String get decreaseBpmSemantics => 'Decrease BPM by 1';

  @override
  String get increaseBpmSemantics => 'Increase BPM by 1';

  @override
  String bpmValueSemantics(int bpm, String tempoMarking) {
    return '$bpm beats per minute, $tempoMarking';
  }

  @override
  String get bpmSliderSemantics => 'BPM quick adjust slider';

  @override
  String bpmWithUnit(int bpm) {
    return '$bpm BPM';
  }

  @override
  String get tapTempoSemantics => 'Tap tempo';

  @override
  String get tapTempoLabel => 'TAP TEMPO';

  @override
  String get stopMetronomeSemantics => 'Stop metronome';

  @override
  String get startMetronomeSemantics => 'Start metronome';

  @override
  String get timeSignatureCaption => 'TIME SIG';

  @override
  String timeSignatureSelectorSemantics(String label) {
    return 'Time signature $label. Tap to change.';
  }

  @override
  String get subdivisionCaption => 'SUBDIVISION';

  @override
  String subdivisionSelectorSemantics(String label) {
    return 'Subdivision $label. Tap to change.';
  }

  @override
  String get downbeatAccentOnTooltip => 'Downbeat accent ON';

  @override
  String get downbeatAccentOffTooltip => 'Downbeat accent OFF';

  @override
  String get downbeatAccentOnSemantics => 'Accent on Beat 1 enabled';

  @override
  String get downbeatAccentOffSemantics => 'Accent on Beat 1 disabled';

  @override
  String get timeSignatureSheetTitle => 'TIME SIGNATURE';

  @override
  String get timeSignaturePresetsSection => 'PRESETS';

  @override
  String timeSignatureOptionSemantics(String label) {
    return 'Time signature $label';
  }

  @override
  String get customMeterSection => 'CUSTOM METER';

  @override
  String get beatsPerBarLabel => 'BEATS PER BAR';

  @override
  String get numeratorRangeLabel => 'Numerator (1–16)';

  @override
  String get decreaseBeatsPerBarSemantics => 'Decrease beats per bar';

  @override
  String get increaseBeatsPerBarSemantics => 'Increase beats per bar';

  @override
  String get noteValueDenominatorLabel => 'NOTE VALUE (DENOMINATOR)';

  @override
  String denominatorSemantics(int denom) {
    return 'Denominator $denom';
  }

  @override
  String get subdivisionsSheetTitle => 'SUBDIVISIONS';

  @override
  String get nextBarBadge => 'NEXT BAR';

  @override
  String get exitSetlistTooltip => 'Exit setlist';

  @override
  String get previousSongSemantics => 'Previous song in setlist';

  @override
  String get nextSongSemantics => 'Next song in setlist';

  @override
  String setlistPosition(int current, int total) {
    return '$current of $total';
  }

  @override
  String get preferencesHeader => 'PREFERENCES';

  @override
  String get backToMetronomeTooltip => 'Back to metronome';

  @override
  String get appearanceSectionHeader => 'APPEARANCE';

  @override
  String get appearanceDescription =>
      'Choose between dark mode, light mode, or match your device system appearance.';

  @override
  String get languageSectionHeader => 'LANGUAGE';

  @override
  String get languageDescription =>
      'Choose the app language or follow your device system language.';

  @override
  String get soundsSectionHeader => 'SOUNDS & VOLUMES';

  @override
  String get soundsDescription =>
      'Select the click timbre, balance strong, weak, and subdivision volumes, or mute audio while keeping the visual pulse.';

  @override
  String get muteAudioTitle => 'Mute audio';

  @override
  String get muteAudioSubtitle =>
      'Silence click while keeping visual beat indicator active';

  @override
  String get strongBeatVolumeLabel => 'Strong Beat';

  @override
  String get weakBeatsVolumeLabel => 'Weak Beats';

  @override
  String get subdivisionsVolumeLabel => 'Subdivisions';

  @override
  String volumeSliderSemantics(String label) {
    return '$label volume';
  }

  @override
  String get backgroundPlaybackSectionHeader => 'BACKGROUND PLAYBACK';

  @override
  String get backgroundPlaybackTitle => 'Play in background';

  @override
  String get backgroundPlaybackSubtitle =>
      'Keep the metronome running with media notification and lock screen controls when you leave the app.';

  @override
  String get presetsHeader => 'PRESETS';

  @override
  String get newPresetButton => 'New Preset';

  @override
  String get searchPresetsPlaceholder => 'Search presets by name...';

  @override
  String get clearSearchTooltip => 'Clear search';

  @override
  String presetCardSemantics(String name, int bpm, String timeSignature) {
    return '$name, $bpm BPM, $timeSignature';
  }

  @override
  String unfavoritePresetTooltip(String name) {
    return 'Unfavorite $name';
  }

  @override
  String favoritePresetTooltip(String name) {
    return 'Favorite $name';
  }

  @override
  String presetBpmTempoSummary(int bpm, String tempoMarking) {
    return '$bpm BPM · $tempoMarking';
  }

  @override
  String get accentOnBadge => 'Accent ON';

  @override
  String get accentOffBadge => 'Accent OFF';

  @override
  String editPresetTooltip(String name) {
    return 'Edit $name';
  }

  @override
  String duplicatePresetTooltip(String name) {
    return 'Duplicate $name';
  }

  @override
  String deletePresetTooltip(String name) {
    return 'Delete $name';
  }

  @override
  String noPresetsMatchQuery(String query) {
    return 'No presets match \"$query\"';
  }

  @override
  String get noPresetsSavedTitle => 'No presets saved yet';

  @override
  String get noPresetsMatchSubtitle =>
      'Try another keyword or clear your search filter.';

  @override
  String get noPresetsSavedSubtitle =>
      'Save tempo, time signature, subdivision, and rehearsal notes for one-tap recall.';

  @override
  String get clearSearchButton => 'Clear Search';

  @override
  String get createPresetButton => 'Create Preset';

  @override
  String get deletePresetDialogTitle => 'Delete Preset?';

  @override
  String deletePresetDialogMessage(String name) {
    return 'Are you sure you want to delete \"$name\"? This action cannot be undone.';
  }

  @override
  String deletePresetSetlistWarning(int count, String setlistNames) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Warning: Used in $count setlists: $setlistNames. Deleting this preset will remove it from those setlists.',
      one:
          'Warning: Used in 1 setlist: $setlistNames. Deleting this preset will remove it from those setlists.',
    );
    return '$_temp0';
  }

  @override
  String get presetNameRequiredError => 'Enter a preset name to save.';

  @override
  String get editPresetSheetTitle => 'EDIT PRESET';

  @override
  String get newPresetSheetTitle => 'NEW PRESET';

  @override
  String get removeFromFavoritesTooltip => 'Remove from favorites';

  @override
  String get markAsFavoriteTooltip => 'Mark as favorite';

  @override
  String get presetNameLabel => 'Preset name';

  @override
  String get presetNamePlaceholder => 'e.g. Opening Groove';

  @override
  String get presetNoteLabel => 'Note (optional)';

  @override
  String get presetNotePlaceholder => 'e.g. Count-in at the start';

  @override
  String get tempoSectionLabel => 'TEMPO';

  @override
  String get decreasePresetBpmSemantics => 'Decrease preset BPM';

  @override
  String get increasePresetBpmSemantics => 'Increase preset BPM';

  @override
  String beatsCountLabel(int count) {
    return 'Beats: $count';
  }

  @override
  String get accentOnBeat1Label => 'ACCENT ON BEAT 1';

  @override
  String get saveChangesButton => 'Save Changes';

  @override
  String get savePresetButton => 'Save Preset';

  @override
  String get setlistsHeader => 'SETLISTS';

  @override
  String get newSetlistButton => 'New Setlist';

  @override
  String get newSetlistDialogTitle => 'New Setlist';

  @override
  String get renameSetlistDialogTitle => 'Rename Setlist';

  @override
  String get deleteSetlistDialogTitle => 'Delete Setlist?';

  @override
  String deleteSetlistDialogMessage(String name) {
    return 'Are you sure you want to delete \"$name\"? Your saved presets will remain in your library.';
  }

  @override
  String get emptySetlistPreview => 'Empty setlist — tap to add presets';

  @override
  String songCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count songs',
      one: '1 song',
      zero: '0 songs',
    );
    return '$_temp0';
  }

  @override
  String setlistCardSemantics(String name, String songCountLabel) {
    return '$name, $songCountLabel';
  }

  @override
  String setlistCardSubtitle(String songCountLabel, String previewText) {
    return '$songCountLabel · $previewText';
  }

  @override
  String get activateSetlistButton => 'Activate';

  @override
  String renameSetlistTooltip(String name) {
    return 'Rename $name';
  }

  @override
  String deleteSetlistTooltip(String name) {
    return 'Delete $name';
  }

  @override
  String get noSetlistsTitle => 'No setlists yet';

  @override
  String get noSetlistsSubtitle =>
      'Group your saved presets into ordered gig or rehearsal setlists with seamless bar-synced transitions.';

  @override
  String get createSetlistButton => 'Create Setlist';

  @override
  String get setlistNameRequiredError => 'Enter a setlist name.';

  @override
  String get setlistNameLabel => 'Setlist name';

  @override
  String get setlistNamePlaceholder => 'e.g. Friday Gig';

  @override
  String setlistSongCountAndReorderHint(String songCountLabel) {
    return '$songCountLabel · Drag to reorder';
  }

  @override
  String get renameSetlistGenericTooltip => 'Rename setlist';

  @override
  String get addPresetButton => 'Add Preset';

  @override
  String get emptySetlistDetailTitle => 'This setlist has no songs yet.';

  @override
  String get emptySetlistDetailSubtitle =>
      'Tap \"Add Preset\" above to build your song order.';

  @override
  String removePresetTooltip(String name) {
    return 'Remove $name';
  }

  @override
  String get addPresetPickerTitle => 'ADD PRESET TO SETLIST';

  @override
  String get addPresetPickerEmpty =>
      'No presets saved yet. Create a preset in the Presets tab first.';
}

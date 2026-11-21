import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Metronome'**
  String get appTitle;

  /// Navigation label for the Metronome screen
  ///
  /// In en, this message translates to:
  /// **'Metronome'**
  String get navMetronome;

  /// Navigation label for the Presets screen
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get navPresets;

  /// Navigation label for the Setlists screen
  ///
  /// In en, this message translates to:
  /// **'Setlists'**
  String get navSetlists;

  /// Navigation label for the Settings screen
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Generic cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Generic save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Generic create button label
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Generic delete button label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Badge indicating the currently active preset or setlist
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get activeBadge;

  /// Beats per minute unit label
  ///
  /// In en, this message translates to:
  /// **'BPM'**
  String get bpmUnit;

  /// Fallback display name when a preset has no name
  ///
  /// In en, this message translates to:
  /// **'Untitled Preset'**
  String get untitledPreset;

  /// Fallback display name when a setlist has no name
  ///
  /// In en, this message translates to:
  /// **'Untitled Setlist'**
  String get untitledSetlist;

  /// Name template when duplicating a preset
  ///
  /// In en, this message translates to:
  /// **'{originalName} (Copy)'**
  String presetCopyName(String originalName);

  /// Theme option matching the device system theme
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeModeSystem;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeModeLight;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeModeDark;

  /// Language option matching the device system locale
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Portuguese language option
  ///
  /// In en, this message translates to:
  /// **'Português'**
  String get languagePortuguese;

  /// Display label for the Click sound timbre
  ///
  /// In en, this message translates to:
  /// **'Click'**
  String get soundClickLabel;

  /// Accessible description for the Click sound timbre
  ///
  /// In en, this message translates to:
  /// **'Crisp studio precision click'**
  String get soundClickDescription;

  /// Display label for the Wood Block sound timbre
  ///
  /// In en, this message translates to:
  /// **'Wood Block'**
  String get soundWoodBlockLabel;

  /// Accessible description for the Wood Block sound timbre
  ///
  /// In en, this message translates to:
  /// **'Warm resonant wooden block'**
  String get soundWoodBlockDescription;

  /// Display label for the Beep sound timbre
  ///
  /// In en, this message translates to:
  /// **'Beep'**
  String get soundBeepLabel;

  /// Accessible description for the Beep sound timbre
  ///
  /// In en, this message translates to:
  /// **'Clear digital metronome tone'**
  String get soundBeepDescription;

  /// Display label for the Drums sound timbre
  ///
  /// In en, this message translates to:
  /// **'Drums'**
  String get soundDrumsLabel;

  /// Accessible description for the Drums sound timbre
  ///
  /// In en, this message translates to:
  /// **'Acoustic kick, rim & hi-hat'**
  String get soundDrumsDescription;

  /// Display label for quarter-note (1 pulse per beat) subdivision
  ///
  /// In en, this message translates to:
  /// **'Quarter'**
  String get subdivisionQuarter;

  /// Display label for eighth-note (2 pulses per beat) subdivision
  ///
  /// In en, this message translates to:
  /// **'Eighths'**
  String get subdivisionEighths;

  /// Display label for triplet (3 pulses per beat) subdivision
  ///
  /// In en, this message translates to:
  /// **'Triplets'**
  String get subdivisionTriplets;

  /// Display label for sixteenth-note (4 pulses per beat) subdivision
  ///
  /// In en, this message translates to:
  /// **'Sixteenths'**
  String get subdivisionSixteenths;

  /// Subtitle showing how many pulses occur per beat
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 pulse per beat} other{{count} pulses per beat}}'**
  String pulsesPerBeat(int count);

  /// Accessibility label for a subdivision option
  ///
  /// In en, this message translates to:
  /// **'Subdivision {label} ({count} per beat)'**
  String subdivisionOptionSemantics(String label, int count);

  /// Display label for strong beat accent
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get beatAccentStrong;

  /// Display label for medium beat accent
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get beatAccentMedium;

  /// Display label for weak beat accent
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get beatAccentWeak;

  /// Display label for subdivision click accent
  ///
  /// In en, this message translates to:
  /// **'Subdivision'**
  String get beatAccentSubdivision;

  /// Header title on the main metronome screen
  ///
  /// In en, this message translates to:
  /// **'METRONOME'**
  String get metronomeHeader;

  /// Header button label to save current metronome settings as a preset
  ///
  /// In en, this message translates to:
  /// **'Save Preset'**
  String get savePresetAction;

  /// Snackbar confirmation after saving a preset
  ///
  /// In en, this message translates to:
  /// **'Saved preset \"{name}\"'**
  String savedPresetSnackbar(String name);

  /// Accessibility label for active beat indicator while playing
  ///
  /// In en, this message translates to:
  /// **'Beat {beat} of {total}'**
  String beatIndicatorPlayingSemantics(int beat, int total);

  /// Accessibility label for beat indicator when stopped
  ///
  /// In en, this message translates to:
  /// **'Pulse indicator stopped, {beatCount, plural, =1{1 beat} other{{beatCount} beats}} per bar'**
  String beatIndicatorStoppedSemantics(int beatCount);

  /// Tooltip and accessibility label for BPM decrement button
  ///
  /// In en, this message translates to:
  /// **'Decrease BPM by 1'**
  String get decreaseBpmSemantics;

  /// Tooltip and accessibility label for BPM increment button
  ///
  /// In en, this message translates to:
  /// **'Increase BPM by 1'**
  String get increaseBpmSemantics;

  /// Accessibility label for hero BPM display
  ///
  /// In en, this message translates to:
  /// **'{bpm} beats per minute, {tempoMarking}'**
  String bpmValueSemantics(int bpm, String tempoMarking);

  /// Accessibility label for BPM slider
  ///
  /// In en, this message translates to:
  /// **'BPM quick adjust slider'**
  String get bpmSliderSemantics;

  /// BPM numeric value with unit
  ///
  /// In en, this message translates to:
  /// **'{bpm} BPM'**
  String bpmWithUnit(int bpm);

  /// Accessibility label for Tap Tempo button
  ///
  /// In en, this message translates to:
  /// **'Tap tempo'**
  String get tapTempoSemantics;

  /// Visible label on Tap Tempo button
  ///
  /// In en, this message translates to:
  /// **'TAP TEMPO'**
  String get tapTempoLabel;

  /// Accessibility label for Play/Stop button while playing
  ///
  /// In en, this message translates to:
  /// **'Stop metronome'**
  String get stopMetronomeSemantics;

  /// Accessibility label for Play/Stop button while stopped
  ///
  /// In en, this message translates to:
  /// **'Start metronome'**
  String get startMetronomeSemantics;

  /// Compact caption for time signature selector card
  ///
  /// In en, this message translates to:
  /// **'TIME SIG'**
  String get timeSignatureCaption;

  /// Accessibility label for time signature selector card
  ///
  /// In en, this message translates to:
  /// **'Time signature {label}. Tap to change.'**
  String timeSignatureSelectorSemantics(String label);

  /// Compact caption for subdivision selector card
  ///
  /// In en, this message translates to:
  /// **'SUBDIVISION'**
  String get subdivisionCaption;

  /// Accessibility label for subdivision selector card
  ///
  /// In en, this message translates to:
  /// **'Subdivision {label}. Tap to change.'**
  String subdivisionSelectorSemantics(String label);

  /// Tooltip for accent toggle when enabled
  ///
  /// In en, this message translates to:
  /// **'Downbeat accent ON'**
  String get downbeatAccentOnTooltip;

  /// Tooltip for accent toggle when disabled
  ///
  /// In en, this message translates to:
  /// **'Downbeat accent OFF'**
  String get downbeatAccentOffTooltip;

  /// Accessibility label for accent toggle when enabled
  ///
  /// In en, this message translates to:
  /// **'Accent on Beat 1 enabled'**
  String get downbeatAccentOnSemantics;

  /// Accessibility label for accent toggle when disabled
  ///
  /// In en, this message translates to:
  /// **'Accent on Beat 1 disabled'**
  String get downbeatAccentOffSemantics;

  /// Title of the time signature bottom sheet
  ///
  /// In en, this message translates to:
  /// **'TIME SIGNATURE'**
  String get timeSignatureSheetTitle;

  /// Section header for standard preset time signatures
  ///
  /// In en, this message translates to:
  /// **'PRESETS'**
  String get timeSignaturePresetsSection;

  /// Accessibility label for a time signature preset pill
  ///
  /// In en, this message translates to:
  /// **'Time signature {label}'**
  String timeSignatureOptionSemantics(String label);

  /// Section header for custom numerator/denominator controls
  ///
  /// In en, this message translates to:
  /// **'CUSTOM METER'**
  String get customMeterSection;

  /// Label for custom time signature numerator
  ///
  /// In en, this message translates to:
  /// **'BEATS PER BAR'**
  String get beatsPerBarLabel;

  /// Helper label showing valid numerator range
  ///
  /// In en, this message translates to:
  /// **'Numerator (1–16)'**
  String get numeratorRangeLabel;

  /// Tooltip and accessibility label for decrementing beats per bar
  ///
  /// In en, this message translates to:
  /// **'Decrease beats per bar'**
  String get decreaseBeatsPerBarSemantics;

  /// Tooltip and accessibility label for incrementing beats per bar
  ///
  /// In en, this message translates to:
  /// **'Increase beats per bar'**
  String get increaseBeatsPerBarSemantics;

  /// Label for custom time signature denominator
  ///
  /// In en, this message translates to:
  /// **'NOTE VALUE (DENOMINATOR)'**
  String get noteValueDenominatorLabel;

  /// Accessibility label for denominator pill
  ///
  /// In en, this message translates to:
  /// **'Denominator {denom}'**
  String denominatorSemantics(int denom);

  /// Title of the subdivisions bottom sheet
  ///
  /// In en, this message translates to:
  /// **'SUBDIVISIONS'**
  String get subdivisionsSheetTitle;

  /// Badge indicating a pending bar-synced setlist transition
  ///
  /// In en, this message translates to:
  /// **'NEXT BAR'**
  String get nextBarBadge;

  /// Tooltip for closing the active setlist stepper bar
  ///
  /// In en, this message translates to:
  /// **'Exit setlist'**
  String get exitSetlistTooltip;

  /// Tooltip and accessibility label for stepping to previous song
  ///
  /// In en, this message translates to:
  /// **'Previous song in setlist'**
  String get previousSongSemantics;

  /// Tooltip and accessibility label for stepping to next song
  ///
  /// In en, this message translates to:
  /// **'Next song in setlist'**
  String get nextSongSemantics;

  /// Setlist song position indicator
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String setlistPosition(int current, int total);

  /// Header title on the Preferences screen
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES'**
  String get preferencesHeader;

  /// Tooltip for back button on Preferences screen
  ///
  /// In en, this message translates to:
  /// **'Back to metronome'**
  String get backToMetronomeTooltip;

  /// Section header for theme settings
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE'**
  String get appearanceSectionHeader;

  /// Description text in the Appearance card
  ///
  /// In en, this message translates to:
  /// **'Choose between dark mode, light mode, or match your device system appearance.'**
  String get appearanceDescription;

  /// Section header for language settings
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get languageSectionHeader;

  /// Description text in the Language card
  ///
  /// In en, this message translates to:
  /// **'Choose the app language or follow your device system language.'**
  String get languageDescription;

  /// Section header for audio timbre and volume settings
  ///
  /// In en, this message translates to:
  /// **'SOUNDS & VOLUMES'**
  String get soundsSectionHeader;

  /// Description text in the Sounds & Volumes card
  ///
  /// In en, this message translates to:
  /// **'Select the click timbre, balance strong, weak, and subdivision volumes, or mute audio while keeping the visual pulse.'**
  String get soundsDescription;

  /// Title for mute audio switch row
  ///
  /// In en, this message translates to:
  /// **'Mute audio'**
  String get muteAudioTitle;

  /// Subtitle for mute audio switch row
  ///
  /// In en, this message translates to:
  /// **'Silence click while keeping visual beat indicator active'**
  String get muteAudioSubtitle;

  /// Slider label for strong beat volume
  ///
  /// In en, this message translates to:
  /// **'Strong Beat'**
  String get strongBeatVolumeLabel;

  /// Slider label for weak beats volume
  ///
  /// In en, this message translates to:
  /// **'Weak Beats'**
  String get weakBeatsVolumeLabel;

  /// Slider label for subdivisions volume
  ///
  /// In en, this message translates to:
  /// **'Subdivisions'**
  String get subdivisionsVolumeLabel;

  /// Accessibility label for a volume slider
  ///
  /// In en, this message translates to:
  /// **'{label} volume'**
  String volumeSliderSemantics(String label);

  /// Header title on the Presets screen
  ///
  /// In en, this message translates to:
  /// **'PRESETS'**
  String get presetsHeader;

  /// Primary button label to create a new preset
  ///
  /// In en, this message translates to:
  /// **'New Preset'**
  String get newPresetButton;

  /// Placeholder text in the presets search field
  ///
  /// In en, this message translates to:
  /// **'Search presets by name...'**
  String get searchPresetsPlaceholder;

  /// Tooltip for clearing the preset search field
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearchTooltip;

  /// Accessibility label for a preset card
  ///
  /// In en, this message translates to:
  /// **'{name}, {bpm} BPM, {timeSignature}'**
  String presetCardSemantics(String name, int bpm, String timeSignature);

  /// Tooltip to remove a preset from favorites
  ///
  /// In en, this message translates to:
  /// **'Unfavorite {name}'**
  String unfavoritePresetTooltip(String name);

  /// Tooltip to mark a preset as favorite
  ///
  /// In en, this message translates to:
  /// **'Favorite {name}'**
  String favoritePresetTooltip(String name);

  /// Badge text combining BPM and tempo marking
  ///
  /// In en, this message translates to:
  /// **'{bpm} BPM · {tempoMarking}'**
  String presetBpmTempoSummary(int bpm, String tempoMarking);

  /// Preset parameter badge when downbeat accent is enabled
  ///
  /// In en, this message translates to:
  /// **'Accent ON'**
  String get accentOnBadge;

  /// Preset parameter badge when downbeat accent is disabled
  ///
  /// In en, this message translates to:
  /// **'Accent OFF'**
  String get accentOffBadge;

  /// Tooltip for editing a preset
  ///
  /// In en, this message translates to:
  /// **'Edit {name}'**
  String editPresetTooltip(String name);

  /// Tooltip for duplicating a preset
  ///
  /// In en, this message translates to:
  /// **'Duplicate {name}'**
  String duplicatePresetTooltip(String name);

  /// Tooltip for deleting a preset
  ///
  /// In en, this message translates to:
  /// **'Delete {name}'**
  String deletePresetTooltip(String name);

  /// Empty search state title
  ///
  /// In en, this message translates to:
  /// **'No presets match \"{query}\"'**
  String noPresetsMatchQuery(String query);

  /// Empty presets library title
  ///
  /// In en, this message translates to:
  /// **'No presets saved yet'**
  String get noPresetsSavedTitle;

  /// Empty search state subtitle
  ///
  /// In en, this message translates to:
  /// **'Try another keyword or clear your search filter.'**
  String get noPresetsMatchSubtitle;

  /// Empty presets library subtitle
  ///
  /// In en, this message translates to:
  /// **'Save tempo, time signature, subdivision, and rehearsal notes for one-tap recall.'**
  String get noPresetsSavedSubtitle;

  /// Button label to clear search filter
  ///
  /// In en, this message translates to:
  /// **'Clear Search'**
  String get clearSearchButton;

  /// Button label to create the first preset
  ///
  /// In en, this message translates to:
  /// **'Create Preset'**
  String get createPresetButton;

  /// Title of delete preset confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Preset?'**
  String get deletePresetDialogTitle;

  /// Confirmation message for deleting a preset
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? This action cannot be undone.'**
  String deletePresetDialogMessage(String name);

  /// Warning shown when deleting a preset that belongs to one or more setlists
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Warning: Used in 1 setlist: {setlistNames}. Deleting this preset will remove it from those setlists.} other{Warning: Used in {count} setlists: {setlistNames}. Deleting this preset will remove it from those setlists.}}'**
  String deletePresetSetlistWarning(int count, String setlistNames);

  /// Validation error when saving a preset without a name
  ///
  /// In en, this message translates to:
  /// **'Enter a preset name to save.'**
  String get presetNameRequiredError;

  /// Title of the preset editor sheet when editing
  ///
  /// In en, this message translates to:
  /// **'EDIT PRESET'**
  String get editPresetSheetTitle;

  /// Title of the preset editor sheet when creating
  ///
  /// In en, this message translates to:
  /// **'NEW PRESET'**
  String get newPresetSheetTitle;

  /// Tooltip to unstar a preset in editor sheet
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFromFavoritesTooltip;

  /// Tooltip to star a preset in editor sheet
  ///
  /// In en, this message translates to:
  /// **'Mark as favorite'**
  String get markAsFavoriteTooltip;

  /// Input label for preset name
  ///
  /// In en, this message translates to:
  /// **'Preset name'**
  String get presetNameLabel;

  /// Input placeholder for preset name
  ///
  /// In en, this message translates to:
  /// **'e.g. Opening Groove'**
  String get presetNamePlaceholder;

  /// Input label for optional preset rehearsal note
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get presetNoteLabel;

  /// Input placeholder for preset rehearsal note
  ///
  /// In en, this message translates to:
  /// **'e.g. Count-in at the start'**
  String get presetNotePlaceholder;

  /// Section label for BPM editor in preset sheet
  ///
  /// In en, this message translates to:
  /// **'TEMPO'**
  String get tempoSectionLabel;

  /// Tooltip for decrementing BPM in preset editor
  ///
  /// In en, this message translates to:
  /// **'Decrease preset BPM'**
  String get decreasePresetBpmSemantics;

  /// Tooltip for incrementing BPM in preset editor
  ///
  /// In en, this message translates to:
  /// **'Increase preset BPM'**
  String get increasePresetBpmSemantics;

  /// Label showing current beat count in preset editor
  ///
  /// In en, this message translates to:
  /// **'Beats: {count}'**
  String beatsCountLabel(int count);

  /// Switch label for Beat 1 accent in preset editor
  ///
  /// In en, this message translates to:
  /// **'ACCENT ON BEAT 1'**
  String get accentOnBeat1Label;

  /// Save button label when editing an existing preset
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChangesButton;

  /// Save button label when creating a new preset
  ///
  /// In en, this message translates to:
  /// **'Save Preset'**
  String get savePresetButton;

  /// Header title on the Setlists screen
  ///
  /// In en, this message translates to:
  /// **'SETLISTS'**
  String get setlistsHeader;

  /// Button label to create a new setlist
  ///
  /// In en, this message translates to:
  /// **'New Setlist'**
  String get newSetlistButton;

  /// Dialog title when creating a setlist
  ///
  /// In en, this message translates to:
  /// **'New Setlist'**
  String get newSetlistDialogTitle;

  /// Dialog title when renaming a setlist
  ///
  /// In en, this message translates to:
  /// **'Rename Setlist'**
  String get renameSetlistDialogTitle;

  /// Title of delete setlist confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Setlist?'**
  String get deleteSetlistDialogTitle;

  /// Confirmation message when deleting a setlist
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? Your saved presets will remain in your library.'**
  String deleteSetlistDialogMessage(String name);

  /// Preview text on an empty setlist card
  ///
  /// In en, this message translates to:
  /// **'Empty setlist — tap to add presets'**
  String get emptySetlistPreview;

  /// Formatted song count in a setlist
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 songs} =1{1 song} other{{count} songs}}'**
  String songCount(int count);

  /// Accessibility label for a setlist card
  ///
  /// In en, this message translates to:
  /// **'{name}, {songCountLabel}'**
  String setlistCardSemantics(String name, String songCountLabel);

  /// Subtitle combining song count and preview text on a setlist card
  ///
  /// In en, this message translates to:
  /// **'{songCountLabel} · {previewText}'**
  String setlistCardSubtitle(String songCountLabel, String previewText);

  /// Button label to activate a setlist on the metronome
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activateSetlistButton;

  /// Tooltip for renaming a specific setlist
  ///
  /// In en, this message translates to:
  /// **'Rename {name}'**
  String renameSetlistTooltip(String name);

  /// Tooltip for deleting a specific setlist
  ///
  /// In en, this message translates to:
  /// **'Delete {name}'**
  String deleteSetlistTooltip(String name);

  /// Empty state title on Setlists screen
  ///
  /// In en, this message translates to:
  /// **'No setlists yet'**
  String get noSetlistsTitle;

  /// Empty state subtitle on Setlists screen
  ///
  /// In en, this message translates to:
  /// **'Group your saved presets into ordered gig or rehearsal setlists with seamless bar-synced transitions.'**
  String get noSetlistsSubtitle;

  /// Button label to create the first setlist
  ///
  /// In en, this message translates to:
  /// **'Create Setlist'**
  String get createSetlistButton;

  /// Validation error when submitting an empty setlist name
  ///
  /// In en, this message translates to:
  /// **'Enter a setlist name.'**
  String get setlistNameRequiredError;

  /// Input label for setlist name
  ///
  /// In en, this message translates to:
  /// **'Setlist name'**
  String get setlistNameLabel;

  /// Input placeholder for setlist name
  ///
  /// In en, this message translates to:
  /// **'e.g. Friday Gig'**
  String get setlistNamePlaceholder;

  /// Subtitle in setlist detail sheet showing song count and drag hint
  ///
  /// In en, this message translates to:
  /// **'{songCountLabel} · Drag to reorder'**
  String setlistSongCountAndReorderHint(String songCountLabel);

  /// Tooltip for rename button in setlist detail sheet
  ///
  /// In en, this message translates to:
  /// **'Rename setlist'**
  String get renameSetlistGenericTooltip;

  /// Button label to add a preset to the setlist
  ///
  /// In en, this message translates to:
  /// **'Add Preset'**
  String get addPresetButton;

  /// Empty state title inside setlist detail sheet
  ///
  /// In en, this message translates to:
  /// **'This setlist has no songs yet.'**
  String get emptySetlistDetailTitle;

  /// Empty state subtitle inside setlist detail sheet
  ///
  /// In en, this message translates to:
  /// **'Tap \"Add Preset\" above to build your song order.'**
  String get emptySetlistDetailSubtitle;

  /// Tooltip to remove a preset from a setlist
  ///
  /// In en, this message translates to:
  /// **'Remove {name}'**
  String removePresetTooltip(String name);

  /// Title of the bottom sheet for picking a preset to add to a setlist
  ///
  /// In en, this message translates to:
  /// **'ADD PRESET TO SETLIST'**
  String get addPresetPickerTitle;

  /// Message shown in add-preset picker when no presets exist
  ///
  /// In en, this message translates to:
  /// **'No presets saved yet. Create a preset in the Presets tab first.'**
  String get addPresetPickerEmpty;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

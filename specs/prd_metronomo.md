# Software Requirements Specification: Metronome

Oct 29, 2026 · @Mateus

## 1. Introduction

### 1.1 Purpose

This document specifies the functional and non-functional requirements of the new version of the Metronome app, a mobile metronome built with Flutter. It is the reference for design, implementation, and testing, and it describes the desired state of the app, not only what exists today.

### 1.2 Scope

The app lets musicians set the tempo, time signature, and subdivisions, hear an accurate click, and follow the pulse visually, even with the screen locked. It also lets them save presets, build setlists, and control the metronome from a home screen widget and a smartwatch. The app works offline and is for individual use.

**In scope (v1):** BPM control, tap tempo, time signature, play/stop, subdivisions, sound selection and volumes, presets and setlists, tempo marking names, visual feedback, background and locked-screen playback, dark theme, keep-screen-on, home screen widget, and smartwatch support.

**Out of scope (v1):** tuner, backing tracks, user accounts and cloud sync, web and desktop versions, integration with MIDI or other music apps, in-app purchases. The practice features listed in section 11 are left for a later version.

### 1.3 Definitions

| Term | Meaning |
| --- | --- |
| BPM | Beats per minute, the unit of tempo |
| Tap tempo | Repeated taps on the screen whose average interval sets the BPM |
| Time signature | Notation such as 4/4 or 6/8: the number of beats per bar and the note value that counts as one beat |
| Strong beat and weak beat | The first beat of the bar (strong, accented) and the remaining beats (weak) |
| Subdivision | Division of each beat into equal parts: eighth notes, triplets, sixteenth notes |
| Preset | A saved combination of BPM, time signature, subdivision, and sounds |
| Setlist | An ordered list of presets, usually the songs of a gig or rehearsal |
| Tempo marking | The traditional name of a speed (Largo, Andante, Allegro, etc.) |
| Latency | Delay between the scheduled instant of the click and the sound coming out of the speaker or headphones |
| Jitter | Irregular variation in the interval between consecutive clicks |
| Foreground service | Android mechanism that keeps a task alive with a visible notification |
| Widget | Home screen component with app controls |

### 1.4 Assumptions and constraints

- The app is built with Flutter (Dart) and targets Android and iOS. Confirmation of the platforms is in section 10.
- Flutter remains the framework for the user interface and business logic.
- The metronome clock and click generation do not run on Dart timers or on the UI loop. They run in a native audio engine (for example, Oboe on Android and AVAudioEngine on iOS), accessed through platform channels or FFI.
- The home screen widget and the smartwatch app require native code on each platform, integrated with the Flutter code. The exact approach is in section 10.
- The app does not depend on the network for any v1 feature.
- The app does not collect personal data.

## 2. Overall Description

### 2.1 Product perspective

The app is standalone, local, and single-user. It has no backend of its own. The only external systems are operating system features: audio, notifications, screen, local storage, widgets, and the paired watch.

### 2.2 User classes

- **Musician practicing or rehearsing:** adjusts BPM and time signature quickly, plays with an instrument in hand, and rarely looks at the screen.
- **Performing musician:** uses setlists, needs fast switching between songs, and needs an audible or visible click in noisy environments.
- **Music student or teacher:** works with subdivisions, tempo markings, and varied time signatures to train reading and rhythmic division.

### 2.3 Operating environment

- Android and iOS smartphones, in portrait and landscape.
- Operation with the screen on, the screen locked, the app in the background, wired headphones, and Bluetooth headphones.
- Paired watches (Wear OS and Apple Watch), as described in section 3.12.
- Fully offline use.

### 2.4 Architectural constraints

- The audio engine and the timing clock live in native code and do not depend on the Flutter UI loop.
- Domain logic (BPM, time signature, subdivisions, presets, setlists, tap tempo) is written in pure Dart, with no dependency on widgets, so it can be tested without a UI.
- The UI drives the audio engine through a single interface (for example, `MetronomeEngine`) and receives beat events from it, so the native implementation can be swapped or simulated in tests.
- The widget and the smartwatch use the same state and the same audio engine as the app. They do not implement a metronome of their own, except for the exception described in 3.12.

## 3. System Features (Functional Requirements)

Priority: **M** = must (v1), **S** = should (v1 if time allows), **C** = could (later). Requirements for clock accuracy and latency are in section 5.

### 3.1 BPM control

| ID | Requirement | Pri |
| --- | --- | --- |
| FR-BPM-01 | The system shall allow setting the BPM from 30 to 300, in whole-number steps. | M |
| FR-BPM-02 | The system shall provide − and + buttons that change the BPM by 1 per tap and repeat the adjustment with acceleration while the button is held. | M |
| FR-BPM-03 | The system shall provide a quick-adjust control (slider or wheel) that covers the whole BPM range. | M |
| FR-BPM-04 | The system shall apply BPM changes during playback, from the next beat, without interrupting the click. | M |
| FR-BPM-05 | The system shall restore the last BPM, time signature, and subdivision when the app opens. | M |
| FR-BPM-06 | The system shall allow typing the BPM by tapping the value, rejecting out-of-range numbers with a clear message. | S |
| FR-BPM-07 | The system shall provide larger adjustment buttons (for example, ±5 and ±10 BPM). | S |
| FR-BPM-08 | The system shall accept fractional BPM (for example, 120.5). | C |

### 3.2 Tap tempo

| ID | Requirement | Pri |
| --- | --- | --- |
| FR-TAP-01 | The system shall provide a large, easy-to-reach tap tempo button. | M |
| FR-TAP-02 | The system shall compute the BPM from the average of the intervals between the most recent taps (minimum of 2 taps, maximum of the last 8). | M |
| FR-TAP-03 | The system shall restart the sequence when more than 2 seconds pass between two taps, which matches the lower limit of 30 BPM. | M |
| FR-TAP-04 | The system shall update the BPM on every tap from the second one on and clamp the result to the range 30 to 300. | M |
| FR-TAP-05 | The system shall measure intervals with a monotonic clock, at the moment of the touch event, and not when the screen is drawn. | M |
| FR-TAP-06 | The system shall work with the metronome stopped or playing; while playing, the new BPM takes effect from the next beat. | S |
| FR-TAP-07 | The system shall give visual feedback on every tap and, optionally, haptic feedback (vibration). | S |

### 3.3 Time signature

| ID | Requirement | Pri |
| --- | --- | --- |
| FR-CMP-01 | The system shall support at least the time signatures 2/4, 3/4, 4/4, and 6/8. | M |
| FR-CMP-02 | The system shall accent the first beat of the bar with a sound and a visual indication distinct from the other beats. | M |
| FR-CMP-03 | The system shall allow additional and custom time signatures, with a numerator from 1 to 16 and a denominator of 2, 4, 8, or 16 (for example, 5/4, 7/8, 9/8, 12/8). | S |
| FR-CMP-04 | The system shall indicate which note value the BPM represents in the chosen time signature (for example, a quarter note in 4/4). The rule for compound meters is open in section 10. | S |
| FR-CMP-05 | The system shall allow, in compound meters, grouping the beats in threes, with an intermediate accent at the start of each group. | S |
| FR-CMP-06 | The system shall apply a time signature change during playback from the start of the next bar, without stopping the click. | S |
| FR-CMP-07 | The system shall allow custom groupings in irregular meters (for example, 7/8 as 2+2+3). | C |

### 3.4 Play/stop

| ID | Requirement | Pri |
| --- | --- | --- |
| FR-PLY-01 | The system shall provide a large play/stop button at the bottom of the screen, within thumb reach. | M |
| FR-PLY-02 | The system shall always start playback on the first beat of the bar, with the strong-beat sound. | M |
| FR-PLY-03 | The system shall show the state (playing or stopped) by icon and also by text or an accessibility label. | M |
| FR-PLY-04 | The system shall stop the click immediately on stop, with no residual sounds, and reset the counter to the first beat. | M |

### 3.5 Subdivisions

| ID | Requirement | Pri |
| --- | --- | --- |
| FR-SUB-01 | The system shall offer these subdivisions: none, eighth notes (2 per beat), triplets (3 per beat), and sixteenth notes (4 per beat). | M |
| FR-SUB-02 | The system shall play subdivisions at their own volume, lower than that of the beats, as described in 3.6. | M |
| FR-SUB-03 | The system shall apply a subdivision change during playback from the next beat, without interrupting the pulse. | M |
| FR-SUB-04 | The system shall show the active subdivision on the main screen, as a musical symbol or a label. | M |
| FR-SUB-05 | The system shall offer additional tuplets (quintuplets and sextuplets). | C |
| FR-SUB-06 | The system shall offer combined patterns (for example, swing and an eighth note followed by two sixteenth notes). | C |

### 3.6 Sounds and volumes

| ID | Requirement | Pri |
| --- | --- | --- |
| FR-SND-01 | The system shall offer at least four sounds: click, wood block, beep, and drums. | M |
| FR-SND-02 | The system shall allow choosing the metronome sound among the available options. | M |
| FR-SND-03 | The system shall distinguish the strong beat from the weak beats by pitch or timbre, for any chosen sound. | M |
| FR-SND-04 | The system shall offer independent volumes, from 0 to 100%, for the strong beat, the weak beats, and the subdivisions. | M |
| FR-SND-05 | The system shall follow the system media volume as the overall volume and shall not change it. | M |
| FR-SND-06 | The system shall allow choosing different sounds for the strong beat, the weak beats, and the subdivisions. | S |
| FR-SND-07 | The system shall play a preview of the sound when it is selected. | S |
| FR-SND-08 | The system shall allow muting the audio while keeping visual feedback active (mute mode). | S |
| FR-SND-09 | The system shall allow importing user sounds. | C |

### 3.7 Presets, favorites, and setlists

| ID | Requirement | Pri |
| --- | --- | --- |
| FR-PRE-01 | The system shall save a preset with a name, BPM, time signature, subdivision, sounds, and volumes. | M |
| FR-PRE-02 | The system shall load a preset with one tap, applying all of its parameters. | M |
| FR-PRE-03 | The system shall allow renaming, editing, duplicating, and deleting presets, with confirmation on delete. | M |
| FR-PRE-04 | The system shall allow marking presets as favorites and list favorites first. | S |
| FR-PRE-05 | The system shall allow searching presets by name. | S |
| FR-PRE-06 | The system shall allow creating, renaming, and deleting setlists, which are ordered lists of presets. | S |
| FR-PRE-07 | The system shall allow adding and removing presets in a setlist, including the same preset in several setlists, and reordering items by dragging. | S |
| FR-PRE-08 | The system shall provide, on the main screen, large previous and next buttons to move through the active setlist, showing the preset name and position (for example, 3 of 12). | S |
| FR-PRE-09 | The system shall, when switching items while the metronome is playing, apply the new configuration from the start of the next bar, without stopping the click. | S |
| FR-PRE-10 | The system shall warn, when deleting a preset, which setlists contain it. | S |
| FR-PRE-11 | The system shall allow a free-text note per preset (for example, "count-in at the start"). | C |
| FR-PRE-12 | The system shall export and import presets and setlists as a JSON file, for backup and sharing. | C |

### 3.8 Tempo marking names

| ID | Requirement | Pri |
| --- | --- | --- |
| FR-AND-01 | The system shall show, next to the BPM, the name of the matching tempo marking, according to the table below. | M |
| FR-AND-02 | The system shall update the name immediately on every BPM change, whether by buttons, slider, tap tempo, or preset. | M |
| FR-AND-03 | The system shall allow hiding the tempo marking name in settings. | S |
| FR-AND-04 | The system shall show a short explanation of the name (for example, "Allegro: fast and lively") when it is tapped. | C |

Reference ranges for v1. The limits vary between musical sources, so this table fixes a single criterion for the app.

| Tempo marking | Range (BPM) |
| --- | --- |
| Largo | 30 to 59 |
| Larghetto | 60 to 65 |
| Adagio | 66 to 75 |
| Andante | 76 to 107 |
| Moderato | 108 to 119 |
| Allegro | 120 to 155 |
| Vivace | 156 to 175 |
| Presto | 176 to 199 |
| Prestissimo | 200 to 300 |

### 3.9 Visual feedback

| ID | Requirement | Pri |
| --- | --- | --- |
| FR-VIS-01 | The system shall show an indicator with one marker per beat of the bar, highlighting the current beat and distinguishing the strong beat by color and by shape. | M |
| FR-VIS-02 | The system shall change the indicator at the same instant the click is heard, compensating for the audio output latency (see NFR-TIM-04). | M |
| FR-VIS-03 | The system shall show subdivisions in the indicator. | S |
| FR-VIS-04 | The system shall offer an optional full-screen flash on each beat, off by default, with a light-sensitivity warning when enabled. | S |
| FR-VIS-05 | The system shall offer optional vibration on each beat, stronger on the strong beat, on devices that support it. | S |
| FR-VIS-06 | The system shall allow manually adjusting the sync between sound and image, from 0 to 500 ms, for Bluetooth headphones. | S |
| FR-VIS-07 | The system shall allow using the device flashlight as a beat indicator. | C |

### 3.10 Background, locked screen, and interruptions

| ID | Requirement | Pri |
| --- | --- | --- |
| FR-BGD-01 | The system shall keep playing with the screen locked, with no change to the pulse. | M |
| FR-BGD-02 | The system shall keep playing with the app in the background (for example, when the user opens sheet music in another app). | M |
| FR-BGD-03 | On Android, the system shall keep playback in a foreground service, with a persistent notification that shows the BPM and time signature and has a play/stop button. | M |
| FR-BGD-04 | On iOS, the system shall configure the audio session and the audio background mode required to play with the screen locked. | M |
| FR-BGD-05 | On Android 13 or later, the system shall request the notification permission with an explanation of why. If it is denied, the app shall keep working and tell the user what is limited. | M |
| FR-BGD-06 | The system shall not be interrupted or paused by notification sounds and other short system sounds, accepting only the temporary volume reduction done by the system. | M |
| FR-BGD-07 | The system shall pause on long interruptions (phone call, alarm, another app taking audio focus) and resume only by user action, unless the automatic resume option is on. | M |
| FR-BGD-08 | The system shall end playback and remove the notification when the app is removed from the recent apps list. | M |
| FR-BGD-09 | The system shall offer play/pause on the lock screen or in the system media controls. | S |
| FR-BGD-10 | The system shall respond to the play/pause button on wired and Bluetooth headphones. | S |
| FR-BGD-11 | The system shall pause when headphones are disconnected, so the click does not suddenly switch to the speaker. | S |
| FR-BGD-12 | The system shall guide the user, with an optional notice, to disable battery optimization for the app when the system ends background playback. | C |

### 3.11 Home screen widget

Platforms limit what a widget can do, especially starting audio on iOS. Feasibility is recorded in section 10.

| ID | Requirement | Pri |
| --- | --- | --- |
| FR-WGT-01 | The system shall provide a widget that shows BPM, time signature, state (playing or stopped), and a play/stop button. | M |
| FR-WGT-02 | The system shall start and stop the metronome from the widget without opening the app, using the same audio engine as the app. | M |
| FR-WGT-03 | The system shall open the app when the widget is tapped outside the button. | M |
| FR-WGT-04 | The system shall reflect on the widget, within 2 seconds, state changes made in the app, in the notification, or on the watch. | M |
| FR-WGT-05 | The system shall provide a larger widget size with − and + BPM buttons. | S |
| FR-WGT-06 | The system shall provide a preset widget, which shows the favorite preset chosen in the widget configuration and starts it with one tap. | S |
| FR-WGT-07 | The system shall follow the system light or dark theme on the widget. | S |
| FR-WGT-08 | The system shall allow several widgets on the same screen, each with its own preset. | C |

The widget does not need to show the animated pulse in real time.

### 3.12 Smartwatch

The watch acts as a remote control for the phone's metronome. The sound keeps coming from the phone or from the headphones connected to it.

| ID | Requirement | Pri |
| --- | --- | --- |
| FR-WCH-01 | The system shall provide an app for Wear OS and for Apple Watch that shows BPM, time signature, and state, with a play/stop button. | M |
| FR-WCH-02 | The system shall allow the watch to start and stop the paired phone's metronome and adjust the BPM with − and + buttons. | M |
| FR-WCH-03 | The system shall sync BPM, time signature, subdivision, and playback state in both directions, within 2 seconds, reflecting changes made on either device. | M |
| FR-WCH-04 | The system shall show on the watch when the phone is out of range and disable the controls that depend on it. | M |
| FR-WCH-05 | The system shall allow adjusting the BPM with the digital crown or rotating bezel, in addition to the buttons. | S |
| FR-WCH-06 | The system shall provide a haptic pulse on the wrist at each beat, with a distinct strong beat, generated on the watch itself from the BPM and a shared start instant, as a silent alternative to sound. | S |
| FR-WCH-07 | The system shall allow viewing the favorites or the active setlist on the watch and switching presets from it. | S |
| FR-WCH-08 | The system shall show a visual pulse indicator on the watch, on a best-effort basis and with no guarantee of alignment with the sound. | S |
| FR-WCH-09 | The system shall provide a tile (Wear OS) and a complication (Apple Watch) for quick access to play/stop. | S |
| FR-WCH-10 | The system shall provide a standalone mode, with the watch alone and without the phone, using the haptic pulse and, if the hardware allows, sound from the watch speaker. | C |
| FR-WCH-11 | The system shall provide tap tempo on the watch. | C |

### 3.13 Settings and preferences

| ID | Requirement | Pri |
| --- | --- | --- |
| FR-CFG-01 | The system shall provide a dark theme, a light theme, and the option to follow the system. | M |
| FR-CFG-02 | The system shall provide an option to keep the screen on while the metronome is playing, on by default and with no effect while stopped. | M |
| FR-CFG-03 | The system shall store all settings locally and restore them when the app opens. | M |
| FR-CFG-04 | The system shall have a settings screen with: sounds and volumes, theme, keep-screen-on, vibration, screen flash, visual sync, automatic resume after interruption, and tempo marking display. | M |
| FR-CFG-05 | The system shall work in portrait and landscape modes. | S |
| FR-CFG-06 | The system shall be available in Portuguese (Brazil) and English, following the system language. | S |
| FR-CFG-07 | The system shall allow restoring default settings, with confirmation. | S |

## 4. User Interface Requirements

Musicians often use the app with an instrument in hand, on stage or in a dark room, glancing at the screen only briefly. The interface prioritizes fast reading and easy-to-hit touch targets.

| ID | Requirement | Pri |
| --- | --- | --- |
| UI-01 | The app shall show on the main screen, without scrolling: BPM, tempo marking name, time signature, subdivision, pulse indicator, tap tempo, and play/stop. | M |
| UI-02 | Touch targets shall be at least 48 dp (Android) or 44 pt (iOS), and the play/stop and tap tempo buttons shall be larger than the minimum. | M |
| UI-03 | The BPM value shall be shown in a large font, readable at arm's length. | M |
| UI-04 | Text and control contrast shall meet the minimum ratio of 4.5:1 (WCAG AA) in the light and dark themes. | M |
| UI-05 | The app shall provide these screens: Metronome (main), Presets, Setlists, Preset or setlist editor, Sound selection, and Settings. | M |
| UI-06 | The app shall ask for confirmation before destructive actions, such as deleting a preset or setlist and restoring default settings. | M |
| UI-07 | The app shall show error messages that say what happened and what the user can do. | M |
| UI-08 | On first use, the app shall open straight to the main screen, at 120 BPM in 4/4, with no sign-up and no mandatory tutorial. | S |
| UI-09 | The main controls shall sit in the lower half of the screen, for one-handed use. | S |
| UI-10 | Navigation shall use a bottom bar with at most four destinations. | S |
| UI-11 | The app shall allow loading a preset from the main screen in at most two taps. | S |
| UI-12 | The slider or wheel BPM control shall avoid accidental changes when scrolling the screen. | S |
| UI-13 | The app state (playing, stopped, strong beat) shall not depend on color alone and shall come with a shape, text, or icon. | S |
| UI-14 | The app shall have accessibility labels on the main controls for TalkBack and VoiceOver and respect the system font size up to 200% without breaking the layout. | S |

## 5. Non-Functional Requirements

The numeric values below are design targets and shall be confirmed on reference devices (section 5.8).

### 5.1 Timing accuracy

| ID | Requirement |
| --- | --- |
| NFR-TIM-01 | The click shall be scheduled by the native audio engine, based on the sample count of the audio stream, and never by Dart timers, system timers, or the UI loop. |
| NFR-TIM-02 | The deviation of each click from its theoretical instant shall not exceed 2 ms, and the accumulated error after 10 minutes of playback shall not exceed 2 ms. |
| NFR-TIM-03 | The average BPM measured over 5 minutes shall be within 0.1% of the configured value. |
| NFR-TIM-04 | The visual indicator shall change with a maximum delay of 20 ms relative to the sound, using the output latency reported by the system plus the manual adjustment from FR-VIS-06. |
| NFR-TIM-05 | Changes of BPM, time signature, and subdivision shall not cause a duplicated click, a missed click, or an audible pop. |
| NFR-TIM-06 | The pulse shall not be affected by UI freezes: audio shall stay stable even with the UI thread blocked for 500 ms. |

### 5.2 Latency

| ID | Requirement |
| --- | --- |
| NFR-LAT-01 | The first click shall sound within 100 ms of the tap on play, on reference devices with a low-latency output. |
| NFR-LAT-02 | The audio engine shall use each platform's low-latency path (for example, Oboe on Android and AVAudioEngine with a short buffer on iOS) and short samples preloaded in memory, with no decoding during playback. |
| NFR-LAT-03 | The UI shall respond to touches within 100 ms. |
| NFR-LAT-04 | The app shall warn the user when the audio output is Bluetooth, explaining that the click may be delayed and pointing to the visual sync adjustment. |

### 5.3 Performance and battery

| ID | Requirement |
| --- | --- |
| NFR-PRF-01 | The app shall open to the main screen, ready for use, within 2 seconds on a mid-range device. |
| NFR-PRF-02 | The pulse indicator animation shall run at 60 frames per second, without affecting audio. |
| NFR-PRF-03 | Battery consumption with the screen locked and the metronome playing shall stay below 3% per hour on a reference device. |
| NFR-PRF-04 | Memory use shall stay below 200 MB in normal operation. |

### 5.4 Reliability

| ID | Requirement |
| --- | --- |
| NFR-REL-01 | The metronome shall play for 4 hours straight without failure, loss of pulse, or noticeable memory growth. |
| NFR-REL-02 | Presets, setlists, and settings shall be written atomically, so an abrupt app shutdown does not corrupt the data. |
| NFR-REL-03 | The audio engine shall reconnect on its own when the output changes (headphones plugged or unplugged, Bluetooth), without freezing the app. |
| NFR-REL-04 | If audio cannot be started, the app shall show an error with the suggested action and try again on the next tap on play. |
| NFR-REL-05 | Screen rotation and window size changes shall not interrupt playback. |

### 5.5 Privacy and permissions

| ID | Requirement |
| --- | --- |
| NFR-PRV-01 | The app shall not collect personal data or telemetry by default. |
| NFR-PRV-02 | The app shall request only the necessary permissions: notifications, foreground service, vibration, and keeping the screen on. The release build shall not request internet access in v1. |
| NFR-PRV-03 | Presets, setlists, and settings shall stay only on the device. |

### 5.6 Portability and compatibility

| ID | Requirement |
| --- | --- |
| NFR-POR-01 | The app shall run on Android and iOS, in the minimum versions defined in section 10. |
| NFR-POR-02 | The app shall work on phones and tablets, in portrait and landscape modes. |
| NFR-POR-03 | The app shall work with the speaker, wired headphones, and Bluetooth headphones. |
| NFR-POR-04 | The watch app shall run on Wear OS and watchOS, in the minimum versions defined in section 10. |

### 5.7 Maintainability

| ID | Requirement |
| --- | --- |
| NFR-MAN-01 | The domain logic (BPM, time signature, subdivisions, tap tempo, presets, setlists, tempo marking ranges) shall be written in pure Dart, with no dependency on Flutter widgets. |
| NFR-MAN-02 | The audio engine shall sit behind a single interface, with native implementations for Android and iOS and a simulated implementation for tests. |
| NFR-MAN-03 | The app, the notification, the widget, and the watch shall use a single source of truth for the metronome state. |
| NFR-MAN-04 | The project shall use Dart static analysis with lints enabled and no warnings. |
| NFR-MAN-05 | Dependencies shall be few, with versions pinned in the lock file (`pubspec.lock`). |

### 5.8 Testability

| ID | Requirement |
| --- | --- |
| NFR-TST-01 | Unit tests shall exist for: BPM limits, tap tempo calculation, tempo marking table, click schedule generation (beats, accents, and subdivisions), and saving of presets and setlists. |
| NFR-TST-02 | Audio engine timing shall be measured for 10 minutes on real reference devices, verifying NFR-TIM-02 and NFR-TIM-03. An emulator is not proof. |
| NFR-TST-03 | The main screens shall have Flutter widget tests, and the preset and setlist flows shall have an integration test. |
| NFR-TST-04 | A manual test checklist shall exist for: locked screen, app in the background, incoming call, notification, headphone switch, rotation, widget, and watch. |

## 6. Data Requirements

### 6.1 Stored data

All data stays on the device. None of it is sensitive.

| Data | Location | Sensitivity | Protection |
| --- | --- | --- | --- |
| Settings (theme, sounds, volumes, keep-screen-on, vibration, flash, visual sync) | App local storage | Low | App-private area |
| Last state (BPM, time signature, subdivision) | App local storage | Low | App-private area |
| Presets | Local database or JSON file | Low | App-private area |
| Setlists | Local database or JSON file | Low | App-private area, with presets referenced by identifier |
| Audio samples for the sounds | App resources (read-only) | None | Bundled with the app |

### 6.2 Main fields

| Entity | Fields |
| --- | --- |
| Preset | identifier, name, BPM, time signature numerator and denominator, subdivision, sounds (strong, weak, subdivision), volumes (strong, weak, subdivision), favorite, note (C), creation date, modification date |
| Setlist | identifier, name, ordered list of preset identifiers, creation date, modification date |
| Settings | theme, keep-screen-on, vibration, screen flash, visual sync (ms), automatic resume, show tempo marking name, language |

### 6.3 Data lifecycle

- Storage shall keep a schema version and migrate data from earlier app versions without losing presets and setlists.
- Deleting a preset shall remove its reference from setlists, after the warning described in FR-PRE-10.
- Data follows the operating system backup, when the user keeps it enabled.
- Uninstalling the app deletes the local data, following the default behavior of each system.

## 7. External Interfaces

### 7.1 Operating system interfaces

The app uses no external network services. It depends on the features of each platform below. The technologies are starting points, and the final choice is left to the technical design.

| Feature | Android | iOS |
| --- | --- | --- |
| Low-latency audio engine | Oboe (AAudio or OpenSL ES), through native code | AVAudioEngine, with a short buffer |
| Background execution | Foreground service of the media playback type, with a notification | Audio background mode and an audio session of the playback category |
| Audio focus and interruptions | `AudioManager` audio focus | `AVAudioSession` interruption notifications |
| Lock screen and headphone controls | `MediaSession` | `MPRemoteCommandCenter` and `MPNowPlayingInfoCenter` |
| Screen always on | Keep-screen-on flag | `idleTimerDisabled` |
| Vibration | `Vibrator` | Core Haptics |
| Home screen widget | App Widget | WidgetKit, with App Intents for the buttons |
| Watch communication | Wear OS Data Layer | WatchConnectivity |
| Local storage | Preferences and local database | `UserDefaults` and local database |

### 7.2 Integration between Flutter and native code

- The Flutter UI drives the audio engine through platform channels or FFI and receives beat events from it, so the UI draws the indicator without controlling timing.
- The widget, the notification, and the watch drive the same audio engine, and the metronome state lives in a single source, as in NFR-MAN-03.
- On iOS, the widget and the app share data through an App Group. The feasibility of starting audio directly from the widget is open in section 10.

### 7.3 Hardware interfaces

- Device speaker, wired headphones, and Bluetooth headphones as audio outputs.
- Vibration or haptic motor, when present.
- Paired smartwatch (Wear OS or Apple Watch).

## 8. Key Use Cases

| ID | Use case | Primary flow |
| --- | --- | --- |
| UC-01 | Start the metronome | Open the app, tap play, hear the click, and follow the beat indicator |
| UC-02 | Adjust the BPM | Use the −/+ buttons, the slider, or typing; the tempo marking name updates |
| UC-03 | Find the tempo of a song | Tap the tap tempo button several times to the rhythm of the song; the BPM is calculated and applied |
| UC-04 | Change time signature and subdivision | Open the time signature selector, choose the signature and the subdivision; the change takes effect on the next bar or beat |
| UC-05 | Choose sounds and volumes | Settings, choose the sound, hear the preview, set the strong, weak, and subdivision volumes |
| UC-06 | Save a preset | Set up the metronome, tap save, enter a name, confirm |
| UC-07 | Load a preset or favorite | Open the preset list, tap the item; all parameters are applied |
| UC-08 | Build a setlist | Create the setlist, add presets, reorder by dragging |
| UC-09 | Play a setlist in rehearsal | Activate the setlist, tap play, and use previous and next to switch songs |
| UC-10 | Play with the screen locked | Tap play, lock the screen, keep playing, and control from the notification or the lock screen |
| UC-11 | Handle a phone call | A call arrives, the metronome pauses, and the user resumes it by their own action after the call |
| UC-12 | Control from the widget | Tap play/stop on the home screen widget, without opening the app |
| UC-13 | Control from the watch | Open the app on the watch, start or stop the metronome, and adjust the BPM; the phone reflects the change |
| UC-14 | Use the haptic pulse on the watch | Turn on the haptic pulse, play silently, and feel the distinct strong beat on the wrist |
| UC-15 | Set the sync with Bluetooth headphones | Settings, move the visual sync control until the image matches the sound |

## 9. Acceptance Criteria (v1 release)

1. The user can set the BPM from 30 to 300 with buttons, slider, and tap tempo, and the tempo marking name shown matches the table in section 3.8 across all ranges.
2. On reference Android and iOS devices, a 10-minute playback at 120 BPM in 4/4, with sixteenth-note subdivision, meets NFR-TIM-02 and NFR-TIM-03, with no missed or duplicated clicks.
3. With the screen locked and with the app in the background, the metronome plays for 30 minutes with no change to the pulse.
4. A message notification does not interrupt the click, and a phone call pauses the metronome, which only resumes by user action in the default configuration.
5. Changing BPM, time signature, and subdivision during playback causes no duplicated click, missed click, or pop.
6. A saved preset, loaded again, reproduces exactly the same parameters, and a 12-item setlist can be walked through with the previous and next buttons.
7. Presets, setlists, and settings remain intact after an abrupt app shutdown.
8. The visual indicator changes together with the sound, within NFR-TIM-04, and the sync adjustment compensates for Bluetooth headphones.
9. The widget starts and stops the metronome without opening the app and reflects the state within 2 seconds, on Android, and on iOS according to the feasibility recorded in section 10.
10. The watch starts, stops, and adjusts the BPM of the phone's metronome, and the state stays in sync on both devices within 2 seconds.
11. The light and dark themes meet the contrast requirement of UI-04, and the keep-screen-on option works.
12. All requirements marked **M** in sections 3, 4, and 5 are implemented and covered by automated tests or documented manual tests.

## 10. Open Questions

- Does the app target Android and iOS? What are the minimum versions of each, and also of Wear OS and watchOS?
- How does the current app generate the click today (a Flutter audio package, Dart timers)? Is the decision to replace it with a native engine of its own or with an existing native library?
- In compound meters (6/8, 9/8, 12/8), does the BPM represent the eighth note or the dotted quarter note? What is the default, and can the user change it?
- Is it feasible to start audio directly from the widget on iOS? If not, the widget button on iOS opens the app instead of playing.
- Does the watch ship in full in v1, or do Wear OS and Apple Watch ship in different phases?
- Which state management solution and which data sharing with the widget and the watch will be used to keep the single source of truth (NFR-MAN-03)?
- Do presets and setlists live in a JSON file or in a local database?
- Where do the sound samples come from, and what is their license?
- Are the default of not resuming on its own after a call (FR-BGD-07) and the default of keep-screen-on enabled (FR-CFG-02) acceptable?
- Will the app have ads or purchases? That would conflict with NFR-PRV-01 and NFR-PRV-02.

## 11. Future Considerations (not in v1)

- Progressive training, with automatic BPM increase or decrease in set steps and intervals.
- Bar muting, which silences some bars to train the sense of pulse.
- Polyrhythm, with two simultaneous pulse layers.
- Study time tracking, with a daily history.
- BPM and time signature changes within a single song, in sequence.
- A count-in before the first click (for example, a one-bar count-in).
- Automatic latency compensation for Bluetooth headphones.
- Preset and setlist sync between devices and MIDI integration.

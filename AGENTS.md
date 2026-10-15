# Metronome Agent Guide

## Project Shape

- This is a Flutter/Dart metronome app. Use the Flutter SDK pinned in `.fvmrc` when available.
- `lib/view/` contains pages and widgets; UI dispatches events to Bloc rather than owning business rules.
- `lib/blocs/` contains presentation state and interaction rules. Metronome behavior, BPM bounds, tap tempo, accents, and time signatures belong here or behind the domain interface.
- `lib/domain/` defines interfaces and value types. `lib/data/metronome_impl.dart` implements the metronome domain contract.
- `lib/ffi.dart` bridges to Android native audio. Native audio implementation and CMake configuration live under `android/app/src/main/cpp/`.
- Theme construction is centralized in `lib/shared/app_theme.dart`; color tokens live in `lib/shared/theme_colors.dart`.
- Read [DESIGN.md](DESIGN.md) before changing user-facing UI and [README.md](README.md) for project setup and usage.

## Development Commands

Run from the repository root:

```sh
flutter pub get
flutter analyze
flutter test
dart format .
flutter run
```

Use `flutter test test/path/to/test.dart` for a focused test. Release builds use the `prod` flavor; see [.github/workflows/release.yaml](.github/workflows/release.yaml).

## Dart and Flutter Conventions

- Prefer package imports such as `package:metronome/...`.
- Keep Bloc events and states as `part` files beside their Bloc implementation.
- Inject `Metronome` into `MetronomeBloc` and use `bloc_test`, `mocktail`, and test doubles rather than constructing native audio in unit tests.
- Keep business rules out of widgets and preserve existing public APIs unless the change requires otherwise.
- Follow `flutter_lints`; formatting is configured for a 120-column width with preserved trailing commas in [analysis_options.yaml](analysis_options.yaml).

## Platform and Generated Files

- The audio FFI implementation is Android-only. Do not assume `MetronomeImpl` or `MetronomeFFI` can be initialized on iOS, web, or desktop.
- Android native changes may require the configured NDK, CMake, compile SDK, and Oboe setup in `android/app/build.gradle.kts` and `android/app/src/main/cpp/CMakeLists.txt`.
- Do not manually edit `build/`, `.dart_tool/`, Flutter plugin registrants, generated xcconfig files, or other generated outputs. Regenerate them with Flutter or Gradle commands.
- Do not commit signing material such as `android/key.properties` or upload keystores.

## Validation

After code changes, run the narrowest relevant test first, then `flutter analyze`; run the full `flutter test` suite when shared Bloc, domain, native bridge, or user-facing behavior changes. For UI changes, verify both light and dark themes against the visual rules in [DESIGN.md](DESIGN.md).

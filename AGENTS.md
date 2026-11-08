# AGENTS.md — Metronome Project Rules & Architecture Blueprint

This document defines the strict architectural, coding, design, and testing rules for the **Metronome** application (`specs/prd_metronomo.md` and `specs/DESIGN.md`). All human developers and AI agents must follow these guidelines.

---

## 1. Architectural Pattern & Layering

Follow the **Flutter Architecture Best Practices** (`flutter-apply-architecture-best-practices` skill) with strict separation of concerns across three layers:

```text
lib/
├── data/
│   ├── models/         # Raw DTOs / platform / serialization models (if needed)
│   ├── repositories/   # Repository implementations (Single Source of Truth)
│   └── services/       # Stateless external/platform wrappers (e.g., MetronomeEngine)
├── domain/
│   ├── models/         # Pure Dart immutable domain models & value rules
│   └── use_cases/      # Pure Dart business logic / calculators (e.g., TapTempoCalculator)
└── ui/
    ├── core/           # "Sonic Architect" theme, colors, typography, shared components
    └── features/
        └── metronome/
            ├── view_models/  # ChangeNotifier ViewModels
            └── views/        # Lean, declarative Widgets using ListenableBuilder
```

### Layer Rules
1. **Domain Layer (`lib/domain/`) — Pure Dart Only (NFR-MAN-01)**:
   - **NEVER** import `package:flutter/...` in `lib/domain/`.
   - Domain models (`Bpm`, `TimeSignature`, `Subdivision`, `TempoMarking`, `BeatEvent`, `MetronomeState`, `BeatAccent`) and logic (`TapTempoCalculator`, `ClickScheduler`) must be 100% pure Dart so they can be unit-tested without Flutter widget bindings.
   - Use immutable classes (`const` constructors, `final` fields, value equality `==` and `hashCode`, `copyWith`). Leverage Dart 3.13+ features (primary constructors, pattern matching, switch expressions, sealed classes/enums).
2. **Data Layer (`lib/data/`)**:
   - **Services (`lib/data/services/`)**: Wrap platform channels, audio synthesis/playback engines (`MetronomeEngine`), and local storage. Behind a single abstract interface (`MetronomeEngine`) so native/in-memory implementations and test fakes (`SimulatedMetronomeEngine`) are interchangeable (NFR-MAN-02).
   - **Repositories (`lib/data/repositories/`)**: Consume services and expose domain state (`MetronomeRepository`) as the single source of truth (NFR-MAN-03).
3. **UI Layer (`lib/ui/`)**:
   - **ViewModels**: Extend `ChangeNotifier`. Receive repositories and use cases via constructor injection. Expose immutable state and command methods.
   - **Views**: Stateless or animation-only StatefulWidgets. Listen to ViewModels via `ListenableBuilder` or `provider`. Never put business calculations in widgets.
   - **Dependency Injection**: Use `package:provider` at the root (`MultiProvider`) and pass dependencies explicitly via constructors. Keep third-party dependencies minimal (NFR-MAN-05).

---

## 2. Design System Rules


see ./specs/DESIGN.md

---

## 3. Core Metronome Domain Specifications (`specs/prd_metronomo.md`)

- **BPM**: Integer range `30` to `300` (default `120`). Changes during playback apply on the next beat without interrupting the pulse.
- **Tempo Markings (FR-AND-01)**:
  - `30–59`: Largo
  - `60–65`: Larghetto
  - `66–75`: Adagio
  - `76–107`: Andante
  - `108–119`: Moderato
  - `120–155`: Allegro
  - `156–175`: Vivace
  - `176–199`: Presto
  - `200–300`: Prestissimo
- **Tap Tempo (FR-TAP-01..06)**:
  - Uses a monotonic clock (`Stopwatch` or injected timestamp source) at pointer-down (`onPointerDown`), not frame render.
  - Computes BPM from the average of recent intervals (minimum 2 taps, maximum last 8 taps / 7 intervals).
  - Resets sequence if interval between taps exceeds `2000 ms` (2 seconds). Clamps result to `[30, 300]`.
- **Time Signatures (FR-CMP-01..02)**:
  - MVP signatures: `2/4`, `3/4`, `4/4`, `6/8` (plus extensible numerator `1..16`, denominator `2, 4, 8, 16`).
  - Beat 1 (`beatIndex == 0`) is always accented (`BeatAccent.strong`). In compound meters (`6/8`), each numerator unit is 1 beat (6 beats per bar) with beat 1 strong, beat 4 (`beatIndex == 3`) medium accent (`BeatAccent.medium`), and others weak (`BeatAccent.weak`).
- **Subdivisions (FR-SUB-01..04)**:
  - None (1 click/beat), Eighth notes (2/beat), Triplets (3/beat), Sixteenth notes (4/beat).
- **Play / Stop (FR-PLY-01..04)**:
  - Always starts immediately on Beat 1 (strong beat). Stopping halts sound immediately and resets counter to Beat 1.

---

## 4. Tooling, Static Analysis & Testing Rules

- **FVM / Flutter SDK**: The project pins Flutter `3.47.8` (`.fvmrc`) with Dart `^3.13.7`.
- **Code Formatting**:
  - Remember to run the formatter with FVM (`fvm dart format .`) or via MCP every time the code changes.
- **Static Analysis (`dart-run-static-analysis` skill, NFR-MAN-04)**:
  - Zero warnings, zero errors, zero lints before completing any task.
  - Enforce `strict-casts: true`, `strict-inference: true`, and `strict-raw-types: true` in `analysis_options.yaml`.
- **Testing (`dart-add-unit-test`, `flutter-add-widget-test`, `dart-migrate-to-checks-package` skills, NFR-TST-01..03)**:
  - Mirror `lib/` structure inside `test/` with `_test.dart` suffix.
  - Prefer `package:checks` (`check(actual).equals(expected)`) for unit test assertions.
  - Every domain model, calculator, repository, ViewModel, and main UI screen must have automated tests.

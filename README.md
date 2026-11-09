<a id="readme-top"></a>
<div align="center">
  
![Flutter](https://img.shields.io/badge/Flutter-3.47.8-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.13.7-%230175C2.svg?style=for-the-badge&logo=Dart&logoColor=white)
![Provider](https://img.shields.io/badge/Provider-6.1.5-%234478e8.svg?style=for-the-badge&logo=flutter&logoColor=white)
![CI](https://github.com/MateusNavarro77/metronome/actions/workflows/ci.yaml/badge.svg)

</div>
<br />
<div align="center">
  <a href="https://github.com/MateusNavarro77/metronome">
    <img src="./readme-assets/app_logo.png" alt="Logo" width="80" height="80">
  </a>

  <h3 align="center">Metronome</h3>

  <p align="center">
    A high-precision, beautifully crafted metronome application built with Flutter, Clean Architecture, and SoLoud low-latency audio synthesis.
    <br />
    <br />
    &middot;
    <a href="https://github.com/MateusNavarro77/metronome/issues/new?labels=bug&template=bug-report---.md">Report Bug</a>
    &middot;
    <a href="https://github.com/MateusNavarro77/metronome/issues/new?labels=enhancement&template=feature-request---.md">Request Feature</a>
  </p>
</div>

<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#key-features">Key Features</a></li>
        <li><a href="#architecture--design-system">Architecture & Design System</a></li>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
        <li><a href="#running-the-app">Running the App</a></li>
        <li><a href="#running-tests">Running Tests</a></li>
        <li><a href="#build-flavors">Build Flavors</a></li>
      </ul>
    </li>
    <li><a href="#cicd--deployment">CI/CD & Deployment</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
  </ol>
</details>

## About The Project

This Metronome app is an ultra-precise, low-latency timing tool for musicians. Refactored from the ground up, it combines a pure Dart domain timing engine with **The Sonic Architect** design language—an immersive OLED dark interface with fluid visual beat pulses and neon green accents.

### Key Features

* **Precision Tempo Control (30–300 BPM):** Seamlessly adjust BPM using interactive controls or rapid increment buttons (+1, +5, -1, -5). Tempo changes take effect on the next pulse without interrupting playback.
* **Dynamic Italian Tempo Markings:** Instant visual markings across classical ranges: *Largo*, *Larghetto*, *Adagio*, *Andante*, *Moderato*, *Allegro*, *Vivace*, *Presto*, and *Prestissimo*.
* **Monotonic Tap Tempo:** Accurate tap tempo calculation based on a monotonic pointer-down clock (`Stopwatch`), averaging recent taps with an automatic 2-second timeout reset.
* **Meter & Time Signatures:** Built-in standard meters (`2/4`, `3/4`, `4/4`, `6/8`) and support for custom time signatures. Accurate accents for Beat 1 (strong), compound meters (e.g., Beat 4 in `6/8` as medium accent), and weak beats.
* **Beat Subdivisions:** Practice with quarter notes (None), eighth notes, triplets, or sixteenth notes.
* **Low-Latency PCM Synthesis:** Crystal-clear ticks synthesized via `flutter_soloud` low-latency audio engine.
* **Sonic Architect Design:** Pure OLED-friendly dark palette (`#0E0E0E` / `#131313` / `#2A2A2A`), neon green pulse accent (`#00FF41`), zero-line border design, Comfortaa typography, and WCAG AA contrast.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Architecture & Design System

The project strictly follows layered Clean Architecture principles:

```text
lib/
├── data/
│   ├── models/         # Data transfer objects
│   ├── repositories/   # MetronomeRepository (Single source of truth)
│   └── services/       # SoLoud audio synthesis & SimulatedMetronomeEngine
├── domain/
│   ├── models/         # 100% Pure Dart immutable models (Bpm, TimeSignature, Subdivision, etc.)
│   └── use_cases/      # Pure Dart logic (TapTempoCalculator, ClickScheduler)
└── ui/
    ├── core/           # Sonic Architect theme, colors, Comfortaa typography
    └── features/
        └── metronome/  # ChangeNotifier ViewModels & ListenableBuilder Views
```

* **Domain Layer (`lib/domain/`):** 100% pure Dart without any Flutter framework dependencies for maximum testability.
* **Data Layer (`lib/data/`):** Encapsulates platform audio via `MetronomeEngine` interface, interchangeable with test fakes.
* **UI Layer (`lib/ui/`):** Declarative, performant widgets listening to `MetronomeViewModel` via `ListenableBuilder`.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Built With

* [Flutter](https://flutter.dev) (v3.47.8 pinned via `.fvmrc`)
* [Dart](https://dart.dev) (^3.13.7)
* [Provider](https://pub.dev/packages/provider)
* [FlutterSoLoud](https://pub.dev/packages/flutter_soloud)
* [Google Fonts](https://pub.dev/packages/google_fonts) (Comfortaa)
* [Checks](https://pub.dev/packages/checks) (Unit & Widget testing assertions)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Getting Started

### Prerequisites

Ensure you have the Flutter SDK installed. The repository pins Flutter **3.47.8** via `.fvmrc`:

```sh
# Using FVM (recommended)
fvm install
fvm use
```

### Installation

1. Clone the repository:
   ```sh
   git clone https://github.com/MateusNavarro77/metronome.git
   cd metronome
   ```

2. Install dependencies:
   ```sh
   flutter pub get
   ```

### Running the App

Run with the desired flavor:

```sh
# Development flavor
flutter run --flavor dev

# Production flavor
flutter run --flavor prod
```

### Running Tests

Run the full suite of unit and widget tests:

```sh
flutter test
```

Run static analysis:

```sh
flutter analyze --fatal-infos
```

### Build Flavors

The Android project is configured with product flavors:

| Flavor | Application ID | App Name |
| :--- | :--- | :--- |
| **`dev`** | `com.mateusnavarro77.metronome.dev` | Metronome Dev |
| **`prod`** | `com.mateusnavarro77.metronome` | Metronome |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## CI/CD & Deployment

Automated pipelines are configured with GitHub Actions:

* **CI (`.github/workflows/ci.yaml`):** Runs on push and pull requests to `main` and feature branches. Verifies formatting (`dart format`), static analysis (`flutter analyze --fatal-infos`), and executes all unit and widget tests (`flutter test`).
* **Release (`.github/workflows/release.yaml`):** Triggered on GitHub Release creation or via manual dispatch. Sets up Java 17 and Flutter 3.47.8, decodes keystore credentials, builds an optimized release AAB (`flutter build appbundle --release --flavor prod`), and uploads directly to Google Play Store internal track.

### Required Secrets for Release

* `KEYSTORE_BASE64`: Base64-encoded upload keystore (`upload-keystore.jks`)
* `KEYSTORE_PASSWORD`: Password for keystore
* `KEY_PASSWORD`: Password for key alias
* `KEY_ALIAS`: Alias of the signing key
* `PLAY_SERVICE_ACCOUNT_JSON`: Google Play Console service account credentials JSON

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

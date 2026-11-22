fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## Android

### android screenshots

```sh
[bundle exec] fastlane android screenshots
```

Generate Play Store phone and tablet screenshots using Flutter golden tests

### android deploy_metadata

```sh
[bundle exec] fastlane android deploy_metadata
```

Upload Play Store listing metadata, icons, feature graphics, and screenshots

### android internal

```sh
[bundle exec] fastlane android internal
```

Build prod AAB with auto-incremented versionCode and upload to Play Store internal track

### android promote_to_beta

```sh
[bundle exec] fastlane android promote_to_beta
```

Promote latest internal release to beta track without rebuilding

### android promote_to_prod

```sh
[bundle exec] fastlane android promote_to_prod
```

Promote latest beta release to production track with staged rollout

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).

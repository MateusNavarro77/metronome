import 'package:package_info_plus/package_info_plus.dart';

/// Immutable representation of the application's version metadata.
class AppVersionInfo {
  const AppVersionInfo({required this.version, required this.buildNumber});

  /// Semantic version string (e.g., `1.3.0-alpha.2`).
  final String version;

  /// Platform build number / versionCode (e.g., `1`).
  final String buildNumber;

  /// Formatted `version+buildNumber` string when [buildNumber] is non-empty,
  /// otherwise [version].
  String get formatted =>
      buildNumber.isNotEmpty ? '$version+$buildNumber' : version;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppVersionInfo &&
          runtimeType == other.runtimeType &&
          version == other.version &&
          buildNumber == other.buildNumber;

  @override
  int get hashCode => Object.hash(version, buildNumber);
}

/// Service interface for reading application version metadata.
abstract interface class AppInfoService {
  /// Returns the current [AppVersionInfo].
  Future<AppVersionInfo> getAppVersion();
}

/// [AppInfoService] backed by `package:package_info_plus`.
class PackageInfoAppInfoService implements AppInfoService {
  const PackageInfoAppInfoService();

  @override
  Future<AppVersionInfo> getAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    return AppVersionInfo(version: info.version, buildNumber: info.buildNumber);
  }
}

/// In-memory [AppInfoService] for testing and fallback defaults.
class FakeAppInfoService implements AppInfoService {
  const FakeAppInfoService({
    this.info = const AppVersionInfo(
      version: '1.3.0-alpha.2',
      buildNumber: '1',
    ),
  });

  final AppVersionInfo info;

  @override
  Future<AppVersionInfo> getAppVersion() async => info;
}

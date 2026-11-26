import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Service interface for launching external URLs.
abstract interface class UrlLauncherService {
  /// Attempts to open [uri] in an external application.
  ///
  /// Returns `true` if the URL was launched successfully, `false` otherwise.
  Future<bool> openUrl(Uri uri);
}

/// [UrlLauncherService] backed by `package:url_launcher`.
class ExternalUrlLauncherService implements UrlLauncherService {
  const ExternalUrlLauncherService();

  @override
  Future<bool> openUrl(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on PlatformException {
      return false;
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'wakelock_service.dart';

/// [WakelockService] implementation backed by `package:wakelock_plus`
/// (FR-CFG-02).
class WakelockPlusService implements WakelockService {
  @override
  Future<void> setEnabled(bool enabled) async {
    try {
      await WakelockPlus.toggle(enable: enabled);
    } on MissingPluginException {
      // Safe no-op in headless/test runners without platform channels.
    } on PlatformException catch (error) {
      debugPrint('WakelockPlusService: failed to toggle($enabled): $error');
    }
  }

  @override
  Future<void> dispose() async {
    await setEnabled(false);
  }
}

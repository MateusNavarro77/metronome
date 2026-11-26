/// Abstract platform service controlling the device screen wake lock
/// (FR-CFG-02, NFR-MAN-02).
abstract interface class WakelockService {
  /// Enables or disables keeping the device screen awake.
  Future<void> setEnabled(bool enabled);

  /// Releases any resources held by the service.
  Future<void> dispose();
}

/// Safe no-op [WakelockService] for tests and unsupported platforms.
class NoopWakelockService implements WakelockService {
  @override
  Future<void> setEnabled(bool enabled) async {}

  @override
  Future<void> dispose() async {}
}

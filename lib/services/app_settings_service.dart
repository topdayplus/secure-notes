import 'secure_value_store.dart';

class AppSettings {
  const AppSettings({
    required this.autoLockDelaySeconds,
    required this.startupPasscodeEnabled,
  });

  final int autoLockDelaySeconds;
  final bool? startupPasscodeEnabled;

  bool get alwaysLockOnResume => autoLockDelaySeconds == 0;

  bool get neverAutoLock => autoLockDelaySeconds < 0;

  AppSettings copyWith({
    int? autoLockDelaySeconds,
    bool? startupPasscodeEnabled,
  }) {
    return AppSettings(
      autoLockDelaySeconds: autoLockDelaySeconds ?? this.autoLockDelaySeconds,
      startupPasscodeEnabled:
          startupPasscodeEnabled ?? this.startupPasscodeEnabled,
    );
  }
}

class AppSettingsService {
  const AppSettingsService(this._store);

  static const _autoLockDelaySecondsKey = 'auto_lock_delay_seconds_v1';
  static const _startupPasscodeEnabledKey = 'startup_passcode_enabled_v1';
  static const defaultAutoLockDelaySeconds = 0;

  final SecureValueStore _store;

  Future<AppSettings> load() async {
    final values = await Future.wait([
      _store.read(_autoLockDelaySecondsKey),
      _store.read(_startupPasscodeEnabledKey),
    ]);
    return AppSettings(
      autoLockDelaySeconds:
          int.tryParse(values[0] ?? '') ?? defaultAutoLockDelaySeconds,
      startupPasscodeEnabled: _readBool(values[1]),
    );
  }

  Future<void> saveAutoLockDelaySeconds(int seconds) {
    return _store.write(_autoLockDelaySecondsKey, seconds.toString());
  }

  Future<void> saveStartupPasscodeEnabled(bool enabled) {
    return _store.write(_startupPasscodeEnabledKey, enabled.toString());
  }

  bool? _readBool(String? value) {
    return switch (value) {
      'true' => true,
      'false' => false,
      _ => null,
    };
  }
}

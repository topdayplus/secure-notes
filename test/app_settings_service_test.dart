import 'package:flutter_test/flutter_test.dart';
import 'package:secure_notes_app/services/app_settings_service.dart';
import 'package:secure_notes_app/services/secure_value_store.dart';

class MemorySecureValueStore implements SecureValueStore {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }
}

void main() {
  test('loads default auto-lock setting', () async {
    final service = AppSettingsService(MemorySecureValueStore());

    final settings = await service.load();

    expect(settings.autoLockDelaySeconds, 0);
    expect(settings.alwaysLockOnResume, isTrue);
    expect(settings.startupPasscodeEnabled, isNull);
  });

  test('saves auto-lock delay setting', () async {
    final service = AppSettingsService(MemorySecureValueStore());

    await service.saveAutoLockDelaySeconds(300);
    final settings = await service.load();

    expect(settings.autoLockDelaySeconds, 300);
    expect(settings.alwaysLockOnResume, isFalse);
    expect(settings.neverAutoLock, isFalse);
  });

  test('saves startup passcode setting', () async {
    final service = AppSettingsService(MemorySecureValueStore());

    await service.saveStartupPasscodeEnabled(false);
    var settings = await service.load();

    expect(settings.startupPasscodeEnabled, isFalse);

    await service.saveStartupPasscodeEnabled(true);
    settings = await service.load();

    expect(settings.startupPasscodeEnabled, isTrue);
  });

  test('supports never auto-lock setting', () async {
    final service = AppSettingsService(MemorySecureValueStore());

    await service.saveAutoLockDelaySeconds(-1);
    final settings = await service.load();

    expect(settings.neverAutoLock, isTrue);
  });
}

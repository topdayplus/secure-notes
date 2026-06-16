import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class SecureValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

class PlatformSecureValueStore implements SecureValueStore {
  const PlatformSecureValueStore();

  static const _storage = FlutterSecureStorage();

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) {
    return _storage.write(key: key, value: value);
  }
}

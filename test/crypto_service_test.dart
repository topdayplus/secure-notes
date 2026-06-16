import 'package:flutter_test/flutter_test.dart';
import 'package:secure_notes_app/services/crypto_service.dart';
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
  test(
    'encrypts and decrypts a note value without storing plaintext',
    () async {
      final store = MemorySecureValueStore();
      final crypto = CryptoService(store);

      final encrypted = await crypto.encryptString('bank card pin 123456');
      final decrypted = await crypto.decryptString(encrypted);

      expect(decrypted, 'bank card pin 123456');
      expect(encrypted.cipherText, isNot(contains('123456')));
      expect(store.values.values.join('\n'), isNot(contains('123456')));
    },
  );

  test('verifies passcode with derived hash', () async {
    final crypto = CryptoService(MemorySecureValueStore());

    await crypto.setPasscode('123456');

    expect(await crypto.verifyPasscode('123456'), isTrue);
    expect(await crypto.verifyPasscode('654321'), isFalse);
  });

  test('changes passcode only after verifying current passcode', () async {
    final crypto = CryptoService(MemorySecureValueStore());

    await crypto.setPasscode('123456');

    expect(
      await crypto.changePasscode(
        currentPasscode: 'wrong-passcode',
        newPasscode: '654321',
      ),
      isFalse,
    );
    expect(await crypto.verifyPasscode('123456'), isTrue);

    expect(
      await crypto.changePasscode(
        currentPasscode: '123456',
        newPasscode: '654321',
      ),
      isTrue,
    );
    expect(await crypto.verifyPasscode('123456'), isFalse);
    expect(await crypto.verifyPasscode('654321'), isTrue);
  });
}

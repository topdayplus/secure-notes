import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'secure_value_store.dart';

class EncryptedValue {
  const EncryptedValue({
    required this.cipherText,
    required this.nonce,
    required this.mac,
  });

  final String cipherText;
  final String nonce;
  final String mac;
}

class CryptoService {
  CryptoService(this._store);

  static const _masterKey = 'master_key_v1';
  static const _passcodeSalt = 'passcode_salt_v1';
  static const _passcodeHash = 'passcode_hash_v1';

  final SecureValueStore _store;
  final AesGcm _cipher = AesGcm.with256bits();
  final Pbkdf2 _passcodeKdf = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 210000,
    bits: 256,
  );
  final Random _random = Random.secure();

  Future<bool> hasPasscode() async {
    return await _store.read(_passcodeHash) != null;
  }

  Future<void> setPasscode(String passcode) async {
    final salt = _randomBytes(16);
    final hash = await _derivePasscodeHash(passcode, salt);
    await _store.write(_passcodeSalt, base64Encode(salt));
    await _store.write(_passcodeHash, base64Encode(hash));
  }

  Future<bool> verifyPasscode(String passcode) async {
    final saltValue = await _store.read(_passcodeSalt);
    final hashValue = await _store.read(_passcodeHash);
    if (saltValue == null || hashValue == null) {
      return false;
    }

    final salt = base64Decode(saltValue);
    final expectedHash = base64Decode(hashValue);
    final actualHash = await _derivePasscodeHash(passcode, salt);
    return _constantTimeEquals(expectedHash, actualHash);
  }

  Future<bool> changePasscode({
    required String currentPasscode,
    required String newPasscode,
  }) async {
    if (!await verifyPasscode(currentPasscode)) {
      return false;
    }
    await setPasscode(newPasscode);
    return true;
  }

  Future<EncryptedValue> encryptString(String value) async {
    final secretKey = await _loadMasterKey();
    final nonce = _randomBytes(12);
    final secretBox = await _cipher.encrypt(
      utf8.encode(value),
      secretKey: secretKey,
      nonce: nonce,
    );
    return EncryptedValue(
      cipherText: base64Encode(secretBox.cipherText),
      nonce: base64Encode(secretBox.nonce),
      mac: base64Encode(secretBox.mac.bytes),
    );
  }

  Future<String> decryptString(EncryptedValue value) async {
    final secretKey = await _loadMasterKey();
    final secretBox = SecretBox(
      base64Decode(value.cipherText),
      nonce: base64Decode(value.nonce),
      mac: Mac(base64Decode(value.mac)),
    );
    final clearText = await _cipher.decrypt(secretBox, secretKey: secretKey);
    return utf8.decode(clearText);
  }

  Future<SecretKey> _loadMasterKey() async {
    final storedKey = await _store.read(_masterKey);
    if (storedKey != null) {
      return SecretKey(base64Decode(storedKey));
    }

    final bytes = _randomBytes(32);
    await _store.write(_masterKey, base64Encode(bytes));
    return SecretKey(bytes);
  }

  Future<List<int>> _derivePasscodeHash(String passcode, List<int> salt) async {
    final key = await _passcodeKdf.deriveKey(
      secretKey: SecretKey(utf8.encode(passcode)),
      nonce: salt,
    );
    return key.extractBytes();
  }

  Uint8List _randomBytes(int length) {
    return Uint8List.fromList(
      List<int>.generate(length, (_) => _random.nextInt(256)),
    );
  }

  bool _constantTimeEquals(List<int> left, List<int> right) {
    if (left.length != right.length) {
      return false;
    }

    var diff = 0;
    for (var i = 0; i < left.length; i += 1) {
      diff |= left[i] ^ right[i];
    }
    return diff == 0;
  }
}

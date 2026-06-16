import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import '../models/note.dart';

class MigrationPackageException implements Exception {
  const MigrationPackageException(this.message);

  final String message;

  @override
  String toString() => message;
}

class MigrationPackageService {
  MigrationPackageService();

  static const _version = 2;
  static const _legacyVersion = 1;
  static const _iterations = 210000;

  final AesGcm _cipher = AesGcm.with256bits();
  final Pbkdf2 _kdf = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: _iterations,
    bits: 256,
  );
  final Random _random = Random.secure();

  Future<String> exportNotes({
    required List<Note> notes,
    required String passphrase,
  }) async {
    final normalizedPassphrase = passphrase.trim();
    if (normalizedPassphrase.length < 8) {
      throw const MigrationPackageException(
        'Migration passphrase must be at least 8 characters.',
      );
    }

    final salt = _randomBytes(16);
    final nonce = _randomBytes(12);
    final secretKey = await _deriveKey(normalizedPassphrase, salt);
    final payload = gzip.encode(
      utf8.encode(jsonEncode({'notes': notes.map(_noteToJson).toList()})),
    );
    final secretBox = await _cipher.encrypt(
      payload,
      secretKey: secretKey,
      nonce: nonce,
    );
    final envelope = {
      'version': _version,
      'kdf': 'pbkdf2-hmac-sha256',
      'iterations': _iterations,
      'compression': 'gzip',
      'salt': base64Encode(salt),
      'nonce': base64Encode(secretBox.nonce),
      'mac': base64Encode(secretBox.mac.bytes),
      'cipherText': base64Encode(secretBox.cipherText),
    };
    return base64UrlEncode(utf8.encode(jsonEncode(envelope)));
  }

  Future<List<Note>> importNotes({
    required String packageText,
    required String passphrase,
  }) async {
    final normalizedPassphrase = passphrase.trim();
    if (normalizedPassphrase.length < 8) {
      throw const MigrationPackageException(
        'Migration passphrase must be at least 8 characters.',
      );
    }

    try {
      final envelope = jsonDecode(
        utf8.decode(base64Url.decode(packageText.trim())),
      );
      if (envelope is! Map<String, Object?> ||
          (envelope['version'] != _version &&
              envelope['version'] != _legacyVersion)) {
        throw const MigrationPackageException('Unsupported migration package.');
      }

      final salt = base64Decode(_readString(envelope, 'salt'));
      final secretKey = await _deriveKey(normalizedPassphrase, salt);
      final secretBox = SecretBox(
        base64Decode(_readString(envelope, 'cipherText')),
        nonce: base64Decode(_readString(envelope, 'nonce')),
        mac: Mac(base64Decode(_readString(envelope, 'mac'))),
      );
      final clearText = await _cipher.decrypt(secretBox, secretKey: secretKey);
      final payloadText = envelope['version'] == _version
          ? utf8.decode(gzip.decode(clearText))
          : utf8.decode(clearText);
      final payload = jsonDecode(payloadText);
      if (payload is! Map<String, Object?> || payload['notes'] is! List) {
        throw const MigrationPackageException('Invalid migration payload.');
      }

      return (payload['notes'] as List<Object?>)
          .whereType<Map<String, Object?>>()
          .map(_noteFromJson)
          .toList();
    } on MigrationPackageException {
      rethrow;
    } catch (_) {
      throw const MigrationPackageException(
        'Cannot decrypt migration package. Check the package text and passphrase.',
      );
    }
  }

  Future<SecretKey> _deriveKey(String passphrase, List<int> salt) {
    return _kdf.deriveKey(
      secretKey: SecretKey(utf8.encode(passphrase)),
      nonce: salt,
    );
  }

  Map<String, Object?> _noteToJson(Note note) {
    return {
      'id': note.id,
      'type': note.type.value,
      'title': note.title,
      'body': note.body,
      'fields': note.fields,
      'createdAt': note.createdAt.millisecondsSinceEpoch,
      'updatedAt': note.updatedAt.millisecondsSinceEpoch,
    };
  }

  Note _noteFromJson(Map<String, Object?> json) {
    final fields = json['fields'];
    return Note(
      id: _readString(json, 'id'),
      type: NoteType.fromValue(_readString(json, 'type')),
      title: _readString(json, 'title'),
      body: _readString(json, 'body'),
      fields: fields is Map<String, Object?>
          ? fields.map((key, value) => MapEntry(key, value?.toString() ?? ''))
          : const {},
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        _readInt(json, 'createdAt'),
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        _readInt(json, 'updatedAt'),
      ),
    );
  }

  String _readString(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is! String) {
      throw const MigrationPackageException('Invalid migration package.');
    }
    return value;
  }

  int _readInt(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is! int) {
      throw const MigrationPackageException('Invalid migration package.');
    }
    return value;
  }

  Uint8List _randomBytes(int length) {
    return Uint8List.fromList(
      List<int>.generate(length, (_) => _random.nextInt(256)),
    );
  }
}

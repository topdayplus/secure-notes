import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../models/note.dart';
import 'crypto_service.dart';
import 'note_database.dart';

class StorageAuditResult {
  const StorageAuditResult({
    required this.checkedNotes,
    required this.plaintextLeakCount,
  });

  final int checkedNotes;
  final int plaintextLeakCount;

  bool get passed => plaintextLeakCount == 0;
}

class NoteRepository {
  NoteRepository({
    required NoteDatabase database,
    required CryptoService crypto,
  }) : this._(database, crypto);

  NoteRepository._(this._database, this._crypto);

  final NoteDatabase _database;
  final CryptoService _crypto;
  final Uuid _uuid = const Uuid();

  Future<List<Note>> listNotes({String query = ''}) async {
    final records = await _database.listNotes();
    final notes = <Note>[];
    for (final record in records) {
      final note = await _decryptRecord(record);
      if (_matches(note, query)) {
        notes.add(note);
      }
    }
    return notes;
  }

  Future<Note?> readNote(String id) async {
    final record = await _database.readNote(id);
    if (record == null) {
      return null;
    }
    return _decryptRecord(record);
  }

  Future<Note> createNote({
    required NoteType type,
    required String title,
    required String body,
    Map<String, String> fields = const {},
  }) async {
    final now = DateTime.now();
    final note = Note(
      id: _uuid.v4(),
      type: type,
      title: title.trim().isEmpty ? 'Untitled' : title.trim(),
      body: body,
      fields: fields,
      createdAt: now,
      updatedAt: now,
    );
    await _database.upsertNote(await _encryptNote(note));
    return note;
  }

  Future<Note> updateNote(
    Note note, {
    required NoteType type,
    required String title,
    required String body,
    Map<String, String> fields = const {},
  }) async {
    final updated = note.copyWith(
      type: type,
      title: title.trim().isEmpty ? 'Untitled' : title.trim(),
      body: body,
      fields: fields,
      updatedAt: DateTime.now(),
    );
    await _database.upsertNote(await _encryptNote(updated));
    return updated;
  }

  Future<void> deleteNote(String id) {
    return _database.deleteNote(id);
  }

  Future<void> importNotes(
    List<Note> notes, {
    void Function(int imported, int total)? onProgress,
  }) async {
    for (var index = 0; index < notes.length; index += 1) {
      final note = notes[index];
      await _database.upsertNote(await _encryptNote(note));
      onProgress?.call(index + 1, notes.length);
    }
  }

  Future<StorageAuditResult> auditPlaintextStorage() async {
    final records = await _database.listNotes();
    var leaks = 0;

    for (final record in records) {
      final note = await _decryptRecord(record);
      final storedValues = [
        record.titleCipherText,
        record.titleNonce,
        record.titleMac,
        record.bodyCipherText,
        record.bodyNonce,
        record.bodyMac,
        record.typeCipherText,
        record.typeNonce,
        record.typeMac,
        record.fieldsCipherText,
        record.fieldsNonce,
        record.fieldsMac,
      ].join('\n');

      if (_containsMeaningfulPlaintext(storedValues, note.title) ||
          _containsMeaningfulPlaintext(storedValues, note.body) ||
          note.fields.values.any(
            (value) => _containsMeaningfulPlaintext(storedValues, value),
          )) {
        leaks += 1;
      }
    }

    return StorageAuditResult(
      checkedNotes: records.length,
      plaintextLeakCount: leaks,
    );
  }

  Future<NoteRecord> _encryptNote(Note note) async {
    final encryptedType = await _crypto.encryptString(note.type.value);
    final encryptedTitle = await _crypto.encryptString(note.title);
    final encryptedBody = await _crypto.encryptString(note.body);
    final encryptedFields = await _crypto.encryptString(
      jsonEncode(note.fields),
    );
    return NoteRecord(
      id: note.id,
      typeCipherText: encryptedType.cipherText,
      typeNonce: encryptedType.nonce,
      typeMac: encryptedType.mac,
      titleCipherText: encryptedTitle.cipherText,
      titleNonce: encryptedTitle.nonce,
      titleMac: encryptedTitle.mac,
      bodyCipherText: encryptedBody.cipherText,
      bodyNonce: encryptedBody.nonce,
      bodyMac: encryptedBody.mac,
      fieldsCipherText: encryptedFields.cipherText,
      fieldsNonce: encryptedFields.nonce,
      fieldsMac: encryptedFields.mac,
      createdAt: note.createdAt.millisecondsSinceEpoch,
      updatedAt: note.updatedAt.millisecondsSinceEpoch,
    );
  }

  Future<Note> _decryptRecord(NoteRecord record) async {
    final typeValue = record.typeCipherText.isEmpty
        ? NoteType.plain.value
        : await _crypto.decryptString(
            EncryptedValue(
              cipherText: record.typeCipherText,
              nonce: record.typeNonce,
              mac: record.typeMac,
            ),
          );
    final title = await _crypto.decryptString(
      EncryptedValue(
        cipherText: record.titleCipherText,
        nonce: record.titleNonce,
        mac: record.titleMac,
      ),
    );
    final body = await _crypto.decryptString(
      EncryptedValue(
        cipherText: record.bodyCipherText,
        nonce: record.bodyNonce,
        mac: record.bodyMac,
      ),
    );
    final fields = record.fieldsCipherText.isEmpty
        ? <String, String>{}
        : _decodeFields(
            await _crypto.decryptString(
              EncryptedValue(
                cipherText: record.fieldsCipherText,
                nonce: record.fieldsNonce,
                mac: record.fieldsMac,
              ),
            ),
          );
    return Note(
      id: record.id,
      type: NoteType.fromValue(typeValue),
      title: title,
      body: body,
      fields: fields,
      createdAt: DateTime.fromMillisecondsSinceEpoch(record.createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(record.updatedAt),
    );
  }

  bool _matches(Note note, String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return true;
    }
    if (note.type == NoteType.credential) {
      return note.title.toLowerCase().contains(normalizedQuery) ||
          (note.fields['website'] ?? '').toLowerCase().contains(
            normalizedQuery,
          ) ||
          (note.fields['remark'] ?? '').toLowerCase().contains(normalizedQuery);
    }
    return note.title.toLowerCase().contains(normalizedQuery) ||
        note.body.toLowerCase().contains(normalizedQuery) ||
        note.fields.values.any(
          (value) => value.toLowerCase().contains(normalizedQuery),
        );
  }

  bool _containsMeaningfulPlaintext(String storedValues, String plaintext) {
    final normalized = plaintext.trim();
    if (normalized.length < 4) {
      return false;
    }
    return storedValues.contains(normalized);
  }

  Map<String, String> _decodeFields(String value) {
    final decoded = jsonDecode(value);
    if (decoded is! Map<String, Object?>) {
      return {};
    }
    return decoded.map((key, value) => MapEntry(key, value?.toString() ?? ''));
  }
}

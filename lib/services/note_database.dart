import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class NoteRecord {
  const NoteRecord({
    required this.id,
    required this.typeCipherText,
    required this.typeNonce,
    required this.typeMac,
    required this.titleCipherText,
    required this.titleNonce,
    required this.titleMac,
    required this.bodyCipherText,
    required this.bodyNonce,
    required this.bodyMac,
    required this.fieldsCipherText,
    required this.fieldsNonce,
    required this.fieldsMac,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String typeCipherText;
  final String typeNonce;
  final String typeMac;
  final String titleCipherText;
  final String titleNonce;
  final String titleMac;
  final String bodyCipherText;
  final String bodyNonce;
  final String bodyMac;
  final String fieldsCipherText;
  final String fieldsNonce;
  final String fieldsMac;
  final int createdAt;
  final int updatedAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'type_cipher_text': typeCipherText,
      'type_nonce': typeNonce,
      'type_mac': typeMac,
      'title_cipher_text': titleCipherText,
      'title_nonce': titleNonce,
      'title_mac': titleMac,
      'body_cipher_text': bodyCipherText,
      'body_nonce': bodyNonce,
      'body_mac': bodyMac,
      'fields_cipher_text': fieldsCipherText,
      'fields_nonce': fieldsNonce,
      'fields_mac': fieldsMac,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  static NoteRecord fromMap(Map<String, Object?> map) {
    return NoteRecord(
      id: map['id'] as String,
      typeCipherText: map['type_cipher_text'] as String? ?? '',
      typeNonce: map['type_nonce'] as String? ?? '',
      typeMac: map['type_mac'] as String? ?? '',
      titleCipherText: map['title_cipher_text'] as String,
      titleNonce: map['title_nonce'] as String,
      titleMac: map['title_mac'] as String,
      bodyCipherText: map['body_cipher_text'] as String,
      bodyNonce: map['body_nonce'] as String,
      bodyMac: map['body_mac'] as String,
      fieldsCipherText: map['fields_cipher_text'] as String? ?? '',
      fieldsNonce: map['fields_nonce'] as String? ?? '',
      fieldsMac: map['fields_mac'] as String? ?? '',
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }
}

class NoteDatabase {
  Database? _database;

  Future<List<NoteRecord>> listNotes() async {
    final db = await _open();
    final rows = await db.query('notes', orderBy: 'updated_at DESC');
    return rows.map(NoteRecord.fromMap).toList();
  }

  Future<NoteRecord?> readNote(String id) async {
    final db = await _open();
    final rows = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return NoteRecord.fromMap(rows.first);
  }

  Future<void> upsertNote(NoteRecord note) async {
    final db = await _open();
    await db.insert(
      'notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteNote(String id) async {
    final db = await _open();
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllNotes() async {
    final db = await _open();
    await db.delete('notes');
  }

  Future<Database> _open() async {
    final existing = _database;
    if (existing != null) {
      return existing;
    }

    final databasePath = await getDatabasesPath();
    final path = p.join(databasePath, 'secure_notes.db');
    _database = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes (
            id TEXT PRIMARY KEY,
            type_cipher_text TEXT NOT NULL DEFAULT '',
            type_nonce TEXT NOT NULL DEFAULT '',
            type_mac TEXT NOT NULL DEFAULT '',
            title_cipher_text TEXT NOT NULL,
            title_nonce TEXT NOT NULL,
            title_mac TEXT NOT NULL,
            body_cipher_text TEXT NOT NULL,
            body_nonce TEXT NOT NULL,
            body_mac TEXT NOT NULL,
            fields_cipher_text TEXT NOT NULL DEFAULT '',
            fields_nonce TEXT NOT NULL DEFAULT '',
            fields_mac TEXT NOT NULL DEFAULT '',
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            "ALTER TABLE notes ADD COLUMN type_cipher_text TEXT NOT NULL DEFAULT ''",
          );
          await db.execute(
            "ALTER TABLE notes ADD COLUMN type_nonce TEXT NOT NULL DEFAULT ''",
          );
          await db.execute(
            "ALTER TABLE notes ADD COLUMN type_mac TEXT NOT NULL DEFAULT ''",
          );
          await db.execute(
            "ALTER TABLE notes ADD COLUMN fields_cipher_text TEXT NOT NULL DEFAULT ''",
          );
          await db.execute(
            "ALTER TABLE notes ADD COLUMN fields_nonce TEXT NOT NULL DEFAULT ''",
          );
          await db.execute(
            "ALTER TABLE notes ADD COLUMN fields_mac TEXT NOT NULL DEFAULT ''",
          );
        }
      },
    );
    return _database!;
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:secure_notes_app/models/note.dart';
import 'package:secure_notes_app/services/migration_package_service.dart';

void main() {
  test('exports encrypted package and imports notes with passphrase', () async {
    final service = MigrationPackageService();
    final notes = [
      Note(
        id: 'note-1',
        type: NoteType.credential,
        title: 'Bank account',
        body: 'private body 123456',
        fields: const {'account': 'topday', 'password': 'sensitive-password'},
        createdAt: DateTime.fromMillisecondsSinceEpoch(1000),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(2000),
      ),
    ];

    final package = await service.exportNotes(
      notes: notes,
      passphrase: 'transfer-passphrase',
    );
    final imported = await service.importNotes(
      packageText: package,
      passphrase: 'transfer-passphrase',
    );

    expect(package, isNot(contains('Bank account')));
    expect(package, isNot(contains('sensitive-password')));
    expect(imported, hasLength(1));
    expect(imported.first.id, 'note-1');
    expect(imported.first.type, NoteType.credential);
    expect(imported.first.title, 'Bank account');
    expect(imported.first.body, 'private body 123456');
    expect(imported.first.fields['password'], 'sensitive-password');
  });

  test('exports compressed version 2 package envelope', () async {
    final service = MigrationPackageService();

    final package = await service.exportNotes(
      notes: [
        Note(
          id: 'note-1',
          type: NoteType.plain,
          title: 'Repeated',
          body: 'secret ' * 100,
          fields: const {},
          createdAt: DateTime.fromMillisecondsSinceEpoch(1000),
          updatedAt: DateTime.fromMillisecondsSinceEpoch(2000),
        ),
      ],
      passphrase: 'transfer-passphrase',
    );
    final envelope = jsonDecode(utf8.decode(base64Url.decode(package)));

    expect(envelope['version'], 2);
    expect(envelope['compression'], 'gzip');
    expect(package, isNot(contains('Repeated')));
    expect(package, isNot(contains('secret')));
  });

  test('rejects wrong migration passphrase', () async {
    final service = MigrationPackageService();
    final package = await service.exportNotes(
      notes: [
        Note(
          id: 'note-1',
          type: NoteType.plain,
          title: 'Secret',
          body: 'body',
          fields: const {},
          createdAt: DateTime.fromMillisecondsSinceEpoch(1000),
          updatedAt: DateTime.fromMillisecondsSinceEpoch(2000),
        ),
      ],
      passphrase: 'correct-passphrase',
    );

    expect(
      () => service.importNotes(
        packageText: package,
        passphrase: 'wrong-passphrase',
      ),
      throwsA(isA<MigrationPackageException>()),
    );
  });

  test('imports generated single-note migration fixture', () async {
    final service = MigrationPackageService();
    final file = File(
      'build/migration-test/secure-notes-dart-seed-1-20260613-141851.snote',
    );

    final imported = await service.importNotes(
      packageText: await file.readAsString(),
      passphrase: 'SNote-dart-single-20260613-141851',
    );

    expect(imported, hasLength(1));
    expect(imported.first.title, '单条迁移测试');
  });
}

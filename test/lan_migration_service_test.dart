import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:secure_notes_app/models/note.dart';
import 'package:secure_notes_app/services/lan_migration_service.dart';
import 'package:secure_notes_app/services/migration_package_service.dart';

void main() {
  test('serves LAN migration payload after sender approval', () async {
    final service = LanMigrationService(
      MigrationPackageService(),
      advertisedAddress: '127.0.0.1',
      sessionTtl: const Duration(minutes: 1),
    );
    final server = await service.startServer(
      notes: [
        Note(
          id: 'note-1',
          type: NoteType.credential,
          title: 'Bank',
          body: 'private',
          fields: const {'account': 'topday', 'password': 'secret'},
          createdAt: DateTime.fromMillisecondsSinceEpoch(1000),
          updatedAt: DateTime.fromMillisecondsSinceEpoch(2000),
        ),
      ],
      passphrase: 'transfer-passphrase',
      onReceiveRequest: (request) {
        request.approve();
      },
    );

    final firstPayload = await service.fetchPayload(server.session.url);
    final secondPayload = await service.fetchPayload(server.session.url);

    expect(firstPayload.noteCount, 1);
    expect(firstPayload.confirmationCode, server.session.confirmationCode);
    expect(secondPayload.noteCount, 1);
    expect(secondPayload.confirmationCode, server.session.confirmationCode);
    await server.stop();
    await server.closed;
    expect(
      () => service.fetchPayload(server.session.url),
      throwsA(isA<MigrationPackageException>()),
    );
  });

  test('rejects browser-style request without app migration header', () async {
    final service = LanMigrationService(
      MigrationPackageService(),
      advertisedAddress: '127.0.0.1',
      sessionTtl: const Duration(minutes: 1),
    );
    final server = await service.startServer(
      notes: [
        Note(
          id: 'note-1',
          type: NoteType.plain,
          title: 'Secret',
          body: 'private',
          fields: const {},
          createdAt: DateTime.fromMillisecondsSinceEpoch(1000),
          updatedAt: DateTime.fromMillisecondsSinceEpoch(2000),
        ),
      ],
      passphrase: 'transfer-passphrase',
    );

    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(server.session.url));
    final response = await request.close();
    final body = await utf8.decodeStream(response);
    client.close(force: true);

    expect(response.statusCode, HttpStatus.forbidden);
    expect(body, contains('app_client_required'));
    await server.stop();
  });
}

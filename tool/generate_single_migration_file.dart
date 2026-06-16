import 'dart:io';

import 'package:secure_notes_app/models/note.dart';
import 'package:secure_notes_app/services/migration_package_service.dart';

Future<void> main() async {
  final count = int.tryParse(Platform.environment['NOTE_COUNT'] ?? '') ?? 1;
  final now = DateTime.now();
  final stamp = [
    now.year.toString().padLeft(4, '0'),
    now.month.toString().padLeft(2, '0'),
    now.day.toString().padLeft(2, '0'),
    '-',
    now.hour.toString().padLeft(2, '0'),
    now.minute.toString().padLeft(2, '0'),
    now.second.toString().padLeft(2, '0'),
  ].join();
  final passphrase = 'SNote-dart-$count-$stamp';
  final notes = List<Note>.generate(count, (index) {
    final number = (index + 1).toString().padLeft(4, '0');
    return Note(
      id: 'seed-$count-$stamp-$number',
      type: NoteType.plain,
      title: '测试便签 $number',
      body:
          '这是一条由 App 迁移服务生成的测试便签。编号: $number。生成时间: ${now.toIso8601String()}。\n'
          '用于验证加密迁移文件导入、列表刷新和大数据迁移性能。',
      fields: const {},
      createdAt: now.add(Duration(milliseconds: index)),
      updatedAt: now.add(Duration(milliseconds: index)),
    );
  });

  final package = await MigrationPackageService().exportNotes(
    notes: notes,
    passphrase: passphrase,
  );

  final outputDirectory = Directory('build/migration-test');
  await outputDirectory.create(recursive: true);
  final baseName = 'secure-notes-dart-seed-$count-$stamp';
  final packageFile = File('${outputDirectory.path}/$baseName.snote');
  final infoFile = File('${outputDirectory.path}/$baseName.txt');

  await packageFile.writeAsString(package);
  await infoFile.writeAsString('''
安全便签单条迁移测试文件

迁移文件: ${packageFile.absolute.path}
迁移口令: $passphrase
便签数量: $count
最终 .snote 大小: ${package.length} bytes
生成方式: secure_notes_app MigrationPackageService.exportNotes
''');

  stdout.writeln(packageFile.path);
  stdout.writeln(passphrase);
}

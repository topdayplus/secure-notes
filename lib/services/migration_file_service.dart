import 'package:flutter/services.dart';

class PickedMigrationFile {
  const PickedMigrationFile({
    required this.name,
    required this.uri,
    required this.bytes,
  });

  final String name;
  final String uri;
  final Uint8List bytes;
}

class MigrationFilePickerException implements Exception {
  const MigrationFilePickerException();
}

class MigrationFileService {
  const MigrationFileService();

  static const _channel = MethodChannel('secure_notes/migration_file');

  Future<String?> saveFile({
    required String fileName,
    required Uint8List bytes,
  }) async {
    try {
      return await _channel.invokeMethod<String>('saveFile', {
        'fileName': fileName,
        'bytes': bytes,
      });
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  Future<PickedMigrationFile?> pickFile() async {
    final Map<Object?, Object?>? result;
    try {
      result = await _channel.invokeMethod<Map<Object?, Object?>>('pickFile');
    } on MissingPluginException {
      return null;
    } on PlatformException catch (error) {
      if (error.code == 'file_picker_unavailable') {
        throw const MigrationFilePickerException();
      }
      return null;
    }
    return _parsePickedFile(result);
  }

  Future<String?> getImportDirectory() async {
    try {
      return await _channel.invokeMethod<String>('getImportDirectory');
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  Future<PickedMigrationFile?> pickFileFromImportDirectory() async {
    final Map<Object?, Object?>? result;
    try {
      result = await _channel.invokeMethod<Map<Object?, Object?>>(
        'pickFileFromImportDirectory',
      );
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
    return _parsePickedFile(result);
  }

  PickedMigrationFile? _parsePickedFile(Map<Object?, Object?>? result) {
    if (result == null) {
      return null;
    }
    final bytes = result['bytes'];
    return PickedMigrationFile(
      name: result['name']?.toString() ?? '',
      uri: result['uri']?.toString() ?? '',
      bytes: bytes is Uint8List ? bytes : Uint8List(0),
    );
  }

  Future<bool> deleteFile(String uri) async {
    try {
      return await _channel.invokeMethod<bool>('deleteFile', {'uri': uri}) ??
          false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}

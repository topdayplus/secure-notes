import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/note.dart';
import '../services/lan_migration_service.dart';
import '../services/migration_file_service.dart';
import '../services/migration_package_service.dart';
import '../services/note_repository.dart';
import '../widgets/app_scope.dart';
import 'qr_scan_screen.dart';

class MigrationScreen extends StatefulWidget {
  const MigrationScreen({super.key, required this.repository});

  final NoteRepository repository;

  @override
  State<MigrationScreen> createState() => _MigrationScreenState();
}

class _MigrationScreenState extends State<MigrationScreen> {
  final _packageService = MigrationPackageService();
  final _fileService = const MigrationFileService();
  late final LanMigrationService _lanService;
  final _exportPassphraseController = TextEditingController();
  final _importPassphraseController = TextEditingController();
  final _lanSendPassphraseController = TextEditingController();
  final _lanReceiveUrlController = TextEditingController();
  final _lanReceivePassphraseController = TextEditingController();
  String _exportedFilePath = '';
  String _importDirectoryPath = '';
  LanMigrationServer? _lanServer;
  LanMigrationRequest? _pendingLanRequest;
  LanMigrationPayload? _receivedLanPayload;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _lanService = LanMigrationService(_packageService);
    _loadImportDirectoryPath();
  }

  @override
  void dispose() {
    _lanServer?.stop();
    _exportPassphraseController.dispose();
    _importPassphraseController.dispose();
    _lanSendPassphraseController.dispose();
    _lanReceiveUrlController.dispose();
    _lanReceivePassphraseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppScope.of(context).strings;
    return Scaffold(
      appBar: AppBar(title: Text(strings.offlineMigration)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(strings.migrationPackageIntro),
          const SizedBox(height: 18),
          _Section(
            title: strings.lanSendTitle,
            children: [
              TextField(
                controller: _lanSendPassphraseController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: strings.migrationPassphrase,
                  helperText: strings.migrationPassphraseHint,
                  helperMaxLines: 3,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _busy
                    ? null
                    : _lanServer == null
                    ? _startLanServer
                    : _stopLanServer,
                icon: Icon(
                  _lanServer == null ? Icons.wifi_tethering : Icons.stop,
                ),
                label: Text(
                  _lanServer == null
                      ? strings.startLanSend
                      : strings.stopLanSend,
                ),
              ),
              if (_lanServer != null) ...[
                const SizedBox(height: 12),
                _InfoLine(
                  label: strings.lanAddress,
                  value: _lanServer!.session.url,
                ),
                for (final url in _lanServer!.session.alternativeUrls)
                  _InfoLine(label: strings.alternativeLanAddress, value: url),
                _InfoLine(
                  label: strings.confirmationCode,
                  value: _lanServer!.session.confirmationCode,
                ),
                _InfoLine(
                  label: strings.noteCount,
                  value: _lanServer!.session.noteCount.toString(),
                ),
                if (_pendingLanRequest != null) ...[
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            strings.lanReceiveRequest,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            strings.lanReceiveRequestBody(
                              _pendingLanRequest!.remoteAddress,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _denyLanRequest,
                                  child: Text(strings.deny),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: FilledButton(
                                  onPressed: _approveLanRequest,
                                  child: Text(strings.allow),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: QrImageView(
                        data: _lanServer!.session.url,
                        version: QrVersions.auto,
                        size: 180,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _copyLanAddress,
                  icon: const Icon(Icons.copy),
                  label: Text(strings.copyLanAddress),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          _Section(
            title: strings.lanReceiveTitle,
            children: [
              TextField(
                controller: _lanReceiveUrlController,
                decoration: InputDecoration(
                  labelText: strings.lanAddress,
                  helperText: strings.lanAddressHint,
                  helperMaxLines: 3,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _busy ? null : _scanLanAddress,
                icon: const Icon(Icons.qr_code_scanner),
                label: Text(strings.scanLanQrCode),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _lanReceivePassphraseController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: strings.migrationPassphrase,
                  helperText: strings.samePassphraseHint,
                  helperMaxLines: 3,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _busy ? null : _fetchLanPackage,
                icon: const Icon(Icons.wifi_find),
                label: Text(strings.fetchLanPackage),
              ),
              if (_receivedLanPayload != null) ...[
                const SizedBox(height: 12),
                _InfoLine(
                  label: strings.confirmationCode,
                  value: _receivedLanPayload!.confirmationCode,
                ),
                _InfoLine(
                  label: strings.noteCount,
                  value: _receivedLanPayload!.noteCount.toString(),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _importLanPackage,
                  icon: const Icon(Icons.download_done),
                  label: Text(strings.importFetchedPackage),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          _AdvancedSection(
            title: strings.advancedMigration,
            subtitle: strings.advancedMigrationDescription,
            children: [
              _Section(
                title: strings.exportMigrationFile,
                children: [
                  TextField(
                    controller: _exportPassphraseController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: strings.migrationPassphrase,
                      helperText: strings.migrationPassphraseHint,
                      helperMaxLines: 3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _busy ? null : _exportMigrationFile,
                    icon: const Icon(Icons.file_upload_outlined),
                    label: Text(strings.exportMigrationFile),
                  ),
                  if (_exportedFilePath.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _InfoLine(
                      label: strings.migrationFilePath,
                      value: _exportedFilePath,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              _Section(
                title: strings.importMigrationFile,
                children: [
                  TextField(
                    controller: _importPassphraseController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: strings.migrationPassphrase,
                      helperText: strings.samePassphraseHint,
                      helperMaxLines: 3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _busy ? null : _importMigrationFile,
                    icon: const Icon(Icons.file_download_outlined),
                    label: Text(strings.importMigrationFile),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _importMigrationFileFromDirectory,
                    icon: const Icon(Icons.folder_open_outlined),
                    label: Text(strings.importFromImportDirectory),
                  ),
                  if (_importDirectoryPath.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _InfoLine(
                      label: strings.importDirectoryPath,
                      value: _importDirectoryPath,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _loadImportDirectoryPath() async {
    final path = await _fileService.getImportDirectory();
    if (!mounted || path == null || path.isEmpty) {
      return;
    }
    setState(() => _importDirectoryPath = path);
  }

  Future<void> _exportMigrationFile() async {
    final strings = AppScope.of(context).strings;
    await _runAction(() async {
      final notes = await widget.repository.listNotes();
      final package = await _packageService.exportNotes(
        notes: notes,
        passphrase: _exportPassphraseController.text,
      );
      final path = await _fileService.saveFile(
        fileName: _migrationFileName(),
        bytes: Uint8List.fromList(package.codeUnits),
      );
      if (path == null) {
        return;
      }
      setState(() => _exportedFilePath = path);
      _showMessage(strings.migrationFileExported(notes.length));
    });
  }

  Future<void> _startLanServer() async {
    final strings = AppScope.of(context).strings;
    await _runAction(() async {
      await _lanServer?.stop();
      final notes = await widget.repository.listNotes();
      final server = await _lanService.startServer(
        notes: notes,
        passphrase: _lanSendPassphraseController.text,
        onReceiveRequest: (request) {
          if (!mounted) {
            request.deny();
            return;
          }
          setState(() => _pendingLanRequest = request);
        },
      );
      setState(() => _lanServer = server);
      _clearLanServerWhenClosed(server);
      _showMessage(strings.lanSendStarted);
    });
  }

  void _clearLanServerWhenClosed(LanMigrationServer server) {
    server.closed.then((_) {
      if (!mounted || !identical(_lanServer, server)) {
        return;
      }
      setState(() => _lanServer = null);
    });
  }

  Future<void> _stopLanServer() async {
    final strings = AppScope.of(context).strings;
    await _lanServer?.stop();
    if (!mounted) {
      return;
    }
    setState(() => _lanServer = null);
    _showMessage(strings.lanSendStopped);
  }

  void _approveLanRequest() {
    _pendingLanRequest?.approve();
    setState(() => _pendingLanRequest = null);
  }

  void _denyLanRequest() {
    _pendingLanRequest?.deny();
    setState(() => _pendingLanRequest = null);
  }

  Future<void> _copyLanAddress() async {
    final strings = AppScope.of(context).strings;
    final server = _lanServer;
    if (server == null) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: server.session.url));
    if (mounted) {
      _showMessage(strings.lanAddressCopied);
    }
  }

  Future<void> _scanLanAddress() async {
    final result = await Navigator.of(
      context,
    ).push<String>(MaterialPageRoute(builder: (_) => const QrScanScreen()));
    if (!mounted || result == null || result.isEmpty) {
      return;
    }
    setState(() => _lanReceiveUrlController.text = result);
  }

  Future<void> _fetchLanPackage() async {
    final strings = AppScope.of(context).strings;
    await _runAction(() async {
      final payload = await _lanService.fetchPayload(
        _lanReceiveUrlController.text,
      );
      setState(() => _receivedLanPayload = payload);
      _showMessage(strings.lanPackageFetched);
    });
  }

  Future<void> _importLanPackage() async {
    final strings = AppScope.of(context).strings;
    final payload = _receivedLanPayload;
    if (payload == null) {
      return;
    }
    final confirmed = await _confirmLanImport(payload);
    if (confirmed != true) {
      return;
    }
    await _runAction(() async {
      final notes = await _importPackageWithProgress(
        packageText: payload.packageText,
        passphrase: _lanReceivePassphraseController.text,
      );
      _showMessage(strings.packageImported(notes.length));
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    });
  }

  Future<bool?> _confirmLanImport(LanMigrationPayload payload) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        final strings = AppScope.of(context).strings;
        return AlertDialog(
          title: Text(strings.confirmLanImportTitle),
          content: Text(
            strings.confirmLanImportBody(
              payload.confirmationCode,
              payload.noteCount,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(strings.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(strings.importPackage),
            ),
          ],
        );
      },
    );
  }

  Future<void> _importMigrationFile() async {
    final strings = AppScope.of(context).strings;
    await _runAction(() async {
      final PickedMigrationFile? file;
      try {
        file = await _fileService.pickFile();
      } on MigrationFilePickerException {
        _showMessage(strings.filePickerUnavailableUseImportDirectory);
        return;
      }
      if (file == null) {
        return;
      }
      await _importPickedMigrationFile(file);
    });
  }

  Future<void> _importMigrationFileFromDirectory() async {
    final strings = AppScope.of(context).strings;
    await _runAction(() async {
      final file = await _fileService.pickFileFromImportDirectory();
      if (file == null) {
        _showMessage(strings.noMigrationFileInImportDirectory);
        return;
      }
      await _importPickedMigrationFile(file);
    });
  }

  Future<void> _importPickedMigrationFile(PickedMigrationFile file) async {
    final strings = AppScope.of(context).strings;
    if (file.bytes.isEmpty) {
      _showMessage(strings.migrationFailed);
      return;
    }
    final notes = await _importPackageWithProgress(
      packageText: String.fromCharCodes(file.bytes),
      passphrase: _importPassphraseController.text,
    );
    _showMessage(strings.packageImported(notes.length));
    if (mounted && file.uri.isNotEmpty) {
      await _askDeleteMigrationFile(file.uri);
    }
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<List<Note>> _importPackageWithProgress({
    required String packageText,
    required String passphrase,
  }) async {
    final progress = ValueNotifier(
      const _ImportProgress(stage: _ImportProgressStage.decrypting),
    );
    var dialogOpen = false;
    if (mounted) {
      dialogOpen = true;
      unawaited(
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => _ImportProgressDialog(progress: progress),
        ).whenComplete(() => dialogOpen = false),
      );
      await Future<void>.delayed(Duration.zero);
    }

    try {
      final notes = await _packageService.importNotes(
        packageText: packageText,
        passphrase: passphrase,
      );
      progress.value = _ImportProgress(
        stage: _ImportProgressStage.writing,
        imported: 0,
        total: notes.length,
      );
      await widget.repository.importNotes(
        notes,
        onProgress: (imported, total) {
          if (imported == total || imported == 1 || imported % 10 == 0) {
            progress.value = _ImportProgress(
              stage: _ImportProgressStage.writing,
              imported: imported,
              total: total,
            );
          }
        },
      );
      progress.value = _ImportProgress(
        stage: _ImportProgressStage.done,
        imported: notes.length,
        total: notes.length,
      );
      return notes;
    } finally {
      if (mounted && dialogOpen) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      progress.dispose();
    }
  }

  Future<void> _askDeleteMigrationFile(String uri) async {
    final strings = AppScope.of(context).strings;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.deleteMigrationFileTitle),
        content: Text(strings.deleteMigrationFileBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(strings.delete),
          ),
        ],
      ),
    );
    if (shouldDelete != true) {
      return;
    }
    if (await _fileService.deleteFile(uri)) {
      _showMessage(strings.migrationFileDeleted);
    }
  }

  String _migrationFileName() {
    final now = DateTime.now();
    final date = [
      now.year.toString().padLeft(4, '0'),
      now.month.toString().padLeft(2, '0'),
      now.day.toString().padLeft(2, '0'),
    ].join();
    final time = [
      now.hour.toString().padLeft(2, '0'),
      now.minute.toString().padLeft(2, '0'),
      now.second.toString().padLeft(2, '0'),
    ].join();
    return 'secure-notes-$date-$time.snote';
  }

  Future<void> _runAction(Future<void> Function() action) async {
    final migrationFailed = AppScope.of(context).strings.migrationFailed;
    setState(() => _busy = true);
    try {
      await action();
    } on MigrationPackageException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage(migrationFailed);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

enum _ImportProgressStage { decrypting, writing, done }

class _ImportProgress {
  const _ImportProgress({
    required this.stage,
    this.imported = 0,
    this.total = 0,
  });

  final _ImportProgressStage stage;
  final int imported;
  final int total;

  double? get value {
    if (stage != _ImportProgressStage.writing || total <= 0) {
      return null;
    }
    return imported / total;
  }
}

class _ImportProgressDialog extends StatelessWidget {
  const _ImportProgressDialog({required this.progress});

  final ValueNotifier<_ImportProgress> progress;

  @override
  Widget build(BuildContext context) {
    final strings = AppScope.of(context).strings;
    return AlertDialog(
      title: Text(strings.importProgressTitle),
      content: ValueListenableBuilder<_ImportProgress>(
        valueListenable: progress,
        builder: (context, value, _) {
          final message = switch (value.stage) {
            _ImportProgressStage.decrypting => strings.importProgressDecrypting,
            _ImportProgressStage.writing => strings.importProgressWriting(
              value.imported,
              value.total,
            ),
            _ImportProgressStage.done => strings.importProgressDone(
              value.total,
            ),
          };
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(value: value.value),
              const SizedBox(height: 12),
              Text(message),
            ],
          );
        },
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: SelectableText.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _AdvancedSection extends StatelessWidget {
  const _AdvancedSection({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text(title),
        subtitle: Text(subtitle),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        children: children,
      ),
    );
  }
}

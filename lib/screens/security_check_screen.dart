import 'package:flutter/material.dart';

import '../services/crypto_service.dart';
import '../services/note_repository.dart';
import '../widgets/app_scope.dart';

class SecurityCheckScreen extends StatefulWidget {
  const SecurityCheckScreen({
    super.key,
    required this.repository,
    required this.crypto,
  });

  final NoteRepository repository;
  final CryptoService crypto;

  @override
  State<SecurityCheckScreen> createState() => _SecurityCheckScreenState();
}

class _SecurityCheckScreenState extends State<SecurityCheckScreen> {
  final _currentPasscodeController = TextEditingController();
  final _newPasscodeController = TextEditingController();
  final _confirmPasscodeController = TextEditingController();
  Future<StorageAuditResult>? _audit;
  String? _passcodeError;
  bool _changingPasscode = false;

  @override
  void initState() {
    super.initState();
    _audit = widget.repository.auditPlaintextStorage();
  }

  @override
  void dispose() {
    _currentPasscodeController.dispose();
    _newPasscodeController.dispose();
    _confirmPasscodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppScope.of(context).strings;
    return Scaffold(
      appBar: AppBar(title: Text(strings.securityCheck)),
      body: FutureBuilder<StorageAuditResult>(
        future: _audit,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final result = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                leading: Icon(
                  result.passed
                      ? Icons.verified_user_outlined
                      : Icons.warning_amber_outlined,
                  color: result.passed
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  result.passed
                      ? strings.encryptedStoragePassed
                      : strings.plaintextRiskFound,
                ),
                subtitle: Text(
                  strings.auditSummary(
                    result.checkedNotes,
                    result.plaintextLeakCount,
                  ),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.storage_outlined),
                title: Text(strings.localDatabase),
                subtitle: Text(strings.localDatabaseDescription),
              ),
              ListTile(
                leading: const Icon(Icons.key_outlined),
                title: Text(strings.deviceKeyStorage),
                subtitle: Text(strings.deviceKeyStorageDescription),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        strings.changePasscode,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(strings.changePasscodeDescription),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _currentPasscodeController,
                        obscureText: true,
                        enabled: !_changingPasscode,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: strings.currentPasscode,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _newPasscodeController,
                        obscureText: true,
                        enabled: !_changingPasscode,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: strings.newPasscode,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _confirmPasscodeController,
                        obscureText: true,
                        enabled: !_changingPasscode,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: strings.confirmPasscode,
                        ),
                      ),
                      if (_passcodeError != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _passcodeError!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _changingPasscode ? null : _changePasscode,
                        icon: _changingPasscode
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.password_outlined),
                        label: Text(strings.savePasscode),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _changePasscode() async {
    final strings = AppScope.of(context).strings;
    final newPasscode = _newPasscodeController.text;

    setState(() {
      _changingPasscode = true;
      _passcodeError = null;
    });

    try {
      if (newPasscode.length < 6) {
        setState(() => _passcodeError = strings.passcodeTooShort);
        return;
      }
      if (newPasscode != _confirmPasscodeController.text) {
        setState(() => _passcodeError = strings.passcodeMismatch);
        return;
      }
      final changed = await widget.crypto.changePasscode(
        currentPasscode: _currentPasscodeController.text,
        newPasscode: newPasscode,
      );
      if (!changed) {
        setState(() => _passcodeError = strings.wrongPasscode);
        return;
      }

      _currentPasscodeController.clear();
      _newPasscodeController.clear();
      _confirmPasscodeController.clear();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(strings.passcodeChanged)));
      }
    } finally {
      if (mounted) {
        setState(() => _changingPasscode = false);
      }
    }
  }
}

import 'package:flutter/material.dart';

import '../services/app_settings_service.dart';
import '../services/crypto_service.dart';
import '../services/note_repository.dart';
import '../widgets/app_scope.dart';
import 'lock_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.settings,
    required this.onAutoLockDelayChanged,
    required this.onStartupPasscodeEnabledChanged,
    required this.crypto,
    required this.repository,
  });

  final AppSettings settings;
  final Future<void> Function(int seconds) onAutoLockDelayChanged;
  final Future<void> Function(bool enabled) onStartupPasscodeEnabledChanged;
  final CryptoService crypto;
  final NoteRepository repository;

  static const _autoLockOptions = <int>[0, 15, 30, 60, 300, 900, -1];

  @override
  Widget build(BuildContext context) {
    final strings = AppScope.of(context).strings;
    return Scaffold(
      appBar: AppBar(title: Text(strings.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              title: Text(strings.startupPasscode),
              subtitle: Text(strings.startupPasscodeDescription),
              value: settings.startupPasscodeEnabled != false,
              onChanged: (enabled) => _changeStartupPasscode(context, enabled),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            strings.autoLockDelay,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(strings.autoLockDelayDescription),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                for (final seconds in _autoLockOptions)
                  ListTile(
                    title: Text(strings.autoLockDelayOption(seconds)),
                    trailing: settings.autoLockDelaySeconds == seconds
                        ? Icon(
                            Icons.check,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () async {
                      await onAutoLockDelayChanged(seconds);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            strings.dangerZone,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(
                Icons.delete_forever_outlined,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(strings.clearAllNotes),
              subtitle: Text(strings.clearAllNotesDescription),
              onTap: () => _clearAllNotes(context),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _changeStartupPasscode(
    BuildContext context,
    bool enabled,
  ) async {
    if (enabled) {
      if (!await crypto.hasPasscode()) {
        if (!context.mounted) {
          return;
        }
        final created = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (routeContext) => LockScreen(
              crypto: crypto,
              mode: LockMode.setup,
              onUnlocked: () => Navigator.of(routeContext).pop(true),
            ),
          ),
        );
        if (created != true) {
          return;
        }
      }
      await onStartupPasscodeEnabledChanged(true);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      return;
    }

    final verified = await _verifyCurrentPasscode(context);
    if (verified != true) {
      return;
    }
    await onStartupPasscodeEnabledChanged(false);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _clearAllNotes(BuildContext context) async {
    final strings = AppScope.of(context).strings;

    final confirmed = await _confirmClearAllNotes(context);
    if (confirmed != true) {
      return;
    }
    if (!context.mounted) {
      return;
    }

    if (settings.startupPasscodeEnabled != false) {
      final verified = await _verifyCurrentPasscode(
        context,
        title: strings.clearAllNotesPasscodeTitle,
        description: strings.clearAllNotesPasscodeDescription,
      );
      if (verified != true) {
        return;
      }
    }

    await repository.deleteAllNotes();
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(strings.allNotesCleared)));
    Navigator.of(context).pop(true);
  }

  Future<bool?> _confirmClearAllNotes(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final strings = AppScope.of(dialogContext).strings;
        final colorScheme = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          title: Text(strings.clearAllNotesConfirmTitle),
          content: Text(strings.clearAllNotesConfirmBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(strings.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(strings.delete),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _verifyCurrentPasscode(
    BuildContext context, {
    String? title,
    String? description,
  }) {
    final controller = TextEditingController();
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final strings = AppScope.of(dialogContext).strings;
        var errorText = '';
        var busy = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title ?? strings.disableStartupPasscode),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    description ?? strings.disableStartupPasscodeDescription,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: strings.currentPasscode,
                      errorText: errorText.isEmpty ? null : errorText,
                    ),
                    onSubmitted: (_) async {
                      if (busy) {
                        return;
                      }
                      setState(() => busy = true);
                      final ok = await crypto.verifyPasscode(controller.text);
                      if (context.mounted && ok) {
                        Navigator.of(dialogContext).pop(true);
                        return;
                      }
                      if (context.mounted) {
                        setState(() {
                          busy = false;
                          errorText = strings.wrongPasscode;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: busy
                      ? null
                      : () => Navigator.of(dialogContext).pop(false),
                  child: Text(strings.cancel),
                ),
                FilledButton(
                  onPressed: busy
                      ? null
                      : () async {
                          setState(() => busy = true);
                          final ok = await crypto.verifyPasscode(
                            controller.text,
                          );
                          if (context.mounted && ok) {
                            Navigator.of(dialogContext).pop(true);
                            return;
                          }
                          if (context.mounted) {
                            setState(() {
                              busy = false;
                              errorText = strings.wrongPasscode;
                            });
                          }
                        },
                  child: Text(strings.confirm),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(controller.dispose);
  }
}

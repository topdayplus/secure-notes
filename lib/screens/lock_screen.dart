import 'dart:async';

import 'package:flutter/material.dart';

import '../design/app_design.dart';
import '../services/crypto_service.dart';
import '../widgets/app_scope.dart';
import '../widgets/language_menu_button.dart';

enum LockMode { setup, unlock }

class LockScreen extends StatefulWidget {
  const LockScreen({
    super.key,
    required this.crypto,
    required this.mode,
    required this.onUnlocked,
  });

  final CryptoService crypto;
  final LockMode mode;
  final VoidCallback onUnlocked;

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  static const _maxFailedAttempts = 5;
  static const _lockoutDuration = Duration(seconds: 30);
  static const _passcodeLength = 6;

  String _passcode = '';
  String _setupPasscode = '';
  String? _error;
  bool _busy = false;
  int _failedAttempts = 0;
  int _lockoutRemainingSeconds = 0;
  Timer? _lockoutTimer;

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppScope.of(context).strings;
    final isSetup = widget.mode == LockMode.setup;
    final lockedOut = _lockoutRemainingSeconds > 0;
    return Scaffold(
      appBar: AppBar(actions: const [LanguageMenuButton()]),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppDesign.surface.withValues(alpha: 0.72),
                          borderRadius: BorderRadius.circular(34),
                          boxShadow: [
                            BoxShadow(
                              color: AppDesign.primary.withValues(alpha: 0.10),
                              blurRadius: 38,
                              offset: const Offset(0, 18),
                            ),
                          ],
                        ),
                        child: const SizedBox.square(
                          dimension: 94,
                          child: Icon(
                            Icons.lock_outline,
                            size: 48,
                            color: AppDesign.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      isSetup && _setupPasscode.isNotEmpty
                          ? strings.confirmPasscode
                          : isSetup
                          ? strings.createPasscode
                          : strings.unlockNotes,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      strings.passcode,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppDesign.muted,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 36),
                    _PasscodeDots(
                      length: _passcodeLength,
                      filled: _passcode.length,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 44),
                    _NumberPad(
                      enabled: !_busy && !lockedOut,
                      onDigit: _appendDigit,
                      onDelete: _deleteDigit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _appendDigit(String digit) {
    if (_busy || _lockoutRemainingSeconds > 0) {
      return;
    }
    if (_passcode.length >= _passcodeLength) {
      return;
    }
    setState(() {
      _passcode += digit;
      _error = null;
    });
    if (_passcode.length == _passcodeLength) {
      _submit(_passcode);
    }
  }

  void _deleteDigit() {
    if (_busy || _passcode.isEmpty) {
      return;
    }
    setState(() {
      _passcode = _passcode.substring(0, _passcode.length - 1);
      _error = null;
    });
  }

  Future<void> _submit(String passcode) async {
    if (_lockoutRemainingSeconds > 0) {
      setState(() {
        _error = AppScope.of(
          context,
        ).strings.unlockLocked(_lockoutRemainingSeconds);
      });
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      if (passcode.length < _passcodeLength) {
        setState(() => _error = AppScope.of(context).strings.passcodeTooShort);
        return;
      }

      if (widget.mode == LockMode.setup) {
        if (_setupPasscode.isEmpty) {
          setState(() {
            _setupPasscode = passcode;
            _passcode = '';
          });
          return;
        }
        if (passcode != _setupPasscode) {
          setState(() {
            _error = AppScope.of(context).strings.passcodeMismatch;
            _setupPasscode = '';
            _passcode = '';
          });
          return;
        }
        await widget.crypto.setPasscode(passcode);
        widget.onUnlocked();
        return;
      }

      final ok = await widget.crypto.verifyPasscode(passcode);
      if (!ok) {
        setState(() => _passcode = '');
        _recordFailedAttempt();
        return;
      }
      _failedAttempts = 0;
      widget.onUnlocked();
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  void _recordFailedAttempt() {
    final strings = AppScope.of(context).strings;
    _failedAttempts += 1;
    if (_failedAttempts < _maxFailedAttempts) {
      setState(() => _error = strings.wrongPasscode);
      return;
    }

    _failedAttempts = 0;
    _lockoutRemainingSeconds = _lockoutDuration.inSeconds;
    _error = strings.unlockLocked(_lockoutRemainingSeconds);
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_lockoutRemainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _lockoutRemainingSeconds = 0;
          _error = null;
        });
        return;
      }
      setState(() {
        _lockoutRemainingSeconds -= 1;
        _error = AppScope.of(
          context,
        ).strings.unlockLocked(_lockoutRemainingSeconds);
      });
    });
    setState(() {});
  }
}

class _PasscodeDots extends StatelessWidget {
  const _PasscodeDots({required this.length, required this.filled});

  final int length;
  final int filled;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var index = 0; index < length; index += 1)
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index < filled ? AppDesign.primary : Colors.transparent,
              border: Border.all(
                color: index < filled ? AppDesign.primary : AppDesign.border,
                width: 2,
              ),
            ),
          ),
      ],
    );
  }
}

class _NumberPad extends StatelessWidget {
  const _NumberPad({
    required this.enabled,
    required this.onDigit,
    required this.onDelete,
  });

  final bool enabled;
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'delete'],
    ];
    return Column(
      children: [
        for (final row in rows) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final item in row)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  child: item.isEmpty
                      ? const SizedBox.square(dimension: 86)
                      : _NumberPadButton(
                          enabled: enabled,
                          label: item,
                          onPressed: item == 'delete'
                              ? onDelete
                              : () => onDigit(item),
                        ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _NumberPadButton extends StatelessWidget {
  const _NumberPadButton({
    required this.enabled,
    required this.label,
    required this.onPressed,
  });

  final bool enabled;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDelete = label == 'delete';
    return SizedBox.square(
      dimension: 86,
      child: TextButton(
        onPressed: enabled ? onPressed : null,
        style: TextButton.styleFrom(
          foregroundColor: AppDesign.ink,
          backgroundColor: AppDesign.surface.withValues(alpha: 0.66),
          shape: const CircleBorder(),
          textStyle: const TextStyle(fontSize: 34, fontWeight: FontWeight.w500),
        ),
        child: isDelete
            ? const Icon(Icons.backspace_outlined, size: 30)
            : Text(label),
      ),
    );
  }
}

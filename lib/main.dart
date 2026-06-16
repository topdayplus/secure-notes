import 'dart:async';

import 'package:flutter/material.dart';

import 'design/app_design.dart';
import 'l10n/app_language.dart';
import 'l10n/app_strings.dart';
import 'screens/lock_screen.dart';
import 'screens/notes_home_screen.dart';
import 'services/app_container.dart';
import 'services/app_settings_service.dart';
import 'widgets/app_scope.dart';
import 'widgets/language_menu_button.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(SecureNotesApp(container: AppContainer.create()));
}

class SecureNotesApp extends StatefulWidget {
  const SecureNotesApp({super.key, required this.container});

  final AppContainer container;

  @override
  State<SecureNotesApp> createState() => _SecureNotesAppState();
}

class _SecureNotesAppState extends State<SecureNotesApp>
    with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late Future<_StartupState> _startupState;
  _StartupState? _startupStateValue;
  DateTime? _backgroundedAt;
  bool _unlocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startupState = _loadStartupState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _backgroundedAt = DateTime.now();
      return;
    }

    if (state == AppLifecycleState.resumed) {
      _lockIfNeededAfterResume();
    }
  }

  void _unlock() {
    _setStartupState((state) => state.copyWith(hasPasscode: true));
    setState(() => _unlocked = true);
  }

  void _lock() {
    if (_unlocked && mounted) {
      _navigatorKey.currentState?.popUntil((route) => route.isFirst);
      setState(() => _unlocked = false);
    }
  }

  Future<void> _skipStartupPasscode() async {
    unawaited(widget.container.settings.saveStartupPasscodeEnabled(false));
    _setStartupState(
      (state) => state.copyWith(
        settings: state.settings.copyWith(startupPasscodeEnabled: false),
      ),
    );
    setState(() => _unlocked = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _navigatorKey.currentContext;
      if (context == null || !context.mounted) {
        return;
      }
      final strings = AppScope.of(context).strings;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.startupPasscodeSkipped)));
    });
  }

  Future<void> _chooseStartupPasscode() async {
    unawaited(widget.container.settings.saveStartupPasscodeEnabled(true));
    _setStartupState(
      (state) => state.copyWith(
        settings: state.settings.copyWith(startupPasscodeEnabled: true),
      ),
    );
  }

  Future<_StartupState> _loadStartupState() async {
    final values = await Future.wait<Object>([
      widget.container.crypto.hasPasscode(),
      widget.container.language.load(),
      widget.container.settings.load(),
    ]);
    final state = _StartupState(
      hasPasscode: values[0] as bool,
      language: values[1] as AppLanguage,
      settings: values[2] as AppSettings,
    );
    _startupStateValue = state;
    return state;
  }

  Future<_StartupState> _currentStartupState() {
    return _startupState;
  }

  void _setStartupState(_StartupState Function(_StartupState state) update) {
    final current = _startupStateValue;
    if (current != null) {
      _startupStateValue = update(current);
      _startupState = Future.value(_startupStateValue);
    } else {
      _startupState = _currentStartupState().then((state) {
        final updated = update(state);
        _startupStateValue = updated;
        return updated;
      });
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _lockIfNeededAfterResume() async {
    final backgroundedAt = _backgroundedAt;
    _backgroundedAt = null;
    if (!_unlocked || backgroundedAt == null) {
      return;
    }

    final state = await _currentStartupState();
    final settings = state.settings;
    if (settings.startupPasscodeEnabled == false) {
      return;
    }
    if (settings.neverAutoLock) {
      return;
    }
    if (settings.alwaysLockOnResume ||
        DateTime.now().difference(backgroundedAt).inSeconds >=
            settings.autoLockDelaySeconds) {
      _lock();
    }
  }

  Future<void> _changeAutoLockDelaySeconds(int seconds) async {
    unawaited(widget.container.settings.saveAutoLockDelaySeconds(seconds));
    _setStartupState(
      (state) => state.copyWith(
        settings: state.settings.copyWith(autoLockDelaySeconds: seconds),
      ),
    );
  }

  Future<void> _changeStartupPasscodeEnabled(bool enabled) async {
    unawaited(widget.container.settings.saveStartupPasscodeEnabled(enabled));
    _setStartupState(
      (state) => state.copyWith(
        hasPasscode: enabled ? true : state.hasPasscode,
        settings: state.settings.copyWith(startupPasscodeEnabled: enabled),
      ),
    );
    if (!enabled && mounted) {
      setState(() {
        _unlocked = true;
      });
    }
  }

  Future<void> _changeLanguage(AppLanguage language) async {
    unawaited(widget.container.language.save(language));
    _setStartupState((state) => state.copyWith(language: language));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_StartupState>(
      future: _startupState,
      initialData: _startupStateValue,
      builder: (context, snapshot) {
        final startupState = snapshot.data;
        final language = startupState?.language ?? AppLanguage.zhHans;
        final strings = AppStrings.of(language);
        return AppScope(
          language: language,
          strings: strings,
          onLanguageChanged: _changeLanguage,
          child: MaterialApp(
            navigatorKey: _navigatorKey,
            title: strings.appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppDesign.theme(),
            home: _buildHome(startupState),
          ),
        );
      },
    );
  }

  Widget _buildHome(_StartupState? startupState) {
    if (startupState == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final hasPasscode = startupState.hasPasscode;
    final settings = startupState.settings;
    final startupPasscodeEnabled =
        settings.startupPasscodeEnabled ?? hasPasscode;

    if (settings.startupPasscodeEnabled == null && !hasPasscode) {
      return StartupPasscodeChoiceScreen(
        onCreatePasscode: _chooseStartupPasscode,
        onSkipPasscode: _skipStartupPasscode,
      );
    }

    if (!startupPasscodeEnabled || _unlocked) {
      return NotesHomeScreen(
        container: widget.container,
        settings: settings,
        onAutoLockDelayChanged: _changeAutoLockDelaySeconds,
        onStartupPasscodeEnabledChanged: _changeStartupPasscodeEnabled,
        onLock: _lock,
      );
    }

    return LockScreen(
      crypto: widget.container.crypto,
      mode: hasPasscode ? LockMode.unlock : LockMode.setup,
      onUnlocked: _unlock,
    );
  }
}

class _StartupState {
  const _StartupState({
    required this.hasPasscode,
    required this.language,
    required this.settings,
  });

  final bool hasPasscode;
  final AppLanguage language;
  final AppSettings settings;

  _StartupState copyWith({
    bool? hasPasscode,
    AppLanguage? language,
    AppSettings? settings,
  }) {
    return _StartupState(
      hasPasscode: hasPasscode ?? this.hasPasscode,
      language: language ?? this.language,
      settings: settings ?? this.settings,
    );
  }
}

class StartupPasscodeChoiceScreen extends StatelessWidget {
  const StartupPasscodeChoiceScreen({
    super.key,
    required this.onCreatePasscode,
    required this.onSkipPasscode,
  });

  final Future<void> Function() onCreatePasscode;
  final Future<void> Function() onSkipPasscode;

  @override
  Widget build(BuildContext context) {
    final strings = AppScope.of(context).strings;
    return Scaffold(
      appBar: AppBar(actions: const [LanguageMenuButton()]),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 56,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    strings.createStartupPasscodeQuestion,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    strings.createStartupPasscodeDescription,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: onCreatePasscode,
                    icon: const Icon(Icons.lock_outline),
                    label: Text(strings.createPasscode),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: onSkipPasscode,
                    child: Text(strings.skipForNow),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

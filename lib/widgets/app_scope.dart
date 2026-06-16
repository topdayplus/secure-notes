import 'package:flutter/widgets.dart';

import '../l10n/app_language.dart';
import '../l10n/app_strings.dart';

class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.language,
    required this.strings,
    required this.onLanguageChanged,
    required super.child,
  });

  final AppLanguage language;
  final AppStrings strings;
  final ValueChanged<AppLanguage> onLanguageChanged;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree.');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) {
    return language != oldWidget.language || strings != oldWidget.strings;
  }
}

import 'package:flutter/material.dart';

import '../l10n/app_language.dart';
import 'app_scope.dart';

class LanguageMenuButton extends StatelessWidget {
  const LanguageMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return PopupMenuButton<AppLanguage>(
      tooltip: scope.strings.languageLabel,
      initialValue: scope.language,
      onSelected: scope.onLanguageChanged,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language),
            const SizedBox(width: 6),
            Text(scope.strings.languageLabel),
          ],
        ),
      ),
      itemBuilder: (context) {
        return AppLanguage.values.map((language) {
          return CheckedPopupMenuItem<AppLanguage>(
            value: language,
            checked: scope.language == language,
            child: Text(_labelFor(language)),
          );
        }).toList();
      },
    );
  }

  String _labelFor(AppLanguage language) {
    return switch (language) {
      AppLanguage.zhHans => '简体中文',
      AppLanguage.zhHant => '繁體中文',
      AppLanguage.en => 'English',
    };
  }
}

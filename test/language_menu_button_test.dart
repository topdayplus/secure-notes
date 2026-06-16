import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_notes_app/l10n/app_language.dart';
import 'package:secure_notes_app/l10n/app_strings.dart';
import 'package:secure_notes_app/widgets/app_scope.dart';
import 'package:secure_notes_app/widgets/language_menu_button.dart';

void main() {
  testWidgets('selects a language from the app bar menu', (tester) async {
    AppLanguage? selectedLanguage;

    await tester.pumpWidget(
      AppScope(
        language: AppLanguage.zhHans,
        strings: AppStrings.of(AppLanguage.zhHans),
        onLanguageChanged: (language) => selectedLanguage = language,
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(actions: const [LanguageMenuButton()]),
            body: const SizedBox.shrink(),
          ),
        ),
      ),
    );

    await tester.tap(find.text('语言'));
    await tester.pumpAndSettle();

    expect(find.text('简体中文'), findsOneWidget);
    expect(find.text('繁體中文'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);

    await tester.tap(
      find.ancestor(
        of: find.text('English'),
        matching: find.byType(CheckedPopupMenuItem<AppLanguage>),
      ),
    );
    await tester.pumpAndSettle();

    expect(selectedLanguage, AppLanguage.en);
  });
}

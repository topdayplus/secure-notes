import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_notes_app/l10n/app_language.dart';
import 'package:secure_notes_app/l10n/app_strings.dart';
import 'package:secure_notes_app/screens/lock_screen.dart';
import 'package:secure_notes_app/services/crypto_service.dart';
import 'package:secure_notes_app/services/secure_value_store.dart';
import 'package:secure_notes_app/widgets/app_scope.dart';

class FakeCryptoService extends CryptoService {
  FakeCryptoService() : super(MemorySecureValueStore());

  @override
  Future<bool> verifyPasscode(String passcode) async => false;
}

class MemorySecureValueStore implements SecureValueStore {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;
}

void main() {
  testWidgets('locks unlock attempts after repeated wrong passcodes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var unlocked = false;

    await tester.pumpWidget(
      AppScope(
        language: AppLanguage.en,
        strings: AppStrings.of(AppLanguage.en),
        onLanguageChanged: (_) {},
        child: MaterialApp(
          home: LockScreen(
            crypto: FakeCryptoService(),
            mode: LockMode.unlock,
            onUnlocked: () => unlocked = true,
          ),
        ),
      ),
    );

    for (var i = 0; i < 5; i += 1) {
      for (var digit = 0; digit < 6; digit += 1) {
        await tester.tap(find.text('0'));
        await tester.pump();
      }
      await tester.pumpAndSettle();
    }

    expect(unlocked, isFalse);
    expect(find.textContaining('Too many failed attempts'), findsOneWidget);
    final zeroButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, '0'),
    );
    expect(zeroButton.enabled, isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

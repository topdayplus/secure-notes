import '../l10n/language_service.dart';
import 'app_settings_service.dart';
import 'crypto_service.dart';
import 'note_database.dart';
import 'note_repository.dart';
import 'secure_value_store.dart';

class AppContainer {
  const AppContainer({
    required this.crypto,
    required this.language,
    required this.settings,
    required this.notes,
  });

  final CryptoService crypto;
  final LanguageService language;
  final AppSettingsService settings;
  final NoteRepository notes;

  factory AppContainer.create() {
    const secureStore = PlatformSecureValueStore();
    final crypto = CryptoService(secureStore);
    return AppContainer(
      crypto: crypto,
      language: const LanguageService(secureStore),
      settings: const AppSettingsService(secureStore),
      notes: NoteRepository(database: NoteDatabase(), crypto: crypto),
    );
  }
}

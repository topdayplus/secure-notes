import '../services/secure_value_store.dart';
import 'app_language.dart';

class LanguageService {
  const LanguageService(this._store);

  static const _languageKey = 'app_language_v1';

  final SecureValueStore _store;

  Future<AppLanguage> load() async {
    return AppLanguage.fromCode(await _store.read(_languageKey));
  }

  Future<void> save(AppLanguage language) {
    return _store.write(_languageKey, language.code);
  }
}

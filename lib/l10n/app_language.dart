enum AppLanguage {
  zhHans('zh-Hans', '简体中文'),
  zhHant('zh-Hant', '繁體中文'),
  en('en', 'English');

  const AppLanguage(this.code, this.label);

  final String code;
  final String label;

  static AppLanguage fromCode(String? code) {
    return AppLanguage.values.firstWhere(
      (language) => language.code == code,
      orElse: () => AppLanguage.zhHans,
    );
  }
}

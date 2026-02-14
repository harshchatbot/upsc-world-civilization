enum AppLanguage { en, hi }

extension AppLanguageX on AppLanguage {
  String get code => this == AppLanguage.hi ? 'hi' : 'en';

  String get label => this == AppLanguage.hi ? 'हिंदी' : 'English';

  static AppLanguage fromCode(String? value) {
    return value == 'hi' ? AppLanguage.hi : AppLanguage.en;
  }
}

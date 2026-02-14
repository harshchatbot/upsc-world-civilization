enum AppLang { en, hi }

extension AppLangX on AppLang {
  String get code => this == AppLang.hi ? 'hi' : 'en';

  static AppLang fromCode(String? code) {
    return code == 'hi' ? AppLang.hi : AppLang.en;
  }
}

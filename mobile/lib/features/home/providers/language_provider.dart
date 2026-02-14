import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/localization/app_language.dart';

final appLanguageProvider =
    AsyncNotifierProvider<AppLanguageController, AppLanguage>(
      AppLanguageController.new,
    );

class AppLanguageController extends AsyncNotifier<AppLanguage> {
  static const String _prefsKey = 'app_language_code';

  @override
  Future<AppLanguage> build() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_prefsKey);
    return AppLanguageX.fromCode(raw);
  }

  Future<void> setLanguage(AppLanguage lang) async {
    state = AsyncData<AppLanguage>(lang);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, lang.code);
  }

  Future<void> toggleLanguage() async {
    final AppLanguage current = state.value ?? AppLanguage.en;
    await setLanguage(
      current == AppLanguage.en ? AppLanguage.hi : AppLanguage.en,
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'lang.dart';

final langControllerProvider = NotifierProvider<LangController, AppLang>(
  LangController.new,
);

class LangController extends Notifier<AppLang> {
  static const String _storageKey = 'upsc_lang';

  @override
  AppLang build() {
    _restore();
    return AppLang.en;
  }

  Future<void> _restore() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? stored = prefs.getString(_storageKey);
    final AppLang restored = AppLangX.fromCode(stored);
    if (restored != state) {
      state = restored;
    }
  }

  Future<void> setLang(AppLang lang) async {
    if (lang == state) return;
    state = lang;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, lang.code);
  }

  Future<void> toggle() async {
    final AppLang next = state == AppLang.en ? AppLang.hi : AppLang.en;
    await setLang(next);
  }
}

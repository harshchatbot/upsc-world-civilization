import '../../data/models/localized_text.dart';
import 'app_language.dart';

String resolve(LocalizedText text, AppLanguage lang) {
  if (lang == AppLanguage.hi && text.hi.trim().isNotEmpty) {
    return text.hi;
  }
  return text.en;
}

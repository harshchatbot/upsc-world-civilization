import 'lang.dart';

class LocalizedText {
  const LocalizedText({required this.values});

  final Map<String, String> values;

  factory LocalizedText.fromJson(dynamic raw) {
    if (raw is String) {
      return LocalizedText(values: <String, String>{'en': raw});
    }
    if (raw is Map<String, dynamic>) {
      return LocalizedText(
        values: raw.map(
          (Object? key, dynamic value) =>
              MapEntry<String, String>(key.toString(), value?.toString() ?? ''),
        ),
      );
    }
    return const LocalizedText(values: <String, String>{'en': ''});
  }

  Map<String, dynamic> toJson() => values;

  String resolve(AppLang lang) {
    final String? selected = values[lang.code];
    if (selected != null && selected.trim().isNotEmpty) {
      return selected;
    }

    final String? english = values['en'];
    if (english != null && english.trim().isNotEmpty) {
      return english;
    }

    for (final String value in values.values) {
      if (value.trim().isNotEmpty) {
        return value;
      }
    }
    return '';
  }
}

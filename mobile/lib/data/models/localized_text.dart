class LocalizedText {
  const LocalizedText({required this.en, this.hi = ''});

  final String en;
  final String hi;

  factory LocalizedText.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const LocalizedText(en: '');
    }
    return LocalizedText(
      en: map['en'] as String? ?? '',
      hi: map['hi'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'en': en, 'hi': hi};
  }
}

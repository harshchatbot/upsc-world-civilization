class WorldMeta {
  const WorldMeta({
    required this.id,
    required this.title,
    required this.subtitle,
  });

  final String id;
  final String title;
  final String subtitle;

  factory WorldMeta.fromMap(String id, Map<String, dynamic> map) {
    return WorldMeta(
      id: id,
      title: map['title'] as String? ?? 'UPSC World: Civilization',
      subtitle: map['subtitle'] as String? ?? 'Civilization learning journey',
    );
  }
}

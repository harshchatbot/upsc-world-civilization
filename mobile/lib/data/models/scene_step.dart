class SceneContent {
  const SceneContent({
    required this.id,
    required this.nodeId,
    required this.imageUrl,
    required this.dialogues,
  });

  final String id;
  final String nodeId;
  final String imageUrl;
  final List<String> dialogues;

  factory SceneContent.fromMap(String id, Map<String, dynamic> map) {
    final List<dynamic> raw = map['dialogues'] as List<dynamic>? ?? <dynamic>[];
    return SceneContent(
      id: id,
      nodeId: map['nodeId'] as String? ?? id,
      imageUrl: map['imageUrl'] as String? ?? '',
      dialogues: raw.map((dynamic e) => e.toString()).toList(),
    );
  }
}

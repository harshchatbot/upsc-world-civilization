class EraNode {
  const EraNode({
    required this.id,
    required this.title,
    required this.order,
    required this.dx,
    required this.dy,
    required this.sceneId,
  });

  final String id;
  final String title;
  final int order;
  final double dx;
  final double dy;
  final String sceneId;

  factory EraNode.fromMap(String id, Map<String, dynamic> map) {
    return EraNode(
      id: id,
      title: map['title'] as String? ?? '',
      order: map['order'] as int? ?? 0,
      dx: (map['dx'] as num? ?? 0).toDouble(),
      dy: (map['dy'] as num? ?? 0).toDouble(),
      sceneId: map['sceneId'] as String? ?? id,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'order': order,
      'dx': dx,
      'dy': dy,
      'sceneId': sceneId,
    };
  }
}

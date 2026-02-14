class SceneLayer {
  const SceneLayer({
    required this.id,
    required this.asset,
    required this.parallax,
  });

  final String id;
  final String asset;
  final double parallax;

  factory SceneLayer.fromJson(Map<String, dynamic> json) {
    return SceneLayer(
      id: json['id'] as String? ?? '',
      asset: json['asset'] as String? ?? '',
      parallax: (json['parallax'] as num? ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'id': id, 'asset': asset, 'parallax': parallax};
  }
}

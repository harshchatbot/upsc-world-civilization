class LoopSpec {
  const LoopSpec({required this.asset, required this.volume});

  final String asset;
  final double volume;

  factory LoopSpec.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const LoopSpec(asset: '', volume: 0);
    }
    return LoopSpec(
      asset: json['asset'] as String? ?? '',
      volume: (json['volume'] as num? ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'asset': asset, 'volume': volume};
  }
}

class SceneAudio {
  const SceneAudio({
    required this.ambient,
    required this.fireLoop,
    required this.sfx,
  });

  final LoopSpec ambient;
  final LoopSpec fireLoop;
  final Map<String, String> sfx;

  factory SceneAudio.fromJson(Map<String, dynamic>? json) {
    final Map<String, dynamic> sfxMap =
        json?['sfx'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return SceneAudio(
      ambient: LoopSpec.fromJson(json?['ambient'] as Map<String, dynamic>?),
      fireLoop: LoopSpec.fromJson(json?['fireLoop'] as Map<String, dynamic>?),
      sfx: sfxMap.map(
        (Object? key, dynamic value) =>
            MapEntry<String, String>(key.toString(), value.toString()),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'ambient': ambient.toJson(),
      'fireLoop': fireLoop.toJson(),
      'sfx': sfx,
    };
  }
}

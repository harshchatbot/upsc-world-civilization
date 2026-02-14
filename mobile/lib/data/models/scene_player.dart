import 'localized_text.dart';

enum SceneStepType { dialogue, prompt, quiz }

SceneStepType _typeFromRaw(String raw) {
  switch (raw) {
    case 'prompt':
      return SceneStepType.prompt;
    case 'quiz':
      return SceneStepType.quiz;
    default:
      return SceneStepType.dialogue;
  }
}

class AudioSpec {
  const AudioSpec({
    required this.ambientAsset,
    required this.musicAsset,
    this.ambientVolume = 0.5,
    this.musicVolume = 0.2,
  });

  final String ambientAsset;
  final String musicAsset;
  final double ambientVolume;
  final double musicVolume;

  factory AudioSpec.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const AudioSpec(ambientAsset: '', musicAsset: '');
    }
    return AudioSpec(
      ambientAsset: map['ambientAsset'] as String? ?? '',
      musicAsset: map['musicAsset'] as String? ?? '',
      ambientVolume: (map['ambientVolume'] as num? ?? 0.5).toDouble(),
      musicVolume: (map['musicVolume'] as num? ?? 0.2).toDouble(),
    );
  }
}

class ParallaxLayer {
  const ParallaxLayer({
    required this.asset,
    required this.depth,
    this.alignmentX = 0.5,
    this.alignmentY = 0.5,
    this.opacity = 1.0,
  });

  final String asset;
  final double depth;
  final double alignmentX;
  final double alignmentY;
  final double opacity;

  factory ParallaxLayer.fromMap(Map<String, dynamic> map) {
    final Map<String, dynamic> align =
        map['alignment'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return ParallaxLayer(
      asset: map['asset'] as String? ?? '',
      depth: (map['depth'] as num? ?? 0).toDouble(),
      alignmentX: (align['x'] as num? ?? 0.5).toDouble(),
      alignmentY: (align['y'] as num? ?? 0.5).toDouble(),
      opacity: (map['opacity'] as num? ?? 1).toDouble(),
    );
  }
}

class SceneStep {
  const SceneStep({
    required this.id,
    required this.type,
    required this.text,
    this.promptLabel,
    this.cta,
  });

  final String id;
  final SceneStepType type;
  final LocalizedText text;
  final LocalizedText? promptLabel;
  final LocalizedText? cta;

  factory SceneStep.fromMap(Map<String, dynamic> map) {
    return SceneStep(
      id: map['id'] as String? ?? '',
      type: _typeFromRaw(map['type'] as String? ?? 'dialogue'),
      text: LocalizedText.fromMap(map['text'] as Map<String, dynamic>?),
      promptLabel: map['promptLabel'] == null
          ? null
          : LocalizedText.fromMap(map['promptLabel'] as Map<String, dynamic>?),
      cta: map['cta'] == null
          ? null
          : LocalizedText.fromMap(map['cta'] as Map<String, dynamic>?),
    );
  }
}

class Scene {
  const Scene({
    required this.id,
    required this.nodeId,
    required this.title,
    required this.backgroundAsset,
    required this.layers,
    required this.audio,
    required this.steps,
    required this.quizId,
  });

  final String id;
  final String nodeId;
  final LocalizedText title;
  final String backgroundAsset;
  final List<ParallaxLayer> layers;
  final AudioSpec audio;
  final List<SceneStep> steps;
  final String quizId;

  factory Scene.fromMap(Map<String, dynamic> map) {
    final List<dynamic> rawLayers =
        map['layers'] as List<dynamic>? ?? <dynamic>[];
    final List<dynamic> rawSteps =
        map['steps'] as List<dynamic>? ?? <dynamic>[];

    return Scene(
      id: map['id'] as String? ?? '',
      nodeId: map['nodeId'] as String? ?? '',
      title: LocalizedText.fromMap(map['title'] as Map<String, dynamic>?),
      backgroundAsset: map['backgroundAsset'] as String? ?? '',
      layers: rawLayers
          .map(
            (dynamic layer) =>
                ParallaxLayer.fromMap(layer as Map<String, dynamic>),
          )
          .toList(),
      audio: AudioSpec.fromMap(map['audio'] as Map<String, dynamic>?),
      steps: rawSteps
          .map((dynamic s) => SceneStep.fromMap(s as Map<String, dynamic>))
          .toList(),
      quizId: map['quizId'] as String? ?? '',
    );
  }
}

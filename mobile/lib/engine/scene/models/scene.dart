import '../../../localization/localized_text.dart';
import 'scene_audio.dart';
import 'scene_layer.dart';
import 'scene_step.dart';

class SceneRewards {
  const SceneRewards({required this.xp, required this.badge});

  final int xp;
  final String badge;

  factory SceneRewards.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const SceneRewards(xp: 0, badge: '');
    }
    return SceneRewards(
      xp: json['xp'] as int? ?? 0,
      badge: json['badge'] as String? ?? '',
    );
  }
}

class SceneNavigate {
  const SceneNavigate({required this.quizId});

  final String quizId;

  factory SceneNavigate.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const SceneNavigate(quizId: '');
    }
    return SceneNavigate(quizId: json['quizId'] as String? ?? '');
  }
}

class Scene {
  const Scene({
    required this.sceneId,
    required this.title,
    required this.layers,
    required this.audio,
    required this.steps,
    required this.rewards,
    required this.navigate,
  });

  final String sceneId;
  final LocalizedText title;
  final List<SceneLayer> layers;
  final SceneAudio audio;
  final List<SceneStep> steps;
  final SceneRewards rewards;
  final SceneNavigate navigate;

  Scene copyWith({List<SceneStep>? steps}) {
    return Scene(
      sceneId: sceneId,
      title: title,
      layers: layers,
      audio: audio,
      steps: steps ?? this.steps,
      rewards: rewards,
      navigate: navigate,
    );
  }

  factory Scene.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawLayers =
        json['layers'] as List<dynamic>? ?? <dynamic>[];
    final List<dynamic> rawSteps =
        json['steps'] as List<dynamic>? ?? <dynamic>[];

    return Scene(
      sceneId: json['sceneId'] as String? ?? '',
      title: LocalizedText.fromJson(json['title']),
      layers: rawLayers
          .map((dynamic e) => SceneLayer.fromJson(e as Map<String, dynamic>))
          .toList(),
      audio: SceneAudio.fromJson(json['audio'] as Map<String, dynamic>?),
      steps: rawSteps
          .map((dynamic e) => SceneStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      rewards: SceneRewards.fromJson(json['rewards'] as Map<String, dynamic>?),
      navigate: SceneNavigate.fromJson(
        json['navigate'] as Map<String, dynamic>?,
      ),
    );
  }
}

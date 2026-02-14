import '../../../localization/localized_text.dart';

sealed class SceneStep {
  const SceneStep({required this.type});

  final String type;

  factory SceneStep.fromJson(Map<String, dynamic> json) {
    final String type = json['type'] as String? ?? 'dialogue';
    switch (type) {
      case 'dialogue':
        return DialogueStep.fromJson(json);
      case 'sfx':
        return SfxStep.fromJson(json);
      case 'audioMix':
        return AudioMixStep.fromJson(json);
      case 'interaction':
        return InteractionStep.fromJson(json);
      case 'montage':
        return MontageStep.fromJson(json);
      case 'navigate':
        return NavigateStep.fromJson(json);
      default:
        return DialogueStep.fromJson(json);
    }
  }
}

class DialogueStep extends SceneStep {
  const DialogueStep({
    required this.speaker,
    required this.text,
    this.enterAnimation,
  }) : super(type: 'dialogue');

  final String speaker;
  final LocalizedText text;
  final String? enterAnimation;

  factory DialogueStep.fromJson(Map<String, dynamic> json) {
    return DialogueStep(
      speaker: json['speaker'] as String? ?? '',
      text: LocalizedText.fromJson(json['text']),
      enterAnimation: json['enter'] as String?,
    );
  }
}

class SfxStep extends SceneStep {
  const SfxStep({required this.key}) : super(type: 'sfx');

  final String key;

  factory SfxStep.fromJson(Map<String, dynamic> json) {
    return SfxStep(key: json['key'] as String? ?? '');
  }
}

class AudioMixStep extends SceneStep {
  const AudioMixStep({
    required this.target,
    required this.toVolume,
    required this.durationMs,
  }) : super(type: 'audioMix');

  final String target;
  final double toVolume;
  final int durationMs;

  factory AudioMixStep.fromJson(Map<String, dynamic> json) {
    return AudioMixStep(
      target: json['target'] as String? ?? 'ambient',
      toVolume: (json['toVolume'] as num? ?? 0).toDouble(),
      durationMs: json['durationMs'] as int? ?? 300,
    );
  }
}

class InteractionStep extends SceneStep {
  const InteractionStep({
    required this.interactionId,
    required this.prompt,
    required this.successSteps,
  }) : super(type: 'interaction');

  final String interactionId;
  final LocalizedText prompt;
  final List<SceneStep> successSteps;

  factory InteractionStep.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawSuccess =
        json['successSteps'] as List<dynamic>? ?? <dynamic>[];
    return InteractionStep(
      interactionId: json['interactionId'] as String? ?? '',
      prompt: LocalizedText.fromJson(json['prompt']),
      successSteps: rawSuccess
          .map((dynamic e) => SceneStep.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MontageStep extends SceneStep {
  const MontageStep({required this.items, required this.durationMs})
    : super(type: 'montage');

  final List<String> items;
  final int durationMs;

  factory MontageStep.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawItems =
        json['items'] as List<dynamic>? ?? <dynamic>[];
    return MontageStep(
      items: rawItems.map((dynamic e) => e.toString()).toList(),
      durationMs: json['durationMs'] as int? ?? 1200,
    );
  }
}

class NavigateStep extends SceneStep {
  const NavigateStep({required this.to, required this.quizId})
    : super(type: 'navigate');

  final String to;
  final String quizId;

  factory NavigateStep.fromJson(Map<String, dynamic> json) {
    return NavigateStep(
      to: json['to'] as String? ?? 'quiz',
      quizId: json['quizId'] as String? ?? '',
    );
  }
}

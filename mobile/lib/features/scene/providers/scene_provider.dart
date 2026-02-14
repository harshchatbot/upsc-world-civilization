import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/scene_player.dart';
import '../../../data/repositories/scene_repository.dart';

class ScenePlayerState {
  const ScenePlayerState({
    required this.scene,
    required this.stepIndex,
    required this.isInteractionResolved,
  });

  final Scene scene;
  final int stepIndex;
  final bool isInteractionResolved;

  SceneStep get currentStep => scene.steps[stepIndex];

  bool get canAdvance {
    if (currentStep.type == SceneStepType.dialogue) return true;
    if (currentStep.type == SceneStepType.prompt) return isInteractionResolved;
    return false;
  }

  bool get showQuizAction => currentStep.type == SceneStepType.quiz;

  ScenePlayerState copyWith({int? stepIndex, bool? isInteractionResolved}) {
    return ScenePlayerState(
      scene: scene,
      stepIndex: stepIndex ?? this.stepIndex,
      isInteractionResolved:
          isInteractionResolved ?? this.isInteractionResolved,
    );
  }
}

final activeSceneIdProvider = NotifierProvider<ActiveSceneIdController, String>(
  ActiveSceneIdController.new,
);

class ActiveSceneIdController extends Notifier<String> {
  @override
  String build() => 'fire_001';

  void setScene(String sceneId) {
    state = sceneId;
  }
}

final sceneControllerProvider =
    AsyncNotifierProvider<SceneController, ScenePlayerState>(
      SceneController.new,
    );

class SceneController extends AsyncNotifier<ScenePlayerState> {
  @override
  Future<ScenePlayerState> build() async {
    final String sceneId = ref.watch(activeSceneIdProvider);
    return _loadScene(sceneId);
  }

  Future<ScenePlayerState> _loadScene(String sceneId) async {
    final Scene scene = await ref
        .read(sceneRepositoryProvider)
        .loadScene(sceneId);
    return ScenePlayerState(
      scene: scene,
      stepIndex: 0,
      isInteractionResolved: scene.steps.first.type == SceneStepType.dialogue,
    );
  }

  void resolveInteraction() {
    final ScenePlayerState? current = state.value;
    if (current == null) return;
    state = AsyncData<ScenePlayerState>(
      current.copyWith(isInteractionResolved: true),
    );
  }

  void nextStep() {
    final ScenePlayerState? current = state.value;
    if (current == null || !current.canAdvance) return;

    final int next = current.stepIndex + 1;
    if (next >= current.scene.steps.length) return;

    final SceneStep nextStep = current.scene.steps[next];
    state = AsyncData<ScenePlayerState>(
      current.copyWith(
        stepIndex: next,
        isInteractionResolved: nextStep.type == SceneStepType.dialogue,
      ),
    );
  }
}

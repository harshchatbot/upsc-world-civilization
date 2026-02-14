import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../localization/lang.dart';
import '../../audio/audio_mixer.dart';
import '../data/asset_scene_repository.dart';
import '../data/scene_repository.dart';
import '../models/scene.dart';
import '../models/scene_step.dart';
import 'scene_events.dart';
import 'scene_state.dart';
import 'step_runner.dart';

final sceneRepositoryProvider = Provider<SceneRepository>((Ref ref) {
  return const AssetSceneRepository();
});

final sceneControllerProvider = NotifierProvider<SceneController, SceneState>(
  SceneController.new,
);

class SceneController extends Notifier<SceneState> {
  final AudioMixer _mixer = AudioMixer();
  final StepRunner _runner = const StepRunner();
  final StreamController<SceneEvent> _events =
      StreamController<SceneEvent>.broadcast();

  Stream<SceneEvent> get events => _events.stream;

  @override
  SceneState build() {
    ref.onDispose(() async {
      await _mixer.stopAll();
      await _mixer.dispose();
      await _events.close();
    });
    return SceneState.initial();
  }

  Future<void> load(String sceneId) async {
    state = state.copyWith(
      loading: true,
      stepIndex: 0,
      isBlocked: false,
      overlayType: SceneOverlayType.none,
      clearError: true,
      clearInteraction: true,
      montageItems: const <String>[],
      montageDurationMs: 0,
    );

    try {
      final Scene scene = await ref
          .read(sceneRepositoryProvider)
          .getScene(sceneId);
      state = state.copyWith(loading: false, scene: scene, stepIndex: 0);

      await _mixer.init();
      await _mixer.playAmbient(
        scene.audio.ambient.asset,
        scene.audio.ambient.volume,
      );
      await _mixer.playFire(
        scene.audio.fireLoop.asset,
        scene.audio.fireLoop.volume,
      );

      await _processCurrentStep();
    } catch (error) {
      state = state.copyWith(
        loading: false,
        error: 'Failed to load scene: $error',
      );
    }
  }

  void setLang(AppLang lang) {
    if (lang == state.currentLang) return;
    state = state.copyWith(currentLang: lang);
  }

  Future<void> next() async {
    if (state.loading || state.isBlocked) return;

    final Scene? scene = state.scene;
    if (scene == null) return;

    final int nextIndex = state.stepIndex + 1;
    if (nextIndex >= scene.steps.length) {
      _events.add(ShowReward(xp: scene.rewards.xp, badge: scene.rewards.badge));
      return;
    }

    state = state.copyWith(
      stepIndex: nextIndex,
      overlayType: SceneOverlayType.none,
      isBlocked: false,
      clearInteraction: true,
      montageItems: const <String>[],
      montageDurationMs: 0,
    );

    await _processCurrentStep();
  }

  Future<void> completeInteraction(String interactionId) async {
    final Scene? scene = state.scene;
    final SceneStep? current = state.currentStep;
    if (scene == null || current is! InteractionStep) return;
    if (current.interactionId != interactionId) return;

    final List<SceneStep> merged = <SceneStep>[
      ...scene.steps.take(state.stepIndex + 1),
      ...current.successSteps,
      ...scene.steps.skip(state.stepIndex + 1),
    ];

    state = state.copyWith(
      scene: scene.copyWith(steps: merged),
      isBlocked: false,
      overlayType: SceneOverlayType.none,
      clearInteraction: true,
      montageItems: const <String>[],
      montageDurationMs: 0,
    );

    await next();
  }

  Future<void> _processCurrentStep() async {
    final Scene? scene = state.scene;
    final SceneStep? step = state.currentStep;
    if (scene == null || step == null) return;

    if (step is NavigateStep) {
      final String quizId = step.quizId.isNotEmpty
          ? step.quizId
          : scene.navigate.quizId;
      _events.add(NavigateToQuiz(quizId));
      return;
    }

    final StepResult result = await _runner.run(
      scene: scene,
      step: step,
      mixer: _mixer,
    );

    state = state.copyWith(
      isBlocked: result.block,
      overlayType: result.overlayType,
      montageItems: result.montageItems,
      montageDurationMs: result.montageDurationMs,
      activeInteractionId: result.interactionId,
    );

    if (step is SfxStep || step is AudioMixStep) {
      await next();
      return;
    }

    if (step is MontageStep) {
      final int duration = result.montageDurationMs <= 0
          ? 1000
          : result.montageDurationMs;
      Future<void>.delayed(Duration(milliseconds: duration), () {
        state = state.copyWith(
          isBlocked: false,
          overlayType: SceneOverlayType.none,
          montageItems: const <String>[],
          montageDurationMs: 0,
        );
      });
    }
  }
}

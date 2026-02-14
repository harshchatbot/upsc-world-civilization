import '../../audio/audio_mixer.dart';
import '../models/scene.dart';
import '../models/scene_step.dart';
import 'scene_state.dart';

class StepResult {
  const StepResult({
    required this.block,
    required this.overlayType,
    required this.montageItems,
    required this.montageDurationMs,
    required this.interactionId,
  });

  final bool block;
  final SceneOverlayType overlayType;
  final List<String> montageItems;
  final int montageDurationMs;
  final String? interactionId;

  factory StepResult.none() {
    return const StepResult(
      block: false,
      overlayType: SceneOverlayType.none,
      montageItems: <String>[],
      montageDurationMs: 0,
      interactionId: null,
    );
  }
}

class StepRunner {
  const StepRunner();

  Future<StepResult> run({
    required Scene scene,
    required SceneStep step,
    required AudioMixer mixer,
  }) async {
    if (step is SfxStep) {
      final String asset = scene.audio.sfx[step.key] ?? '';
      await mixer.playSfx(asset);
      return StepResult.none();
    }

    if (step is AudioMixStep) {
      final MixerTrack track = step.target == 'fireLoop'
          ? MixerTrack.fire
          : MixerTrack.ambient;
      await mixer.setVolume(track, step.toVolume, step.durationMs);
      return StepResult.none();
    }

    if (step is MontageStep) {
      return StepResult(
        block: true,
        overlayType: SceneOverlayType.montage,
        montageItems: step.items,
        montageDurationMs: step.durationMs,
        interactionId: null,
      );
    }

    if (step is InteractionStep) {
      return StepResult(
        block: true,
        overlayType: SceneOverlayType.interaction,
        montageItems: const <String>[],
        montageDurationMs: 0,
        interactionId: step.interactionId,
      );
    }

    return StepResult.none();
  }
}

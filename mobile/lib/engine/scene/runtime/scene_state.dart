import '../../../localization/lang.dart';
import '../models/scene.dart';
import '../models/scene_step.dart';

enum SceneOverlayType { none, montage, interaction }

class SceneState {
  const SceneState({
    required this.loading,
    required this.scene,
    required this.stepIndex,
    required this.isBlocked,
    required this.overlayType,
    required this.error,
    required this.currentLang,
    required this.montageItems,
    required this.montageDurationMs,
    required this.activeInteractionId,
  });

  final bool loading;
  final Scene? scene;
  final int stepIndex;
  final bool isBlocked;
  final SceneOverlayType overlayType;
  final String? error;
  final AppLang currentLang;
  final List<String> montageItems;
  final int montageDurationMs;
  final String? activeInteractionId;

  factory SceneState.initial() {
    return const SceneState(
      loading: false,
      scene: null,
      stepIndex: 0,
      isBlocked: false,
      overlayType: SceneOverlayType.none,
      error: null,
      currentLang: AppLang.en,
      montageItems: <String>[],
      montageDurationMs: 0,
      activeInteractionId: null,
    );
  }

  SceneStep? get currentStep {
    final Scene? s = scene;
    if (s == null || s.steps.isEmpty) return null;
    if (stepIndex < 0 || stepIndex >= s.steps.length) return null;
    return s.steps[stepIndex];
  }

  SceneState copyWith({
    bool? loading,
    Scene? scene,
    int? stepIndex,
    bool? isBlocked,
    SceneOverlayType? overlayType,
    String? error,
    bool clearError = false,
    AppLang? currentLang,
    List<String>? montageItems,
    int? montageDurationMs,
    String? activeInteractionId,
    bool clearInteraction = false,
  }) {
    return SceneState(
      loading: loading ?? this.loading,
      scene: scene ?? this.scene,
      stepIndex: stepIndex ?? this.stepIndex,
      isBlocked: isBlocked ?? this.isBlocked,
      overlayType: overlayType ?? this.overlayType,
      error: clearError ? null : (error ?? this.error),
      currentLang: currentLang ?? this.currentLang,
      montageItems: montageItems ?? this.montageItems,
      montageDurationMs: montageDurationMs ?? this.montageDurationMs,
      activeInteractionId: clearInteraction
          ? null
          : (activeInteractionId ?? this.activeInteractionId),
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_language.dart';
import '../../../core/localization/localization_resolver.dart';
import '../../../core/widgets/language_toggle_button.dart';
import '../../../data/models/localized_text.dart';
import '../../../data/models/scene_player.dart';
import '../../home/providers/language_provider.dart';
import '../audio/audio_mixer.dart';
import '../providers/scene_provider.dart';

class SceneScreen extends ConsumerStatefulWidget {
  const SceneScreen({super.key, required this.nodeId, required this.sceneId});

  final String nodeId;
  final String sceneId;

  @override
  ConsumerState<SceneScreen> createState() => _SceneScreenState();
}

class _SceneScreenState extends ConsumerState<SceneScreen> {
  final AudioMixer _mixer = AudioMixer();
  String? _audioSceneId;
  double _lookX = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeSceneIdProvider.notifier).setScene(widget.sceneId);
    });
  }

  @override
  void didUpdateWidget(covariant SceneScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sceneId != widget.sceneId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(activeSceneIdProvider.notifier).setScene(widget.sceneId);
      });
    }
  }

  @override
  void dispose() {
    _mixer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLanguage lang =
        ref.watch(appLanguageProvider).value ?? AppLanguage.en;
    final AsyncValue<ScenePlayerState> sceneStateAsync = ref.watch(
      sceneControllerProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scene Player'),
        actions: const <Widget>[LanguageToggleButton(), SizedBox(width: 8)],
      ),
      body: sceneStateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) =>
            Center(child: Text('Unable to load scene: $error')),
        data: (ScenePlayerState sceneState) {
          _startAudioIfNeeded(sceneState.scene);
          _syncCrossfade(sceneState);

          final Scene scene = sceneState.scene;
          final SceneStep step = sceneState.currentStep;

          return Column(
            children: <Widget>[
              Expanded(flex: 5, child: _buildParallaxView(scene)),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        resolve(scene.title, lang),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF5A3E2B)),
                        ),
                        child: Text(
                          resolve(step.text, lang),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (step.type == SceneStepType.prompt &&
                          !sceneState.isInteractionResolved)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ref
                                  .read(sceneControllerProvider.notifier)
                                  .resolveInteraction();
                            },
                            icon: const Icon(Icons.touch_app),
                            label: Text(
                              resolve(
                                step.promptLabel ??
                                    const LocalizedText(
                                      en: 'Acknowledge Prompt',
                                      hi: 'संकेत स्वीकारें',
                                    ),
                                lang,
                              ),
                            ),
                          ),
                        ),
                      const Spacer(),
                      _buildBottomAction(
                        context: context,
                        lang: lang,
                        step: step,
                        sceneState: sceneState,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildParallaxView(Scene scene) {
    return GestureDetector(
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        setState(() {
          _lookX = (_lookX + details.delta.dx / 220).clamp(-1.0, 1.0);
        });
      },
      onHorizontalDragEnd: (_) {
        setState(() {
          _lookX = 0;
        });
      },
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.asset(
              scene.backgroundAsset,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.low,
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stackTrace) {
                    return Container(
                      color: const Color(0xFF544434),
                      alignment: Alignment.center,
                      child: const Text('Background missing'),
                    );
                  },
            ),
            ...scene.layers.map((ParallaxLayer layer) {
              final double shift = _lookX * 18 * layer.depth;
              return TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: shift),
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                builder: (BuildContext context, double value, Widget? child) {
                  return Positioned.fill(
                    child: Transform.translate(
                      offset: Offset(value, 0),
                      child: Opacity(opacity: layer.opacity, child: child),
                    ),
                  );
                },
                child: Align(
                  alignment: Alignment(
                    (layer.alignmentX * 2) - 1,
                    (layer.alignmentY * 2) - 1,
                  ),
                  child: Image.asset(
                    layer.asset,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.low,
                    errorBuilder:
                        (
                          BuildContext context,
                          Object error,
                          StackTrace? stackTrace,
                        ) {
                          return const SizedBox.shrink();
                        },
                  ),
                ),
              );
            }),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.black.withValues(alpha: 0.16),
                    Colors.black.withValues(alpha: 0.35),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction({
    required BuildContext context,
    required AppLanguage lang,
    required SceneStep step,
    required ScenePlayerState sceneState,
  }) {
    if (step.type == SceneStepType.quiz) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: () {
            context.push(
              '/quiz/${sceneState.scene.quizId}?nodeId=${Uri.encodeComponent(widget.nodeId)}',
            );
          },
          child: Text(
            resolve(
              step.cta ??
                  const LocalizedText(en: 'Start Quiz', hi: 'क्विज़ शुरू करें'),
              lang,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: sceneState.canAdvance
            ? () {
                ref.read(sceneControllerProvider.notifier).nextStep();
              }
            : null,
        child: Text(
          sceneState.canAdvance
              ? (lang == AppLanguage.hi ? 'आगे' : 'Next')
              : (lang == AppLanguage.hi
                    ? 'पहले संकेत पूरा करें'
                    : 'Complete prompt first'),
        ),
      ),
    );
  }

  void _startAudioIfNeeded(Scene scene) {
    if (_audioSceneId == scene.id) return;
    _audioSceneId = scene.id;
    _mixer.loadAndPlay(
      ambientAsset: scene.audio.ambientAsset,
      musicAsset: scene.audio.musicAsset,
      ambientVolume: scene.audio.ambientVolume,
      musicVolume: scene.audio.musicVolume,
    );
  }

  void _syncCrossfade(ScenePlayerState state) {
    final int total = math.max(1, state.scene.steps.length - 1);
    final double progress = state.stepIndex / total;
    _mixer.crossfade(progress);
  }
}

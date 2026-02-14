import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../localization/lang.dart';
import '../../../localization/lang_controller.dart';
import '../../../localization/localized_text.dart';
import '../models/scene_step.dart';
import '../runtime/scene_controller.dart';
import '../runtime/scene_events.dart';
import '../runtime/scene_state.dart';
import 'widgets/dialogue_box.dart';
import 'widgets/interaction_overlay.dart';
import 'widgets/montage_overlay.dart';
import 'widgets/next_button.dart';
import 'widgets/parallax_stack.dart';

class ScenePlayerScreen extends ConsumerStatefulWidget {
  const ScenePlayerScreen({super.key, required this.sceneId});

  final String sceneId;

  @override
  ConsumerState<ScenePlayerScreen> createState() => _ScenePlayerScreenState();
}

class _ScenePlayerScreenState extends ConsumerState<ScenePlayerScreen> {
  StreamSubscription<SceneEvent>? _eventSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sceneControllerProvider.notifier).load(widget.sceneId);
      _subscribeEvents();
    });
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    super.dispose();
  }

  void _subscribeEvents() {
    _eventSub?.cancel();
    _eventSub = ref.read(sceneControllerProvider.notifier).events.listen((
      SceneEvent event,
    ) {
      if (!mounted) return;
      if (event is NavigateToQuiz) {
        context.go('/quiz/${event.quizId}');
      } else if (event is ShowReward) {
        showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Reward Unlocked'),
              content: Text('XP +${event.xp}\nBadge: ${event.badge}'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLang lang = ref.watch(langControllerProvider);
    final SceneState sceneState = ref.watch(sceneControllerProvider);

    if (sceneState.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (sceneState.error != null) {
      return Scaffold(body: Center(child: Text(sceneState.error!)));
    }

    final SceneStep? step = sceneState.currentStep;
    if (sceneState.scene == null || step == null) {
      return const Scaffold(body: Center(child: Text('No scene loaded')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(sceneState.scene!.title.resolve(lang)),
        actions: <Widget>[
          IconButton(
            tooltip: 'Toggle language',
            onPressed: () => ref.read(langControllerProvider.notifier).toggle(),
            icon: Text(
              lang == AppLang.en ? 'EN' : 'हि',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                ParallaxStack(layers: sceneState.scene!.layers),
                if (sceneState.overlayType == SceneOverlayType.interaction &&
                    step is InteractionStep)
                  InteractionOverlay(
                    prompt: step.prompt.resolve(lang),
                    onSuccess: () {
                      ref
                          .read(sceneControllerProvider.notifier)
                          .completeInteraction(step.interactionId);
                    },
                  ),
                if (sceneState.overlayType == SceneOverlayType.montage)
                  MontageOverlay(items: sceneState.montageItems),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  if (step is DialogueStep)
                    DialogueBox(
                      speaker: step.speaker,
                      text: step.text.resolve(lang),
                    )
                  else if (step is InteractionStep)
                    DialogueBox(speaker: '', text: step.prompt.resolve(lang))
                  else
                    DialogueBox(
                      speaker: '',
                      text: const LocalizedText(
                        values: <String, String>{
                          'en': 'Prepare for the next moment.',
                          'hi': 'अगले क्षण के लिए तैयार रहें।',
                        },
                      ).resolve(lang),
                    ),
                  const Spacer(),
                  NextButton(
                    enabled: !sceneState.isBlocked,
                    onPressed: () {
                      ref.read(sceneControllerProvider.notifier).next();
                    },
                    label: lang == AppLang.hi ? 'आगे' : 'Next',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

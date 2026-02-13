import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/scene_step.dart';
import '../providers/scene_provider.dart';

class SceneScreen extends ConsumerStatefulWidget {
  const SceneScreen({super.key, required this.nodeId});

  final String nodeId;

  @override
  ConsumerState<SceneScreen> createState() => _SceneScreenState();
}

class _SceneScreenState extends ConsumerState<SceneScreen> {
  int _stepIndex = 0;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<SceneContent> sceneAsync = ref.watch(
      sceneByNodeProvider(widget.nodeId),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Historical Scene')),
      body: sceneAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) =>
            const Center(child: Text('Unable to load scene.')),
        data: (SceneContent scene) {
          final List<String> dialogues = scene.dialogues;
          final bool hasNext = _stepIndex < dialogues.length - 1;

          return Column(
            children: <Widget>[
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  scene.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (
                        BuildContext context,
                        Object error,
                        StackTrace? stackTrace,
                      ) => Container(
                        color: const Color(0xFFCFC1AA),
                        alignment: Alignment.center,
                        child: const Text('Image unavailable'),
                      ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Container(
                            key: ValueKey<int>(_stepIndex),
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF5A3E2B),
                              ),
                            ),
                            child: Text(
                              dialogues[_stepIndex],
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                            if (hasNext) {
                              setState(() {
                                _stepIndex += 1;
                              });
                            } else {
                              context.push('/quiz/${widget.nodeId}');
                            }
                          },
                          child: Text(hasNext ? 'Next' : 'Start Quiz'),
                        ),
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
}

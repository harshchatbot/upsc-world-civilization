import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/era_node.dart';
import '../../../data/models/quiz_question.dart';
import '../../home/providers/home_providers.dart';
import '../../map/providers/map_providers.dart';
import '../providers/quiz_provider.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key, required this.nodeId});

  final String nodeId;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _questionIndex = 0;
  int? _selectedIndex;
  bool _submitted = false;
  int _correctCount = 0;

  static const int _xpPerCorrect = 20;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<QuizQuestion>> quizAsync = ref.watch(
      quizByNodeProvider(widget.nodeId),
    );
    final AsyncValue<List<EraNode>> nodesAsync = ref.watch(eraNodesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Checkpoint')),
      body: quizAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) =>
            const Center(child: Text('Unable to load quiz.')),
        data: (List<QuizQuestion> questions) {
          if (questions.isEmpty) {
            return const Center(child: Text('No quiz questions available.'));
          }

          final QuizQuestion question = questions[_questionIndex];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Question ${_questionIndex + 1}/${questions.length}'),
                const SizedBox(height: 10),
                Text(
                  question.question,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ...List<Widget>.generate(question.options.length, (int idx) {
                  final bool isCorrect = idx == question.correctIndex;
                  final bool isSelected = idx == _selectedIndex;

                  Color? tileColor;
                  if (_submitted && isSelected && !isCorrect) {
                    tileColor = Colors.red.shade100;
                  }
                  if (_submitted && isCorrect) {
                    tileColor = Colors.green.shade100;
                  }

                  return Card(
                    color: tileColor,
                    child: ListTile(
                      title: Text(question.options[idx]),
                      onTap: _submitted
                          ? null
                          : () {
                              setState(() {
                                _selectedIndex = idx;
                              });
                            },
                    ),
                  );
                }),
                const SizedBox(height: 10),
                if (_submitted)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF5A3E2B)),
                    ),
                    child: Text(question.explanation),
                  ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      if (!_submitted) {
                        if (_selectedIndex == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Select an answer first.'),
                            ),
                          );
                          return;
                        }
                        setState(() {
                          _submitted = true;
                          if (_selectedIndex == question.correctIndex) {
                            _correctCount += 1;
                          }
                        });
                        return;
                      }

                      if (_questionIndex < questions.length - 1) {
                        setState(() {
                          _questionIndex += 1;
                          _submitted = false;
                          _selectedIndex = null;
                        });
                        return;
                      }

                      final int xpGain = _correctCount * _xpPerCorrect;
                      final List<EraNode> nodes =
                          nodesAsync.value ?? <EraNode>[];
                      final EraNode node = nodes.firstWhere(
                        (EraNode n) => n.id == widget.nodeId,
                        orElse: () => const EraNode(
                          id: 'fallback',
                          title: 'Fallback',
                          order: 0,
                          dx: 0,
                          dy: 0,
                          sceneId: 'fallback',
                        ),
                      );
                      await ref
                          .read(progressControllerProvider.notifier)
                          .completeNode(
                            nodeId: widget.nodeId,
                            nodeOrder: node.order,
                            xpGain: xpGain,
                          );

                      if (!context.mounted) return;
                      final ScaffoldMessengerState messenger =
                          ScaffoldMessenger.of(context);
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            'Quiz complete. +$xpGain XP. $_correctCount/${questions.length} correct.',
                          ),
                        ),
                      );
                      context.go('/map');
                    },
                    child: Text(
                      _submitted
                          ? (_questionIndex < questions.length - 1
                                ? 'Next Question'
                                : 'Finish Era')
                          : 'Submit Answer',
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

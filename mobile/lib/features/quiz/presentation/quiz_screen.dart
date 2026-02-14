import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_language.dart';
import '../../../core/localization/localization_resolver.dart';
import '../../../core/widgets/language_toggle_button.dart';
import '../../../data/models/era_node.dart';
import '../../../data/models/localized_quiz.dart';
import '../../home/providers/home_providers.dart';
import '../../home/providers/language_provider.dart';
import '../../map/providers/map_providers.dart';
import '../providers/quiz_provider.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key, required this.quizId, this.nodeId});

  final String quizId;
  final String? nodeId;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _questionIndex = 0;
  int? _selectedIndex;
  bool _submitted = false;
  int _correctCount = 0;

  @override
  Widget build(BuildContext context) {
    final AppLanguage lang =
        ref.watch(appLanguageProvider).value ?? AppLanguage.en;
    final AsyncValue<LocalizedQuiz> quizAsync = ref.watch(
      localizedQuizProvider(widget.quizId),
    );
    final AsyncValue<List<EraNode>> nodesAsync = ref.watch(eraNodesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang == AppLanguage.hi ? 'ज्ञान जांच' : 'Quiz Checkpoint'),
        actions: const <Widget>[LanguageToggleButton(), SizedBox(width: 8)],
      ),
      body: quizAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) =>
            const Center(child: Text('Unable to load quiz.')),
        data: (LocalizedQuiz quiz) {
          if (quiz.questions.isEmpty) {
            return const Center(child: Text('No quiz questions available.'));
          }

          final LocalizedQuizQuestion question = quiz.questions[_questionIndex];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(resolve(quiz.title, lang)),
                const SizedBox(height: 6),
                Text(
                  lang == AppLanguage.hi
                      ? 'प्रश्न ${_questionIndex + 1}/${quiz.questions.length}'
                      : 'Question ${_questionIndex + 1}/${quiz.questions.length}',
                ),
                const SizedBox(height: 10),
                Text(
                  resolve(question.question, lang),
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
                      title: Text(resolve(question.options[idx], lang)),
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
                    child: Text(resolve(question.explanation, lang)),
                  ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      if (!_submitted) {
                        if (_selectedIndex == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                lang == AppLanguage.hi
                                    ? 'पहले एक उत्तर चुनें।'
                                    : 'Select an answer first.',
                              ),
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

                      if (_questionIndex < quiz.questions.length - 1) {
                        setState(() {
                          _questionIndex += 1;
                          _submitted = false;
                          _selectedIndex = null;
                        });
                        return;
                      }

                      final int xpGain = _correctCount * quiz.xpPerCorrect;

                      if (widget.nodeId != null && widget.nodeId!.isNotEmpty) {
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
                              nodeId: widget.nodeId!,
                              nodeOrder: node.order,
                              xpGain: xpGain,
                            );

                        final EraNode? nextNode = nodes
                            .cast<EraNode?>()
                            .firstWhere(
                              (EraNode? n) => n?.order == node.order + 1,
                              orElse: () => null,
                            );

                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              lang == AppLanguage.hi
                                  ? 'क्विज़ पूरा। +$xpGain XP। सही: $_correctCount/${quiz.questions.length}'
                                  : 'Quiz complete. +$xpGain XP. Correct: $_correctCount/${quiz.questions.length}',
                            ),
                          ),
                        );

                        final String focusNodeId = (nextNode ?? node).id;
                        context.go(
                          '/map?focusNodeId=${Uri.encodeComponent(focusNodeId)}',
                        );
                        return;
                      }

                      if (!context.mounted) return;
                      context.go('/map');
                    },
                    child: Text(
                      !_submitted
                          ? (lang == AppLanguage.hi ? 'जमा करें' : 'Submit')
                          : (_questionIndex < quiz.questions.length - 1
                                ? (lang == AppLanguage.hi
                                      ? 'अगला प्रश्न'
                                      : 'Next Question')
                                : (lang == AppLanguage.hi
                                      ? 'क्विज़ समाप्त'
                                      : 'Finish Quiz')),
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

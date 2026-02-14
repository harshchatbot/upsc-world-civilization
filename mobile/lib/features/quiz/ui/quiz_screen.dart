import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../engine/audio/audio_keys.dart';
import '../../../engine/audio/audio_mixer.dart';
import '../../../localization/lang.dart';
import '../../../localization/lang_controller.dart';
import '../data/asset_quiz_repository.dart';
import '../data/quiz_repository.dart';
import '../models/quiz.dart';

final quizRepositoryProvider = Provider<QuizRepository>((Ref ref) {
  return const AssetQuizRepository();
});

final quizProvider = FutureProvider.family<Quiz, String>((
  Ref ref,
  String quizId,
) {
  return ref.read(quizRepositoryProvider).getQuiz(quizId);
});

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key, required this.quizId});

  final String quizId;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _qIndex = 0;
  String? _selectedId;
  bool _submitted = false;

  final AudioMixer _mixer = AudioMixer();

  @override
  void dispose() {
    _mixer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLang lang = ref.watch(langControllerProvider);
    final AsyncValue<Quiz> quizAsync = ref.watch(quizProvider(widget.quizId));

    return Scaffold(
      appBar: AppBar(
        title: Text(lang == AppLang.hi ? 'क्विज़' : 'Quiz'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Toggle language',
            onPressed: () => ref.read(langControllerProvider.notifier).toggle(),
            icon: Text(lang == AppLang.en ? 'EN' : 'हि'),
          ),
        ],
      ),
      body: quizAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) =>
            Center(child: Text('Failed to load quiz: $error')),
        data: (Quiz quiz) {
          if (quiz.questions.isEmpty) {
            return const Center(child: Text('No questions found.'));
          }

          final QuizQuestion question = quiz.questions[_qIndex];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  quiz.title.resolve(lang),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  lang == AppLang.hi
                      ? 'प्रश्न ${_qIndex + 1}/${quiz.questions.length}'
                      : 'Question ${_qIndex + 1}/${quiz.questions.length}',
                ),
                const SizedBox(height: 12),
                Text(question.prompt.resolve(lang)),
                const SizedBox(height: 12),
                ...question.options.map((QuizOption option) {
                  final bool isCorrect = option.id == question.answerId;
                  final bool isSelected = option.id == _selectedId;

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
                      title: Text(option.text.resolve(lang)),
                      onTap: _submitted
                          ? null
                          : () {
                              setState(() {
                                _selectedId = option.id;
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
                    child: Text(question.explanation.resolve(lang)),
                  ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      if (!_submitted) {
                        if (_selectedId == null) return;
                        final bool isCorrect = _selectedId == question.answerId;
                        await _mixer.playSfx(
                          isCorrect
                              ? 'assets/audio/${AudioKeys.correct}.mp3'
                              : 'assets/audio/${AudioKeys.wrong}.mp3',
                        );
                        setState(() {
                          _submitted = true;
                        });
                        return;
                      }

                      if (_qIndex < quiz.questions.length - 1) {
                        setState(() {
                          _qIndex += 1;
                          _selectedId = null;
                          _submitted = false;
                        });
                        return;
                      }

                      if (!mounted) return;
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      !_submitted
                          ? (lang == AppLang.hi ? 'जमा करें' : 'Submit')
                          : (_qIndex < quiz.questions.length - 1
                                ? (lang == AppLang.hi
                                      ? 'अगला प्रश्न'
                                      : 'Next Question')
                                : (lang == AppLang.hi ? 'समाप्त' : 'Finish')),
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

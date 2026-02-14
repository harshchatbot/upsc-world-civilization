import 'localized_text.dart';

class LocalizedQuizQuestion {
  const LocalizedQuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String id;
  final LocalizedText question;
  final List<LocalizedText> options;
  final int correctIndex;
  final LocalizedText explanation;

  factory LocalizedQuizQuestion.fromMap(Map<String, dynamic> map) {
    final List<dynamic> rawOptions =
        map['options'] as List<dynamic>? ?? <dynamic>[];
    return LocalizedQuizQuestion(
      id: map['id'] as String? ?? '',
      question: LocalizedText.fromMap(map['question'] as Map<String, dynamic>?),
      options: rawOptions
          .map(
            (dynamic option) =>
                LocalizedText.fromMap(option as Map<String, dynamic>?),
          )
          .toList(),
      correctIndex: map['correctIndex'] as int? ?? 0,
      explanation: LocalizedText.fromMap(
        map['explanation'] as Map<String, dynamic>?,
      ),
    );
  }
}

class LocalizedQuiz {
  const LocalizedQuiz({
    required this.id,
    required this.title,
    required this.questions,
    this.xpPerCorrect = 20,
  });

  final String id;
  final LocalizedText title;
  final List<LocalizedQuizQuestion> questions;
  final int xpPerCorrect;

  factory LocalizedQuiz.fromMap(Map<String, dynamic> map) {
    final List<dynamic> rawQuestions =
        map['questions'] as List<dynamic>? ?? <dynamic>[];

    return LocalizedQuiz(
      id: map['id'] as String? ?? '',
      title: LocalizedText.fromMap(map['title'] as Map<String, dynamic>?),
      xpPerCorrect: map['xpPerCorrect'] as int? ?? 20,
      questions: rawQuestions
          .map(
            (dynamic q) =>
                LocalizedQuizQuestion.fromMap(q as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

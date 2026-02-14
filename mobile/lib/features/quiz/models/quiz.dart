import '../../../localization/localized_text.dart';

class QuizOption {
  const QuizOption({required this.id, required this.text});

  final String id;
  final LocalizedText text;

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(
      id: json['id'] as String? ?? '',
      text: LocalizedText.fromJson(json['text']),
    );
  }
}

class QuizQuestion {
  const QuizQuestion({
    required this.prompt,
    required this.options,
    required this.answerId,
    required this.explanation,
  });

  final LocalizedText prompt;
  final List<QuizOption> options;
  final String answerId;
  final LocalizedText explanation;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawOptions =
        json['options'] as List<dynamic>? ?? <dynamic>[];
    return QuizQuestion(
      prompt: LocalizedText.fromJson(json['prompt']),
      options: rawOptions
          .map((dynamic e) => QuizOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      answerId: json['answerId'] as String? ?? '',
      explanation: LocalizedText.fromJson(json['explanation']),
    );
  }
}

class Quiz {
  const Quiz({
    required this.quizId,
    required this.title,
    required this.questions,
  });

  final String quizId;
  final LocalizedText title;
  final List<QuizQuestion> questions;

  factory Quiz.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawQuestions =
        json['questions'] as List<dynamic>? ?? <dynamic>[];
    return Quiz(
      quizId: json['quizId'] as String? ?? '',
      title: LocalizedText.fromJson(json['title']),
      questions: rawQuestions
          .map((dynamic e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

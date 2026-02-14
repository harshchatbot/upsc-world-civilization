import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/quiz.dart';
import 'quiz_repository.dart';

class AssetQuizRepository implements QuizRepository {
  const AssetQuizRepository();

  @override
  Future<Quiz> getQuiz(String quizId) async {
    try {
      final String raw = await rootBundle.loadString(
        'assets/quizzes/$quizId.json',
      );
      return Quiz.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      final String raw = await rootBundle.loadString(
        'assets/quizzes/quiz_fire_001.json',
      );
      return Quiz.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    }
  }
}

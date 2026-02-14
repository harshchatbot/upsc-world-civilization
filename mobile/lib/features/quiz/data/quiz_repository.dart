import '../models/quiz.dart';

abstract class QuizRepository {
  Future<Quiz> getQuiz(String quizId);
}

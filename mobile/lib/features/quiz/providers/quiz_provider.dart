import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/localized_quiz.dart';
import '../../../data/repositories/scene_repository.dart';

final localizedQuizProvider = FutureProvider.family<LocalizedQuiz, String>((
  Ref ref,
  String quizId,
) async {
  return ref.read(sceneRepositoryProvider).loadQuiz(quizId);
});

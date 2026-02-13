import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/quiz_question.dart';
import '../../../data/repositories/content_repository.dart';

final quizByNodeProvider = FutureProvider.family<List<QuizQuestion>, String>((
  Ref ref,
  String nodeId,
) async {
  return ref.read(contentRepositoryProvider).fetchQuizByNodeId(nodeId);
});

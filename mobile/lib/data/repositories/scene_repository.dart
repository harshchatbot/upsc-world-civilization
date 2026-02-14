import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/localized_quiz.dart';
import '../models/scene_player.dart';

final sceneRepositoryProvider = Provider<SceneRepository>((Ref ref) {
  return SceneRepository();
});

class SceneRepository {
  Future<Scene> loadScene(String sceneId) async {
    final String raw = await rootBundle.loadString(
      'assets/scenes/$sceneId.json',
    );
    final Map<String, dynamic> map = jsonDecode(raw) as Map<String, dynamic>;
    return Scene.fromMap(map);
  }

  Future<LocalizedQuiz> loadQuiz(String quizId) async {
    final String raw = await rootBundle.loadString(
      'assets/quizzes/$quizId.json',
    );
    final Map<String, dynamic> map = jsonDecode(raw) as Map<String, dynamic>;
    return LocalizedQuiz.fromMap(map);
  }
}

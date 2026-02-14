import '../models/scene.dart';

abstract class SceneRepository {
  Future<Scene> getScene(String sceneId);
}

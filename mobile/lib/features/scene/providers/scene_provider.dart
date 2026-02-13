import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/scene_step.dart';
import '../../../data/repositories/content_repository.dart';

final sceneByNodeProvider = FutureProvider.family<SceneContent, String>((
  Ref ref,
  String nodeId,
) async {
  return ref.read(contentRepositoryProvider).fetchSceneByNodeId(nodeId);
});

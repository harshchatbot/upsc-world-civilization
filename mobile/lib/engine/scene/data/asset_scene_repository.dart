import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/scene.dart';
import 'scene_repository.dart';

class AssetSceneRepository implements SceneRepository {
  const AssetSceneRepository();

  @override
  Future<Scene> getScene(String sceneId) async {
    try {
      final String raw = await rootBundle.loadString(
        'assets/scenes/$sceneId.json',
      );
      final Map<String, dynamic> json = jsonDecode(raw) as Map<String, dynamic>;
      return Scene.fromJson(json);
    } catch (_) {
      final String raw = await rootBundle.loadString(
        'assets/scenes/fire_001.json',
      );
      final Map<String, dynamic> json = jsonDecode(raw) as Map<String, dynamic>;
      return Scene.fromJson(json);
    }
  }
}

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_progress.dart';

final Provider<ProgressRepository> progressRepositoryProvider =
    Provider<ProgressRepository>((Ref ref) {
      return ProgressRepository(FirebaseFirestore.instance);
    });

class ProgressRepository {
  ProgressRepository(this._firestore);

  final FirebaseFirestore _firestore;
  static const String _localKey = 'user_progress_v1';

  Future<UserProgress> loadProgress() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_localKey);
    if (raw == null) {
      return UserProgress.initial();
    }
    final Map<String, dynamic> map = jsonDecode(raw) as Map<String, dynamic>;
    return UserProgress(
      xp: map['xp'] as int? ?? 0,
      unlockedOrder: map['unlockedOrder'] as int? ?? 0,
      completedNodeIds:
          (map['completedNodeIds'] as List<dynamic>? ?? <dynamic>[])
              .map((dynamic e) => e.toString())
              .toSet(),
    );
  }

  Future<void> saveProgress(UserProgress progress) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> map = <String, dynamic>{
      'xp': progress.xp,
      'unlockedOrder': progress.unlockedOrder,
      'completedNodeIds': progress.completedNodeIds.toList(),
    };
    await prefs.setString(_localKey, jsonEncode(map));

    try {
      await _firestore.collection('user_progress').doc('local_user').set(map);
    } catch (_) {
      // Firestore sync is optional for offline-first MVP.
    }
  }
}

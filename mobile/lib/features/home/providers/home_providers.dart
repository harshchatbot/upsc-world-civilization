import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/user_progress.dart';
import '../../../data/repositories/progress_repository.dart';

final AsyncNotifierProvider<ProgressController, UserProgress>
progressControllerProvider =
    AsyncNotifierProvider<ProgressController, UserProgress>(
      ProgressController.new,
    );

class ProgressController extends AsyncNotifier<UserProgress> {
  @override
  Future<UserProgress> build() async {
    return ref.read(progressRepositoryProvider).loadProgress();
  }

  Future<void> completeNode({
    required String nodeId,
    required int nodeOrder,
    required int xpGain,
  }) async {
    final UserProgress current = state.value ?? UserProgress.initial();
    if (current.completedNodeIds.contains(nodeId)) {
      return;
    }
    final Set<String> updatedIds = Set<String>.from(current.completedNodeIds)
      ..add(nodeId);
    final UserProgress updated = current.copyWith(
      xp: current.xp + xpGain,
      unlockedOrder: nodeOrder + 1 > current.unlockedOrder
          ? nodeOrder + 1
          : current.unlockedOrder,
      completedNodeIds: updatedIds,
    );
    state = AsyncData<UserProgress>(updated);
    await ref.read(progressRepositoryProvider).saveProgress(updated);
  }
}

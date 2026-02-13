class UserProgress {
  const UserProgress({
    required this.xp,
    required this.unlockedOrder,
    required this.completedNodeIds,
  });

  final int xp;
  final int unlockedOrder;
  final Set<String> completedNodeIds;

  UserProgress copyWith({
    int? xp,
    int? unlockedOrder,
    Set<String>? completedNodeIds,
  }) {
    return UserProgress(
      xp: xp ?? this.xp,
      unlockedOrder: unlockedOrder ?? this.unlockedOrder,
      completedNodeIds: completedNodeIds ?? this.completedNodeIds,
    );
  }

  factory UserProgress.initial() {
    return const UserProgress(
      xp: 0,
      unlockedOrder: 0,
      completedNodeIds: <String>{},
    );
  }
}

sealed class SceneEvent {
  const SceneEvent();
}

class NavigateToQuiz extends SceneEvent {
  const NavigateToQuiz(this.quizId);

  final String quizId;
}

class ShowReward extends SceneEvent {
  const ShowReward({required this.xp, required this.badge});

  final int xp;
  final String badge;
}

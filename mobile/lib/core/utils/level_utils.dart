int levelFromXp(int xp) => (xp ~/ 100) + 1;

int xpToNextLevel(int xp) {
  final int nextLevelXp = ((xp ~/ 100) + 1) * 100;
  return nextLevelXp - xp;
}

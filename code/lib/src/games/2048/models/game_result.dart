class GameResult {
  const GameResult({
    required this.score,
    required this.bestTile,
    required this.moveCount,
    required this.durationMs,
    required this.reached2048,
    required this.isGameOver,
  });

  final int score;
  final int bestTile;
  final int moveCount;
  final int durationMs;
  final bool reached2048;
  final bool isGameOver;

  Map<String, Object?> toSummary() {
    return {
      'score': score,
      'bestTile': bestTile,
      'moveCount': moveCount,
      'durationMs': durationMs,
      'mode': 'classic',
      'reached2048': reached2048,
    };
  }
}

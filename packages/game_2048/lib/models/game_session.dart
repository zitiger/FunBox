import '../logic/board_state.dart';

class GameSession {
  GameSession({
    required this.board,
    this.score = 0,
    this.moveCount = 0,
    this.startTimeMs = 0,
    this.elapsedMs = 0,
    this.reached2048 = false,
    this.bestTile = 0,
  });

  BoardState board;
  int score;
  int moveCount;
  int startTimeMs;
  int elapsedMs;
  bool reached2048;
  int bestTile;

  Map<String, Object?> toJson() {
    return {
      'board': board.toJson(),
      'score': score,
      'moveCount': moveCount,
      'startTimeMs': startTimeMs,
      'elapsedMs': elapsedMs,
      'reached2048': reached2048,
      'bestTile': bestTile,
    };
  }

  factory GameSession.fromJson(Map<String, Object?> json) {
    return GameSession(
      board: BoardState.fromJson(json['board'] as Map<String, Object?>),
      score: json['score'] as int? ?? 0,
      moveCount: json['moveCount'] as int? ?? 0,
      startTimeMs: json['startTimeMs'] as int? ?? 0,
      elapsedMs: json['elapsedMs'] as int? ?? 0,
      reached2048: json['reached2048'] as bool? ?? false,
      bestTile: json['bestTile'] as int? ?? 0,
    );
  }
}

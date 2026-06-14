import 'board_state.dart';
import 'move_engine.dart';

class GameOverChecker {
  static bool isGameOver(BoardState board) {
    if (board.emptyCells.isNotEmpty) return false;

    for (final dir in MoveDirection.values) {
      if (MoveEngine.isValidMove(board, dir)) return false;
    }

    return true;
  }
}

import 'dart:math';
import 'board_state.dart';

class RandomTileSpawner {
  RandomTileSpawner({Random? random}) : _random = random ?? Random();

  final Random _random;

  void spawn(BoardState board) {
    final empty = board.emptyCells;
    if (empty.isEmpty) return;

    final (row, col) = empty[_random.nextInt(empty.length)];
    board.setCell(row, col, _random.nextDouble() < 0.9 ? 2 : 4);
  }
}

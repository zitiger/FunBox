import 'board_state.dart';

enum MoveDirection { left, right, up, down }

class MoveResult {
  const MoveResult({
    required this.board,
    required this.merged,
    required this.scoreGained,
  });

  final BoardState board;
  final bool merged;
  final int scoreGained;
}

class MoveEngine {
  static MoveResult move(BoardState board, MoveDirection direction) {
    final clone = board.clone();
    bool anyMerged = false;
    int score = 0;

    if (direction == MoveDirection.left) {
      for (var r = 0; r < 4; r++) {
        final rowData = List<int>.from(clone.grid[r]);
        final (row, rowMerged, rowScore) = _slideLeft(rowData);
        anyMerged = anyMerged || rowMerged;
        score += rowScore;
        clone.setRow(r, row);
      }
    } else if (direction == MoveDirection.right) {
      for (var r = 0; r < 4; r++) {
        final rowData = List<int>.from(clone.grid[r]);
        final (row, rowMerged, rowScore) = _slideRight(rowData);
        anyMerged = anyMerged || rowMerged;
        score += rowScore;
        clone.setRow(r, row);
      }
    } else if (direction == MoveDirection.up) {
      for (var c = 0; c < 4; c++) {
        final col = clone.column(c);
        final (slid, merged, rowScore) = _slideLeft(col);
        anyMerged = anyMerged || merged;
        score += rowScore;
        clone.setColumn(c, slid);
      }
    } else {
      for (var c = 0; c < 4; c++) {
        final col = clone.column(c);
        final (slid, merged, rowScore) = _slideRight(col);
        anyMerged = anyMerged || merged;
        score += rowScore;
        clone.setColumn(c, slid);
      }
    }

    return MoveResult(board: clone, merged: anyMerged, scoreGained: score);
  }

  static (List<int>, bool, int) _slideLeft(List<int> line) {
    final filtered = line.where((v) => v != 0).toList();
    bool merged = false;
    int score = 0;

    for (var i = 0; i < filtered.length - 1; i++) {
      if (filtered[i] == filtered[i + 1]) {
        filtered[i] *= 2;
        score += filtered[i];
        filtered[i + 1] = 0;
        merged = true;
        i++;
      }
    }

    final result = filtered.where((v) => v != 0).toList();
    while (result.length < 4) {
      result.add(0);
    }

    return (result, merged, score);
  }

  static (List<int>, bool, int) _slideRight(List<int> line) {
    final reversed = line.reversed.toList();
    final (slid, merged, score) = _slideLeft(reversed);
    return (slid.reversed.toList(), merged, score);
  }

  static bool isValidMove(BoardState board, MoveDirection direction) {
    final result = move(board, direction);
    return !result.board.equals(board);
  }
}

class BoardState {
  BoardState({List<List<int>>? grid})
    : grid = grid ?? List.generate(4, (_) => List.filled(4, 0));

  factory BoardState.empty() => BoardState();

  final List<List<int>> grid;

  int cell(int row, int col) => grid[row][col];

  void setCell(int row, int col, int value) {
    grid[row][col] = value;
  }

  List<int> get row0 => grid[0];
  List<int> get row1 => grid[1];
  List<int> get row2 => grid[2];
  List<int> get row3 => grid[3];

  List<int> column(int col) => [
    grid[0][col],
    grid[1][col],
    grid[2][col],
    grid[3][col],
  ];

  void setRow(int row, List<int> values) {
    grid[row][0] = values[0];
    grid[row][1] = values[1];
    grid[row][2] = values[2];
    grid[row][3] = values[3];
  }

  void setColumn(int col, List<int> values) {
    grid[0][col] = values[0];
    grid[1][col] = values[1];
    grid[2][col] = values[2];
    grid[3][col] = values[3];
  }

  List<(int, int)> get emptyCells {
    final result = <(int, int)>[];
    for (var r = 0; r < 4; r++) {
      for (var c = 0; c < 4; c++) {
        if (grid[r][c] == 0) {
          result.add((r, c));
        }
      }
    }
    return result;
  }

  int get maxTile {
    var max = 0;
    for (var r = 0; r < 4; r++) {
      for (var c = 0; c < 4; c++) {
        if (grid[r][c] > max) {
          max = grid[r][c];
        }
      }
    }
    return max;
  }

  BoardState clone() {
    return BoardState(grid: List.generate(4, (r) => List.from(grid[r])));
  }

  bool equals(BoardState other) {
    for (var r = 0; r < 4; r++) {
      for (var c = 0; c < 4; c++) {
        if (grid[r][c] != other.grid[r][c]) return false;
      }
    }
    return true;
  }

  Map<String, Object?> toJson() {
    return {'grid': grid.map((row) => row.toList()).toList()};
  }

  factory BoardState.fromJson(Map<String, Object?> json) {
    final gridData = json['grid'] as List<dynamic>;
    final grid = gridData.map((row) {
      return (row as List<dynamic>).map((e) => e as int).toList();
    }).toList();
    return BoardState(grid: grid);
  }
}

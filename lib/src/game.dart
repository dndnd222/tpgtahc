import 'dart:math';

enum MoveDirection { up, down, left, right }

class GameBoard {
  GameBoard({int? bestScore, Random? random})
      : bestScore = bestScore ?? 0,
        _random = random ?? Random() {
    reset();
  }

  GameBoard.seeded(
    List<List<int>> initialGrid, {
    int? score,
    int? bestScore,
    Random? random,
  })  : bestScore = bestScore ?? 0,
        score = score ?? 0,
        _random = random ?? Random() {
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        _grid[r][c] = initialGrid[r][c];
      }
    }
  }

  static const int size = 4;
  static const List<int> _newTileValues = [2, 4];

  final Random _random;
  final List<List<int>> _grid =
      List.generate(size, (_) => List<int>.filled(size, 0, growable: false),
          growable: false);

  int score = 0;
  int bestScore;

  List<List<int>> get grid =>
      _grid.map((row) => List<int>.unmodifiable(row)).toList(growable: false);

  bool get isGameOver => !canMove();

  void reset() {
    score = 0;
    for (final row in _grid) {
      row.fillRange(0, row.length, 0);
    }
    _addRandomTile();
    _addRandomTile();
  }

  bool move(MoveDirection direction, {bool spawnTile = true}) {
    final previous = _clone();
    switch (direction) {
      case MoveDirection.left:
        _moveRowsLeft();
        break;
      case MoveDirection.right:
        _moveRowsRight();
        break;
      case MoveDirection.up:
        _moveColumnsUp();
        break;
      case MoveDirection.down:
        _moveColumnsDown();
        break;
    }

    final changed = !_areEqual(previous, _grid);
    if (changed) {
      if (spawnTile) {
        _addRandomTile();
      }
      bestScore = max(bestScore, score);
    }
    return changed;
  }

  bool canMove() {
    if (_grid.any((row) => row.any((cell) => cell == 0))) {
      return true;
    }

    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size - 1; c++) {
        if (_grid[r][c] == _grid[r][c + 1]) {
          return true;
        }
      }
    }

    for (var c = 0; c < size; c++) {
      for (var r = 0; r < size - 1; r++) {
        if (_grid[r][c] == _grid[r + 1][c]) {
          return true;
        }
      }
    }

    return false;
  }

  void _moveRowsLeft() {
    for (var r = 0; r < size; r++) {
      _grid[r] = _compressAndMerge(_grid[r]);
    }
  }

  void _moveRowsRight() {
    for (var r = 0; r < size; r++) {
      final reversed = _grid[r].reversed.toList(growable: false);
      final merged = _compressAndMerge(reversed).reversed.toList(growable: false);
      _grid[r] = merged;
    }
  }

  void _moveColumnsUp() {
    for (var c = 0; c < size; c++) {
      final column = List<int>.generate(size, (r) => _grid[r][c]);
      final merged = _compressAndMerge(column);
      for (var r = 0; r < size; r++) {
        _grid[r][c] = merged[r];
      }
    }
  }

  void _moveColumnsDown() {
    for (var c = 0; c < size; c++) {
      final column = List<int>.generate(size, (r) => _grid[r][c]).reversed.toList();
      final merged = _compressAndMerge(column).reversed.toList(growable: false);
      for (var r = 0; r < size; r++) {
        _grid[r][c] = merged[r];
      }
    }
  }

  List<int> _compressAndMerge(List<int> values) {
    final nonZero = values.where((value) => value != 0).toList(growable: false);
    final List<int> merged = [];

    for (var i = 0; i < nonZero.length; i++) {
      if (i + 1 < nonZero.length && nonZero[i] == nonZero[i + 1]) {
        final combined = nonZero[i] * 2;
        merged.add(combined);
        score += combined;
        i++; // Skip the next tile because it merged.
      } else {
        merged.add(nonZero[i]);
      }
    }

    while (merged.length < size) {
      merged.add(0);
    }

    return merged;
  }

  bool _addRandomTile() {
    final emptyCells = <(int, int)>[];
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        if (_grid[r][c] == 0) {
          emptyCells.add((r, c));
        }
      }
    }

    if (emptyCells.isEmpty) {
      return false;
    }

    final (row, col) = emptyCells[_random.nextInt(emptyCells.length)];
    _grid[row][col] = _newTileValues[_random.nextInt(_newTileValues.length)];
    return true;
  }

  List<List<int>> _clone() {
    return _grid
        .map((row) => List<int>.from(row, growable: false))
        .toList(growable: false);
  }

  bool _areEqual(List<List<int>> a, List<List<int>> b) {
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        if (a[r][c] != b[r][c]) {
          return false;
        }
      }
    }
    return true;
  }
}

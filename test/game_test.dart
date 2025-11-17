import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tpgtahc/src/game.dart';

void main() {
  test('merges identical tiles when moving left', () {
    final board = GameBoard.seeded(
      const [
        [2, 2, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ],
    );

    final changed = board.move(MoveDirection.left, spawnTile: false);

    expect(changed, isTrue);
    expect(board.grid[0], const [4, 0, 0, 0]);
    expect(board.score, 4);
  });

  test('detects when no moves are available', () {
    final board = GameBoard.seeded(
      const [
        [2, 4, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, 2],
      ],
    );

    expect(board.canMove(), isFalse);
    expect(board.isGameOver, isTrue);
  });

  test('adds a random tile after a successful move', () {
    final board = GameBoard.seeded(
      const [
        [0, 2, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ],
      random: Random(1),
    );

    final emptyBefore = board.grid.expand((row) => row).where((v) => v == 0).length;
    board.move(MoveDirection.left);
    final emptyAfter = board.grid.expand((row) => row).where((v) => v == 0).length;

    expect(emptyBefore, 15);
    expect(emptyAfter, 14);
  });
}

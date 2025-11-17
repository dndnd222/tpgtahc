import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/game.dart';

void main() {
  runApp(const Game2048App());
}

class Game2048App extends StatelessWidget {
  const Game2048App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2048',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.orange,
        scaffoldBackgroundColor: const Color(0xFFfaf8ef),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF776e65),
          ),
        ),
      ),
      home: const GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late GameBoard _board;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _board = GameBoard();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleMove(MoveDirection direction) {
    final changed = _board.move(direction);
    if (changed) {
      setState(() {});
    }
  }

  void _handleKeyboard(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return;

    switch (event.logicalKey.keyLabel) {
      case 'Arrow Left':
      case 'A':
      case 'a':
        _handleMove(MoveDirection.left);
        break;
      case 'Arrow Right':
      case 'D':
      case 'd':
        _handleMove(MoveDirection.right);
        break;
      case 'Arrow Up':
      case 'W':
      case 'w':
        _handleMove(MoveDirection.up);
        break;
      case 'Arrow Down':
      case 'S':
      case 's':
        _handleMove(MoveDirection.down);
        break;
      default:
        break;
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond;
    final dx = velocity.dx;
    final dy = velocity.dy;
    final threshold = 200;

    if (dx.abs() < threshold && dy.abs() < threshold) {
      return;
    }

    if (dx.abs() > dy.abs()) {
      _handleMove(dx > 0 ? MoveDirection.right : MoveDirection.left);
    } else {
      _handleMove(dy > 0 ? MoveDirection.down : MoveDirection.up);
    }
  }

  void _reset() {
    setState(() {
      _board.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('2048'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RawKeyboardListener(
        focusNode: _focusNode,
        onKey: _handleKeyboard,
        child: GestureDetector(
          onPanEnd: _handlePanEnd,
          behavior: HitTestBehavior.opaque,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('2048', style: Theme.of(context).textTheme.headlineLarge),
                        const SizedBox(height: 4),
                        const Text('스와이프 또는 화살표 키로 이동하세요'),
                      ],
                    ),
                    Row(
                      children: [
                        _ScoreBadge(label: 'SCORE', value: _board.score),
                        const SizedBox(width: 8),
                        _ScoreBadge(label: 'BEST', value: _board.bestScore),
                        const SizedBox(width: 8),
                        FilledButton.icon(
                          onPressed: _reset,
                          icon: const Icon(Icons.refresh),
                          label: const Text('재시작'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final tileSize = (constraints.maxWidth - 5 * 12) / GameBoard.size;
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFbbada0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: GameBoard.size * GameBoard.size,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: GameBoard.size,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                ),
                                itemBuilder: (context, index) {
                                  final row = index ~/ GameBoard.size;
                                  final col = index % GameBoard.size;
                                  final value = _board.grid[row][col];
                                  return _Tile(value: value);
                                },
                              ),
                              if (_board.isGameOver)
                                _GameOverOverlay(
                                  onRestart: _reset,
                                  tileSize: tileSize,
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFbbada0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFeee4da),
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    final background = _tileColor(value);
    final textColor = value <= 4 ? const Color(0xFF776e65) : Colors.white;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: value == 0
            ? const SizedBox.shrink()
            : Text(
                '$value',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
      ),
    );
  }

  Color _tileColor(int value) {
    switch (value) {
      case 0:
        return const Color(0xFFcdc1b4);
      case 2:
        return const Color(0xFFeee4da);
      case 4:
        return const Color(0xFFede0c8);
      case 8:
        return const Color(0xFFf2b179);
      case 16:
        return const Color(0xFFf59563);
      case 32:
        return const Color(0xFFf67c5f);
      case 64:
        return const Color(0xFFf65e3b);
      case 128:
        return const Color(0xFFedcf72);
      case 256:
        return const Color(0xFFedcc61);
      case 512:
        return const Color(0xFFedc850);
      case 1024:
        return const Color(0xFFedc53f);
      default:
        return const Color(0xFFedc22e);
    }
  }
}

class _GameOverOverlay extends StatelessWidget {
  const _GameOverOverlay({required this.onRestart, required this.tileSize});

  final VoidCallback onRestart;
  final double tileSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Colors.black.withOpacity(0.45),
      child: Container(
        width: tileSize * 2.5,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Game Over',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF776e65),
              ),
            ),
            const SizedBox(height: 12),
            const Text('다시 시작하여 2048에 도전하세요!'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRestart,
              child: const Text('재시작'),
            ),
          ],
        ),
      ),
    );
  }
}

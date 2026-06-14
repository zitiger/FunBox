import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_theme.dart';
import '../game_2048_module.dart';
import '../logic/board_state.dart';
import '../logic/game_over_checker.dart';
import '../logic/move_engine.dart';
import '../logic/random_tile_spawner.dart';
import '../models/game_result.dart';
import '../models/game_session.dart';
import 'game_2048_start_page.dart';

class Game2048PlayPage extends StatefulWidget {
  const Game2048PlayPage({
    super.key,
    required this.module,
    this.resumeSession,
    required this.onSessionSaved,
  });

  final Game2048Module module;
  final GameSession? resumeSession;
  final void Function(GameSession session) onSessionSaved;

  @override
  State<Game2048PlayPage> createState() => _Game2048PlayPageState();
}

class _Game2048PlayPageState extends State<Game2048PlayPage> {
  late GameSession session;
  late BoardState board;
  final spawner = RandomTileSpawner();
  late DateTime sessionStartTime;
  Timer? _timer;
  GameResult? lastResult;
  bool moving = false;

  @override
  void initState() {
    super.initState();
    if (widget.resumeSession != null) {
      session = widget.resumeSession!;
      board = session.board.clone();
    } else {
      board = BoardState.empty();
      spawner.spawn(board);
      spawner.spawn(board);
      session = GameSession(
        board: board.clone(),
        startTimeMs: DateTime.now().millisecondsSinceEpoch,
      );
    }
    sessionStartTime = DateTime.now();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          session.elapsedMs =
              DateTime.now().difference(sessionStartTime).inMilliseconds +
                  (widget.resumeSession?.elapsedMs ?? 0);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _saveSession() {
    session.board = board.clone();
    widget.onSessionSaved(session);
  }

  void _handleMove(MoveDirection direction) {
    if (moving || lastResult != null) return;

    final result = MoveEngine.move(board, direction);
    if (result.board.equals(board)) return;

    setState(() {
      board = result.board;
      session.score += result.scoreGained;
      session.moveCount++;

      if (board.maxTile > session.bestTile) {
        session.bestTile = board.maxTile;
      }

      if (board.maxTile >= 2048 && !session.reached2048) {
        session.reached2048 = true;
      }

      spawner.spawn(board);

      if (GameOverChecker.isGameOver(board)) {
        lastResult = GameResult(
          score: session.score,
          bestTile: session.bestTile,
          moveCount: session.moveCount,
          durationMs: session.elapsedMs,
          reached2048: session.reached2048,
          isGameOver: true,
        );
      }

      _saveSession();
    });
  }

  String _formatTime(int ms) {
    final totalSeconds = ms ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            _handleMove(MoveDirection.left);
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            _handleMove(MoveDirection.right);
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            _handleMove(MoveDirection.up);
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            _handleMove(MoveDirection.down);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onPanEnd: (details) {
          final dx = details.velocity.pixelsPerSecond.dx;
          final dy = details.velocity.pixelsPerSecond.dy;
          if (dx.abs() > dy.abs()) {
            _handleMove(dx > 0 ? MoveDirection.right : MoveDirection.left);
          } else if (dy.abs() > dx.abs()) {
            _handleMove(dy > 0 ? MoveDirection.down : MoveDirection.up);
          }
        },
        behavior: HitTestBehavior.translucent,
        child: Scaffold(
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppTheme.backgroundTop, AppTheme.backgroundBottom],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                child: Column(
                  children: [
                    _buildTopBar(),
                    const SizedBox(height: 12),
                    _buildScoreRow(),
                    const Spacer(),
                    _buildBoard(),
                    const Spacer(),
                    _buildBottomHint(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppTheme.textPrimary),
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
        const Spacer(),
        IconButton(
          icon:
              const Icon(Icons.refresh_rounded, color: AppTheme.textPrimary),
          tooltip: '重新开始',
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppTheme.surface,
                title: const Text('确认',
                    style: TextStyle(color: AppTheme.textPrimary)),
                content: const Text('确定要重新开始吗？当前进度将会丢失。',
                    style: TextStyle(color: AppTheme.textSecondary)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('取消',
                        style: TextStyle(color: AppTheme.textSecondary)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => Game2048PlayPage(
                            module: widget.module,
                            onSessionSaved: widget.onSessionSaved,
                          ),
                        ),
                      );
                    },
                    child: const Text('确定',
                        style: TextStyle(color: AppTheme.accent)),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildScoreRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ScoreChip(label: '分数', value: session.score.toString()),
        _ScoreChip(label: '最高', value: session.bestTile.toString()),
        _ScoreChip(label: '步数', value: session.moveCount.toString()),
        _ScoreChip(label: '时间', value: _formatTime(session.elapsedMs)),
      ],
    );
  }

  Widget _buildBoard() {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1A225D),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Stack(
          children: [
            _buildGrid(),
            if (lastResult != null) _buildGameOverOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(4, (r) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (c) {
            return _TileCell(value: board.cell(r, c));
          }),
        );
      }),
    );
  }

  Widget _buildGameOverOverlay() {
    final result = lastResult!;
    final title = result.reached2048 ? '🎉 达成 2048！' : '游戏结束';
    final subtitle =
        result.reached2048 ? '可以继续挑战更高分' : '棋盘已满，无法移动';

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(180),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 14)),
                const SizedBox(height: 8),
                Text('分数: ${result.score}',
                    style: const TextStyle(
                        color: AppTheme.accentSoft, fontSize: 18)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                        side: const BorderSide(color: AppTheme.textSecondary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('返回大厅'),
                    ),
                    const SizedBox(width: 14),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => Game2048PlayPage(
                              module: widget.module,
                              onSessionSaved: widget.onSessionSaved,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('再来一局'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomHint() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.swipe_rounded, color: AppTheme.textSecondary, size: 18),
        SizedBox(width: 6),
        Text('滑动屏幕或按方向键移动方块',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
      ],
    );
  }
}

class _ScoreChip extends StatelessWidget {
  const _ScoreChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label,
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _TileCell extends StatelessWidget {
  const _TileCell({required this.value});

  final int value;

  static const Map<int, Color> _bgColors = {
    2: Color(0xFFE8E0D8),
    4: Color(0xFFE8D8B8),
    8: Color(0xFFF0A860),
    16: Color(0xFFF09050),
    32: Color(0xFFF07050),
    64: Color(0xFFE85038),
    128: Color(0xFFE8C858),
    256: Color(0xFFE8C840),
    512: Color(0xFFE8C830),
    1024: Color(0xFFE8C020),
    2048: Color(0xFFE8B810),
    4096: Color(0xFF70C8E8),
    8192: Color(0xFF50B0E0),
  };

  Color _bgColor() {
    return _bgColors[value] ?? const Color(0xFF303878);
  }

  Color _textColor() {
    if (value == 0) return Colors.transparent;
    return value <= 4 ? const Color(0xFF6A5A4C) : Colors.white;
  }

  double _fontSize() {
    if (value < 100) return 24;
    if (value < 1000) return 20;
    if (value < 10000) return 16;
    return 13;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        color: _bgColor(),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 120),
        style: TextStyle(
          color: _textColor(),
          fontSize: _fontSize(),
          fontWeight: FontWeight.w900,
        ),
        child: Text(value == 0 ? '' : value.toString()),
      ),
    );
  }
}

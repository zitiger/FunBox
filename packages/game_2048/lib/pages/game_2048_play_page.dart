import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_theme.dart';
import '../game_2048_module.dart';
import '../logic/board_state.dart';
import '../logic/game_over_checker.dart';
import '../logic/move_engine.dart';
import '../logic/random_tile_spawner.dart';
import '../models/game_result.dart';
import '../models/game_session.dart';
import '../widgets/game_2048_components.dart';
import 'game_2048_rules_page.dart';

enum _OverlayMode { reached2048, gameOver }

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
  _OverlayMode? _overlayMode;
  bool _celebrationShown = false;

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
    _celebrationShown = session.reached2048;
    sessionStartTime = DateTime.now();
    session.elapsedMs = widget.resumeSession?.elapsedMs ?? 0;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || lastResult != null) return;
      setState(() {
        session.elapsedMs =
            DateTime.now().difference(sessionStartTime).inMilliseconds +
            (widget.resumeSession?.elapsedMs ?? 0);
      });
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

  void _restartGame() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => Game2048PlayPage(
          module: widget.module,
          onSessionSaved: widget.onSessionSaved,
        ),
      ),
    );
  }

  void _showRules() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Game2048RulesPage(module: widget.module),
      ),
    );
  }

  void _backToLobby() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _handleMove(MoveDirection direction) {
    if (moving || _overlayMode != null || lastResult != null) return;

    final result = MoveEngine.move(board, direction);
    if (result.board.equals(board)) return;

    moving = true;
    setState(() {
      board = result.board;
      session.score += result.scoreGained;
      session.moveCount++;

      if (board.maxTile > session.bestTile) {
        session.bestTile = board.maxTile;
      }

      final crossed2048 = board.maxTile >= 2048 && !session.reached2048;
      if (crossed2048) {
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
        _overlayMode = _OverlayMode.gameOver;
      } else if (crossed2048 && !_celebrationShown) {
        _overlayMode = _OverlayMode.reached2048;
      }

      _saveSession();
    });
    moving = false;
  }

  void _closeOverlay() {
    if (_overlayMode == _OverlayMode.reached2048) {
      _celebrationShown = true;
    }
    setState(() {
      _overlayMode = null;
    });
  }

  void _continueAfterCelebration() {
    _celebrationShown = true;
    setState(() {
      _overlayMode = null;
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
        behavior: HitTestBehavior.translucent,
        onPanEnd: (details) {
          final dx = details.velocity.pixelsPerSecond.dx;
          final dy = details.velocity.pixelsPerSecond.dy;
          if (dx.abs() > dy.abs()) {
            _handleMove(dx > 0 ? MoveDirection.right : MoveDirection.left);
          } else if (dy.abs() > dx.abs()) {
            _handleMove(dy > 0 ? MoveDirection.down : MoveDirection.up);
          }
        },
        child: Scaffold(
          body: Game2048Backdrop(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                child: Column(
                  children: [
                    _buildTopBar(),
                    const SizedBox(height: 14),
                    _buildStatsRow(),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Center(
                        child: _buildBoardArea(),
                      ),
                    ),
                    const SizedBox(height: 16),
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
        Game2048IconButton(
          icon: Icons.arrow_back_rounded,
          tooltip: '返回',
          onPressed: _backToLobby,
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Center(
            child: Text(
              '2048',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 38,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
        ),
        Game2048IconButton(
          icon: Icons.refresh_rounded,
          tooltip: '重新开始',
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppTheme.surface,
                title: const Text(
                  '重新开始本局？',
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
                content: const Text(
                  '当前进度会丢失，但已保存的对局记录不会受影响。',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text(
                      '取消',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _restartGame();
                    },
                    child: const Text(
                      '确定',
                      style: TextStyle(color: AppTheme.accent),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(width: 10),
        Game2048IconButton(
          icon: Icons.menu_book_rounded,
          tooltip: '规则',
          onPressed: _showRules,
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: Game2048StatChip(
            icon: Icons.emoji_events_rounded,
            label: '当前分数',
            value: session.score.toString(),
            tint: AppTheme.accent,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Game2048StatChip(
            icon: Icons.workspace_premium_rounded,
            label: '历史最高',
            value: session.bestTile.toString(),
            tint: const Color(0xFF6FA2FF),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Game2048StatChip(
            icon: Icons.near_me_rounded,
            label: '步数',
            value: session.moveCount.toString(),
            tint: AppTheme.success,
          ),
        ),
      ],
    );
  }

  Widget _buildBoardArea() {
    final boardWidth = MediaQuery.sizeOf(context).width - 36;
    final constrainedWidth = boardWidth > 440 ? 440.0 : boardWidth;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: constrainedWidth),
      child: AspectRatio(
        aspectRatio: 1,
        child: Game2048BoardFrame(
          child: Stack(
            children: [
              Positioned.fill(child: _buildGrid()),
              if (_overlayMode != null) Positioned.fill(child: _buildOverlay()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: 16,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final row = index ~/ 4;
        final col = index % 4;
        return Game2048TileCell(value: board.cell(row, col));
      },
    );
  }

  Widget _buildOverlay() {
    if (_overlayMode == _OverlayMode.gameOver && lastResult != null) {
      return _GameOverOverlay(
        result: lastResult!,
        onRestart: _restartGame,
        onBackToLobby: _backToLobby,
        onClose: _closeOverlay,
      );
    }

    return _ReachedOverlay(
      score: session.score,
      bestTile: session.bestTile,
      moveCount: session.moveCount,
      durationLabel: _formatTime(session.elapsedMs),
      onRestart: _restartGame,
      onContinue: _continueAfterCelebration,
      onClose: _closeOverlay,
    );
  }

  Widget _buildBottomHint() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.swipe_rounded, color: AppTheme.textSecondary, size: 18),
          const SizedBox(width: 8),
          const Text(
            '滑动屏幕或按方向键移动方块',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(width: 10),
          const Game2048HintIconRow(),
        ],
      ),
    );
  }
}

class _ReachedOverlay extends StatelessWidget {
  const _ReachedOverlay({
    required this.score,
    required this.bestTile,
    required this.moveCount,
    required this.durationLabel,
    required this.onRestart,
    required this.onContinue,
    required this.onClose,
  });

  final int score;
  final int bestTile;
  final int moveCount;
  final String durationLabel;
  final VoidCallback onRestart;
  final VoidCallback onContinue;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 360),
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A285E), Color(0xFF101A46)],
                  ),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.42),
                      blurRadius: 24,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.emoji_events_rounded,
                      size: 42,
                      color: AppTheme.success,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '已达成 2048，继续挑战更高分',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '本局成绩',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _MiniResultStat(
                                  label: '分数',
                                  value: score.toString(),
                                  accent: AppTheme.accent,
                                ),
                              ),
                              Expanded(
                                child: _MiniResultStat(
                                  label: '最高块',
                                  value: bestTile.toString(),
                                  accent: const Color(0xFF79A8FF),
                                ),
                              ),
                              Expanded(
                                child: _MiniResultStat(
                                  label: '步数',
                                  value: moveCount.toString(),
                                  accent: AppTheme.success,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '用时 $durationLabel',
                            style: const TextStyle(
                              color: AppTheme.textTertiary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Game2048Button(
                            label: '再来一局',
                            onPressed: onRestart,
                            filled: false,
                            foregroundColor: AppTheme.textSecondary,
                            height: 52,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Game2048Button(
                            label: '继续游戏',
                            onPressed: onContinue,
                            height: 52,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                right: -2,
                top: -2,
                child: Game2048IconButton(
                  icon: Icons.close_rounded,
                  tooltip: '关闭',
                  size: 38,
                  iconSize: 18,
                  onPressed: onClose,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameOverOverlay extends StatelessWidget {
  const _GameOverOverlay({
    required this.result,
    required this.onRestart,
    required this.onBackToLobby,
    required this.onClose,
  });

  final GameResult result;
  final VoidCallback onRestart;
  final VoidCallback onBackToLobby;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 360),
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A285E), Color(0xFF101A46)],
                  ),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.42),
                      blurRadius: 24,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '游戏结束',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '本局成绩',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            result.score.toString(),
                            style: const TextStyle(
                              color: AppTheme.accent,
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '棋盘已经没有可走的方向了。下一局你会走得更远。',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Game2048Button(
                            label: '再来一局',
                            onPressed: onRestart,
                            height: 52,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Game2048Button(
                            label: '返回大厅',
                            onPressed: onBackToLobby,
                            filled: false,
                            foregroundColor: AppTheme.textSecondary,
                            height: 52,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                right: -2,
                top: -2,
                child: Game2048IconButton(
                  icon: Icons.close_rounded,
                  tooltip: '关闭',
                  size: 38,
                  iconSize: 18,
                  onPressed: onClose,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniResultStat extends StatelessWidget {
  const _MiniResultStat({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              color: accent,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

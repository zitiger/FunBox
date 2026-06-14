import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../game_2048_module.dart';
import '../models/game_session.dart';
import 'game_2048_play_page.dart';

class Game2048StartPage extends StatefulWidget {
  const Game2048StartPage({
    super.key,
    required this.module,
    this.showRulesOnEntry = false,
  });

  final Game2048Module module;
  final bool showRulesOnEntry;

  @override
  State<Game2048StartPage> createState() => _Game2048StartPageState();
}

class _Game2048StartPageState extends State<Game2048StartPage> {
  static GameSession? _savedSession;

  @override
  void initState() {
    super.initState();
    if (widget.showRulesOnEntry) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showRules(context);
      });
    }
  }

  bool get hasSession {
    final session = _savedSession;
    if (session == null) return false;
    return session.moveCount > 0;
  }

  void _startNewGame() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => Game2048PlayPage(
          module: widget.module,
          onSessionSaved: (session) {
            _savedSession = session;
          },
        ),
      ),
    );
  }

  void _continueGame() {
    if (!hasSession) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => Game2048PlayPage(
          module: widget.module,
          resumeSession: _savedSession,
          onSessionSaved: (session) {
            _savedSession = session;
          },
        ),
      ),
    );
  }

  void _showRules(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text(
          '2048 游戏规则',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _RuleLine('滑动屏幕或按方向键移动所有方块。'),
              SizedBox(height: 6),
              _RuleLine('相同数字的方块碰撞后会合并为它们的和。'),
              SizedBox(height: 6),
              _RuleLine('每次移动后，随机位置会生成 2 或 4。'),
              SizedBox(height: 6),
              _RuleLine('当凑出 2048 时即达成目标，但可以继续冲更高分。'),
              SizedBox(height: 6),
              _RuleLine('当棋盘满且无法移动时，游戏结束。'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('知道了', style: TextStyle(color: AppTheme.accent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: AppTheme.textPrimary),
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                    ),
                  ],
                ),
                const Spacer(flex: 2),
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.asset(
                    widget.module.manifest.coverAsset,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  widget.module.manifest.title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '经典数独合并',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const Spacer(flex: 2),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _startNewGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      '开始新局',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                if (hasSession) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _continueGame,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.accentSoft,
                        side: const BorderSide(color: AppTheme.accentSoft),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        '继续游戏',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => _showRules(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      side: const BorderSide(color: AppTheme.textSecondary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      '游戏规则',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RuleLine extends StatelessWidget {
  const _RuleLine(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '• ',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
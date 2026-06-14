import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../game_2048_module.dart';
import '../models/game_session.dart';
import '../widgets/game_2048_components.dart';
import 'game_2048_play_page.dart';
import 'game_2048_rules_page.dart';

class Game2048StartPage extends StatefulWidget {
  const Game2048StartPage({super.key, required this.module});

  final Game2048Module module;

  @override
  State<Game2048StartPage> createState() => _Game2048StartPageState();
}

class _Game2048StartPageState extends State<Game2048StartPage> {
  static GameSession? _savedSession;

  bool get hasSession {
    final session = _savedSession;
    return session != null && session.moveCount > 0;
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

  void _openRules() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Game2048RulesPage(module: widget.module),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Game2048Backdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: Column(
              children: [
                Row(
                  children: [
                    Game2048IconButton(
                      icon: Icons.arrow_back_rounded,
                      tooltip: '返回',
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                    ),
                  ],
                ),
                const Spacer(flex: 2),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    children: [
                      Game2048EmblemFrame(
                        assetPath: widget.module.manifest.iconAsset,
                        packageName: widget.module.manifest.packageName,
                        size: 182,
                        padding: 14,
                        innerRadius: 32,
                      ),
                      const SizedBox(height: 24),
                      const Game2048PageTitle(
                        title: '2048',
                        subtitle: '滑动合并数字，冲击更高分。',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                const Game2048SectionDivider(),
                const SizedBox(height: 22),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    children: [
                      Game2048Button(
                        label: '开始新局',
                        onPressed: _startNewGame,
                        leadingIcon: Icons.play_arrow_rounded,
                      ),
                      if (hasSession) ...[
                        const SizedBox(height: 14),
                        Game2048Button(
                          label: '继续游戏',
                          onPressed: _continueGame,
                          filled: false,
                          leadingIcon: Icons.history_rounded,
                          foregroundColor: AppTheme.accentSoft,
                        ),
                      ],
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: _openRules,
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.textSecondary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.menu_book_rounded, size: 20),
                          label: const Text(
                            '游戏规则',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
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

import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../game_2048_module.dart';
import '../widgets/game_2048_components.dart';

class Game2048RulesPage extends StatelessWidget {
  const Game2048RulesPage({super.key, required this.module});

  final Game2048Module module;

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
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Game2048PageTitle(
                  title: '游戏规则',
                  subtitle:
                      '${module.manifest.title} 是一局轻量、克制、随手可玩的数字合并游戏。',
                ),
                const SizedBox(height: 18),
                const Game2048SectionDivider(),
                const SizedBox(height: 18),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: const [
                      Game2048RuleCard(
                        icon: Icons.swipe_rounded,
                        title: '滑动移动所有方块',
                        detail: '向任意方向滑动，所有可移动的方块都会一起滑向边缘。每一次有效滑动，才算一步。',
                        tint: AppTheme.accent,
                      ),
                      SizedBox(height: 14),
                      Game2048RuleCard(
                        icon: Icons.add_box_rounded,
                        title: '相同数字会合并',
                        detail: '两个相同数字相撞后会合并成一个更大的数字。合并得到的数值，会直接计入当前分数。',
                        tint: Color(0xFF79A8FF),
                      ),
                      SizedBox(height: 14),
                      Game2048RuleCard(
                        icon: Icons.auto_awesome_rounded,
                        title: '每次有效移动后会生成新块',
                        detail: '只要这一步真的改变了棋盘，就会在空位里随机生成一个新块。通常是 2，偶尔是 4。',
                        tint: AppTheme.success,
                      ),
                      SizedBox(height: 14),
                      Game2048RuleCard(
                        icon: Icons.emoji_events_rounded,
                        title: '达到 2048 仍可继续',
                        detail: '合成 2048 只是阶段性达成，游戏不会立刻结束。你可以继续冲击更高数字和更高分。',
                        tint: Color(0xFFFFC65C),
                      ),
                      SizedBox(height: 14),
                      Game2048RuleCard(
                        icon: Icons.warning_rounded,
                        title: '棋盘无路可走时结束',
                        detail: '当棋盘被填满，并且没有任何相邻数字能够合并时，本局结束。',
                        tint: Color(0xFFFF8B66),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '提示',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '页面上的所有数值都会由代码实时渲染，图标和按钮只保留最必要的信息，避免把注意力从棋盘上抢走。',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

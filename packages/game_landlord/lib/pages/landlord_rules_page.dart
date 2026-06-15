import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../game_landlord_module.dart';
import 'landlord_start_page.dart';

class LandlordRulesPage extends StatelessWidget {
  const LandlordRulesPage({super.key, required this.module});

  final GameLandlordModule module;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LandlordBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: Column(
              children: [
                Row(
                  children: [
                    LandlordIconButton(
                      icon: Icons.arrow_back_rounded,
                      tooltip: '返回',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                LandlordPageTitle(
                  title: '游戏规则',
                  subtitle: '${module.manifest.title} 的基础规则说明。',
                ),
                const SizedBox(height: 18),
                const LandlordSectionDivider(),
                const SizedBox(height: 18),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: const [
                      _RuleCard(
                        icon: Icons.groups_rounded,
                        title: '三人参与',
                        detail: '使用一副 54 张牌进行对局，3 名玩家参与，其中 1 人为地主，2 人为农民。',
                        tint: AppTheme.accent,
                      ),
                      SizedBox(height: 14),
                      _RuleCard(
                        icon: Icons.confirmation_number_rounded,
                        title: '叫地主与底牌',
                        detail: '系统随机指定或分配地主身份，地主获得 3 张底牌并先出牌。',
                        tint: Color(0xFF79A8FF),
                      ),
                      SizedBox(height: 14),
                      _RuleCard(
                        icon: Icons.swap_horiz_rounded,
                        title: '轮流出牌',
                        detail: '按逆时针轮流出牌，玩家可以选择出牌或不出牌，必须压过上一手牌型。',
                        tint: AppTheme.success,
                      ),
                      SizedBox(height: 14),
                      _RuleCard(
                        icon: Icons.view_list_rounded,
                        title: '常见牌型',
                        detail: '支持单张、对子、三条、三带一、三带二、顺子、连对、飞机、炸弹和火箭。',
                        tint: Color(0xFFFFC65C),
                      ),
                      SizedBox(height: 14),
                      _RuleCard(
                        icon: Icons.emoji_events_rounded,
                        title: '胜负判定',
                        detail: '先出完手牌的一方获胜。火箭最大，炸弹次之，炸弹可压过普通牌型。',
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
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
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
                        '出牌区、提示和不出按钮都以当前回合状态为准，界面会尽量保持简洁，方便快速开局。',
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

class _RuleCard extends StatelessWidget {
  const _RuleCard({
    required this.icon,
    required this.title,
    required this.detail,
    required this.tint,
  });

  final IconData icon;
  final String title;
  final String detail;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: AppTheme.surface.withValues(alpha: 0.92),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  tint.withValues(alpha: 0.24),
                  tint.withValues(alpha: 0.08),
                ],
              ),
              border: Border.all(color: tint.withValues(alpha: 0.18)),
            ),
            child: Icon(icon, size: 36, color: tint),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  detail,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

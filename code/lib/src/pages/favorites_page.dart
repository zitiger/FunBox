import 'package:flutter/material.dart';

import '../platform/games/game_catalog.dart';
import '../theme/app_theme.dart';
import '../widgets/game_grid_card.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key, required this.catalog});

  final GameCatalog catalog;

  @override
  Widget build(BuildContext context) {
    final cards = catalog.favoriteCards;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.backgroundTop, AppTheme.backgroundBottom],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('我的收藏', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text(
                '回到你最常玩的那几款游戏',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              if (cards.isEmpty)
                _EmptyFavorites(onPressed: () {})
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cards.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.74,
                  ),
                  itemBuilder: (context, index) =>
                      GameGridCard(data: cards[index]),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.favorite_border_rounded,
            size: 42,
            color: Colors.white,
          ),
          const SizedBox(height: 14),
          Text('你还没有收藏的游戏', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            '后续这里会根据游戏模块的收藏状态自动聚合展示。',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

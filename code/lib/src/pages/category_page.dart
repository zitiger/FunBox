import 'package:flutter/material.dart';

import '../platform/games/game_catalog.dart';
import '../theme/app_theme.dart';
import '../widgets/category_chips.dart';
import '../widgets/game_grid_card.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key, required this.catalog});

  final GameCatalog catalog;

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late String selectedCategoryId = widget.catalog.categoryChips.first.id;

  @override
  Widget build(BuildContext context) {
    final categoryChips = widget.catalog.categoryChips;
    final cards = widget.catalog.cardsForCategory(selectedCategoryId);

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
              Text('分类', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text(
                '按类型挑选你想玩的小游戏',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              CategoryChips(
                items: categoryChips,
                selectedId: selectedCategoryId,
                onSelected: (id) {
                  setState(() {
                    selectedCategoryId = id;
                  });
                },
              ),
              const SizedBox(height: 18),
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
                itemBuilder: (context, index) {
                  final card = cards[index];
                  return GameGridCard(
                    data: card,
                    onTap: () => _navigateToGame(context, card.gameId),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToGame(BuildContext context, String gameId) {
    final module = widget.catalog.byId(gameId);
    if (module == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => module.buildStartPage(context)),
    );
  }
}

import 'package:flutter/material.dart';

import '../models/home_models.dart';
import '../platform/games/game_catalog.dart';
import '../theme/app_theme.dart';
import '../widgets/category_chips.dart';
import '../widgets/feature_banner.dart';
import '../widgets/game_grid_card.dart';
import '../widgets/home_header.dart';
import '../widgets/recent_games_row.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.catalog});

  final GameCatalog catalog;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String selectedCategoryId = widget.catalog.categoryChips.first.id;

  @override
  Widget build(BuildContext context) {
    final filteredCards = _filteredCards();
    final categoryChips = widget.catalog.categoryChips;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.backgroundTop, AppTheme.backgroundBottom],
        ),
      ),
      child: Stack(
        children: [
          const _BackgroundGlow(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HomeHeader(),
                  const SizedBox(height: 20),
                  FeatureBanner(data: widget.catalog.featureCard),
                  const SizedBox(height: 24),
                  const _SectionHeader(title: '最近游玩', actionLabel: '查看全部'),
                  const SizedBox(height: 14),
                  RecentGamesRow(items: widget.catalog.recentGames),
                  const SizedBox(height: 22),
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
                    itemCount: filteredCards.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.68,
                        ),
                    itemBuilder: (context, index) {
                      return GameGridCard(data: filteredCards[index]);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<GameCardData> _filteredCards() {
    return widget.catalog.cardsForCategory(selectedCategoryId);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.actionLabel});

  final String title;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const Spacer(),
        Text(
          actionLabel,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF9095C9)),
        ),
        const SizedBox(width: 4),
        const Icon(
          Icons.chevron_right_rounded,
          size: 18,
          color: Color(0xFF9095C9),
        ),
      ],
    );
  }
}

class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -30,
            child: _GlowOrb(
              size: 210,
              colors: const [Color(0xAA812DFF), Colors.transparent],
            ),
          ),
          Positioned(
            top: 160,
            left: -60,
            child: _GlowOrb(
              size: 160,
              colors: const [Color(0x6634C8FF), Colors.transparent],
            ),
          ),
          const Positioned(top: 82, left: 62, child: _StarDot(size: 4)),
          const Positioned(top: 126, left: 114, child: _StarDot(size: 3)),
          const Positioned(top: 220, right: 92, child: _StarDot(size: 3)),
          const Positioned(top: 438, left: 24, child: _StarDot(size: 2)),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}

class _StarDot extends StatelessWidget {
  const _StarDot({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFECD49A),
        shape: BoxShape.circle,
      ),
    );
  }
}

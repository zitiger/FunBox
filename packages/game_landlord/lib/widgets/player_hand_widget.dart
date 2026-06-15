import 'package:flutter/material.dart';
import '../models/card.dart';
import 'card_widget.dart';

class PlayerHandWidget extends StatelessWidget {
  const PlayerHandWidget({
    super.key,
    required this.cards,
    required this.selectedIndices,
    required this.onToggleCard,
    this.enabled = true,
    this.minCardWidth = 34,
    this.maxCardWidth = 56,
    this.cardHeight = 78,
  });

  final List<PlayingCard> cards;
  final Set<int> selectedIndices;
  final void Function(int index) onToggleCard;
  final bool enabled;
  final double minCardWidth;
  final double maxCardWidth;
  final double cardHeight;

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth =
            constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : 800.0;

        final cardWidth = (availableWidth / (cards.length + 1.8))
            .clamp(minCardWidth, maxCardWidth)
            .toDouble();
        final overlap = cards.length <= 1
            ? 0.0
            : (cardWidth * 0.58).clamp(12.0, cardWidth * 0.82).toDouble();
        final totalWidth = cardWidth + (cards.length - 1) * overlap;
        final startX = totalWidth < availableWidth
            ? (availableWidth - totalWidth) / 2
            : 0.0;
        final displayHeight = cardHeight + 18;

        return SizedBox(
          width: availableWidth,
          height: displayHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: List.generate(cards.length, (i) {
              final left = startX + i * overlap;
              return Positioned(
                left: left,
                top: 0,
                child: GestureDetector(
                  onTap: () {
                    if (enabled) onToggleCard(i);
                  },
                  child: CardWidget(
                    card: cards[i],
                    selected: selectedIndices.contains(i),
                    width: cardWidth,
                    height: cardHeight,
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

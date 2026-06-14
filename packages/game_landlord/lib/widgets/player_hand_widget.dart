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
  });

  final List<PlayingCard> cards;
  final Set<int> selectedIndices;
  final void Function(int index) onToggleCard;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) return const SizedBox.shrink();

    final cardWidth = 48.0;
    final overlap = 16.0;
    final totalWidth = cardWidth + (cards.length - 1) * overlap;
    final startX = -(totalWidth / 2) + cardWidth / 2;

    return SizedBox(
      height: 100,
      child: Align(
        alignment: Alignment.topCenter,
        child: Stack(
          clipBehavior: Clip.none,
          children: List.generate(cards.length, (i) {
            final left = startX + i * overlap;
            return Positioned(
              left: left,
              child: GestureDetector(
                onTap: () {
                  if (enabled) onToggleCard(i);
                },
                child: CardWidget(
                  card: cards[i],
                  selected: selectedIndices.contains(i),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

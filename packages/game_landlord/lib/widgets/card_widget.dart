import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/card.dart';

class CardWidget extends StatelessWidget {
  const CardWidget({
    super.key,
    required this.card,
    this.selected = false,
    this.faceDown = false,
    this.width = 48,
    this.height = 66,
  });

  final PlayingCard card;
  final bool selected;
  final bool faceDown;
  final double width;
  final double height;

  bool get isRed =>
      card.isRed || (card.isJoker && card.rank == PlayingCard.rankSmallJoker);
  bool get isBlackCard => !isRed;

  Color get suitColor {
    if (card.isJoker) {
      return card.rank == PlayingCard.rankSmallJoker
          ? const Color(0xFFE53E3E)
          : const Color(0xFF1A1A2E);
    }
    return isRed ? const Color(0xFFE53E3E) : const Color(0xFF1A1A2E);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: width,
      height: height,
      margin: EdgeInsets.only(top: selected ? 0 : 6),
      decoration: BoxDecoration(
        color: faceDown ? const Color(0xFF1A225D) : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: selected
            ? Border.all(color: AppTheme.accent, width: 2.5)
            : Border.all(color: const Color(0xFFD0CFD8), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: selected ? 0.35 : 0.18),
            blurRadius: selected ? 6 : 3,
            offset: Offset(0, selected ? 3 : 1.5),
          ),
        ],
      ),
      child: faceDown ? _buildCardBack() : _buildCardFace(),
    );
  }

  Widget _buildCardBack() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A225D),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0xFF2A3270), width: 1.5),
      ),
      child: Center(
        child: Icon(
          Icons.casino,
          color: Colors.white.withValues(alpha: 0.25),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildCardFace() {
    final rankSize = card.isJoker ? width * 0.18 : width * 0.28;
    final suitSize = card.isJoker ? width * 0.15 : width * 0.18;
    final centerSize = card.isJoker ? width * 0.2 : width * 0.42;

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 3, 4, 3),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.rankLabel,
                    style: TextStyle(
                      color: suitColor,
                      fontSize: rankSize,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  if (!card.isJoker)
                    Text(
                      card.suitLabel,
                      style: TextStyle(
                        color: suitColor,
                        fontSize: suitSize,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                ],
              ),
              const Spacer(),
              if (card.isJoker)
                Text(
                  card.rank == PlayingCard.rankBigJoker ? 'BJ' : 'SJ',
                  style: TextStyle(
                    color: suitColor,
                    fontSize: width * 0.13,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
            ],
          ),
          Expanded(
            child: Center(
              child: card.isJoker
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'JOKER',
                          style: TextStyle(
                            color: suitColor,
                            fontSize: width * 0.18,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                        Text(
                          card.rank == PlayingCard.rankBigJoker
                              ? 'BIG'
                              : 'SMALL',
                          style: TextStyle(
                            color: suitColor,
                            fontSize: width * 0.11,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      card.suitLabel,
                      style: TextStyle(
                        color: suitColor,
                        fontSize: centerSize,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

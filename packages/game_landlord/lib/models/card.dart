import 'dart:math';

enum CardSuit { spade, heart, club, diamond, joker }

class PlayingCard {
  final CardSuit suit;
  final int rank;

  const PlayingCard(this.suit, this.rank);

  bool get isJoker => suit == CardSuit.joker;

  static const int rankSmallJoker = 16;
  static const int rankBigJoker = 17;
  static const int rank2 = 15;
  static const int rankA = 14;

  String get rankLabel {
    if (rank == rankSmallJoker) return '小王';
    if (rank == rankBigJoker) return '大王';
    if (rank >= 3 && rank <= 10) return rank.toString();
    switch (rank) {
      case 11:
        return 'J';
      case 12:
        return 'Q';
      case 13:
        return 'K';
      case rankA:
        return 'A';
      case rank2:
        return '2';
      default:
        return '';
    }
  }

  String get suitLabel {
    switch (suit) {
      case CardSuit.spade:
        return '\u2660';
      case CardSuit.heart:
        return '\u2665';
      case CardSuit.club:
        return '\u2663';
      case CardSuit.diamond:
        return '\u2666';
      case CardSuit.joker:
        return rank == rankBigJoker ? '\u5927' : '\u5C0F';
    }
  }

  bool get isBlack => suit == CardSuit.spade || suit == CardSuit.club;
  bool get isRed => suit == CardSuit.heart || suit == CardSuit.diamond;

  @override
  String toString() => '$suitLabel$rankLabel';

  @override
  bool operator ==(Object other) =>
      other is PlayingCard && other.suit == suit && other.rank == rank;

  @override
  int get hashCode => suit.index * 100 + rank;
}

class CardDeck {
  static List<PlayingCard> createFullDeck() {
    final deck = <PlayingCard>[];
    for (final suit in [
      CardSuit.spade,
      CardSuit.heart,
      CardSuit.club,
      CardSuit.diamond,
    ]) {
      for (int rank = 3; rank <= 15; rank++) {
        deck.add(PlayingCard(suit, rank));
      }
    }
    deck.add(const PlayingCard(CardSuit.joker, PlayingCard.rankSmallJoker));
    deck.add(const PlayingCard(CardSuit.joker, PlayingCard.rankBigJoker));
    return deck;
  }

  static void shuffle(List<PlayingCard> cards) {
    final rng = Random();
    for (int i = cards.length - 1; i > 0; i--) {
      final j = rng.nextInt(i + 1);
      final tmp = cards[i];
      cards[i] = cards[j];
      cards[j] = tmp;
    }
  }

  static List<PlayingCard> sortByRank(List<PlayingCard> cards) {
    final sorted = List<PlayingCard>.from(cards);
    sorted.sort((a, b) {
      final rankCmp = a.rank.compareTo(b.rank);
      if (rankCmp != 0) return rankCmp;
      return a.suit.index.compareTo(b.suit.index);
    });
    return sorted;
  }
}

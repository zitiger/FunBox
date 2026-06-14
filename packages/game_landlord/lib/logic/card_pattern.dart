import '../models/card.dart';

enum PatternType {
  single,
  pair,
  triple,
  tripleWithOne,
  tripleWithPair,
  straight,
  consecutivePairs,
  plane,
  bomb,
  rocket,
}

class CardPattern {
  final PatternType type;
  final int mainRank;
  final List<PlayingCard> cards;

  const CardPattern(this.type, this.mainRank, this.cards);

  bool canBeat(CardPattern other) {
    if (type == PatternType.rocket) return true;
    if (other.type == PatternType.rocket) return false;
    if (type == PatternType.bomb && other.type != PatternType.bomb) return true;
    if (type == other.type) return mainRank > other.mainRank;
    return false;
  }

  @override
  String toString() => '$type($mainRank)';
}

class PatternRecognizer {
  static CardPattern? recognize(List<PlayingCard> cards) {
    if (cards.isEmpty) return null;

    final sorted = CardDeck.sortByRank(cards);
    final ranks = _rankCounts(sorted);

    if (sorted.length == 1) {
      return CardPattern(PatternType.single, sorted.first.rank, sorted);
    }
    if (sorted.length == 2) {
      if (_isRocket(sorted)) {
        return CardPattern(
          PatternType.rocket,
          PlayingCard.rankBigJoker,
          sorted,
        );
      }
      if (_isPair(sorted)) {
        return CardPattern(PatternType.pair, sorted.first.rank, sorted);
      }
      return null;
    }
    if (sorted.length == 3) {
      if (_isTriple(sorted)) {
        return CardPattern(PatternType.triple, sorted.first.rank, sorted);
      }
      return null;
    }
    if (sorted.length == 4) {
      if (_isRocket(sorted)) {
        return CardPattern(
          PatternType.rocket,
          PlayingCard.rankBigJoker,
          sorted,
        );
      }
      if (_isBomb(sorted)) {
        return CardPattern(PatternType.bomb, sorted.first.rank, sorted);
      }
      final tripleOne = _tryTripleWithOne(sorted, ranks);
      if (tripleOne != null) return tripleOne;
      return null;
    }
    if (sorted.length == 5) {
      final straight = _tryStraight(sorted, ranks);
      if (straight != null) return straight;

      final triplePair = _tryTripleWithPair(sorted, ranks);
      if (triplePair != null) return triplePair;

      final tripleOne = _tryTripleWithOne(sorted, ranks);
      if (tripleOne != null) return tripleOne;

      return null;
    }

    if (sorted.length >= 6) {
      final consecutivePairs = _tryConsecutivePairs(sorted, ranks);
      if (consecutivePairs != null) return consecutivePairs;

      final straight = _tryStraight(sorted, ranks);
      if (straight != null) return straight;

      final plane = _tryPlane(sorted, ranks);
      if (plane != null) return plane;

      final triplePair = _tryTripleWithPair(sorted, ranks);
      if (triplePair != null) return triplePair;

      final tripleOne = _tryTripleWithOne(sorted, ranks);
      if (tripleOne != null) return tripleOne;

      return null;
    }

    return null;
  }

  static Map<int, int> _rankCounts(List<PlayingCard> sorted) {
    final counts = <int, int>{};
    for (final c in sorted) {
      counts[c.rank] = (counts[c.rank] ?? 0) + 1;
    }
    return counts;
  }

  static bool _isPair(List<PlayingCard> sorted) {
    return sorted.length == 2 && sorted[0].rank == sorted[1].rank;
  }

  static bool _isTriple(List<PlayingCard> sorted) {
    return sorted.length == 3 &&
        sorted[0].rank == sorted[1].rank &&
        sorted[1].rank == sorted[2].rank;
  }

  static bool _isBomb(List<PlayingCard> sorted) {
    return sorted.length == 4 &&
        sorted[0].rank == sorted[1].rank &&
        sorted[1].rank == sorted[2].rank &&
        sorted[2].rank == sorted[3].rank;
  }

  static bool _isRocket(List<PlayingCard> sorted) {
    if (sorted.length != 2) return false;
    return sorted[0].rank == PlayingCard.rankSmallJoker &&
        sorted[1].rank == PlayingCard.rankBigJoker;
  }

  static CardPattern? _tryStraight(
    List<PlayingCard> sorted,
    Map<int, int> ranks,
  ) {
    if (sorted.length < 5) return null;
    for (final c in sorted) {
      if (c.rank >= PlayingCard.rank2 || c.isJoker) return null;
    }
    for (
      int r = sorted.first.rank;
      r < sorted.first.rank + sorted.length;
      r++
    ) {
      if ((ranks[r] ?? 0) != 1) return null;
    }
    return CardPattern(PatternType.straight, sorted.last.rank, sorted);
  }

  static CardPattern? _tryConsecutivePairs(
    List<PlayingCard> sorted,
    Map<int, int> ranks,
  ) {
    if (sorted.length < 6 || sorted.length % 2 != 0) return null;
    final pairCount = sorted.length ~/ 2;
    for (final r in ranks.keys) {
      if (ranks[r] == 2) {
        if (r >= PlayingCard.rank2) return null;
      }
    }
    final pairRanks = <int>[];
    for (final r in ranks.keys.toList()..sort()) {
      if (ranks[r] == 2) pairRanks.add(r);
    }
    if (pairRanks.length != pairCount) return null;
    for (int i = 1; i < pairRanks.length; i++) {
      if (pairRanks[i] != pairRanks[i - 1] + 1) return null;
    }
    for (final r in pairRanks) {
      if (r >= PlayingCard.rank2) return null;
    }
    return CardPattern(PatternType.consecutivePairs, pairRanks.last, sorted);
  }

  static CardPattern? _tryTripleWithOne(
    List<PlayingCard> sorted,
    Map<int, int> ranks,
  ) {
    if (sorted.length != 4) return null;
    int? tripleRank;
    for (final r in ranks.keys) {
      if (ranks[r] == 3) tripleRank = r;
    }
    if (tripleRank == null) return null;
    return CardPattern(PatternType.tripleWithOne, tripleRank, sorted);
  }

  static CardPattern? _tryTripleWithPair(
    List<PlayingCard> sorted,
    Map<int, int> ranks,
  ) {
    if (sorted.length != 5) return null;
    int? tripleRank;
    int? pairRank;
    for (final r in ranks.keys) {
      if (ranks[r] == 3) tripleRank = r;
      if (ranks[r] == 2) pairRank = r;
    }
    if (tripleRank == null || pairRank == null) return null;
    return CardPattern(PatternType.tripleWithPair, tripleRank, sorted);
  }

  static CardPattern? _tryPlane(List<PlayingCard> sorted, Map<int, int> ranks) {
    final tripleRanks = <int>[];
    for (final r in ranks.keys.toList()..sort()) {
      if (ranks[r] == 3) tripleRanks.add(r);
    }
    if (tripleRanks.length < 2) return null;

    int bestStart = 0;
    int bestLen = 1;
    int curStart = 0;
    for (int i = 1; i < tripleRanks.length; i++) {
      if (tripleRanks[i] == tripleRanks[i - 1] + 1) {
        final curLen = i - curStart + 1;
        if (curLen > bestLen) {
          bestLen = curLen;
          bestStart = curStart;
        }
      } else {
        curStart = i;
      }
    }

    final planeTripleCount = bestLen;
    final totalTripleCards = planeTripleCount * 3;
    final remaining = sorted.length - totalTripleCards;

    if (remaining == 0) {
      int maxTripleRank = tripleRanks[bestStart + planeTripleCount - 1];
      return CardPattern(PatternType.plane, maxTripleRank, sorted);
    }
    if (remaining == planeTripleCount) {
      int maxTripleRank = tripleRanks[bestStart + planeTripleCount - 1];
      return CardPattern(PatternType.plane, maxTripleRank, sorted);
    }
    if (remaining == planeTripleCount * 2) {
      final pairCount = ranks.values.where((c) => c == 2).length;
      if (pairCount >= planeTripleCount) {
        int maxTripleRank = tripleRanks[bestStart + planeTripleCount - 1];
        return CardPattern(PatternType.plane, maxTripleRank, sorted);
      }
    }

    return null;
  }
}

class MoveFinder {
  static int? canBeat(List<PlayingCard> hand, CardPattern lastPlay) {
    return null;
  }

  static List<List<PlayingCard>> findAllPlays(List<PlayingCard> hand) {
    final sorted = CardDeck.sortByRank(hand);
    final plays = <List<PlayingCard>>[];
    final ranks = PatternRecognizer._rankCounts(sorted);

    for (final c in sorted) {
      plays.add([c]);
    }

    for (final r in ranks.keys) {
      if (ranks[r]! >= 2) {
        final cards = sorted.where((c) => c.rank == r).take(2).toList();
        plays.add(cards);
      }
    }

    for (final r in ranks.keys) {
      if (ranks[r]! >= 3) {
        final threeCards = sorted.where((c) => c.rank == r).take(3).toList();
        plays.add(threeCards);

        final remaining = sorted.where((c) => c.rank != r).toList();
        if (remaining.isNotEmpty) {
          plays.add([...threeCards, remaining.first]);
        }
        final pairsInRemaining = <int>[];
        for (final remR in PatternRecognizer._rankCounts(remaining).keys) {
          if (PatternRecognizer._rankCounts(remaining)[remR]! >= 2)
            pairsInRemaining.add(remR);
        }
        if (pairsInRemaining.isNotEmpty) {
          final pr = pairsInRemaining.first;
          final pairCards = remaining
              .where((c) => c.rank == pr)
              .take(2)
              .toList();
          plays.add([...threeCards, ...pairCards]);
        }
      }
    }

    for (final r in ranks.keys) {
      if (ranks[r]! >= 4) {
        final fourCards = sorted.where((c) => c.rank == r).take(4).toList();
        plays.add(fourCards);
      }
    }

    final hasSmall = sorted.any((c) => c.rank == PlayingCard.rankSmallJoker);
    final hasBig = sorted.any((c) => c.rank == PlayingCard.rankBigJoker);
    if (hasSmall && hasBig) {
      plays.add([
        sorted.firstWhere((c) => c.rank == PlayingCard.rankSmallJoker),
        sorted.firstWhere((c) => c.rank == PlayingCard.rankBigJoker),
      ]);
    }

    for (int len = 5; len <= 12; len++) {
      for (int start = 3; start + len - 1 <= PlayingCard.rankA; start++) {
        bool hasAll = true;
        for (int r = start; r < start + len; r++) {
          if ((ranks[r] ?? 0) == 0) {
            hasAll = false;
            break;
          }
        }
        if (hasAll) {
          final straight = <PlayingCard>[];
          for (int r = start; r < start + len; r++) {
            straight.add(sorted.firstWhere((c) => c.rank == r));
          }
          plays.add(straight);
        }
      }
    }

    for (int pairLen = 3; pairLen * 2 <= sorted.length; pairLen++) {
      for (int start = 3; start + pairLen - 1 <= PlayingCard.rankA; start++) {
        bool hasAll = true;
        for (int r = start; r < start + pairLen; r++) {
          if ((ranks[r] ?? 0) < 2) {
            hasAll = false;
            break;
          }
        }
        if (hasAll) {
          final pairs = <PlayingCard>[];
          for (int r = start; r < start + pairLen; r++) {
            pairs.addAll(sorted.where((c) => c.rank == r).take(2));
          }
          plays.add(pairs);
        }
      }
    }

    return plays;
  }
}

extension CardListExt on List<PlayingCard> {
  List<PlayingCard> sorted() => CardDeck.sortByRank(this);
}

import '../models/card.dart';
import 'card_pattern.dart';

class AIStrategy {
  static List<PlayingCard>? choosePlay(List<PlayingCard> hand, CardPattern? lastPlay, bool isLandlord) {
    final sorted = CardDeck.sortByRank(hand);

    if (lastPlay == null) {
      return _chooseFirstPlay(sorted, isLandlord);
    }

    return _chooseBeatPlay(sorted, lastPlay, isLandlord);
  }

  static List<PlayingCard>? _chooseFirstPlay(List<PlayingCard> sorted, bool isLandlord) {
    final allPlays = MoveFinder.findAllPlays(sorted);
    if (allPlays.isEmpty) return null;

    bool isBombOrRocket(List<PlayingCard> cards) {
      final pattern = PatternRecognizer.recognize(cards);
      if (pattern == null) return false;
      return pattern.type == PatternType.bomb || pattern.type == PatternType.rocket;
    }

    final nonBombPlays = allPlays.where((p) => !isBombOrRocket(p)).toList();
    final plays = nonBombPlays.isNotEmpty ? nonBombPlays : allPlays;

    plays.sort((a, b) {
      final patternA = PatternRecognizer.recognize(a);
      final patternB = PatternRecognizer.recognize(b);
      final rankA = patternA?.mainRank ?? 100;
      final rankB = patternB?.mainRank ?? 100;

      final typePriority = (PatternType t) {
        switch (t) {
          case PatternType.single:
            return 0;
          case PatternType.pair:
            return 1;
          case PatternType.triple:
            return 2;
          case PatternType.tripleWithOne:
            return 3;
          case PatternType.tripleWithPair:
            return 4;
          case PatternType.straight:
            return 5;
          case PatternType.consecutivePairs:
            return 6;
          case PatternType.plane:
            return 7;
          case PatternType.bomb:
            return 8;
          case PatternType.rocket:
            return 9;
        }
      };

      final typeCmp = typePriority(patternA!.type).compareTo(typePriority(patternB!.type));
      if (typeCmp != 0) return typeCmp;
      return rankA.compareTo(rankB);
    });

    return CardDeck.sortByRank(plays.first);
  }

  static List<PlayingCard>? _chooseBeatPlay(List<PlayingCard> sorted, CardPattern lastPlay, bool isLandlord) {
    final allPlays = MoveFinder.findAllPlays(sorted);
    final validPlays = <List<PlayingCard>>[];

    for (final cards in allPlays) {
      final pattern = PatternRecognizer.recognize(cards);
      if (pattern != null && pattern.canBeat(lastPlay)) {
        validPlays.add(cards);
      }
    }

    if (validPlays.isEmpty) return null;

    final nonBombRocket = validPlays.where((p) {
      final pattern = PatternRecognizer.recognize(p)!;
      return pattern.type != PatternType.bomb && pattern.type != PatternType.rocket;
    }).toList();

    final remainingCount = sorted.length;
    final canWinRightNow = validPlays.any((p) => p.length == remainingCount);

    if (canWinRightNow) {
      for (final p in validPlays) {
        if (p.length == remainingCount) return CardDeck.sortByRank(p);
      }
    }

    if (nonBombRocket.isNotEmpty) {
      nonBombRocket.sort((a, b) {
        final pa = PatternRecognizer.recognize(a)!;
        final pb = PatternRecognizer.recognize(b)!;
        return pa.mainRank.compareTo(pb.mainRank);
      });
      return CardDeck.sortByRank(nonBombRocket.first);
    }

    if (validPlays.isNotEmpty) {
      validPlays.sort((a, b) {
        final pa = PatternRecognizer.recognize(a)!;
        final pb = PatternRecognizer.recognize(b)!;
        return pa.mainRank.compareTo(pb.mainRank);
      });
      return CardDeck.sortByRank(validPlays.first);
    }

    return null;
  }
}

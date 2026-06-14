import 'dart:math';
import '../models/card.dart';
import 'card_pattern.dart';

enum GamePhase { dealing, playing, finished }

class GameSession {
  List<List<PlayingCard>> hands;
  int playerIndex;
  int landlordIndex;
  List<PlayingCard> holeCards;
  int currentTurn;
  List<PlayingCard> lastPlay;
  int lastPlayPlayer;
  int passCount;
  int gameRound;
  GamePhase phase;
  bool gameOver;
  int winnerIndex;
  int startTimeMs;
  int elapsedMs;

  GameSession({
    required this.hands,
    required this.playerIndex,
    required this.landlordIndex,
    required this.holeCards,
    required this.currentTurn,
    this.lastPlay = const [],
    this.lastPlayPlayer = -1,
    this.passCount = 0,
    this.gameRound = 0,
    this.phase = GamePhase.playing,
    this.gameOver = false,
    this.winnerIndex = -1,
    this.startTimeMs = 0,
    this.elapsedMs = 0,
  });

  bool get isPlayerLandlord => playerIndex == landlordIndex;

  List<PlayingCard> get playerHand => hands[playerIndex];
  List<PlayingCard> get leftAIHand => hands[(playerIndex + 1) % 3];
  List<PlayingCard> get rightAIHand => hands[(playerIndex + 2) % 3];

  int get leftAICount => leftAIHand.length;
  int get rightAICount => rightAIHand.length;
  int get playerCount => playerHand.length;

  String playerIdentity(int index) {
    if (index == landlordIndex) return '\u5730\u4E3B';
    return '\u519C\u6C11';
  }

  Map<String, Object?> toJson() {
    return {
      'hands': hands
          .map(
            (h) =>
                h.map((c) => {'suit': c.suit.index, 'rank': c.rank}).toList(),
          )
          .toList(),
      'playerIndex': playerIndex,
      'landlordIndex': landlordIndex,
      'holeCards': holeCards
          .map((c) => {'suit': c.suit.index, 'rank': c.rank})
          .toList(),
      'currentTurn': currentTurn,
      'lastPlay': lastPlay
          .map((c) => {'suit': c.suit.index, 'rank': c.rank})
          .toList(),
      'lastPlayPlayer': lastPlayPlayer,
      'passCount': passCount,
      'gameRound': gameRound,
      'phase': phase.index,
      'gameOver': gameOver,
      'winnerIndex': winnerIndex,
      'startTimeMs': startTimeMs,
      'elapsedMs': elapsedMs,
    };
  }

  factory GameSession.fromJson(Map<String, Object?> json) {
    final hands = (json['hands'] as List)
        .map(
          (h) => (h as List).map((c) {
            final m = c as Map;
            return PlayingCard(
              CardSuit.values[m['suit'] as int],
              m['rank'] as int,
            );
          }).toList(),
        )
        .toList();
    final holeCards = (json['holeCards'] as List).map((c) {
      final m = c as Map;
      return PlayingCard(CardSuit.values[m['suit'] as int], m['rank'] as int);
    }).toList();
    final lastPlay = (json['lastPlay'] as List).map((c) {
      final m = c as Map;
      return PlayingCard(CardSuit.values[m['suit'] as int], m['rank'] as int);
    }).toList();

    return GameSession(
      hands: hands,
      playerIndex: json['playerIndex'] as int,
      landlordIndex: json['landlordIndex'] as int,
      holeCards: holeCards,
      currentTurn: json['currentTurn'] as int,
      lastPlay: lastPlay,
      lastPlayPlayer: json['lastPlayPlayer'] as int,
      passCount: json['passCount'] as int,
      gameRound: json['gameRound'] as int,
      phase: GamePhase.values[json['phase'] as int],
      gameOver: json['gameOver'] as bool,
      winnerIndex: json['winnerIndex'] as int,
      startTimeMs: json['startTimeMs'] as int,
      elapsedMs: json['elapsedMs'] as int,
    );
  }
}

class GameEngine {
  static GameSession createNewGame() {
    final deck = CardDeck.createFullDeck();
    CardDeck.shuffle(deck);

    final hands = <List<PlayingCard>>[
      deck.sublist(0, 17),
      deck.sublist(17, 34),
      deck.sublist(34, 51),
    ];
    final holeCards = deck.sublist(51, 54);

    for (final h in hands) {
      CardDeck.sortByRank(h);
    }

    final rng = Random();
    final playerIndex = 0;
    final landlordIndex = rng.nextInt(3);

    hands[landlordIndex].addAll(holeCards);
    CardDeck.sortByRank(hands[landlordIndex]);

    return GameSession(
      hands: hands,
      playerIndex: playerIndex,
      landlordIndex: landlordIndex,
      holeCards: holeCards,
      currentTurn: landlordIndex,
      lastPlay: [],
      lastPlayPlayer: -1,
      passCount: 0,
      gameRound: 0,
      phase: GamePhase.playing,
      gameOver: false,
      winnerIndex: -1,
      startTimeMs: DateTime.now().millisecondsSinceEpoch,
    );
  }

  static String? validatePlay(List<PlayingCard> cards, GameSession session) {
    if (cards.isEmpty) return null;
    final pattern = PatternRecognizer.recognize(cards);
    if (pattern == null) return '\u65E0\u6548\u7684\u724C\u578B';

    if (session.lastPlay.isEmpty &&
        session.lastPlayPlayer == session.currentTurn) {
      return null;
    }

    if (session.lastPlay.isEmpty) return null;

    final lastPattern = PatternRecognizer.recognize(session.lastPlay);
    if (lastPattern == null) return '\u5185\u90E8\u9519\u8BEF';

    if (!pattern.canBeat(lastPattern)) {
      return '\u6253\u4E0D\u8FC7\u4E0A\u5BB6\u51FA\u7684\u724C';
    }

    return null;
  }

  static void applyPlay(List<PlayingCard> cards, GameSession session) {
    final playerHand = session.hands[session.currentTurn];
    for (final card in cards) {
      final idx = playerHand.indexWhere(
        (c) => c.rank == card.rank && c.suit == card.suit,
      );
      if (idx != -1) playerHand.removeAt(idx);
    }

    session.lastPlay = cards;
    session.lastPlayPlayer = session.currentTurn;
    session.passCount = 0;
    session.gameRound++;

    if (playerHand.isEmpty) {
      session.gameOver = true;
      session.winnerIndex = session.currentTurn;
      session.phase = GamePhase.finished;
    }

    session.currentTurn = (session.currentTurn + 1) % 3;
  }

  static void applyPass(GameSession session) {
    session.passCount++;
    session.currentTurn = (session.currentTurn + 1) % 3;

    if (session.passCount >= 2) {
      session.lastPlay = [];
      session.lastPlayPlayer = session.currentTurn;
      session.passCount = 0;
    }
  }

  static bool isNewRound(GameSession session) {
    return session.lastPlay.isEmpty;
  }
}

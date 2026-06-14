import 'lib/src/games/landlord/models/card.dart';
import 'lib/src/games/landlord/logic/card_pattern.dart';
import 'lib/src/games/landlord/logic/game_engine.dart';
import 'lib/src/games/landlord/logic/ai_strategy.dart';

void main() {
  final session = GameEngine.createNewGame();
  print('Cards: ${session.playerHand.length}');
  print('Card: ${session.playerHand[0]}');
  
  final pattern = PatternRecognizer.recognize([PlayingCard(CardSuit.spade, 3)]);
  print('Pattern: ${pattern?.type}');
  
  final deck = CardDeck.createFullDeck();
  print('Deck: ${deck.length} cards, CardSuit values: ${CardSuit.values}');
  
  int rounds = 0;
  while (!session.gameOver && rounds++ < 200) {
    final hand = session.hands[session.currentTurn];
    CardPattern? lastPattern;
    if (session.lastPlay.isNotEmpty) {
      lastPattern = PatternRecognizer.recognize(session.lastPlay);
    }
    final play = AIStrategy.choosePlay(hand, lastPattern, session.currentTurn == session.landlordIndex);
    if (play != null) GameEngine.applyPlay(play, session);
    else GameEngine.applyPass(session);
  }
  print('Winner: ${session.winnerIndex}, rounds: ${session.gameRound}');
  print('ALL OK');
}

import 'dart:async';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../game_landlord_module.dart';
import '../logic/card_pattern.dart';
import '../logic/game_engine.dart';
import '../logic/ai_strategy.dart';
import '../models/card.dart';
import '../widgets/card_widget.dart';
import '../widgets/opponent_area_widget.dart';
import '../widgets/player_hand_widget.dart';
import 'landlord_start_page.dart';

class LandlordPlayPage extends StatefulWidget {
  const LandlordPlayPage({
    super.key,
    required this.module,
    this.resumeSession,
    required this.onSessionSaved,
  });

  final GameLandlordModule module;
  final Map<String, Object?>? resumeSession;
  final void Function(Map<String, Object?> session) onSessionSaved;

  @override
  State<LandlordPlayPage> createState() => _LandlordPlayPageState();
}

class _LandlordPlayPageState extends State<LandlordPlayPage> {
  late GameSession session;
  final selectedIndices = <int>{};
  String statusText = '';
  bool processing = false;
  Timer? _aiTimer;
  Timer? _timer;
  DateTime? sessionStartTime;
  List<PlayingCard>? lastAiPlay;
  String? lastAiPlayLabel;
  int lastAiPlayPlayer = -1;

  @override
  void initState() {
    super.initState();
    if (widget.resumeSession != null) {
      session = GameSession.fromJson(widget.resumeSession!);
    } else {
      session = GameEngine.createNewGame();
    }
    _saveSession();
    sessionStartTime = DateTime.now();
    _startTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _afterBuild();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          session.elapsedMs =
              DateTime.now().difference(sessionStartTime!).inMilliseconds;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _aiTimer?.cancel();
    super.dispose();
  }

  void _saveSession() {
    widget.onSessionSaved(session.toJson());
  }

  void _afterBuild() {
    if (session.gameOver) return;
    if (session.currentTurn != session.playerIndex) {
      _doAITurn();
    } else {
      _updateStatus();
    }
  }

  void _updateStatus() {
    if (session.gameOver) {
      final winnerName = session.winnerIndex == session.playerIndex
          ? '\u4F60'
          : 'AI-${session.winnerIndex + 1}';
      final won = session.winnerIndex == session.playerIndex;
      setState(() {
        statusText = won ? '\u4F60\u8D62\u4E86\uFF01' : '$winnerName \u83B7\u80DC';
      });
      return;
    }

    if (session.currentTurn == session.playerIndex) {
      setState(() {
        statusText = '\u8BF7\u51FA\u724C';
      });
    } else {
      setState(() {
        statusText = 'AI-${session.currentTurn + 1} \u601D\u8003\u4E2D...';
      });
    }
  }

  Future<void> _doAITurn() async {
    if (session.gameOver) return;
    if (session.currentTurn == session.playerIndex) {
      _updateStatus();
      return;
    }

    setState(() => processing = true);
    _updateStatus();

    _aiTimer?.cancel();
    _aiTimer = Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      final aiHand = session.hands[session.currentTurn];
      final isLandlord = session.currentTurn == session.landlordIndex;

      CardPattern? lastPattern;
      if (session.lastPlay.isNotEmpty) {
        lastPattern = PatternRecognizer.recognize(session.lastPlay);
      }

      if (lastPattern == null && session.lastPlayPlayer == session.currentTurn) {
        lastPattern = null;
      }

      final chosen = AIStrategy.choosePlay(aiHand, lastPattern, isLandlord);

      if (chosen != null) {
        final sortedChosen = CardDeck.sortByRank(chosen);
        final pattern = PatternRecognizer.recognize(sortedChosen);
        final label = _patternLabel(pattern);
        setState(() {
          lastAiPlay = sortedChosen;
          lastAiPlayLabel = label;
          lastAiPlayPlayer = session.currentTurn;
        });
        GameEngine.applyPlay(chosen, session);
      } else {
        setState(() {
          lastAiPlay = null;
          lastAiPlayLabel = '\u4E0D\u51FA';
          lastAiPlayPlayer = session.currentTurn;
        });
        GameEngine.applyPass(session);
      }

      _saveSession();
      setState(() => processing = false);
      _updateStatus();

      if (session.gameOver) {
        _showGameOver();
        return;
      }

      if (session.currentTurn != session.playerIndex) {
        _doAITurn();
      }
    });
  }

  String _patternLabel(CardPattern? pattern) {
    if (pattern == null) return '';
    switch (pattern.type) {
      case PatternType.single:
        return '\u5355\u724C';
      case PatternType.pair:
        return '\u5BF9\u5B50';
      case PatternType.triple:
        return '\u4E09\u6761';
      case PatternType.tripleWithOne:
        return '\u4E09\u5E26\u4E00';
      case PatternType.tripleWithPair:
        return '\u4E09\u5E26\u4E8C';
      case PatternType.straight:
        return '\u987A\u5B50';
      case PatternType.consecutivePairs:
        return '\u8FDE\u5BF9';
      case PatternType.plane:
        return '\u98DE\u673A';
      case PatternType.bomb:
        return '\u70B8\u5F39\uFF01';
      case PatternType.rocket:
        return '\u738B\u70B8\uFF01\uFF01';
    }
  }

  void _onToggleCard(int index) {
    if (processing || session.currentTurn != session.playerIndex) return;
    setState(() {
      if (selectedIndices.contains(index)) {
        selectedIndices.remove(index);
      } else {
        selectedIndices.add(index);
      }
    });
  }

  List<PlayingCard> get _selectedCards {
    final indices = selectedIndices.toList()..sort();
    return indices.map((i) => session.playerHand[i]).toList();
  }

  void _playCards() {
    if (processing || session.currentTurn != session.playerIndex) return;
    if (selectedIndices.isEmpty) return;

    final cards = CardDeck.sortByRank(_selectedCards);
    final error = GameEngine.validatePlay(cards, session);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final pattern = PatternRecognizer.recognize(cards);
    setState(() {
      lastAiPlay = cards;
      lastAiPlayLabel = _patternLabel(pattern);
      lastAiPlayPlayer = session.playerIndex;
      selectedIndices.clear();
    });

    GameEngine.applyPlay(cards, session);
    _saveSession();
    _updateStatus();

    if (session.gameOver) {
      _showGameOver();
      return;
    }

    _doAITurn();
  }

  void _passCards() {
    if (processing || session.currentTurn != session.playerIndex) return;

    if (session.lastPlay.isEmpty || session.lastPlayPlayer == session.playerIndex) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('\u65B0\u56DE\u5408\u5FC5\u987B\u51FA\u724C'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      lastAiPlay = null;
      lastAiPlayLabel = '\u4E0D\u51FA';
      lastAiPlayPlayer = session.playerIndex;
      selectedIndices.clear();
    });

    GameEngine.applyPass(session);
    _saveSession();
    _updateStatus();

    if (session.gameOver) {
      _showGameOver();
      return;
    }

    _doAITurn();
  }

  void _showHint() {
    if (processing || session.currentTurn != session.playerIndex) return;
    final hand = session.playerHand;

    CardPattern? lastPattern;
    if (session.lastPlay.isNotEmpty &&
        session.lastPlayPlayer != session.playerIndex) {
      lastPattern = PatternRecognizer.recognize(session.lastPlay);
    }

    List<PlayingCard>? hint;
    if (lastPattern == null) {
      hint = AIStrategy.choosePlay(hand, null, session.isPlayerLandlord);
    } else {
      hint = AIStrategy.choosePlay(hand, lastPattern, session.isPlayerLandlord);
    }

    if (hint == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('\u6CA1\u6709\u80FD\u51FA\u7684\u724C\uFF0C\u5EFA\u8BAE\u4E0D\u51FA'),
          backgroundColor: AppTheme.surfaceAlt,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      selectedIndices.clear();
      if (hint == null) return;
      for (final c in hint!) {
        for (int i = 0; i < hand.length; i++) {
          if (hand[i].rank == c.rank && hand[i].suit == c.suit) {
            selectedIndices.add(i);
            break;
          }
        }
      }
    });
  }

  void _showGameOver() {
    final won = session.winnerIndex == session.playerIndex;
    final winnerName = won
        ? '\u4F60'
        : 'AI-${session.winnerIndex + 1}';
    final identity = session.playerIdentity(session.winnerIndex);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Center(
          child: Text(
            won ? '\uD83C\uDF89 \u4F60\u8D62\u4E86\uFF01' : '\uD83D\uDE14 $winnerName \u83B7\u80DC',
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 24),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Text('\u8EAB\u4EFD: $identity',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
            const SizedBox(height: 4),
            Text('\u56DE\u5408: ${session.gameRound}',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .popUntil((route) => route.isFirst);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    side: const BorderSide(color: AppTheme.textSecondary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('\u8FD4\u56DE\u5927\u5385'),
                ),
                const SizedBox(width: 14),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => LandlordPlayPage(
                          module: widget.module,
                          onSessionSaved: widget.onSessionSaved,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('\u518D\u6765\u4E00\u5C40'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.backgroundTop, AppTheme.backgroundBottom],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              const SizedBox(height: 8),
              _buildOpponentsRow(),
              const SizedBox(height: 12),
              _buildCenterArea(),
              const Spacer(),
              _buildPlayerArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textSecondary, size: 22),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppTheme.surface,
                  title: const Text('\u9000\u51FA\u6E38\u620F',
                      style: TextStyle(color: AppTheme.textPrimary)),
                  content: const Text('\u5F53\u524D\u6E38\u620F\u8FDB\u5EA6\u5C06\u88AB\u4FDD\u5B58\uFF0C\u786E\u8BA4\u9000\u51FA\uFF1F',
                      style: TextStyle(color: AppTheme.textSecondary)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('\u53D6\u6D88',
                          style: TextStyle(color: AppTheme.textSecondary)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      },
                      child: const Text('\u9000\u51FA',
                          style: TextStyle(color: AppTheme.accent)),
                    ),
                  ],
                ),
              );
            },
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '\u7B2C ${session.gameRound + 1} \u56DE\u5408',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          if (session.isPlayerLandlord)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.accent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('\u5730\u4E3B',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.success,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('\u519C\u6C11',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }

  Widget _buildOpponentsRow() {
    final ai1Name = 'AI-1';
    final ai2Name = 'AI-2';

    final ai1Identity = session.playerIdentity((session.playerIndex + 1) % 3);
    final ai2Identity = session.playerIdentity((session.playerIndex + 2) % 3);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          OpponentAreaWidget(
            name: ai1Name,
            cardCount: session.leftAICount,
            identity: ai1Identity,
            isCurrentTurn: session.currentTurn == (session.playerIndex + 1) % 3,
            willPlay: !processing &&
                session.currentTurn == (session.playerIndex + 1) % 3,
          ),
          OpponentAreaWidget(
            name: ai2Name,
            cardCount: session.rightAICount,
            identity: ai2Identity,
            isCurrentTurn: session.currentTurn == (session.playerIndex + 2) % 3,
            willPlay: !processing &&
                session.currentTurn == (session.playerIndex + 2) % 3,
          ),
        ],
      ),
    );
  }

  Widget _buildCenterArea() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (lastAiPlayLabel != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.surface.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    lastAiPlayLabel!,
                    style: TextStyle(
                      color: lastAiPlayLabel == '\u4E0D\u51FA'
                          ? AppTheme.textSecondary
                          : AppTheme.accent,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (lastAiPlay != null && lastAiPlay!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 72,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: lastAiPlay!
                            .map((c) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 2),
                                  child: CardWidget(card: c, width: 42, height: 60),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          if (statusText.isNotEmpty && !session.gameOver)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                statusText,
                style: TextStyle(
                  color: session.currentTurn == session.playerIndex
                      ? AppTheme.accent
                      : AppTheme.textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlayerArea() {
    return Container(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppTheme.navSurface.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PlayerHandWidget(
            cards: session.playerHand,
            selectedIndices: selectedIndices,
            onToggleCard: _onToggleCard,
            enabled: session.currentTurn == session.playerIndex && !processing,
          ),
          const SizedBox(height: 10),
          _buildActionButtons(),
          const SizedBox(height: 6),
          if (session.holeCards.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('\u5E95\u724C: ',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12)),
                  ...session.holeCards.map((c) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: CardWidget(card: c, width: 36, height: 50),
                      )),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final myTurn = session.currentTurn == session.playerIndex && !processing;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 80,
          height: 40,
          child: ElevatedButton(
            onPressed: myTurn ? _playCards : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppTheme.surfaceAlt,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('\u51FA\u724C',
                style:
                    TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          height: 40,
          child: OutlinedButton(
            onPressed: myTurn ? _passCards : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.textSecondary,
              side: const BorderSide(color: AppTheme.textSecondary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('\u4E0D\u51FA',
                style:
                    TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          height: 40,
          child: OutlinedButton(
            onPressed: myTurn ? _showHint : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.accentSoft,
              side: const BorderSide(color: AppTheme.accentSoft),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('\u63D0\u793A',
                style:
                    TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}

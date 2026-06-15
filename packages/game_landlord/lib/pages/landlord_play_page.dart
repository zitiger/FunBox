import 'dart:async';
import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../game_landlord_module.dart';
import '../logic/ai_strategy.dart';
import '../logic/card_pattern.dart';
import '../logic/game_engine.dart';
import '../models/card.dart';
import '../widgets/card_widget.dart';
import '../widgets/opponent_area_widget.dart';
import '../widgets/player_hand_widget.dart';

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
  static const _leftOpponentName = '\u5c0f\u6a59';
  static const _rightOpponentName = '\u963f\u9752';

  late GameSession session;
  final selectedIndices = <int>{};
  final recentPlayByPlayer = <int, List<PlayingCard>>{};
  final recentPlayLabelByPlayer = <int, String>{};
  String statusText = '';
  bool processing = false;
  Timer? _aiTimer;
  Timer? _timer;
  DateTime? sessionStartTime;
  List<PlayingCard>? lastAiPlay;
  String? lastAiPlayLabel;

  @override
  void initState() {
    super.initState();
    if (widget.resumeSession != null) {
      session = GameSession.fromJson(widget.resumeSession!);
    } else {
      session = GameEngine.createNewGame();
    }
    GameEngine.sortHands(session);
    _seedRecentPlayState();
    _saveSession();
    sessionStartTime = DateTime.now();
    _startTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _afterBuild();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _aiTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        session.elapsedMs = DateTime.now()
            .difference(sessionStartTime!)
            .inMilliseconds;
      });
    });
  }

  void _saveSession() {
    widget.onSessionSaved(session.toJson());
  }

  void _seedRecentPlayState() {
    if (session.lastPlay.isEmpty || session.lastPlayPlayer < 0) return;
    final pattern = PatternRecognizer.recognize(session.lastPlay);
    final label = _patternLabel(pattern);
    recentPlayByPlayer[session.lastPlayPlayer] = List<PlayingCard>.from(
      session.lastPlay,
    );
    recentPlayLabelByPlayer[session.lastPlayPlayer] = label;
    lastAiPlay = List<PlayingCard>.from(session.lastPlay);
    lastAiPlayLabel = label;
  }

  void _rememberPlay(int playerIndex, List<PlayingCard> cards, String label) {
    recentPlayByPlayer[playerIndex] = List<PlayingCard>.from(cards);
    recentPlayLabelByPlayer[playerIndex] = label;
  }

  String _playerName(int playerIndex) {
    if (playerIndex == session.playerIndex) return '\u4f60';
    if (playerIndex == (session.playerIndex + 1) % 3) {
      return _leftOpponentName;
    }
    return _rightOpponentName;
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
      final winnerName = _playerName(session.winnerIndex);
      final won = session.winnerIndex == session.playerIndex;
      setState(() {
        statusText = won ? '你赢了！' : '$winnerName 获胜';
      });
      return;
    }

    setState(() {
      statusText = session.currentTurn == session.playerIndex
          ? '请出牌'
          : '${_playerName(session.currentTurn)} 思考中...';
    });
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
      if (lastPattern == null &&
          session.lastPlayPlayer == session.currentTurn) {
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
          _rememberPlay(session.currentTurn, sortedChosen, label);
        });
        GameEngine.applyPlay(chosen, session);
      } else {
        setState(() {
          lastAiPlay = null;
          lastAiPlayLabel = '不出';
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
        return '单牌';
      case PatternType.pair:
        return '对子';
      case PatternType.triple:
        return '三条';
      case PatternType.tripleWithOne:
        return '三带一';
      case PatternType.tripleWithPair:
        return '三带二';
      case PatternType.straight:
        return '顺子';
      case PatternType.consecutivePairs:
        return '连对';
      case PatternType.plane:
        return '飞机';
      case PatternType.bomb:
        return '炸弹';
      case PatternType.rocket:
        return '王炸';
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
    final label = _patternLabel(pattern);
    setState(() {
      lastAiPlay = cards;
      lastAiPlayLabel = label;
      _rememberPlay(session.playerIndex, cards, label);
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

    if (session.lastPlay.isEmpty ||
        session.lastPlayPlayer == session.playerIndex) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('新回合必须出牌'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      lastAiPlay = null;
      lastAiPlayLabel = '不出';
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

    final hint = lastPattern == null
        ? AIStrategy.choosePlay(hand, null, session.isPlayerLandlord)
        : AIStrategy.choosePlay(hand, lastPattern, session.isPlayerLandlord);

    if (hint == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('没有能出的牌，建议不出'),
          backgroundColor: AppTheme.surfaceAlt,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      selectedIndices.clear();
      for (final c in hint) {
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
    final winnerName = _playerName(session.winnerIndex);
    final identity = session.playerIdentity(session.winnerIndex);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Center(
          child: Text(
            won ? '你赢了！' : '$winnerName 获胜',
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 24),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Text(
              '身份: $identity',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '回合: ${session.gameRound}',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    side: const BorderSide(color: AppTheme.textSecondary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('返回大厅'),
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('再来一局'),
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
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1440),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= 720) {
                    return _buildTableLayout(constraints);
                  }
                  return _buildPortraitLayout();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableLayout(BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;
    final isShort = height < 470;
    final handHeight = isShort ? 126.0 : 142.0;
    final topBarHeight = 44.0;
    final leftPlayer = (session.playerIndex + 1) % 3;
    final rightPlayer = (session.playerIndex + 2) % 3;
    final leftPreview = _buildOpponentRecentPlay(leftPlayer);
    final rightPreview = _buildOpponentRecentPlay(rightPlayer);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Stack(
        children: [
          Positioned(
            left: 6,
            right: 6,
            top: topBarHeight + 8,
            bottom: handHeight + 10,
            child: _buildTableSurface(),
          ),
          Positioned(top: 4, left: 4, right: 4, child: _buildTopBar()),
          Positioned(
            top: topBarHeight + 14,
            left: 6,
            child: _buildOpponentDock(
              name: _leftOpponentName,
              cardCount: session.leftAICount,
              identity: session.playerIdentity(leftPlayer),
              isCurrentTurn: session.currentTurn == leftPlayer,
              willPlay: !processing && session.currentTurn == leftPlayer,
            ),
          ),
          Positioned(
            top: topBarHeight + 14,
            right: 6,
            child: _buildOpponentDock(
              name: _rightOpponentName,
              cardCount: session.rightAICount,
              identity: session.playerIdentity(rightPlayer),
              isCurrentTurn: session.currentTurn == rightPlayer,
              willPlay: !processing && session.currentTurn == rightPlayer,
            ),
          ),
          if (leftPreview != null)
            Positioned(top: isShort ? 134 : 154, left: 150, child: leftPreview),
          if (rightPreview != null)
            Positioned(
              top: isShort ? 134 : 154,
              right: 150,
              child: rightPreview,
            ),
          Positioned(
            top: isShort ? 102 : 118,
            left: width * 0.35,
            right: width * 0.35,
            child: _buildTurnChip(),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 6,
            height: handHeight,
            child: _buildPlayerDock(),
          ),
        ],
      ),
    );
  }

  Widget _buildPortraitLayout() {
    final ai1Identity = session.playerIdentity((session.playerIndex + 1) % 3);
    final ai2Identity = session.playerIdentity((session.playerIndex + 2) % 3);

    return Column(
      children: [
        _buildTopBar(),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildCompactOpponentPane(
                  playerIndex: (session.playerIndex + 1) % 3,
                  name: _leftOpponentName,
                  cardCount: session.leftAICount,
                  identity: ai1Identity,
                  isCurrentTurn:
                      session.currentTurn == (session.playerIndex + 1) % 3,
                  willPlay:
                      !processing &&
                      session.currentTurn == (session.playerIndex + 1) % 3,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCompactOpponentPane(
                  playerIndex: (session.playerIndex + 2) % 3,
                  name: _rightOpponentName,
                  cardCount: session.rightAICount,
                  identity: ai2Identity,
                  isCurrentTurn:
                      session.currentTurn == (session.playerIndex + 2) % 3,
                  willPlay:
                      !processing &&
                      session.currentTurn == (session.playerIndex + 2) % 3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(child: _buildTableSurface(child: _buildCenterArea())),
        const SizedBox(height: 8),
        _buildPlayerDock(),
      ],
    );
  }

  Widget _buildTopBar() {
    final roundText = session.gameOver
        ? '对局结束'
        : session.currentTurn == session.playerIndex
        ? '轮到你'
        : '${_playerName(session.currentTurn)} 出牌中';

    return Row(
      children: [
        _LandlordTopChipButton(
          icon: Icons.arrow_back_rounded,
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppTheme.surface,
                title: const Text(
                  '退出游戏',
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
                content: const Text(
                  '当前游戏进度将被保存，确认退出？',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text(
                      '取消',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: const Text(
                      '退出',
                      style: TextStyle(color: AppTheme.accent),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppTheme.surface.withValues(alpha: 0.86),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Text(
            '第 ${session.gameRound + 1} 回合 · $roundText',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: session.isPlayerLandlord
                ? AppTheme.accent.withValues(alpha: 0.95)
                : AppTheme.success.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            session.isPlayerLandlord ? '地主' : '农民',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableSurface({Widget? child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF08234B).withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildCenterArea() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTurnChip(),
          const SizedBox(height: 10),
          _buildLatestPlayCard(),
          const SizedBox(height: 10),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: Text(
              statusText.isEmpty ? ' ' : statusText,
              key: ValueKey<String>(statusText),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: session.currentTurn == session.playerIndex
                    ? AppTheme.accentSoft
                    : AppTheme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerDock() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 7, 12, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.navSurface.withValues(alpha: 0.42),
            AppTheme.navSurface.withValues(alpha: 0.88),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildActionButtons(),
          const SizedBox(height: 5),
          PlayerHandWidget(
            cards: session.playerHand,
            selectedIndices: selectedIndices,
            onToggleCard: _onToggleCard,
            enabled: session.currentTurn == session.playerIndex && !processing,
            minCardWidth: 34,
            maxCardWidth: 54,
            cardHeight: 72,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final myTurn = session.currentTurn == session.playerIndex && !processing;

    return Center(
      child: Wrap(
        spacing: 10,
        children: [
          _ActionButton(
            label: '出牌',
            primary: true,
            enabled: myTurn,
            onPressed: _playCards,
          ),
          _ActionButton(label: '提示', enabled: myTurn, onPressed: _showHint),
          _ActionButton(label: '不出', enabled: myTurn, onPressed: _passCards),
        ],
      ),
    );
  }

  Widget _buildTurnChip() {
    final currentTurnName = session.currentTurn == session.playerIndex
        ? '你'
        : _playerName(session.currentTurn);
    final hintText = session.gameOver
        ? '对局已结束'
        : session.currentTurn == session.playerIndex
        ? '轮到你出牌'
        : '$currentTurnName 正在思考';

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surface.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Text(
          hintText,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: session.currentTurn == session.playerIndex
                ? AppTheme.accentSoft
                : AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildLatestPlayCard() {
    final showCards = lastAiPlay != null && lastAiPlay!.isNotEmpty;
    final title = lastAiPlayLabel ?? '等待出牌';
    final titleColor = lastAiPlayLabel == '不出'
        ? AppTheme.textSecondary
        : AppTheme.accent;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Container(
        key: ValueKey<String>(
          '${lastAiPlayLabel ?? 'empty'}-${showCards ? lastAiPlay!.length : 0}',
        ),
        constraints: const BoxConstraints(minHeight: 76, maxWidth: 420),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surface.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                color: titleColor,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (showCards) ...[
              const SizedBox(height: 7),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 3,
                runSpacing: 3,
                children: lastAiPlay!
                    .map((c) => CardWidget(card: c, width: 36, height: 52))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOpponentDock({
    required String name,
    required int cardCount,
    required String identity,
    required bool isCurrentTurn,
    required bool willPlay,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 132),
      child: OpponentAreaWidget(
        name: name,
        cardCount: cardCount,
        identity: identity,
        isCurrentTurn: isCurrentTurn,
        willPlay: willPlay,
      ),
    );
  }

  Widget _buildCompactOpponentPane({
    required int playerIndex,
    required String name,
    required int cardCount,
    required String identity,
    required bool isCurrentTurn,
    required bool willPlay,
  }) {
    final preview = _buildOpponentRecentPlay(playerIndex);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OpponentAreaWidget(
          name: name,
          cardCount: cardCount,
          identity: identity,
          isCurrentTurn: isCurrentTurn,
          willPlay: willPlay,
        ),
        if (preview != null) ...[const SizedBox(height: 6), preview],
      ],
    );
  }

  Widget? _buildOpponentRecentPlay(int playerIndex) {
    final cards = recentPlayByPlayer[playerIndex];
    if (cards == null || cards.isEmpty) return null;

    final label = recentPlayLabelByPlayer[playerIndex] ?? '最近出牌';
    final shownCards = cards.length > 5
        ? cards.sublist(cards.length - 5)
        : cards;

    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 62,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                for (int i = 0; i < shownCards.length; i++)
                  Positioned(
                    left: i * 23,
                    child: CardWidget(
                      card: shownCards[i],
                      width: 40,
                      height: 58,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
    this.primary = false,
  });

  final String label;
  final bool enabled;
  final VoidCallback onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final foreground = primary ? Colors.white : AppTheme.textPrimary;
    final background = primary
        ? AppTheme.accent
        : AppTheme.surfaceAlt.withValues(alpha: 0.58);

    return SizedBox(
      width: 104,
      height: 34,
      child: TextButton(
        onPressed: enabled ? onPressed : null,
        style: TextButton.styleFrom(
          foregroundColor: foreground,
          disabledForegroundColor: AppTheme.textSecondary.withValues(
            alpha: 0.48,
          ),
          backgroundColor: enabled
              ? background
              : AppTheme.surfaceAlt.withValues(alpha: 0.34),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
            side: BorderSide(
              color: primary
                  ? Colors.transparent
                  : AppTheme.textSecondary.withValues(alpha: 0.36),
            ),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _LandlordTopChipButton extends StatelessWidget {
  const _LandlordTopChipButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface.withValues(alpha: 0.82),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 38,
          child: Center(
            child: Icon(icon, color: AppTheme.textSecondary, size: 22),
          ),
        ),
      ),
    );
  }
}

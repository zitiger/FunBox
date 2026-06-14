import 'package:flutter/material.dart';

import '../../platform/games/game_manifest.dart';
import '../../platform/games/game_module.dart';
import 'models/game_result.dart';
import 'models/game_session.dart';
import 'pages/game_2048_start_page.dart';

class Game2048Module extends GameModule {
  const Game2048Module();

  @override
  GameManifest get manifest => const GameManifest(
    id: '2048',
    title: '2048',
    category: 'puzzle',
    iconAsset: 'games/2048/assets/images/icon.png',
    coverAsset: 'games/2048/assets/images/icon.png',
    supportsResume: true,
    supportedModes: ['classic'],
    sortOrder: 10,
    enabled: true,
  );

  @override
  Widget buildStartPage(BuildContext context) {
    return Game2048StartPage(module: this);
  }

  @override
  Widget buildRuleEntry(BuildContext context) {
    return Game2048StartPage(module: this, showRulesOnEntry: true);
  }

  @override
  GameSessionAdapter createSessionSerializer() => _Game2048SessionAdapter();

  @override
  GameResultAdapter createResultAdapter() => _Game2048ResultAdapter();
}

class _Game2048SessionAdapter extends GameSessionAdapter {
  const _Game2048SessionAdapter();

  @override
  Map<String, Object?> encode(Object? session) {
    if (session is GameSession) {
      return session.toJson();
    }
    return const <String, Object?>{};
  }

  @override
  Object? decode(Map<String, Object?> payload) {
    return GameSession.fromJson(payload);
  }
}

class _Game2048ResultAdapter extends GameResultAdapter {
  const _Game2048ResultAdapter();

  @override
  Map<String, Object?> toSummary(Object? result) {
    if (result is GameResult) {
      return result.toSummary();
    }
    return const <String, Object?>{};
  }
}

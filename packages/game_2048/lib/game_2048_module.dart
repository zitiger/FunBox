import 'package:flutter/material.dart';
import 'package:funbox_game_api/funbox_game_api.dart';

import 'models/game_result.dart';
import 'models/game_session.dart';
import 'pages/game_2048_start_page.dart';

class Game2048Module extends GameModule {
  const Game2048Module({required this.manifest});

  @override
  final GameManifest manifest;

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

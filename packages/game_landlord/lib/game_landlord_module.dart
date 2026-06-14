import 'package:flutter/material.dart';
import 'package:funbox_game_api/funbox_game_api.dart';

import 'logic/game_engine.dart';
import 'pages/landlord_start_page.dart';

class GameLandlordModule extends GameModule {
  const GameLandlordModule({required this.manifest});

  @override
  final GameManifest manifest;

  @override
  Widget buildStartPage(BuildContext context) {
    return LandlordStartPage(module: this);
  }

  @override
  Widget buildRuleEntry(BuildContext context) {
    return LandlordStartPage(module: this, showRulesOnEntry: true);
  }

  @override
  GameSessionAdapter createSessionSerializer() =>
      const _LandlordSessionAdapter();

  @override
  GameResultAdapter createResultAdapter() => const _LandlordResultAdapter();
}

class _LandlordSessionAdapter extends GameSessionAdapter {
  const _LandlordSessionAdapter();

  @override
  Map<String, Object?> encode(Object? session) {
    if (session is Map<String, Object?>) return session;
    return const <String, Object?>{};
  }

  @override
  Object? decode(Map<String, Object?> payload) {
    return GameSession.fromJson(payload).toJson();
  }
}

class _LandlordResultAdapter extends GameResultAdapter {
  const _LandlordResultAdapter();

  @override
  Map<String, Object?> toSummary(Object? result) {
    if (result is Map<String, Object?>) return result;
    return const <String, Object?>{};
  }
}

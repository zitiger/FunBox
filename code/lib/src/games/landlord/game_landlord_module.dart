import 'package:flutter/material.dart';
import '../../platform/games/game_manifest.dart';
import '../../platform/games/game_module.dart';
import 'logic/game_engine.dart';
import 'pages/landlord_start_page.dart';

class GameLandlordModule extends GameModule {
  const GameLandlordModule();

  @override
  GameManifest get manifest => const GameManifest(
        id: 'landlord',
        title: '\u6597\u5730\u4E3B',
        category: 'board',
        iconAsset: 'games/landlord/assets/images/icon.png',
        coverAsset: 'games/landlord/assets/images/icon.png',
        supportsResume: true,
        supportedModes: ['ai'],
        sortOrder: 30,
        enabled: true,
      );

  @override
  Widget buildStartPage(BuildContext context) {
    return LandlordStartPage(module: this);
  }

  @override
  Widget buildRuleEntry(BuildContext context) {
    return LandlordStartPage(module: this, showRulesOnEntry: true);
  }

  @override
  GameSessionAdapter createSessionSerializer() => _LandlordSessionAdapter();

  @override
  GameResultAdapter createResultAdapter() => _LandlordResultAdapter();
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

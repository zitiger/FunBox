import 'package:flutter/widgets.dart';

import 'game_manifest.dart';

abstract class GameModule {
  const GameModule();

  GameManifest get manifest;

  Widget buildStartPage(BuildContext context);

  Widget buildRuleEntry(BuildContext context);

  GameSessionAdapter createSessionSerializer();

  GameResultAdapter createResultAdapter();
}

abstract class GameSessionAdapter {
  const GameSessionAdapter();

  Map<String, Object?> encode(Object? session);

  Object? decode(Map<String, Object?> payload);
}

abstract class GameResultAdapter {
  const GameResultAdapter();

  Map<String, Object?> toSummary(Object? result);
}

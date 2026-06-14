import 'package:flutter/widgets.dart';

import 'game_manifest.dart';
import 'game_module.dart';
import 'placeholder_game_page.dart';

class StaticGameModule extends GameModule {
  const StaticGameModule({required this.manifest});

  @override
  final GameManifest manifest;

  @override
  Widget buildRuleEntry(BuildContext context) {
    return PlaceholderGamePage(
      manifest: manifest,
      title: '${manifest.title}规则',
      message: '统一游戏规则入口已接入，后续可在各自模块中替换为正式规则页面。',
    );
  }

  @override
  Widget buildStartPage(BuildContext context) {
    return PlaceholderGamePage(
      manifest: manifest,
      title: manifest.title,
      message: '这个小游戏已经通过可拔插模块接入大厅，后续可以在自己的目录里独立实现正式玩法。',
    );
  }

  @override
  GameResultAdapter createResultAdapter() => const NoopGameResultAdapter();

  @override
  GameSessionAdapter createSessionSerializer() =>
      const NoopGameSessionAdapter();
}

class NoopGameSessionAdapter extends GameSessionAdapter {
  const NoopGameSessionAdapter();

  @override
  Object? decode(Map<String, Object?> payload) => payload;

  @override
  Map<String, Object?> encode(Object? session) {
    if (session is Map<String, Object?>) {
      return session;
    }

    return const <String, Object?>{};
  }
}

class NoopGameResultAdapter extends GameResultAdapter {
  const NoopGameResultAdapter();

  @override
  Map<String, Object?> toSummary(Object? result) {
    if (result is Map<String, Object?>) {
      return result;
    }

    return const <String, Object?>{};
  }
}

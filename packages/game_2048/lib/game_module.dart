import 'package:funbox_game_api/funbox_game_api.dart';

import 'game_2048_module.dart';

GameModule createGameModule(GameManifest manifest) {
  return Game2048Module(manifest: manifest);
}

import 'package:funbox_game_api/funbox_game_api.dart';

import 'game_landlord_module.dart';

GameModule createGameModule(GameManifest manifest) {
  return GameLandlordModule(manifest: manifest);
}

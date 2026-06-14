import 'package:code/src/games/2048/game_2048_module.dart';
import 'package:code/src/games/landlord/game_landlord_module.dart';
import 'package:code/src/platform/games/game_manifest.dart';
import 'package:code/src/platform/games/game_module.dart';
import 'package:code/src/platform/games/static_game_module.dart';

final List<GameModule> generatedGameModules = [
  const Game2048Module(),
  const GameLandlordModule(),
  const StaticGameModule(
    manifest: GameManifest(
      id: 'gomoku',
      title: '\u4E94\u5B50\u68CB',
      category: 'board',
      iconAsset: 'games/gomoku/assets/images/icon.png',
      coverAsset: 'games/gomoku/assets/images/icon.png',
      supportsResume: true,
      supportedModes: ['ai', 'local'],
      sortOrder: 20,
      enabled: true,
    ),
  ),
  const StaticGameModule(
    manifest: GameManifest(
      id: 'minesweeper',
      title: '\u626B\u96F7',
      category: 'puzzle',
      iconAsset: 'games/minesweeper/assets/images/icon.png',
      coverAsset: 'games/minesweeper/assets/images/icon.png',
      supportsResume: true,
      supportedModes: ['classic'],
      sortOrder: 40,
      enabled: true,
    ),
  ),
  const StaticGameModule(
    manifest: GameManifest(
      id: 'snake',
      title: '\u8D2A\u5403\u86C7',
      category: 'casual',
      iconAsset: 'games/snake/assets/images/icon.png',
      coverAsset: 'games/snake/assets/images/icon.png',
      supportsResume: true,
      supportedModes: ['endless'],
      sortOrder: 50,
      enabled: true,
    ),
  ),
  const StaticGameModule(
    manifest: GameManifest(
      id: 'solitaire',
      title: '\u7EB8\u724C\u63A5\u9F99',
      category: 'board',
      iconAsset: 'games/solitaire/assets/images/icon.png',
      coverAsset: 'games/solitaire/assets/images/icon.png',
      supportsResume: true,
      supportedModes: ['classic'],
      sortOrder: 60,
      enabled: true,
    ),
  ),
  const StaticGameModule(
    manifest: GameManifest(
      id: 'airplane',
      title: '\u98DE\u673A\u5927\u6218',
      category: 'arcade',
      iconAsset: 'games/airplane/assets/images/icon.png',
      coverAsset: 'games/airplane/assets/images/icon.png',
      supportsResume: true,
      supportedModes: ['classic'],
      sortOrder: 70,
      enabled: true,
    ),
  ),
  const StaticGameModule(
    manifest: GameManifest(
      id: 'tetris',
      title: '\u4FC4\u7F57\u65AF\u65B9\u5757',
      category: 'arcade',
      iconAsset: 'games/tetris/assets/images/icon.png',
      coverAsset: 'games/tetris/assets/images/icon.png',
      supportsResume: true,
      supportedModes: ['classic'],
      sortOrder: 80,
      enabled: true,
    ),
  ),
];

import 'package:code/src/games/2048/game_2048_module.dart';
import 'package:code/src/platform/games/game_manifest.dart';
import 'package:code/src/platform/games/game_module.dart';
import 'package:code/src/platform/games/static_game_module.dart';

final List<GameModule> generatedGameModules = [
  const Game2048Module(),
  const StaticGameModule(
    manifest: GameManifest(
      id: 'gomoku',
      title: '五子棋',
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
      id: 'landlord',
      title: '斗地主',
      category: 'board',
      iconAsset: 'games/landlord/assets/images/icon.png',
      coverAsset: 'games/landlord/assets/images/icon.png',
      supportsResume: true,
      supportedModes: ['ai'],
      sortOrder: 30,
      enabled: true,
    ),
  ),
  const StaticGameModule(
    manifest: GameManifest(
      id: 'minesweeper',
      title: '扫雷',
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
      title: '贪吃蛇',
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
      title: '纸牌接龙',
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
      title: '飞机大战',
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
      title: '俄罗斯方块',
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

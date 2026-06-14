import 'package:code/src/platform/games/game_manifest.dart';
import 'package:code/src/platform/games/game_module.dart';
import 'package:code/src/platform/games/static_game_module.dart';
import 'package:game_2048/game_module.dart' as game_2048_module;
import 'package:game_landlord/game_module.dart' as landlord_module;

final List<GameModule> generatedGameModules = [
  game_2048_module.createGameModule(
    const GameManifest(
      id: '2048',
      title: '2048',
      category: 'puzzle',
      packageName: 'game_2048',
      iconAsset: 'assets/images/icon.png',
      coverAsset: 'assets/images/icon.png',
      supportsResume: true,
      supportedModes: ['classic'],
      sortOrder: 10,
      enabled: true,
    ),
  ),
  const StaticGameModule(
    manifest: GameManifest(
      id: 'gomoku',
      title: '五子棋',
      category: 'board',
      packageName: 'game_gomoku',
      iconAsset: 'assets/images/icon.png',
      coverAsset: 'assets/images/icon.png',
      supportsResume: true,
      supportedModes: ['ai', 'local'],
      sortOrder: 20,
      enabled: true,
    ),
  ),
  landlord_module.createGameModule(
    const GameManifest(
      id: 'landlord',
      title: '斗地主',
      category: 'board',
      packageName: 'game_landlord',
      iconAsset: 'assets/images/icon.png',
      coverAsset: 'assets/images/icon.png',
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
      packageName: 'game_minesweeper',
      iconAsset: 'assets/images/icon.png',
      coverAsset: 'assets/images/icon.png',
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
      packageName: 'game_snake',
      iconAsset: 'assets/images/icon.png',
      coverAsset: 'assets/images/icon.png',
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
      packageName: 'game_solitaire',
      iconAsset: 'assets/images/icon.png',
      coverAsset: 'assets/images/icon.png',
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
      packageName: 'game_airplane',
      iconAsset: 'assets/images/icon.png',
      coverAsset: 'assets/images/icon.png',
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
      packageName: 'game_tetris',
      iconAsset: 'assets/images/icon.png',
      coverAsset: 'assets/images/icon.png',
      supportsResume: true,
      supportedModes: ['classic'],
      sortOrder: 80,
      enabled: true,
    ),
  ),
];

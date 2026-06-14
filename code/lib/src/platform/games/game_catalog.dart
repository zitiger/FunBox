import 'package:flutter/material.dart';

import '../../models/home_models.dart';
import 'game_module.dart';

class GameCatalog {
  GameCatalog({
    required List<GameModule> modules,
    List<String>? recentGameIds,
    List<String>? favoriteGameIds,
    Map<String, int>? progressByGameId,
  }) : _modules = List.unmodifiable(
         modules.where((module) => module.manifest.enabled).toList()..sort(
           (a, b) => a.manifest.sortOrder.compareTo(b.manifest.sortOrder),
         ),
       ),
       _recentGameIds = List.unmodifiable(
         recentGameIds ??
             const ['landlord', '2048', 'snake', 'minesweeper', 'gomoku'],
       ),
       _favoriteGameIds = List.unmodifiable(
         favoriteGameIds ?? const ['2048', 'gomoku', 'landlord'],
       ),
       _progressByGameId = Map.unmodifiable(
         progressByGameId ??
             const {
               '2048': 68,
               'airplane': 35,
               'gomoku': 72,
               'landlord': 75,
               'minesweeper': 60,
               'snake': 54,
               'solitaire': 48,
               'tetris': 42,
             },
       );

  final List<GameModule> _modules;
  final List<String> _recentGameIds;
  final List<String> _favoriteGameIds;
  final Map<String, int> _progressByGameId;

  static const Map<String, String> _categoryLabels = {
    'board': '棋牌',
    'puzzle': '益智',
    'casual': '休闲',
    'arcade': '街机',
  };

  static const Map<String, List<Color>> _categoryColors = {
    'board': [Color(0xFFAD7C45), Color(0xFF6A472B)],
    'puzzle': [Color(0xFF6D5DFF), Color(0xFF3D5BD7)],
    'casual': [Color(0xFF7EE0FF), Color(0xFF2DA985)],
    'arcade': [Color(0xFFFFA33D), Color(0xFFC9631B)],
  };

  List<GameModule> get modules => _modules;

  GameModule get featuredGame => byId('landlord') ?? _modules.first;

  List<GameCategoryChipData> get categoryChips {
    final categories = <GameCategoryChipData>[
      const GameCategoryChipData(id: 'all', label: '全部'),
    ];

    for (final entry in _categoryLabels.entries) {
      if (_modules.any((module) => module.manifest.category == entry.key)) {
        categories.add(GameCategoryChipData(id: entry.key, label: entry.value));
      }
    }

    return categories;
  }

  HomeFeatureCardData get featureCard {
    final module = featuredGame;
    return HomeFeatureCardData(
      title: module.manifest.title,
      subtitle: '离线也能随时开一局',
      progress: (_progressByGameId[module.manifest.id] ?? 0) / 100,
      buttonLabel: module.manifest.supportsResume ? '继续游戏' : '开始游戏',
      imagePath: module.manifest.coverAsset,
    );
  }

  List<RecentGameData> get recentGames => _resolveModules(_recentGameIds)
      .map(
        (module) => RecentGameData(
          title: module.manifest.title,
          imagePath: module.manifest.iconAsset,
        ),
      )
      .toList();

  List<GameCardData> cardsForCategory(String categoryId) {
    final source = categoryId == 'all'
        ? _modules
        : _modules
              .where((module) => module.manifest.category == categoryId)
              .toList();

    return source.map(_toCardData).toList();
  }

  List<GameCardData> get favoriteCards =>
      _resolveModules(_favoriteGameIds).map(_toCardData).toList();

  GameModule? byId(String id) {
    for (final module in _modules) {
      if (module.manifest.id == id) {
        return module;
      }
    }

    return null;
  }

  List<GameModule> _resolveModules(List<String> ids) {
    return ids.map(byId).whereType<GameModule>().toList();
  }

  GameCardData _toCardData(GameModule module) {
    final categoryId = module.manifest.category;
    return GameCardData(
      gameId: module.manifest.id,
      title: module.manifest.title,
      categoryId: categoryId,
      categoryLabel: _categoryLabels[categoryId] ?? categoryId,
      imagePath: module.manifest.iconAsset,
      progress: _progressByGameId[module.manifest.id] ?? 0,
      colors:
          _categoryColors[categoryId] ??
          const [Color(0xFF373E88), Color(0xFF25295E)],
    );
  }
}

import 'package:flutter/material.dart';

class HomeFeatureCardData {
  const HomeFeatureCardData({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.buttonLabel,
    required this.imagePath,
    required this.packageName,
  });

  final String title;
  final String subtitle;
  final double progress;
  final String buttonLabel;
  final String imagePath;
  final String packageName;
}

class RecentGameData {
  const RecentGameData({
    required this.title,
    required this.imagePath,
    required this.packageName,
  });

  final String title;
  final String imagePath;
  final String packageName;
}

class GameCategoryChipData {
  const GameCategoryChipData({required this.id, required this.label});

  final String id;
  final String label;
}

class GameCardData {
  const GameCardData({
    required this.gameId,
    required this.title,
    required this.categoryId,
    required this.categoryLabel,
    required this.imagePath,
    required this.packageName,
    required this.progress,
    required this.colors,
    this.isMoreCard = false,
  });

  final String gameId;
  final String title;
  final String categoryId;
  final String categoryLabel;
  final String imagePath;
  final String packageName;
  final int progress;
  final List<Color> colors;
  final bool isMoreCard;
}

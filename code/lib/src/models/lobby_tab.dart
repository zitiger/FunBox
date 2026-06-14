import 'package:flutter/material.dart';

enum LobbyTab {
  home('首页', Icons.home_rounded),
  category('分类', Icons.grid_view_rounded),
  favorites('收藏', Icons.star_rounded),
  settings('设置', Icons.settings_rounded);

  const LobbyTab(this.label, this.icon);

  final String label;
  final IconData icon;
}

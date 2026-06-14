import 'package:flutter/material.dart';

import '../generated/game_registry.g.dart';
import '../models/lobby_tab.dart';
import '../platform/games/game_catalog.dart';
import '../widgets/bottom_nav_shell.dart';
import 'category_page.dart';
import 'favorites_page.dart';
import 'home_page.dart';
import 'placeholder_page.dart';

class HomeShellPage extends StatefulWidget {
  const HomeShellPage({super.key});

  @override
  State<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends State<HomeShellPage> {
  LobbyTab selectedTab = LobbyTab.home;
  late final GameCatalog catalog = GameCatalog(modules: generatedGameModules);

  late final Map<LobbyTab, Widget> pages = {
    LobbyTab.home: HomePage(catalog: catalog),
    LobbyTab.category: CategoryPage(catalog: catalog),
    LobbyTab.favorites: FavoritesPage(catalog: catalog),
    LobbyTab.settings: const PlaceholderPage(
      title: '设置',
      message: '设置内容建设中',
      icon: Icons.tune_rounded,
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: KeyedSubtree(
          key: ValueKey(selectedTab),
          child: pages[selectedTab]!,
        ),
      ),
      bottomNavigationBar: BottomNavShell(
        selectedTab: selectedTab,
        onSelected: (tab) {
          setState(() {
            selectedTab = tab;
          });
        },
      ),
    );
  }
}

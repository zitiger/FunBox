import 'package:flutter/material.dart';

import '../models/lobby_tab.dart';
import '../theme/app_theme.dart';

class BottomNavShell extends StatelessWidget {
  const BottomNavShell({
    super.key,
    required this.selectedTab,
    required this.onSelected,
  });

  final LobbyTab selectedTab;
  final ValueChanged<LobbyTab> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.navSurface.withValues(alpha: 0.98),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.24),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: LobbyTab.values.map((tab) {
            final isSelected = tab == selectedTab;
            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => onSelected(tab),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        tab.icon,
                        color: isSelected
                            ? AppTheme.accent
                            : Colors.white.withValues(alpha: 0.68),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tab.label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? AppTheme.textPrimary
                              : Colors.white.withValues(alpha: 0.68),
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

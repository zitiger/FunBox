import 'package:flutter/material.dart';
import '../app_theme.dart';

class OpponentAreaWidget extends StatelessWidget {
  const OpponentAreaWidget({
    super.key,
    required this.name,
    required this.cardCount,
    required this.identity,
    this.isCurrentTurn = false,
    this.willPlay = false,
  });

  final String name;
  final int cardCount;
  final String identity;
  final bool isCurrentTurn;
  final bool willPlay;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: isCurrentTurn
            ? AppTheme.surface.withValues(alpha: 0.92)
            : AppTheme.surface.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCurrentTurn
              ? AppTheme.accent.withValues(alpha: 0.95)
              : Colors.white.withValues(alpha: 0.05),
          width: isCurrentTurn ? 1.8 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isCurrentTurn ? 0.22 : 0.12),
            blurRadius: isCurrentTurn ? 16 : 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: AppTheme.surfaceAlt,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name.characters.first,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 7),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              _IdentityPill(identity: identity),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '剩余 $cardCount 张',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _IdentityPill extends StatelessWidget {
  const _IdentityPill({required this.identity});

  final String identity;

  @override
  Widget build(BuildContext context) {
    final isLandlord = identity == '地主';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isLandlord
            ? AppTheme.accent.withValues(alpha: 0.26)
            : AppTheme.success.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        identity,
        style: TextStyle(
          color: isLandlord ? AppTheme.accent : AppTheme.success,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

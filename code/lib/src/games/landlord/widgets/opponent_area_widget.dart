import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrentTurn
            ? AppTheme.surface.withValues(alpha: 0.9)
            : AppTheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: isCurrentTurn
            ? Border.all(color: AppTheme.accent, width: 2)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.surfaceAlt,
            child: Text(
              name[0],
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(name,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: identity == '\u5730\u4E3B'
                          ? AppTheme.accent.withValues(alpha: 0.25)
                          : AppTheme.success.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(identity,
                        style: TextStyle(
                            color: identity == '\u5730\u4E3B'
                                ? AppTheme.accent
                                : AppTheme.success,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('\u5269\u4F59 $cardCount \u5F20',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12)),
            ],
          ),
          if (isCurrentTurn) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(willPlay ? '\u51FA\u724C' : '\u601D\u8003\u4E2D...',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ],
      ),
    );
  }
}

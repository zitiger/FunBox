import 'package:flutter/material.dart';

import '../app_theme.dart';

class Game2048Backdrop extends StatelessWidget {
  const Game2048Backdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.backgroundTop, AppTheme.backgroundBottom],
        ),
      ),
      child: Stack(
        children: [
          const _BackdropOrnaments(),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class Game2048EmblemFrame extends StatelessWidget {
  const Game2048EmblemFrame({
    super.key,
    required this.assetPath,
    required this.packageName,
    this.size = 176,
    this.padding = 16,
    this.innerRadius = 30,
  });

  final String assetPath;
  final String packageName;
  final double size;
  final double padding;
  final double innerRadius;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF3B5EA6),
              Color(0xFF17285A),
              Color(0xFF0E1838),
            ],
            stops: [0.0, 0.58, 1.0],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF69B8FF).withValues(alpha: 0.38),
              blurRadius: 28,
              spreadRadius: 2,
              offset: const Offset(0, 0),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.34),
              blurRadius: 28,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(innerRadius),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF172A60),
                  Color(0xFF101A41),
                ],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(innerRadius - 8),
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF7FD9FF).withValues(alpha: 0.15),
                            Colors.transparent,
                          ],
                          radius: 0.95,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Image.asset(
                      assetPath,
                      package: packageName,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BackdropOrnaments extends StatelessWidget {
  const _BackdropOrnaments();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            left: -40,
            top: -10,
            child: _GlowBlob(
              size: 220,
              color: AppTheme.accent.withValues(alpha: 0.12),
            ),
          ),
          Positioned(
            right: -70,
            top: 130,
            child: _GlowBlob(
              size: 240,
              color: AppTheme.success.withValues(alpha: 0.10),
            ),
          ),
          Positioned(
            left: 24,
            top: 180,
            child: _GlowBlob(
              size: 120,
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          Positioned(
            right: 18,
            bottom: 240,
            child: _GlowBlob(
              size: 160,
              color: AppTheme.accentSoft.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: 0.01),
          ],
        ),
      ),
    );
  }
}

class Game2048IconButton extends StatelessWidget {
  const Game2048IconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 48,
    this.iconSize = 24,
    this.backgroundColor,
    this.borderColor,
    this.iconColor = AppTheme.textPrimary,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final double iconSize;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(size / 4),
        onTap: onPressed,
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor ?? AppTheme.navSurface.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(size / 4),
            border: Border.all(
              color: borderColor ?? Colors.white.withValues(alpha: 0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.24),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(icon, color: iconColor, size: iconSize),
        ),
      ),
    );

    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

class Game2048Button extends StatelessWidget {
  const Game2048Button({
    super.key,
    required this.label,
    required this.onPressed,
    this.filled = true,
    this.leadingIcon,
    this.trailingIcon,
    this.height = 56,
    this.foregroundColor = AppTheme.textPrimary,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool filled;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final double height;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final style = filled
        ? ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accent,
            foregroundColor: Colors.white,
            shadowColor: AppTheme.accent.withValues(alpha: 0.45),
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          )
        : OutlinedButton.styleFrom(
            foregroundColor: foregroundColor ?? AppTheme.textPrimary,
            side: BorderSide(
              color: (foregroundColor ?? AppTheme.textPrimary).withValues(alpha: 0.35),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          );

    final button = filled
        ? ElevatedButton(
            onPressed: onPressed,
            style: style,
            child: _ButtonContent(
              label: label,
              leadingIcon: leadingIcon,
              trailingIcon: trailingIcon,
            ),
          )
        : OutlinedButton(
            onPressed: onPressed,
            style: style,
            child: _ButtonContent(
              label: label,
              leadingIcon: leadingIcon,
              trailingIcon: trailingIcon,
            ),
          );

    return SizedBox(width: double.infinity, height: height, child: button);
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    this.leadingIcon,
    this.trailingIcon,
  });

  final String label;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    if (leadingIcon != null) {
      children.add(Icon(leadingIcon, size: 20));
      children.add(const SizedBox(width: 10));
    }
    children.add(Text(
      label,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
    ));
    if (trailingIcon != null) {
      children.add(const SizedBox(width: 10));
      children.add(Icon(trailingIcon, size: 20));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
}

class Game2048StatChip extends StatelessWidget {
  const Game2048StatChip({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.tint,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.24),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: tint),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: tint,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Game2048BoardFrame extends StatelessWidget {
  const Game2048BoardFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.boardSurface, AppTheme.boardSurfaceDeep],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: child,
    );
  }
}

class Game2048TileCell extends StatelessWidget {
  const Game2048TileCell({super.key, required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    final colors = _paletteForValue(value);
    final textColor = value == 0
        ? Colors.transparent
        : value <= 4
            ? const Color(0xFF31415F)
            : Colors.white;
    final textSize = _fontSizeForValue(value);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.last.withValues(alpha: value == 0 ? 0.05 : 0.32),
            blurRadius: value == 0 ? 0 : 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 140),
          style: TextStyle(
            color: textColor,
            fontSize: textSize,
            fontWeight: FontWeight.w900,
            letterSpacing: value >= 1024 ? -1 : -0.3,
            shadows: value == 0
                ? const []
                : [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Text(value == 0 ? '' : value.toString()),
        ),
      ),
    );
  }

  static List<Color> _paletteForValue(int value) {
    switch (value) {
      case 2:
        return const [Color(0xFF4F648D), Color(0xFF3D5076)];
      case 4:
        return const [Color(0xFFBDAF93), Color(0xFF988875)];
      case 8:
        return const [Color(0xFFF1A358), Color(0xFFE07F26)];
      case 16:
        return const [Color(0xFFF07C5B), Color(0xFFD85C3E)];
      case 32:
        return const [Color(0xFFF2AD44), Color(0xFFE09122)];
      case 64:
        return const [Color(0xFFE46B3E), Color(0xFFC94E2A)];
      case 128:
        return const [Color(0xFFE9D06A), Color(0xFFD7B144)];
      case 256:
        return const [Color(0xFFD7C95A), Color(0xFFB9A13A)];
      case 512:
        return const [Color(0xFFD3B24A), Color(0xFFB78D24)];
      case 1024:
        return const [Color(0xFF78DCC8), Color(0xFF39B89F)];
      case 2048:
        return const [Color(0xFF7DE8BB), Color(0xFF33BF93)];
      default:
        return const [AppTheme.cellSurface, AppTheme.cellSurfaceAlt];
    }
  }

  static double _fontSizeForValue(int value) {
    if (value == 0) return 0;
    if (value < 100) return 28;
    if (value < 1000) return 23;
    if (value < 10000) return 19;
    return 15;
  }
}

class Game2048RuleCard extends StatelessWidget {
  const Game2048RuleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.detail,
    required this.tint,
  });

  final IconData icon;
  final String title;
  final String detail;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: AppTheme.surface.withValues(alpha: 0.92),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  tint.withValues(alpha: 0.24),
                  tint.withValues(alpha: 0.08),
                ],
              ),
              border: Border.all(color: tint.withValues(alpha: 0.18)),
            ),
            child: Icon(icon, size: 36, color: tint),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  detail,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Game2048PageTitle extends StatelessWidget {
  const Game2048PageTitle({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 40,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            shadows: [
              Shadow(
                color: Colors.black54,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 12),
          Text(
            subtitle!,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}

class Game2048SectionDivider extends StatelessWidget {
  const Game2048SectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppTheme.divider,
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppTheme.textTertiary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: AppTheme.divider,
          ),
        ),
      ],
    );
  }
}

class Game2048HintIconRow extends StatelessWidget {
  const Game2048HintIconRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MiniKey(icon: Icons.arrow_back_rounded),
        const SizedBox(width: 4),
        _MiniKey(icon: Icons.arrow_downward_rounded),
        const SizedBox(width: 4),
        _MiniKey(icon: Icons.arrow_forward_rounded),
        const SizedBox(width: 4),
        _MiniKey(icon: Icons.arrow_upward_rounded),
      ],
    );
  }
}

class _MiniKey extends StatelessWidget {
  const _MiniKey({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: AppTheme.navSurface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Icon(icon, size: 13, color: AppTheme.textSecondary),
    );
  }
}

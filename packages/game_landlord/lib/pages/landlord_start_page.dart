import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../game_landlord_module.dart';
import 'landlord_play_page.dart';
import 'landlord_rules_page.dart';

class LandlordStartPage extends StatefulWidget {
  const LandlordStartPage({super.key, required this.module});

  final GameLandlordModule module;

  @override
  State<LandlordStartPage> createState() => _LandlordStartPageState();
}

class _LandlordStartPageState extends State<LandlordStartPage> {
  static Map<String, Object?>? _savedSession;

  bool get hasSession => _savedSession != null;

  void _startNewGame() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => LandlordPlayPage(
          module: widget.module,
          onSessionSaved: (session) {
            _savedSession = session;
          },
        ),
      ),
    );
  }

  void _continueGame() {
    if (!hasSession) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => LandlordPlayPage(
          module: widget.module,
          resumeSession: _savedSession,
          onSessionSaved: (session) {
            _savedSession = session;
          },
        ),
      ),
    );
  }

  void _openRules() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LandlordRulesPage(module: widget.module),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LandlordBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: Column(
              children: [
                Row(
                  children: [
                    LandlordIconButton(
                      icon: Icons.arrow_back_rounded,
                      tooltip: '返回',
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      },
                    ),
                  ],
                ),
                const Spacer(flex: 2),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    children: [
                      LandlordEmblemFrame(
                        assetPath: widget.module.manifest.coverAsset,
                        packageName: widget.module.manifest.packageName,
                        size: 182,
                        padding: 14,
                        innerRadius: 32,
                      ),
                      const SizedBox(height: 24),
                      const LandlordPageTitle(
                        title: '斗地主',
                        subtitle: '经典三人扑克对战，先出完手牌的一方获胜。',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                const LandlordSectionDivider(),
                const SizedBox(height: 22),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    children: [
                      LandlordButton(
                        label: '开始新局',
                        onPressed: _startNewGame,
                        leadingIcon: Icons.play_arrow_rounded,
                      ),
                      if (hasSession) ...[
                        const SizedBox(height: 14),
                        LandlordButton(
                          label: '继续游戏',
                          onPressed: _continueGame,
                          filled: false,
                          leadingIcon: Icons.history_rounded,
                          foregroundColor: AppTheme.accentSoft,
                        ),
                      ],
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: _openRules,
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.textSecondary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.menu_book_rounded, size: 20),
                          label: const Text(
                            '游戏规则',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LandlordBackdrop extends StatelessWidget {
  const LandlordBackdrop({super.key, required this.child});

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

class LandlordEmblemFrame extends StatelessWidget {
  const LandlordEmblemFrame({
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
            colors: [Color(0xFF3B5EA6), Color(0xFF17285A), Color(0xFF0E1838)],
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
                colors: [Color(0xFF172A60), Color(0xFF101A41)],
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

class LandlordIconButton extends StatelessWidget {
  const LandlordIconButton({
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
            color:
                backgroundColor ?? AppTheme.navSurface.withValues(alpha: 0.95),
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

class LandlordButton extends StatelessWidget {
  const LandlordButton({
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
              color: (foregroundColor ?? AppTheme.textPrimary).withValues(
                alpha: 0.35,
              ),
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
      children.add(const SizedBox(width: 2));
      children.add(Icon(leadingIcon, size: 20));
      children.add(const SizedBox(width: 10));
    }
    children.add(
      Text(
        label,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
    );
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

class LandlordPageTitle extends StatelessWidget {
  const LandlordPageTitle({super.key, required this.title, this.subtitle});

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
            textAlign: TextAlign.center,
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

class LandlordSectionDivider extends StatelessWidget {
  const LandlordSectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: const Color(0x2E7F90CB))),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppTheme.textTertiary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Expanded(child: Container(height: 1, color: const Color(0x2E7F90CB))),
      ],
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
          colors: [color, color.withValues(alpha: 0.01)],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../game_landlord_module.dart';
import 'landlord_play_page.dart';

class LandlordStartPage extends StatefulWidget {
  const LandlordStartPage({
    super.key,
    required this.module,
    this.showRulesOnEntry = false,
  });

  final GameLandlordModule module;
  final bool showRulesOnEntry;

  @override
  State<LandlordStartPage> createState() => _LandlordStartPageState();
}

class _LandlordStartPageState extends State<LandlordStartPage> {
  Map<String, Object?>? _savedSession;

  @override
  void initState() {
    super.initState();
    if (widget.showRulesOnEntry) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showRules(context);
      });
    }
  }

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

  void _showRules(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text(
          '\u6597\u5730\u4E3B\u89C4\u5219',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _RuleLine('\u4F7F\u7528\u4E00\u526F54\u5F20\u724C\uFF08\u542B\u5927\u5C0F\u738B\uFF09\uFF0C\u75313\u4EBA\u53C2\u4E0E\u3002'),
              SizedBox(height: 4),
              _RuleLine('\u7CFB\u7EDF\u968F\u673A\u6307\u5B9A\u4E00\u540D\u201C\u5730\u4E3B\u201D\uFF0C\u5730\u4E3B\u83B7\u5F973\u5F20\u5E95\u724C\u3002'),
              SizedBox(height: 4),
              _RuleLine('\u5730\u4E3B\u5148\u51FA\u724C\uFF0C\u9006\u65F6\u9488\u8F6E\u6D41\uFF0C\u73A9\u5BB6\u53EF\u9009\u62E9\u51FA\u724C\u6216\u4E0D\u51FA\uFF08Pass\uFF09\u3002'),
              SizedBox(height: 4),
              _RuleLine('\u51FA\u724C\u5FC5\u987B\u7B26\u5408\u724C\u578B\uFF0C\u4E14\u5FC5\u987B\u5927\u4E8E\u4E0A\u5BB6\u7684\u724C\uFF08\u70B8\u5F39/\u706B\u7BAD\u9664\u5916\uFF09\u3002'),
              SizedBox(height: 4),
              _RuleLine('\u724C\u578B\uFF1A\u5355\u5F20\u3001\u5BF9\u5B50\u3001\u4E09\u6761\u3001\u4E09\u5E26\u4E00\u3001\u4E09\u5E26\u4E8C\u3001\u987A\u5B50\u3001\u8FDE\u5BF9\u3001\u98DE\u673A\u3001\u70B8\u5F39\u3001\u706B\u7BAD\u3002'),
              SizedBox(height: 4),
              _RuleLine('\u706B\u7BAD\uFF08\u5927\u5C0F\u738B\uFF09\u6700\u5927\uFF0C\u70B8\u5F39\u6B21\u4E4B\uFF0C\u70B8\u5F39\u53EF\u5927\u8FC7\u4EFB\u4F55\u666E\u901A\u724C\u578B\u3002'),
              SizedBox(height: 4),
              _RuleLine('\u6700\u5148\u51FA\u5B8C\u6240\u6709\u724C\u7684\u4E00\u65B9\u83B7\u80DC\u3002'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('\u77E5\u9053\u4E86',
                style: TextStyle(color: AppTheme.accent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.backgroundTop, AppTheme.backgroundBottom],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                    ),
                  ],
                ),
                const Spacer(flex: 2),
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.asset(
                    widget.module.manifest.coverAsset,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '\u6597\u5730\u4E3B',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '\u7ECF\u5178\u4E09\u4EBA\u6251\u514B\u724C\u6E38\u620F',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const Spacer(flex: 2),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _startNewGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      '\u5F00\u59CB\u65B0\u5C40',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                if (hasSession) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _continueGame,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.accentSoft,
                        side: const BorderSide(color: AppTheme.accentSoft),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text(
                        '\u7EE7\u7EED\u6E38\u620F',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => _showRules(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      side: const BorderSide(color: AppTheme.textSecondary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text(
                      '\u6E38\u620F\u89C4\u5219',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
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

class _RuleLine extends StatelessWidget {
  const _RuleLine(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('\u2022 ',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        Expanded(
          child: Text(text,
              style:
                  const TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
        ),
      ],
    );
  }
}

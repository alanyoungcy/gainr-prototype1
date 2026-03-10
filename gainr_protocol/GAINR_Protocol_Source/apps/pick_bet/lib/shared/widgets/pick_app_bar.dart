import 'package:flutter/material.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class PickAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String activePath;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const PickAppBar({
    super.key,
    this.activePath = '/',
    this.scaffoldKey,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isSmall = constraints.maxWidth < 900;
        return Container(
          height: 70,
          padding: EdgeInsets.symmetric(horizontal: isSmall ? 16 : 48),
          decoration: const BoxDecoration(
            color: Colors.black,
            border: Border(bottom: BorderSide(color: Colors.white10)),
          ),
          child: Row(
            children: [
              if (isSmall) ...[
                IconButton(
                  icon: const Icon(LucideIcons.menu, color: Colors.white70),
                  onPressed: () => scaffoldKey?.currentState?.openDrawer(),
                ),
                const SizedBox(width: 8),
              ],
              // Logo
              InkWell(
                onTap: () => context.go('/'),
                child: Row(
                  children: [
                    AnimatedGradientBorder(
                      borderWidth: 2,
                      borderRadius: 8,
                      colors: const [
                        AppTheme.neonOrange,
                        AppTheme.neonMagenta,
                        AppTheme.neonCyan,
                        AppTheme.neonOrange,
                      ],
                      duration: const Duration(seconds: 4),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Icon(LucideIcons.terminal,
                              color: AppTheme.neonOrange, size: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (!isSmall)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          NeonText(
                            text: 'PICK.BET',
                            glowColor: AppTheme.neonOrange,
                            glowRadius: 6,
                            style: AppTextStyles.h1.copyWith(
                              fontSize: 20,
                              letterSpacing: 2,
                              height: 1.0,
                            ),
                          ),
                          const _BlinkingOperationalText(),
                        ],
                      ),
                  ],
                ),
              ),
              const Spacer(),
              // Nav Links
              if (!isSmall) ...[
                _NavLink(
                  label: 'LEADERBOARD',
                  path: '/',
                  isActive: activePath == '/',
                ),
                const SizedBox(width: 32),
                _NavLink(
                  label: 'HISTORY',
                  path: '/history',
                  isActive: activePath == '/history',
                ),
                const SizedBox(width: 32),
                _NavLink(
                  label: 'MARKET_DATA',
                  path: '/market-data',
                  isActive: activePath == '/market-data',
                ),
                const SizedBox(width: 32),
                _NavLink(
                  label: 'SIGNALS_API',
                  path: '/signals-api',
                  isActive: activePath == '/signals-api',
                ),
                const SizedBox(width: 48),
              ],
              // Action
              FittedBox(
                fit: BoxFit.scaleDown,
                child: PickHeaderButton(
                  label: isSmall ? 'CONNECT' : 'CONNECT_WALLET',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'WALLET_CONNECT_INITIATED… SCANNING_PROVIDERS',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1),
                        ),
                        backgroundColor: AppTheme.neonOrange,
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final String? path;
  final bool isActive;

  const _NavLink({
    required this.label,
    this.path,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: path != null ? () => context.go(path!) : null,
      hoverColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style: TextStyle(
                color: isActive ? AppTheme.neonOrange : Colors.white70,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                letterSpacing: 1,
              )),
          if (isActive) ...[
            const SizedBox(height: 4),
            Container(width: 40, height: 2, color: AppTheme.neonOrange),
          ],
        ],
      ),
    );
  }
}

class _BlinkingOperationalText extends StatefulWidget {
  const _BlinkingOperationalText();

  @override
  _BlinkingOperationalTextState createState() =>
      _BlinkingOperationalTextState();
}

class _BlinkingOperationalTextState extends State<_BlinkingOperationalText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: const Text('GAINR PROTOCOL',
          style: TextStyle(
            color: AppTheme.neonOrange,
            fontSize: 8,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          )),
    );
  }
}

class PickHeaderButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const PickHeaderButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  State<PickHeaderButton> createState() => _PickHeaderButtonState();
}

class _PickHeaderButtonState extends State<PickHeaderButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: widget.isPrimary
                  ? (_isHovered
                      ? AppTheme.neonOrange.withValues(alpha: 0.8)
                      : AppTheme.neonOrange)
                  : Colors.transparent,
              border: Border.all(color: AppTheme.neonOrange),
              borderRadius: BorderRadius.circular(4),
              boxShadow: _isHovered && widget.isPrimary
                  ? [
                      BoxShadow(
                        color: AppTheme.neonOrange.withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      )
                    ]
                  : [],
            ),
            child: Text(widget.label,
                style: TextStyle(
                  color: widget.isPrimary ? Colors.black : AppTheme.neonOrange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1,
                )),
          ),
        ),
      ),
    );
  }
}

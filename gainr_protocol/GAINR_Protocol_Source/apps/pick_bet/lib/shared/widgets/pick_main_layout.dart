import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'package:pick_bet/shared/widgets/pick_app_bar.dart';
import 'package:pick_bet/shared/widgets/pick_bottom_nav_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';

class PickMainLayout extends ConsumerWidget {
  final Widget child;
  final String activePath;

  const PickMainLayout({
    super.key,
    required this.child,
    required this.activePath,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.black,
      drawer: _buildPickDrawer(context),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          if (MediaQuery.sizeOf(context).width < GainrBreakpoints.mobile) {
            return PickBottomNavBar(activePath: activePath);
          }
          return const SizedBox.shrink();
        },
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: IgnorePointer(
              child: FloatingParticles(
                particleCount: 20,
                particleColor: AppTheme.neonOrange,
              ),
            ),
          ),
          Column(
            children: [
              PickAppBar(
                activePath: activePath,
                scaffoldKey: scaffoldKey,
              ),
              Expanded(
                child: KeyedSubtree(
                  key: ValueKey(activePath),
                  child: child,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPickDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      width: 280,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D0F).withValues(alpha: 0.9),
            border: const Border(right: BorderSide(color: Colors.white10)),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.neonOrange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppTheme.neonOrange.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Icon(LucideIcons.terminal,
                            color: AppTheme.neonOrange, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'PICK.BET',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white10, height: 1),
                const SizedBox(height: 24),
                _DrawerItem(
                  icon: LucideIcons.trophy,
                  label: 'LEADERBOARD',
                  isActive: activePath == '/',
                  onTap: () {
                    context.go('/');
                    context.pop();
                  },
                ),
                _DrawerItem(
                  icon: LucideIcons.history,
                  label: 'HISTORY',
                  isActive: activePath == '/history',
                  onTap: () {
                    context.go('/history');
                    context.pop();
                  },
                ),
                _DrawerItem(
                  icon: LucideIcons.chart_bar,
                  label: 'MARKET_DATA',
                  isActive: activePath == '/market-data',
                  onTap: () {
                    context.go('/market-data');
                    context.pop();
                  },
                ),
                _DrawerItem(
                  icon: LucideIcons.code,
                  label: 'SIGNALS_API',
                  isActive: activePath == '/signals-api',
                  onTap: () {
                    context.go('/signals-api');
                    context.pop();
                  },
                ),
                const Spacer(),
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: NeonText(
                    text: 'GAINR_PROTOCOL_v1.2',
                    glowColor: AppTheme.neonOrange,
                    glowRadius: 4,
                    style: TextStyle(
                      color: Colors.white24,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.neonOrange.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isActive
                ? Border.all(color: AppTheme.neonOrange.withValues(alpha: 0.2))
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive ? AppTheme.neonOrange : Colors.white24,
                size: 20,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.white24,
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

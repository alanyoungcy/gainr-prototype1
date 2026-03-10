import 'package:flutter/material.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class PriceSideBar extends StatelessWidget {
  final String activePath;

  const PriceSideBar({
    super.key,
    required this.activePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0D0D0F),
            Color(0xFF08080A),
          ],
        ),
        border: const Border(right: BorderSide(color: Colors.white10)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neonOrange.withValues(alpha: 0.03),
            blurRadius: 40,
            offset: const Offset(5, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Logo/Home with animated gradient border
          InkWell(
            onTap: () => context.go('/'),
            child: AnimatedGradientBorder(
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
                child: const Icon(LucideIcons.activity,
                    color: AppColors.neonOrange, size: 24),
              ),
            ),
          ),
          const SizedBox(height: 60),

          _NavIcon(
            icon: LucideIcons.layout_dashboard,
            isActive: activePath == '/',
            onTap: () => context.go('/'),
          ),
          const SizedBox(height: 32),

          _NavIcon(
            icon: LucideIcons.trending_up,
            isActive: activePath == '/portfolio',
            onTap: () => context.go('/portfolio'),
          ),
          const SizedBox(height: 32),

          _NavIcon(
            icon: LucideIcons.repeat,
            isActive: activePath == '/swap',
            onTap: () => context.go('/swap'),
          ),
          const SizedBox(height: 32),

          _NavIcon(
            icon: LucideIcons.wallet,
            isActive: activePath == '/profile',
            onTap: () => context.go('/profile'),
          ),

          const Spacer(),

          // Bottom Info
          const Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: RotatedBox(
              quarterTurns: 3,
              child: NeonText(
                text: 'SPORTS_EDITION',
                glowColor: AppTheme.neonOrange,
                glowRadius: 4,
                style: TextStyle(
                  color: Colors.white24,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        color: isActive ? AppColors.neonOrange : Colors.white30,
        size: 24,
      ),
      onPressed: onTap,
    );
  }
}

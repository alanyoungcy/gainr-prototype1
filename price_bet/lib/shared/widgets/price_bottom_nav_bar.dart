import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class PriceBottomNavBar extends StatelessWidget {
  final String activePath;

  const PriceBottomNavBar({
    super.key,
    required this.activePath,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF111114).withValues(alpha: 0.85),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.06),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _BottomNavItem(
                    icon: LucideIcons.layout_dashboard,
                    label: 'Home',
                    isSelected: activePath == '/',
                    onTap: () => context.go('/'),
                  ),
                  _BottomNavItem(
                    icon: LucideIcons.trending_up,
                    label: 'Portfolio',
                    isSelected: activePath == '/portfolio',
                    onTap: () => context.go('/portfolio'),
                  ),
                  _BottomNavItem(
                    icon: LucideIcons.repeat,
                    label: 'Swap',
                    isSelected: activePath == '/swap',
                    onTap: () => context.go('/swap'),
                  ),
                  _BottomNavItem(
                    icon: LucideIcons.wallet,
                    label: 'Profile',
                    isSelected: activePath == '/profile',
                    onTap: () => context.go('/profile'),
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

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80, // Slightly wider for 3 items
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: AppTheme.animFast,
              curve: AppTheme.animCurve,
              width: isSelected ? 24 : 0,
              height: 3,
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [AppTheme.neonOrange, AppTheme.neonMagenta],
                      )
                    : null,
                borderRadius: BorderRadius.circular(2),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.neonOrange.withValues(alpha: 0.5),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
            AnimatedScale(
              scale: isSelected ? 1.15 : 1.0,
              duration: AppTheme.animFast,
              curve: AppTheme.animCurve,
              child: Icon(
                icon,
                color: isSelected
                    ? AppTheme.neonOrange
                    : Colors.white.withValues(alpha: 0.35),
                size: 22,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: AppTheme.animFast,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.35),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

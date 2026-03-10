import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gainr_ui/gainr_ui.dart';
class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onIndexChanged;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
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
                    icon: Icons.sports,
                    label: 'Sports',
                    isSelected: selectedIndex == 0,
                    onTap: () => onIndexChanged(0),
                  ),
                  _BottomNavItem(
                    icon: Icons.play_circle_outline,
                    label: 'Live',
                    isSelected: selectedIndex == 1,
                    onTap: () => onIndexChanged(1),
                    showDot: true,
                    dotColor: Colors.redAccent,
                  ),
                  _BottomNavItem(
                    icon: Icons.receipt_long,
                    label: 'Bets',
                    isSelected: selectedIndex == 3,
                    onTap: () => onIndexChanged(3),
                  ),
                  _BottomNavItem(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Wallet',
                    isSelected: selectedIndex == 4,
                    onTap: () => onIndexChanged(4),
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
  final bool showDot;
  final Color dotColor;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.showDot = false,
    this.dotColor = Colors.redAccent,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Active indicator with glow
            AnimatedContainer(
              duration: AppTheme.animFast,
              curve: AppTheme.animCurve,
              width: isSelected ? 24 : 0,
              height: 3,
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: AppTheme.primaryGlow,
                      )
                    : null,
                borderRadius: BorderRadius.circular(2),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.gainrGreen.withValues(alpha: 0.5),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                        BoxShadow(
                          color: AppTheme.neonCyan.withValues(alpha: 0.2),
                          blurRadius: 16,
                        ),
                      ]
                    : null,
              ),
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedScale(
                  scale: isSelected ? 1.15 : 1.0,
                  duration: AppTheme.animFast,
                  curve: AppTheme.animCurve,
                  child: Icon(
                    icon,
                    color: isSelected
                        ? AppTheme.gainrGreen
                        : Colors.white.withValues(alpha: 0.35),
                    size: 22,
                  ),
                ),
                if (showDot)
                  Positioned(
                    top: -2,
                    right: -4,
                    child: GlowPulse(
                      glowColor: dotColor,
                      glowRadius: 6,
                      duration: const Duration(milliseconds: 1000),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
              ],
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


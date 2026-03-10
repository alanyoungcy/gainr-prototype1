import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gainr_ui/gainr_ui.dart';
class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onIndexChanged;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D0D0F),
            Color(0xFF08080A),
          ],
        ),
        border: const Border(
          right: BorderSide(color: Color(0xFF1A1A1E), width: 1),
        ),
        // Subtle ambient glow on the sidebar edge
        boxShadow: [
          BoxShadow(
            color: AppTheme.gainrGreen.withValues(alpha: 0.03),
            blurRadius: 40,
            offset: const Offset(10, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo with animated gradient border
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
            child: Row(
              children: [
                AnimatedGradientBorder(
                  borderWidth: 2,
                  borderRadius: 10,
                  colors: const [
                    Color(0xFFFF6B00),
                    Color(0xFFFF8533),
                    AppTheme.neonCyan,
                    Color(0xFFFF6B00),
                  ],
                  duration: const Duration(seconds: 4),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B00), Color(0xFFFF8533)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'B',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          NeonText(
                            text: 'BACK',
                            glowColor: Colors.white,
                            glowRadius: 4,
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                          NeonText(
                            text: '.bet',
                            glowColor: AppTheme.gainrGreen,
                            glowRadius: 8,
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.gainrGreen,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Powered by Solana',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.25),
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Platform Section
          const _SectionLabel(label: 'PLATFORM'),
          const SizedBox(height: 8),

          _NavItem(
            icon: Icons.sports,
            label: 'Sportsbook',
            isSelected: selectedIndex == 0,
            onTap: () => onIndexChanged(0),
          ),
          _NavItem(
            icon: Icons.play_circle_outline,
            label: 'Live Events',
            isSelected: selectedIndex == 1,
            onTap: () => onIndexChanged(1),
            badge: 'LIVE',
            badgeColor: Colors.redAccent,
            showPulse: true,
          ),
          _NavItem(
            icon: Icons.casino_outlined,
            label: 'Casino',
            isSelected: selectedIndex == 2,
            onTap: () => onIndexChanged(2),
            badge: 'SOON',
            badgeColor: Colors.white38,
          ),

          const SizedBox(height: 24),

          // Account Section
          const _SectionLabel(label: 'ACCOUNT'),
          const SizedBox(height: 8),

          _NavItem(
            icon: Icons.swap_horiz,
            label: 'Swap',
            isSelected: selectedIndex == 6,
            onTap: () => onIndexChanged(6),
          ),
          _NavItem(
            icon: Icons.receipt_long,
            label: 'My Bets',
            isSelected: selectedIndex == 3,
            onTap: () => onIndexChanged(3),
          ),
          _NavItem(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Wallet',
            isSelected: selectedIndex == 4,
            onTap: () => onIndexChanged(4),
          ),
          _NavItem(
            icon: Icons.history,
            label: 'History',
            isSelected: selectedIndex == 5,
            onTap: () => onIndexChanged(5),
          ),

          const Spacer(),

          // Support Card with glassmorphism
          GlassmorphicContainer(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.all(16),
            blur: 8,
            opacity: 0.04,
            borderRadius: 14,
            borderColor: AppTheme.gainrGreen.withValues(alpha: 0.12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppTheme.gainrGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.headset_mic_outlined,
                        color: AppTheme.gainrGreen,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      '24/7 Support',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Decentralized assistance powered by the GAINR community.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // Version
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Text(
              'v1.0.0-beta',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.15),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.25),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.8,
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final String? badge;
  final Color? badgeColor;
  final bool showPulse;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge,
    this.badgeColor,
    this.showPulse = false,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppTheme.animFast,
          curve: AppTheme.animCurve,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppTheme.gainrGreen.withValues(alpha: 0.08)
                : _isHovered
                    ? Colors.white.withValues(alpha: 0.03)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              // Active accent bar with glow
              AnimatedContainer(
                duration: AppTheme.animFast,
                width: 3,
                height: widget.isSelected ? 20 : 0,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? AppTheme.gainrGreen
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: widget.isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.gainrGreen.withValues(alpha: 0.6),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),
              AnimatedContainer(
                duration: AppTheme.animFast,
                child: Icon(
                  widget.icon,
                  color: widget.isSelected
                      ? AppTheme.gainrGreen
                      : _isHovered
                          ? Colors.white.withValues(alpha: 0.7)
                          : Colors.white.withValues(alpha: 0.45),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.isSelected
                        ? Colors.white
                        : _isHovered
                            ? Colors.white.withValues(alpha: 0.8)
                            : Colors.white.withValues(alpha: 0.5),
                    fontWeight:
                        widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
              ),
              if (widget.badge != null)
                widget.showPulse && widget.badge == 'LIVE'
                    ? GlowPulse(
                        glowColor: Colors.redAccent,
                        glowRadius: 8,
                        duration: const Duration(milliseconds: 1200),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.badge!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (widget.badgeColor ?? Colors.white)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.badge!,
                          style: TextStyle(
                            color: widget.badgeColor ?? Colors.white54,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
            ],
          ),
        ),
      ),
    );
  }
}


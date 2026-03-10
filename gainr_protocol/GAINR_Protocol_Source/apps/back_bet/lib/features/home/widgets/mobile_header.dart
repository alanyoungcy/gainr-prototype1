import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'package:gainr_mobile/features/wallet/widgets/connect_wallet_button.dart';

class MobileHeader extends StatelessWidget {
  final VoidCallback onMenuPressed;

  const MobileHeader({
    super.key,
    required this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF111114).withValues(alpha: 0.85),
            border: Border(
              bottom: BorderSide(
                color: AppTheme.neonCyan.withValues(alpha: 0.08),
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.neonCyan.withValues(alpha: 0.03),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white70, size: 22),
                  onPressed: onMenuPressed,
                  splashRadius: 20,
                ),
                const SizedBox(width: 4),
                // Logo with animated gradient border
                AnimatedGradientBorder(
                  borderWidth: 1.5,
                  borderRadius: 8,
                  colors: const [
                    Color(0xFFFF6B00),
                    Color(0xFFFF8533),
                    AppTheme.gainrGreen,
                  ],
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFF6B00),
                          Color(0xFFFF8533),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        'B',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      NeonText(
                        text: 'BACK',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                        glowColor: Colors.white,
                        glowRadius: 4,
                      ),
                      Text(
                        '.bet',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.gainrGreen,
                          letterSpacing: 1,
                          shadows: [
                            Shadow(
                              color: AppTheme.gainrGreen.withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Flexible(child: ConnectWalletButton()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'package:gainr_mobile/features/betting/providers/social_win_provider.dart';

class SocialWinOverlay extends ConsumerWidget {
  const SocialWinOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final win = ref.watch(socialWinProvider);

    if (win == null) return const SizedBox.shrink();

    return Positioned(
      bottom: 24,
      left: 24,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: Opacity(
              opacity: value.clamp(0.0, 1.0),
              child: child,
            ),
          );
        },
        child: AnimatedGradientBorder(
          borderWidth: 1.5,
          borderRadius: 16,
          colors: const [
            AppTheme.gainrGreen,
            AppTheme.neonCyan,
            AppTheme.gainrGreen,
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.gainrGreen.withValues(alpha: 0.15),
                  blurRadius: 25,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GlowPulse(
                  glowColor: AppTheme.gainrGreen,
                  glowRadius: 15,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.gainrGreen.withValues(alpha: 0.2),
                          AppTheme.gainrGreen.withValues(alpha: 0.05),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.gainrGreen.withValues(alpha: 0.15),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: AppTheme.gainrGreen,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShimmerEffect(
                      baseColor: AppTheme.gainrGreen,
                      highlightColor: AppTheme.neonCyan,
                      child: Text(
                        'BIG WIN!',
                        style: GoogleFonts.outfit(
                          color: AppTheme.gainrGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: win.user,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          TextSpan(
                            text: ' just won ',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 14,
                            ),
                          ),
                          TextSpan(
                            text:
                                '${(win.amount * win.multiplier).toStringAsFixed(0)} \$BET',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              shadows: [
                                Shadow(
                                  color: AppTheme.gainrGreen
                                      .withValues(alpha: 0.4),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${win.multiplier.toStringAsFixed(1)}x on ${win.event}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


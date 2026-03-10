import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gainr_ui/gainr_ui.dart';
class ComingSoonScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const ComingSoonScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with animated gradient border + glow
            GlowPulse(
              glowColor: AppTheme.neonCyan,
              glowRadius: 30,
              child: AnimatedGradientBorder(
                borderWidth: 2,
                borderRadius: 24,
                colors: const [
                  AppTheme.neonCyan,
                  AppTheme.gainrGreen,
                  AppTheme.neonMagenta,
                ],
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.neonCyan.withValues(alpha: 0.12),
                        AppTheme.gainrGreen.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Icon(
                    icon,
                    size: 36,
                    color: AppTheme.neonCyan.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Title with neon glow
            NeonText(
              text: title,
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              glowColor: AppTheme.neonCyan,
              glowRadius: 8,
            ),
            const SizedBox(height: 12),

            // COMING SOON badge with shimmer
            ShimmerEffect(
              baseColor: AppTheme.gainrGreen,
              highlightColor: AppTheme.neonCyan,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.gainrGreen.withValues(alpha: 0.4),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'COMING SOON',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.gainrGreen,
                    letterSpacing: 3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Notify button with glassmorphism + hover
            HoverScaleGlow(
              glowColor: AppTheme.neonCyan,
              child: GlassmorphicContainer(
                borderRadius: 14,
                blur: 10,
                opacity: 0.08,
                borderColor: AppTheme.neonCyan.withValues(alpha: 0.15),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GlowPulse(
                        glowColor: AppTheme.neonCyan,
                        glowRadius: 8,
                        child: Icon(
                          Icons.notifications_outlined,
                          size: 16,
                          color: AppTheme.neonCyan.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Get Notified on Launch',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


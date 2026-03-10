import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gainr_ui/gainr_ui.dart';
class AiBadge extends StatefulWidget {
  final VoidCallback onTap;
  final bool compact;

  const AiBadge({
    super.key,
    required this.onTap,
    this.compact = false,
  });

  @override
  State<AiBadge> createState() => _AiBadgeState();
}

class _AiBadgeState extends State<AiBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.2, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: widget.compact ? 8 : 12,
                vertical: widget.compact ? 4 : 6,
              ),
              decoration: BoxDecoration(
                color: AppTheme.gainrGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(widget.compact ? 6 : 8),
                border: Border.all(
                  color: AppTheme.gainrGreen
                      .withValues(alpha: _glowAnimation.value),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.gainrGreen
                        .withValues(alpha: _glowAnimation.value * 0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.psychology,
                    size: 14,
                    color: AppTheme.gainrGreen,
                  ),
                  if (!widget.compact) ...[
                    const SizedBox(width: 8),
                    Text(
                      'AI INSIGHT',
                      style: GoogleFonts.outfit(
                        color: AppTheme.gainrGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


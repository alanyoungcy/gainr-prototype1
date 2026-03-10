import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'package:gainr_solana/gainr_solana.dart';

class GainrStakingCard extends ConsumerStatefulWidget {
  const GainrStakingCard({super.key});

  @override
  ConsumerState<GainrStakingCard> createState() => _GainrStakingCardState();
}

class _GainrStakingCardState extends ConsumerState<GainrStakingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  bool _isClaiming = false;
  double _simulatedRewards = 450.0;
  Timer? _rewardTimer;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _rewardTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _simulatedRewards += 0.0012 + (Random().nextDouble() * 0.0008);
        });
      }
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    _rewardTimer?.cancel();
    super.dispose();
  }

  void _handleClaim() async {
    if (_isClaiming) return;
    setState(() => _isClaiming = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isClaiming = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: AppTheme.gainrGreen),
              const SizedBox(width: 12),
              Text(
                'Rewards Claimed Successfully!',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1A1A1A),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tier = ref.watch(userTierProvider);
    final progress = ref.watch(tierProgressProvider);

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return AnimatedGradientBorder(
          borderWidth: 1.5,
          borderRadius: 28,
          colors: [
            tier.color.withValues(alpha: 0.4),
            AppTheme.neonCyan.withValues(alpha: 0.3),
            tier.color.withValues(alpha: 0.4),
          ],
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF141416).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: tier.color
                      .withValues(alpha: 0.08 * _glowController.value),
                  blurRadius: 30,
                  spreadRadius: 2,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with Holographic Tier Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerEffect(
                            baseColor: Colors.white.withValues(alpha: 0.4),
                            highlightColor: AppTheme.neonCyan,
                            child: Text(
                              '\$GAINR REWARDS PROGRAM',
                              style: GoogleFonts.outfit(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _HolographicBadge(tier: tier),
                        ],
                      ),
                    ),
                    _PulseIcon(color: tier.color),
                  ],
                ),

                const SizedBox(height: 24),

                // Level Progress System
                _LevelProgress(tier: tier, progress: progress),

                const SizedBox(height: 28),

                // Animated Metrics Grid
                RepaintBoundary(
                  child: Row(
                    children: [
                      const Expanded(
                        child: _AnimatedMetricTile(
                          label: 'STAKED BALANCE',
                          value: 12500,
                          unit: 'GAINR',
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 45,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppTheme.neonCyan.withValues(alpha: 0.15),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: _AnimatedMetricTile(
                          label: 'EST. MONTHLY YIELD',
                          value: _simulatedRewards,
                          unit: 'GAINR',
                          valueColor: AppTheme.gainrGreen,
                          isDecimal: true,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Buyback & Burn
                const RepaintBoundary(child: _PremiumBurnCounter()),

                const SizedBox(height: 24),

                // Interactive Claim Button
                _ClaimButton(
                  onPressed: _handleClaim,
                  isClaiming: _isClaiming,
                  color: tier.color,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HolographicBadge extends StatelessWidget {
  final TierInfo tier;
  const _HolographicBadge({required this.tier});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      baseColor: tier.color,
      highlightColor: AppTheme.neonCyan,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              tier.color.withValues(alpha: 0.2),
              tier.color.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: tier.color.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: tier.color.withValues(alpha: 0.1),
              blurRadius: 8,
            ),
          ],
        ),
        child: Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(tier.emoji, style: const TextStyle(fontSize: 16)),
            Text(
              '${tier.name.toUpperCase()} TIER',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            GlowPulse(
              glowColor: tier.color,
              glowRadius: 4,
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: tier.color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Text(
              tier.feeLabel,
              style: TextStyle(
                color: tier.color,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelProgress extends StatelessWidget {
  final TierInfo tier;
  final double progress;

  const _LevelProgress({required this.tier, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TIER PROGRESS',
              style: GoogleFonts.outfit(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
            NeonText(
              text: '${(progress * 100).toInt()}%',
              style: GoogleFonts.outfit(
                color: tier.color,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
              glowColor: tier.color,
              glowRadius: 4,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      tier.color.withValues(alpha: 0.4),
                      tier.color,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: tier.color.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (tier.nextTierMin != null) ...[
          const SizedBox(height: 8),
          Text(
            'Next Reward: ${_getNextTierEmoji(tier.tier)} Stake ${_formatValue(tier.nextTierMin!)} \$GAINR',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.25),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  String _getNextTierEmoji(UserTier t) {
    switch (t) {
      case UserTier.bronze:
        return '🥈';
      case UserTier.silver:
        return '🥇';
      case UserTier.gold:
        return '💎';
      default:
        return '🏆';
    }
  }

  String _formatValue(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }
}

class _AnimatedMetricTile extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final Color? valueColor;
  final bool isDecimal;

  const _AnimatedMetricTile({
    required this.label,
    required this.value,
    required this.unit,
    this.valueColor,
    this.isDecimal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        TweenAnimationBuilder<double>(
          duration: const Duration(seconds: 1),
          tween: Tween(begin: value - (isDecimal ? 0.01 : 100), end: value),
          builder: (context, val, child) {
            final formattedValue = isDecimal
                ? val.toStringAsFixed(4)
                : val.toStringAsFixed(0).replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},');

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StableDigitCounter(
                  value: formattedValue,
                  style: GoogleFonts.sourceCodePro(
                    color: valueColor ?? Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    shadows: valueColor != null
                        ? [
                            Shadow(
                              color: valueColor!.withValues(alpha: 0.3),
                              blurRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                  charWidth: 10.0,
                ),
                const SizedBox(height: 4),
                Text(
                  unit,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.2),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _PremiumBurnCounter extends StatefulWidget {
  const _PremiumBurnCounter();

  @override
  State<_PremiumBurnCounter> createState() => _PremiumBurnCounterState();
}

class _PremiumBurnCounterState extends State<_PremiumBurnCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      borderRadius: 20,
      blur: 4,
      opacity: 0.03,
      borderColor: const Color(0xFFFF4D4D).withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF4D4D), Color(0xFFFF944D)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF4D4D)
                            .withValues(alpha: 0.3 * _controller.value),
                        blurRadius: 20,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Transform.scale(
                      scale: 0.9 + (_controller.value * 0.15),
                      child: const Icon(Icons.local_fire_department,
                          color: Colors.white, size: 22),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BUYBACK & BURN',
                    style: GoogleFonts.outfit(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  NeonText(
                    text: '1.24M \$GAINR Destroyed',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    glowColor: const Color(0xFFFF4D4D),
                    glowRadius: 4,
                  ),
                ],
              ),
            ),
            ShimmerEffect(
              baseColor: AppTheme.gainrGreen,
              highlightColor: AppTheme.neonCyan,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.gainrGreen.withValues(alpha: 0.15),
                  ),
                ),
                child: Text(
                  '\$42,150',
                  style: GoogleFonts.outfit(
                    color: AppTheme.gainrGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
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

class _ClaimButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isClaiming;
  final Color color;

  const _ClaimButton({
    required this.onPressed,
    required this.isClaiming,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 56,
      child: isClaiming
          ? AnimatedGradientShift(
              colors: [
                color.withValues(alpha: 0.3),
                AppTheme.neonCyan.withValues(alpha: 0.3),
                color.withValues(alpha: 0.3),
              ],
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white.withValues(alpha: 0.05),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                ),
              ),
            )
          : HoverScaleGlow(
              glowColor: Colors.white,
              child: TextButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  onPressed();
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  padding: EdgeInsets.zero,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.auto_awesome,
                        color: Colors.black, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      'CLAIM REWARDS',
                      style: GoogleFonts.outfit(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
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

class _StableDigitCounter extends StatelessWidget {
  final String value;
  final TextStyle style;
  final double charWidth;

  const _StableDigitCounter({
    required this.value,
    required this.style,
    this.charWidth = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: value.split('').map((char) {
        return SizedBox(
          width: charWidth,
          child: Text(
            char,
            style: style,
            textAlign: TextAlign.center,
          ),
        );
      }).toList(),
    );
  }
}

class _PulseIcon extends StatelessWidget {
  final Color color;
  const _PulseIcon({required this.color});

  @override
  Widget build(BuildContext context) {
    return GlowPulse(
      glowColor: color,
      glowRadius: 10,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(Icons.insights, color: color, size: 20),
      ),
    );
  }
}

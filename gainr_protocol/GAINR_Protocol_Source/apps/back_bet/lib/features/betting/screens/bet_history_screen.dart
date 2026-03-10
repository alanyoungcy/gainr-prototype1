import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'package:gainr_mobile/features/betting/providers/placed_bets_provider.dart';
import 'package:gainr_models/gainr_models.dart';

class BetHistoryScreen extends ConsumerWidget {
  const BetHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeBets = ref.watch(activeBetsProvider);
    final settledBets = ref.watch(settledBetsProvider);
    final allEmpty = activeBets.isEmpty && settledBets.isEmpty;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: allEmpty
          ? const _EmptyState()
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Stats Bar with stagger
                StaggeredFadeSlide(
                  index: 0,
                  child: _BetStatsBar(
                    active: activeBets.length,
                    won: settledBets.where((b) => b.isWon).length,
                    lost: settledBets.where((b) => b.isLost).length,
                  ),
                ),
                const SizedBox(height: 32),

                // Active Bets
                if (activeBets.isNotEmpty) ...[
                  StaggeredFadeSlide(
                    index: 1,
                    child: _SectionHeader(
                      title: 'Active Bets',
                      count: activeBets.length,
                      dotColor: AppTheme.gainrGreen,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...activeBets.asMap().entries.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: StaggeredFadeSlide(
                          index: entry.key + 2,
                          child: _ActiveBetCard(bet: entry.value),
                        ),
                      )),
                  const SizedBox(height: 24),
                ],

                // Settled Bets
                if (settledBets.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Settled',
                    count: settledBets.length,
                    dotColor: Colors.white38,
                  ),
                  const SizedBox(height: 16),
                  ...settledBets.asMap().entries.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: StaggeredFadeSlide(
                          index: entry.key,
                          child: _SettledBetCard(bet: entry.value),
                        ),
                      )),
                ],
              ],
            ),
    );
  }
}

// ─── Stats Bar ───────────────────────────────────────────────────────
class _BetStatsBar extends StatelessWidget {
  final int active;
  final int won;
  final int lost;

  const _BetStatsBar({
    required this.active,
    required this.won,
    required this.lost,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _BetStat(
          label: 'Active',
          value: active.toString(),
          color: AppTheme.neonCyan,
          glowColor: AppTheme.neonCyan,
        ),
        const SizedBox(width: 12),
        _BetStat(
          label: 'Won',
          value: won.toString(),
          color: AppTheme.success,
          glowColor: AppTheme.gainrGreen,
        ),
        const SizedBox(width: 12),
        _BetStat(
          label: 'Lost',
          value: lost.toString(),
          color: AppTheme.error,
          glowColor: AppTheme.neonMagenta,
        ),
      ],
    );
  }
}

class _BetStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color glowColor;

  const _BetStat({
    required this.label,
    required this.value,
    required this.color,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassmorphicContainer(
        borderRadius: 16,
        blur: 6,
        opacity: 0.05,
        borderColor: color.withValues(alpha: 0.2),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.08),
                color.withValues(alpha: 0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              NeonText(
                text: value,
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                glowColor: glowColor,
                glowRadius: 8,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Section Header ──────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color dotColor;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GlowPulse(
          glowColor: dotColor,
          glowRadius: 8,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 10),
        NeonText(
          text: title.toUpperCase(),
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
          glowColor: dotColor,
          glowRadius: 4,
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: dotColor.withValues(alpha: 0.15),
            ),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Active Bet Card (with countdown) ────────────────────────────────
class _ActiveBetCard extends StatefulWidget {
  final PlacedBet bet;

  const _ActiveBetCard({required this.bet});

  @override
  State<_ActiveBetCard> createState() => _ActiveBetCardState();
}

class _ActiveBetCardState extends State<_ActiveBetCard> {
  Timer? _tickTimer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _remaining = widget.bet.timeUntilSettlement;
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _remaining = widget.bet.timeUntilSettlement;
      });
    });
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seconds = _remaining.inSeconds;
    final progress = 1.0 - (seconds / 30.0).clamp(0.0, 1.0);
    final isUrgent = seconds <= 10;

    return AnimatedGradientBorder(
      borderWidth: 1.5,
      borderRadius: 16,
      colors: isUrgent
          ? [Colors.amber, const Color(0xFFFF6B00), Colors.amber]
          : [AppTheme.neonCyan, AppTheme.gainrGreen, AppTheme.neonCyan],
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sport badge + Event name
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.neonCyan.withValues(alpha: 0.15),
                        AppTheme.gainrGreen.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppTheme.neonCyan.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Text(
                    widget.bet.sport.toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.neonCyan,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GlowPulse(
                  glowColor: Colors.amber,
                  glowRadius: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.amber,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'PENDING',
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                // Countdown badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isUrgent
                        ? Colors.amber.withValues(alpha: 0.1)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: isUrgent
                        ? Border.all(color: Colors.amber.withValues(alpha: 0.3))
                        : null,
                  ),
                  child: Text(
                    '${seconds}s',
                    style: GoogleFonts.outfit(
                      color: isUrgent
                          ? Colors.amber
                          : Colors.white.withValues(alpha: 0.6),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Event name
            Text(
              widget.bet.eventName,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),

            // Selection
            Text(
              widget.bet.selectionName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Progress bar with gradient
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Stack(
                children: [
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isUrgent
                              ? [Colors.amber, const Color(0xFFFF6B00)]
                              : [AppTheme.neonCyan, AppTheme.gainrGreen],
                        ),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: (isUrgent ? Colors.amber : AppTheme.neonCyan)
                                .withValues(alpha: 0.4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Odds + Stake + Return
            Row(
              children: [
                _InfoChip(
                    label: 'Odds', value: widget.bet.odds.toStringAsFixed(2)),
                const SizedBox(width: 12),
                _InfoChip(
                    label: 'Stake',
                    value: '\$${widget.bet.stake.toStringAsFixed(2)}'),
                const SizedBox(width: 12),
                _InfoChip(
                  label: 'To Return',
                  value: '\$${widget.bet.potentialReturn.toStringAsFixed(2)}',
                  valueColor: AppTheme.gainrGreen,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Settled Bet Card ────────────────────────────────────────────────
class _SettledBetCard extends StatelessWidget {
  final PlacedBet bet;

  const _SettledBetCard({required this.bet});

  @override
  Widget build(BuildContext context) {
    final isWon = bet.isWon;
    final statusColor = isWon ? AppTheme.success : AppTheme.error;
    final glowColor = isWon ? AppTheme.gainrGreen : AppTheme.neonMagenta;

    return GlassmorphicContainer(
      borderRadius: 16,
      blur: 4,
      opacity: 0.04,
      borderColor: statusColor.withValues(alpha: 0.15),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GlowPulse(
                  glowColor: glowColor,
                  glowRadius: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          statusColor.withValues(alpha: 0.15),
                          statusColor.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isWon ? Icons.emoji_events : Icons.close,
                          color: statusColor,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isWon ? 'WON' : 'LOST',
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTime(bet.settledAt ?? bet.placedAt),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              bet.eventName,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              bet.selectionName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _InfoChip(label: 'Odds', value: bet.odds.toStringAsFixed(2)),
                const SizedBox(width: 12),
                _InfoChip(
                    label: 'Stake', value: '\$${bet.stake.toStringAsFixed(2)}'),
                const SizedBox(width: 12),
                _InfoChip(
                  label: isWon ? 'Payout' : 'Lost',
                  value: isWon
                      ? '+\$${bet.potentialReturn.toStringAsFixed(2)}'
                      : '-\$${bet.stake.toStringAsFixed(2)}',
                  valueColor: statusColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ─── Info Chip ───────────────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoChip({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: (valueColor ?? Colors.white).withValues(alpha: 0.06),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                shadows: valueColor != null
                    ? [
                        Shadow(
                          color: valueColor!.withValues(alpha: 0.4),
                          blurRadius: 6,
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty State ─────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GlowPulse(
            glowColor: AppTheme.neonCyan,
            glowRadius: 20,
            child: AnimatedGradientBorder(
              borderWidth: 1.5,
              borderRadius: 50,
              colors: const [
                AppTheme.neonCyan,
                AppTheme.gainrGreen,
                AppTheme.neonMagenta,
              ],
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  size: 48,
                  color: AppTheme.neonCyan.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          NeonText(
            text: 'No Bets Yet',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            glowColor: AppTheme.neonCyan,
            glowRadius: 6,
          ),
          const SizedBox(height: 8),
          Text(
            'Place your first bet to see it here.\nBets auto-settle in 30 seconds for demo.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

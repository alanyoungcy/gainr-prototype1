import 'package:gainr_ui/gainr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gainr_models/gainr_models.dart';
import 'package:gainr_mobile/features/betting/providers/bet_slip_provider.dart';
import 'package:gainr_mobile/features/betting/widgets/ai_badge.dart';
import 'package:gainr_mobile/features/betting/widgets/ai_insights_panel.dart';
import 'package:flutter/services.dart';

class EventCard extends ConsumerWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('EEE, MMM d • HH:mm');
    final isValue = event.isValueBet;

    return HoverScaleGlow(
      glowColor: isValue ? AppTheme.gainrGreen : const Color(0xFF6C5CE7),
      scaleFactor: 1.02,
      glowRadius: isValue ? 24 : 16,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isValue
                ? [const Color(0xFF1A2332), const Color(0xFF162218)]
                : [const Color(0xFF1C1D22), const Color(0xFF15161A)],
          ),
          border: Border.all(
            color: isValue
                ? AppTheme.gainrGreen.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.06),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Top accent bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 2,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isValue
                          ? [
                              AppTheme.gainrGreen.withValues(alpha: 0.6),
                              AppTheme.neonCyan.withValues(alpha: 0.3),
                              AppTheme.gainrGreen.withValues(alpha: 0.1),
                            ]
                          : [
                              const Color(0xFF6C5CE7).withValues(alpha: 0.3),
                              Colors.transparent,
                            ],
                    ),
                  ),
                ),
              ),

              Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                    child: Row(
                      children: [
                        // Sport icon
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            _getSportIcon(event.sport),
                            size: 13,
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // League badge
                        Expanded(
                          child: Text(
                            event.league.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (event.isLive) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GlowPulse(
                                  glowColor: Colors.redAccent,
                                  glowRadius: 4,
                                  duration: const Duration(milliseconds: 1000),
                                  child: Container(
                                    width: 5,
                                    height: 5,
                                    decoration: const BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'LIVE',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          Text(
                            dateFormat.format(event.startTime),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.35),
                              fontSize: 10,
                            ),
                          ),
                        ],
                        const SizedBox(width: 8),
                        if (isValue)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.gainrGreen.withValues(alpha: 0.2),
                                  AppTheme.gainrGreen.withValues(alpha: 0.08),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color:
                                    AppTheme.gainrGreen.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.gainrGreen,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '+${event.aiEdge.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    color: AppTheme.gainrGreen,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        AiBadge(
                          compact: true,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _showAiInsights(context);
                          },
                        ),
                      ],
                    ),
                  ),

                  // Teams
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                    child: Row(
                      children: [
                        Expanded(
                            child:
                                _buildTeamInfo(context, event.homeTeam, true)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Column(
                            children: [
                              if (event.isLive &&
                                  event.homeTeam.score != null) ...[
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      event.homeTeam.score ?? '0',
                                      style: GoogleFonts.outfit(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      child: Text(
                                        ':',
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.25),
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      event.awayTeam.score ?? '0',
                                      style: GoogleFonts.outfit(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                Text(
                                  'VS',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Expanded(
                            child:
                                _buildTeamInfo(context, event.awayTeam, false)),
                      ],
                    ),
                  ),

                  // Odds Strip
                  Container(
                    margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        _OddsButton(
                          label: '1',
                          odd: event.odds.homeWin,
                          isHighlighted: isValue &&
                              event.kellyStake > 0 &&
                              event.fairProbabilities['home']! >
                                  event.impliedProbabilities['home']!,
                          onTap: () => ref
                              .read(betSlipControllerProvider.notifier)
                              .addBet(event, 'Home', event.homeTeam.name,
                                  event.odds.homeWin),
                        ),
                        if (event.marketType == MarketType.threeWay) ...[
                          Container(
                            width: 1,
                            height: 22,
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                          _OddsButton(
                            label: 'X',
                            odd: event.odds.draw,
                            isHighlighted: isValue &&
                                event.kellyStake > 0 &&
                                event.fairProbabilities['draw']! >
                                    event.impliedProbabilities['draw']!,
                            onTap: () => ref
                                .read(betSlipControllerProvider.notifier)
                                .addBet(event, 'Draw', 'Draw', event.odds.draw),
                          ),
                        ],
                        Container(
                          width: 1,
                          height: 22,
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                        _OddsButton(
                          label: '2',
                          odd: event.odds.awayWin,
                          isHighlighted: isValue &&
                              event.kellyStake > 0 &&
                              event.fairProbabilities['away']! >
                                  event.impliedProbabilities['away']!,
                          onTap: () => ref
                              .read(betSlipControllerProvider.notifier)
                              .addBet(event, 'Away', event.awayTeam.name,
                                  event.odds.awayWin),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamInfo(BuildContext context, Team team, bool isHome) {
    return Row(
      mainAxisAlignment:
          isHome ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        if (isHome) ...[
          TeamBranding.buildTeamAvatar(team.name, size: 32),
          const SizedBox(width: 10),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment:
                isHome ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              Text(
                team.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: isHome ? TextAlign.start : TextAlign.end,
              ),
            ],
          ),
        ),
        if (!isHome) ...[
          const SizedBox(width: 10),
          TeamBranding.buildTeamAvatar(team.name, size: 32),
        ],
      ],
    );
  }

  void _showAiInsights(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AiInsightsPanel(event: event),
    );
  }

  IconData _getSportIcon(String sport) {
    switch (sport.toLowerCase()) {
      case 'football':
        return Icons.sports_football;
      case 'basketball':
        return Icons.sports_basketball;
      case 'soccer':
        return Icons.sports_soccer;
      default:
        return Icons.sports;
    }
  }
}

class _OddsButton extends StatefulWidget {
  final String label;
  final double odd;
  final VoidCallback onTap;
  final bool isHighlighted;

  const _OddsButton({
    required this.label,
    required this.odd,
    required this.onTap,
    this.isHighlighted = false,
  });

  @override
  State<_OddsButton> createState() => _OddsButtonState();
}

class _OddsButtonState extends State<_OddsButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _tapController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    _tapController.forward().then((_) => _tapController.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: _handleTap,
          child: AnimatedBuilder(
            animation: _tapController,
            builder: (context, child) {
              final tapValue = _tapController.value;
              return AnimatedContainer(
                duration: AppTheme.animFast,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: _isHovered
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.transparent,
                  boxShadow: tapValue > 0
                      ? [
                          BoxShadow(
                            color: (widget.isHighlighted
                                    ? AppTheme.gainrGreen
                                    : AppTheme.neonCyan)
                                .withValues(alpha: 0.3 * tapValue),
                            blurRadius: 12 * tapValue,
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.odd.toStringAsFixed(2),
                      style: TextStyle(
                        color: widget.isHighlighted
                            ? AppTheme.gainrGreen
                            : _isHovered
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}



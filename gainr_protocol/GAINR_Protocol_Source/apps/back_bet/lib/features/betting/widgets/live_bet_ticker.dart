import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gainr_ui/gainr_ui.dart';
class LiveBetTicker extends StatefulWidget {
  const LiveBetTicker({super.key});

  @override
  State<LiveBetTicker> createState() => _LiveBetTickerState();
}

class _LiveBetTickerState extends State<LiveBetTicker> {
  late ScrollController _scrollController;
  late Timer _timer;
  final List<Map<String, dynamic>> _bets = [
    {
      'user': 'sol_whale',
      'amount': '250',
      'odds': '1.85',
      'type': 'HOME',
      'isAIValue': true
    },
    {
      'user': 'gainr_pro',
      'amount': '1,200',
      'odds': '3.20',
      'type': 'DRAW',
      'isAIValue': false
    },
    {
      'user': 'degen_king',
      'amount': '50',
      'odds': '5.50',
      'type': 'AWAY',
      'isAIValue': true
    },
    {
      'user': 'crypto_bet',
      'amount': '450',
      'odds': '1.45',
      'type': 'HOME',
      'isAIValue': false
    },
    {
      'user': 'pixel_master',
      'amount': '150',
      'odds': '2.10',
      'type': 'AWAY',
      'isAIValue': false
    },
    {
      'user': 'sol_lion',
      'amount': '3,000',
      'odds': '2.40',
      'type': 'DRAW',
      'isAIValue': true
    },
    {
      'user': 'bet_wiz',
      'amount': '100',
      'odds': '1.95',
      'type': 'HOME',
      'isAIValue': false
    },
    {
      'user': 'gainr_bull',
      'amount': '750',
      'odds': '4.80',
      'type': 'AWAY',
      'isAIValue': true
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  void _startScrolling() {
    _timer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.offset;

        if (currentScroll >= maxScroll) {
          _scrollController.jumpTo(0);
        } else {
          _scrollController.animateTo(
            currentScroll + 1,
            duration: const Duration(milliseconds: 60),
            curve: Curves.linear,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0F1012),
            Colors.black.withValues(alpha: 0.5),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.04),
            width: 1,
          ),
        ),
      ),
      child: Stack(
        children: [
          Row(
            children: [
              // Leading LIVE BETS label
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Colors.white.withValues(alpha: 0.06),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GlowPulse(
                      glowColor: Colors.redAccent,
                      glowRadius: 6,
                      duration: const Duration(milliseconds: 1000),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'LIVE BETS',
                      style: GoogleFonts.outfit(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              // Scrolling ticker
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final bet = _bets[index % _bets.length];
                    return _TickerItem(bet: bet);
                  },
                ),
              ),
            ],
          ),
          // Left fade gradient overlay
          Positioned(
            left: 90,
            top: 0,
            bottom: 0,
            width: 32,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0F1012),
                    const Color(0xFF0F1012).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          // Right fade gradient overlay
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 48,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0F1012).withValues(alpha: 0.0),
                    const Color(0xFF0F1012),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TickerItem extends StatelessWidget {
  final Map<String, dynamic> bet;

  const _TickerItem({required this.bet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Colors.white.withValues(alpha: 0.04),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppTheme.gainrGreen,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.gainrGreen.withValues(alpha: 0.4),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            bet['user'],
            style: GoogleFonts.outfit(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${bet['amount']} \$BET',
            style: GoogleFonts.outfit(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              '@ ${bet['odds']}',
              style: const TextStyle(
                color: AppTheme.gainrGreen,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (bet['isAIValue'] == true) ...[
            const SizedBox(width: 6),
            GlowPulse(
              glowColor: AppTheme.gainrGreen,
              glowRadius: 4,
              duration: const Duration(milliseconds: 1800),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppTheme.gainrGreen.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 8,
                  color: AppTheme.gainrGreen,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}


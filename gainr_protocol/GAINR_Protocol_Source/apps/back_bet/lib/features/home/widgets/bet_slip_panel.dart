import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'package:gainr_mobile/features/betting/providers/bet_slip_provider.dart';
import 'package:gainr_solana/gainr_solana.dart';
import 'package:gainr_mobile/features/wallet/widgets/staking_card.dart';
import 'package:gainr_mobile/features/betting/widgets/bet_confirmation_modal.dart';

class BetSlipPanel extends ConsumerWidget {
  const BetSlipPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bets = ref.watch(betSlipControllerProvider);
    final wallet = ref.watch(walletProvider);

    final totalStake = bets.fold<double>(0, (sum, b) => sum + b.stake);
    final totalReturn =
        bets.fold<double>(0, (sum, b) => sum + b.potentialReturn);

    return Column(
      children: [
        // Header with glassmorphism
        ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.neonCyan.withValues(alpha: 0.08),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const NeonText(
                    text: 'BET SLIP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                    glowColor: AppTheme.neonCyan,
                    glowRadius: 6,
                  ),
                  const Spacer(),
                  if (bets.isNotEmpty)
                    GlowPulse(
                      glowColor: const Color(0xFFFF6B00),
                      glowRadius: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6B00), Color(0xFFFF8533)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF6B00)
                                  .withValues(alpha: 0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Text(
                          '${bets.length} Active',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // Bets List or Staking Info
        Expanded(
          child: bets.isEmpty
              ? const SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      GainrStakingCard(),
                      SizedBox(height: 24),
                      Text(
                        'Select odds to add bets',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...bets.asMap().entries.map((entry) => StaggeredFadeSlide(
                            index: entry.key,
                            child: _BetSlipItem(bet: entry.value),
                          )),

                      const SizedBox(height: 24),
                      // Divider with gradient
                      Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              AppTheme.neonCyan.withValues(alpha: 0.2),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Total Stake
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Stake',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '\$${totalStake.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Potential Return with glow
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Potential Return',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          Row(
                            children: [
                              NeonText(
                                text: '\$${totalReturn.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppTheme.gainrGreen,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                glowColor: AppTheme.gainrGreen,
                                glowRadius: 6,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '\$BET',
                                style: TextStyle(
                                  color: AppTheme.gainrGreen,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: AppTheme.gainrGreen
                                          .withValues(alpha: 0.5),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Place Bet Button with animated gradient
                      SizedBox(
                        width: double.infinity,
                        child: wallet.isConnected
                            ? AnimatedGradientShift(
                                colors: const [
                                  Colors.white,
                                  Color(0xFFE0E0E0),
                                  Colors.white,
                                ],
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (wallet.betBalance < totalStake) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Insufficient \$BET balance. Please deposit USDC.'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) =>
                                          BetConfirmationModal(
                                        bets: bets,
                                        totalStake: totalStake,
                                        totalReturn: totalReturn,
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'PLACE BET',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: null,
                                style: ElevatedButton.styleFrom(
                                  disabledBackgroundColor:
                                      AppTheme.surfaceColor,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'CONNECT WALLET',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                      ),

                      const SizedBox(height: 12),

                      Center(
                        child: Text(
                          'By placing a bet you agree to the Terms of Service',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.3),
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 32),
                      Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              AppTheme.neonCyan.withValues(alpha: 0.15),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      const _LiveWinsFeed(),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _LiveWinsFeed extends StatefulWidget {
  const _LiveWinsFeed();

  @override
  State<_LiveWinsFeed> createState() => _LiveWinsFeedState();
}

class _LiveWinsFeedState extends State<_LiveWinsFeed> {
  final List<Map<String, dynamic>> _wins = [
    {
      'username': '0x4a...3b9',
      'sport': 'SOCCER',
      'type': 'MULTIPLE',
      'amount': '+420 USDC',
      'time': 'Just now',
      'color': Colors.purple,
    },
    {
      'username': 'vitalik.eth',
      'sport': 'TENNIS',
      'type': 'SINGLE',
      'amount': '+1,250 USDC',
      'time': '2m ago',
      'color': const Color(0xFFFF6B00),
    },
    {
      'username': 'SatoshiN',
      'sport': 'NBA',
      'type': 'LIVE',
      'amount': '+89.40 USDC',
      'time': '5m ago',
      'color': AppTheme.gainrGreen,
    },
  ];

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (mounted) {
        _addNewWin();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _addNewWin() {
    final usernames = [
      'cryptoknight',
      'solana_whale',
      'degen_king',
      'mooner',
      '0x22...f11',
      'wagmi_expert'
    ];
    final sports = ['CRICKET', 'RACING', 'SOCCER', 'NFL', 'UFC'];
    final types = ['SINGLE', 'PARLAY', 'SYSTEM', 'VALU'];
    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.pink,
      Colors.cyan,
      Colors.yellow
    ];
    final random = Random();

    setState(() {
      _wins.insert(0, {
        'username': usernames[random.nextInt(usernames.length)],
        'sport': sports[random.nextInt(sports.length)],
        'type': types[random.nextInt(types.length)],
        'amount': '+\$${(50 + random.nextInt(1000000)).toStringAsFixed(2)}',
        'time': 'Just now',
        'color': colors[random.nextInt(colors.length)],
      });
      if (_wins.length > 5) _wins.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            GlowPulse(
              glowColor: AppTheme.gainrGreen,
              glowRadius: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.gainrGreen,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const NeonText(
              text: 'LIVE WINS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
              glowColor: AppTheme.gainrGreen,
              glowRadius: 4,
            ),
            const Spacer(),
            Text(
              '${_wins.length} active',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._wins.asMap().entries.map((entry) {
          final win = entry.value;
          final isNew = win['time'] == 'Just now';

          return AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.only(bottom: 12),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 400),
              tween: Tween(begin: isNew ? 0.0 : 1.0, end: 1.0),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: 0.95 + (0.05 * value),
                    child: child,
                  ),
                );
              },
              child: _LiveWinItem(
                username: win['username'],
                sport: win['sport'],
                type: win['type'],
                amount: win['amount'],
                time: win['time'],
                color: win['color'],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _BetSlipItem extends ConsumerStatefulWidget {
  final dynamic bet;

  const _BetSlipItem({required this.bet});

  @override
  ConsumerState<_BetSlipItem> createState() => _BetSlipItemState();
}

class _BetSlipItemState extends ConsumerState<_BetSlipItem> {
  late TextEditingController _stakeController;

  @override
  void initState() {
    super.initState();
    _stakeController = TextEditingController(
      text: widget.bet.stake.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _stakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      borderRadius: 14,
      blur: 6,
      opacity: 0.06,
      borderColor: AppTheme.neonCyan.withValues(alpha: 0.1),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.sports_soccer,
                  color: AppTheme.neonCyan,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${widget.bet.event.sport.toString().toUpperCase()} • ${widget.bet.event.isLive ? "LIVE" : "UPCOMING"}',
                    style: TextStyle(
                      color: widget.bet.event.isLive
                          ? AppTheme.neonGreen
                          : AppTheme.neonCyan,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InkWell(
                  onTap: () => ref
                      .read(betSlipControllerProvider.notifier)
                      .removeBet(widget.bet.id),
                  child: Icon(
                    Icons.close,
                    color: Colors.white.withValues(alpha: 0.4),
                    size: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.bet.selectionName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.bet.event.homeTeam.name} vs ${widget.bet.event.awayTeam.name}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Odds display with gradient
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                    widget.bet.odd.toStringAsFixed(2),
                    style: const TextStyle(
                      color: AppTheme.neonCyan,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                // Stake input
                SizedBox(
                  width: 80,
                  height: 36,
                  child: TextField(
                    controller: _stakeController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      filled: true,
                      fillColor: Colors.black.withValues(alpha: 0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppTheme.neonCyan.withValues(alpha: 0.1),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppTheme.neonCyan.withValues(alpha: 0.1),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppTheme.neonCyan.withValues(alpha: 0.4),
                        ),
                      ),
                      prefixText: '\$ ',
                      prefixStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                    onChanged: (value) {
                      final stake = double.tryParse(value) ?? 0;
                      ref
                          .read(betSlipControllerProvider.notifier)
                          .updateStake(widget.bet.id, stake);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveWinItem extends StatelessWidget {
  final String username;
  final String sport;
  final String type;
  final String amount;
  final String time;
  final Color color;

  const _LiveWinItem({
    required this.username,
    required this.sport,
    required this.type,
    required this.amount,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      borderRadius: 10,
      blur: 4,
      opacity: 0.05,
      borderColor: color.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Avatar with gradient
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.3),
                    color.withValues(alpha: 0.1),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withValues(alpha: 0.2),
                ),
              ),
              child: Center(
                child: Text(
                  username.substring(0, 2).toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '$sport • $type',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: TextStyle(
                    color: AppTheme.gainrGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    shadows: [
                      Shadow(
                        color: AppTheme.gainrGreen.withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


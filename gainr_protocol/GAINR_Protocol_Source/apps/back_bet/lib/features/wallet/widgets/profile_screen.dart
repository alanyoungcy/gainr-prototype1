import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'package:gainr_solana/gainr_solana.dart';
import 'package:gainr_mobile/features/wallet/widgets/withdraw_modal.dart';
import 'package:gainr_mobile/features/betting/providers/placed_bets_provider.dart';
import 'transaction_history.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);

    if (!wallet.isConnected) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const GlowPulse(
              glowColor: AppTheme.neonCyan,
              glowRadius: 20,
              child: Icon(Icons.lock_outline,
                  size: 64, color: AppTheme.textDisabled),
            ),
            const SizedBox(height: 16),
            NeonText(
              text: 'Please connect your wallet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ) ??
                  const TextStyle(),
              glowColor: AppTheme.neonCyan,
              glowRadius: 4,
            ),
            const SizedBox(height: 24),
            HoverScaleGlow(
              glowColor: AppTheme.gainrGreen,
              child: ElevatedButton(
                onPressed: () => ref.read(walletProvider.notifier).connect(),
                child: const Text('Connect Wallet'),
              ),
            ),
          ],
        ),
      );
    }

    final tier = ref.watch(userTierProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with glow avatar
          StaggeredFadeSlide(
            index: 0,
            child: Row(
              children: [
                GlowPulse(
                  glowColor: tier.color,
                  glowRadius: 12,
                  child: AnimatedGradientBorder(
                    borderWidth: 2,
                    borderRadius: 32,
                    colors: [
                      tier.color,
                      AppTheme.gainrGreen,
                      AppTheme.neonCyan,
                    ],
                    child: const CircleAvatar(
                      radius: 30,
                      backgroundColor: AppTheme.gainrGreen,
                      child: Icon(Icons.person,
                          color: Colors.black, size: 30),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Wallet Connected',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                          ),
                          const SizedBox(width: 8),
                          ShimmerEffect(
                            baseColor: tier.color,
                            highlightColor: Colors.white,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    tier.color.withValues(alpha: 0.15),
                                    tier.color.withValues(alpha: 0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: tier.color.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                '${tier.emoji} ${tier.name}',
                                style: TextStyle(
                                  color: tier.color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        wallet.address ?? '',
                        style: GoogleFonts.sourceCodePro(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Balances title with neon
          StaggeredFadeSlide(
            index: 1,
            child: NeonText(
              text: 'Balances',
              style:
                  Theme.of(context).textTheme.titleMedium ?? const TextStyle(),
              glowColor: AppTheme.neonCyan,
              glowRadius: 4,
            ),
          ),
          const SizedBox(height: 16),
          StaggeredFadeSlide(
            index: 2,
            child: _BalanceCard(
              symbol: 'SOL',
              balance: wallet.solBalance,
              color: Colors.blueAccent,
              icon: Icons.account_balance_wallet,
            ),
          ),
          const SizedBox(height: 12),
          StaggeredFadeSlide(
            index: 3,
            child: _BalanceCard(
              symbol: '\$BET',
              balance: wallet.betBalance,
              color: AppTheme.gainrGreen,
              icon: Icons.casino,
            ),
          ),
          const SizedBox(height: 12),
          StaggeredFadeSlide(
            index: 4,
            child: _BalanceCard(
              symbol: '\$GAINR',
              balance: wallet.gainrBalance,
              color: Colors.purpleAccent,
              icon: Icons.token,
            ),
          ),
          const SizedBox(height: 12),
          StaggeredFadeSlide(
            index: 5,
            child: _BalanceCard(
              symbol: 'USDC',
              balance: wallet.usdcBalance,
              color: Colors.blue,
              icon: Icons.monetization_on,
            ),
          ),

          const SizedBox(height: 32),

          // Actions Row
          StaggeredFadeSlide(
            index: 6,
            child: Row(
              children: [
                Expanded(
                  child: HoverScaleGlow(
                    glowColor: AppTheme.neonCyan,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const WithdrawModal(),
                        );
                      },
                      icon: const Icon(Icons.arrow_upward, size: 18),
                      label: const Text('Withdraw'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.surfaceColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: HoverScaleGlow(
                    glowColor: AppTheme.neonMagenta,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          ref.read(walletProvider.notifier).disconnect(),
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text('Disconnect'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.withValues(alpha: 0.1),
                        foregroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Bet Summary Stats
          NeonText(
            text: 'Bet Summary',
            style: Theme.of(context).textTheme.titleMedium ?? const TextStyle(),
            glowColor: AppTheme.neonCyan,
            glowRadius: 4,
          ),
          const SizedBox(height: 16),
          Consumer(
            builder: (context, ref, _) {
              final active = ref.watch(activeBetsProvider);
              final settled = ref.watch(settledBetsProvider);
              final won = settled.where((b) => b.isWon).length;
              final lost = settled.where((b) => b.isLost).length;
              final totalWinnings = settled
                  .where((b) => b.isWon)
                  .fold<double>(0, (sum, b) => sum + b.potentialReturn);

              return Row(
                children: [
                  _StatCard(
                      label: 'Active',
                      value: active.length.toString(),
                      color: AppTheme.neonCyan),
                  const SizedBox(width: 8),
                  _StatCard(
                      label: 'Won',
                      value: won.toString(),
                      color: AppTheme.gainrGreen),
                  const SizedBox(width: 8),
                  _StatCard(
                      label: 'Lost',
                      value: lost.toString(),
                      color: AppTheme.neonMagenta),
                  const SizedBox(width: 8),
                  _StatCard(
                      label: 'Winnings',
                      value: '\$${totalWinnings.toStringAsFixed(0)}',
                      color: Colors.amber),
                ],
              );
            },
          ),

          const SizedBox(height: 32),
          NeonText(
            text: 'Activity History',
            style: Theme.of(context).textTheme.titleMedium ?? const TextStyle(),
            glowColor: AppTheme.neonCyan,
            glowRadius: 4,
          ),
          const SizedBox(height: 16),
          const SizedBox(
            height: 400,
            child: TransactionHistory(),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassmorphicContainer(
        borderRadius: 12,
        blur: 4,
        opacity: 0.05,
        borderColor: color.withValues(alpha: 0.2),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              NeonText(
                text: value,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                glowColor: color,
                glowRadius: 6,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color.withValues(alpha: 0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final String symbol;
  final double balance;
  final Color color;
  final IconData icon;

  const _BalanceCard({
    required this.symbol,
    required this.balance,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      borderRadius: 16,
      blur: 6,
      opacity: 0.05,
      borderColor: color.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
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
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.15),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 16),
                Text(
                  symbol,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            NeonText(
              text: balance.toStringAsFixed(2),
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
              glowColor: color,
              glowRadius: 4,
            ),
          ],
        ),
      ),
    );
  }
}

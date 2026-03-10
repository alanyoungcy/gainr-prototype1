import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'package:gainr_solana/gainr_solana.dart';
import 'deposit_modal.dart';
import 'swap_screen.dart';

class WalletInfoCard extends ConsumerWidget {
  const WalletInfoCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletProvider);

    return GlassmorphicContainer(
      borderRadius: 12,
      blur: 6,
      opacity: 0.06,
      borderColor: AppTheme.neonCyan.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 300;
            final isVeryCompact = constraints.maxWidth < 150;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Balances
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: NeonText(
                          text:
                              '${walletState.betBalance.toStringAsFixed(2)} \$GBET',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          glowColor: AppTheme.gainrGreen,
                          glowRadius: 4,
                        ),
                      ),
                      if (!isVeryCompact)
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${walletState.solBalance.toStringAsFixed(2)} SOL',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                if (!isCompact) ...[
                  const SizedBox(width: 12),
                  Container(
                    width: 1,
                    height: 32,
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
                  const SizedBox(width: 12),
                  // Address
                Flexible(
                  child: GestureDetector(
                    onTap: () => _copyAddress(context, walletState.address),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF6C5CE7).withValues(alpha: 0.25),
                                const Color(0xFF6C5CE7).withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6C5CE7)
                                    .withValues(alpha: 0.15),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet,
                            color: Color(0xFF6C5CE7),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            walletState.displayAddress,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontFamily: 'monospace',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

                const SizedBox(width: 12),

                // Swap button
                HoverScaleGlow(
                  glowColor: AppTheme.neonCyan,
                  child: GestureDetector(
                    onTap: () => _showSwapScreen(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppTheme.neonCyan.withValues(alpha: 0.15)),
                      ),
                      child: const Text(
                        'Swap',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Deposit button
                HoverScaleGlow(
                  glowColor: const Color(0xFF6C5CE7),
                  child: GestureDetector(
                    onTap: () => _showDepositModal(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF6C5CE7),
                            Color(0xFF7C6CF7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF6C5CE7).withValues(alpha: 0.2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Text(
                        'Deposit',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 4),

                // Menu
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert,
                      color: Colors.white.withValues(alpha: 0.6), size: 20),
                  color: AppTheme.cardBackground,
                  onSelected: (value) {
                    if (value == 'Disconnect') {
                      ref.read(walletProvider.notifier).disconnect();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'Disconnect',
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: Colors.red, size: 18),
                          SizedBox(width: 12),
                          Text(
                            'Disconnect',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _copyAddress(BuildContext context, String? address) {
    if (address != null) {
      Clipboard.setData(ClipboardData(text: address));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Address copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showSwapScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SwapScreen()),
    );
  }

  void _showDepositModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const DepositModal(),
    );
  }
}

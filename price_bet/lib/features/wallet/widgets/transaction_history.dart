import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'package:gainr_solana/gainr_solana.dart';

class TransactionHistory extends ConsumerWidget {
  const TransactionHistory({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);
    final txs = wallet.transactions;

    if (txs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GlowPulse(
              glowColor: AppTheme.neonCyan,
              glowRadius: 15,
              child: Icon(Icons.history,
                  color: Colors.white.withValues(alpha: 0.15), size: 48),
            ),
            const SizedBox(height: 16),
            NeonText(
              text: 'No transaction history yet',
              style: GoogleFonts.outfit(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 14,
              ),
              glowColor: AppTheme.neonCyan,
              glowRadius: 3,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: txs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return StaggeredFadeSlide(
          index: index,
          child: _TransactionTile(tx: txs[index]),
        );
      },
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final WalletTransaction tx;

  const _TransactionTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    final color = _getTypeColor();

    String tokenLabel = tx.token;
    if (tokenLabel == 'BET') tokenLabel = 'GBET';

    return GlassmorphicContainer(
      borderRadius: 16,
      blur: 4,
      opacity: 0.04,
      borderColor: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildIcon(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getTypeLabel(),
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    tx.details?.replaceAll('BET', 'GBET') ??
                        DateFormat('MMM dd, HH:mm').format(tx.timestamp),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${_getAmountPrefix()}${tx.amount.toStringAsFixed(2)} $tokenLabel',
                  style: GoogleFonts.outfit(
                    color: _getAmountColor(),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    shadows: [
                      Shadow(
                        color: _getAmountColor().withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                Text(
                  DateFormat('HH:mm').format(tx.timestamp),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.2),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    IconData icon;
    Color color;

    switch (tx.type) {
      case TransactionType.deposit:
        icon = Icons.add_circle_outline;
        color = Colors.blue;
        break;
      case TransactionType.withdraw:
        icon = Icons.remove_circle_outline;
        color = Colors.orange;
        break;
      case TransactionType.swap:
        icon = Icons.swap_horiz;
        color = const Color(0xFF14F195);
        break;
      case TransactionType.reward:
        icon = Icons.stars;
        color = Colors.amber;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.2),
            color.withValues(alpha: 0.05),
          ],
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 6,
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Color _getTypeColor() {
    switch (tx.type) {
      case TransactionType.deposit:
        return Colors.blue;
      case TransactionType.withdraw:
        return Colors.orange;
      case TransactionType.swap:
        return const Color(0xFF14F195);
      case TransactionType.reward:
        return Colors.amber;
    }
  }

  String _getTypeLabel() {
    switch (tx.type) {
      case TransactionType.deposit:
        return 'Deposit';
      case TransactionType.withdraw:
        return 'Withdrawal';
      case TransactionType.swap:
        return 'Swap';
      case TransactionType.reward:
        return 'Staking Reward';
    }
  }

  String _getAmountPrefix() {
    if (tx.type == TransactionType.withdraw) return '-';
    if (tx.type == TransactionType.deposit ||
        tx.type == TransactionType.reward) {
      return '+';
    }
    return '';
  }

  Color _getAmountColor() {
    if (tx.type == TransactionType.withdraw) return Colors.redAccent;
    if (tx.type == TransactionType.deposit ||
        tx.type == TransactionType.reward) {
      return const Color(0xFF14F195);
    }
    return Colors.white;
  }
}

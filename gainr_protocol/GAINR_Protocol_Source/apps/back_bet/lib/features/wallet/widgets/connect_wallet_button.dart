import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'package:gainr_solana/gainr_solana.dart';
import 'wallet_modal.dart';
import 'wallet_info_card.dart';

class ConnectWalletButton extends ConsumerWidget {
  const ConnectWalletButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletProvider);

    if (walletState.isConnected) {
      return const WalletInfoCard();
    }

    return HoverScaleGlow(
      glowColor: const Color(0xFF6C5CE7),
      scaleFactor: 1.05,
      glowRadius: 24,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _showWalletModal(context);
        },
        child: AnimatedGradientShift(
          colors: const [
            Color(0xFF6C5CE7),
            Color(0xFF00F0FF),
            Color(0xFFA29BFE),
            Color(0xFF6C5CE7),
          ],
          borderRadius: 12,
          duration: const Duration(seconds: 3),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C5CE7).withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Connect Wallet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWalletModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const WalletConnectModal(),
    );
  }
}


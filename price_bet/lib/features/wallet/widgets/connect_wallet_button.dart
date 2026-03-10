import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'package:gainr_solana/gainr_solana.dart';
import 'wallet_modal.dart';
import 'wallet_info_card.dart';

class ConnectWalletButton extends ConsumerWidget {
  const ConnectWalletButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);

    if (wallet.isConnected) {
      return const WalletInfoCard();
    }

    return HoverScaleGlow(
      glowColor: AppTheme.neonCyan,
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const WalletConnectModal(),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.neonCyan,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_balance_wallet_outlined, size: 18),
            SizedBox(width: 8),
            Text(
              'Connect Wallet',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

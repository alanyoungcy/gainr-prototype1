import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'package:gainr_solana/gainr_solana.dart';
class WithdrawModal extends ConsumerStatefulWidget {
  const WithdrawModal({super.key});

  @override
  ConsumerState<WithdrawModal> createState() => _WithdrawModalState();
}

class _WithdrawModalState extends ConsumerState<WithdrawModal> {
  final _amountController = TextEditingController();
  bool _isProcessing = false;
  bool _isSuccess = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleWithdraw() async {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) return;

    final wallet = ref.read(walletProvider);
    if (wallet.betBalance < amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient \$BET balance'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);
    await ref.read(walletProvider.notifier).withdraw(amount);

    setState(() {
      _isProcessing = false;
      _isSuccess = true;
    });

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider);

    if (_isSuccess) {
      return _WithdrawSuccessView();
    }

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: AnimatedGradientBorder(
          borderWidth: 1.5,
          borderRadius: 24,
          colors: const [
            Color(0xFF2775CA),
            AppTheme.neonCyan,
            Color(0xFF2775CA),
          ],
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: NeonText(
                        text: 'Withdraw to USDC',
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                        glowColor: AppTheme.neonCyan,
                        glowRadius: 6,
                      ),
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.close, color: AppTheme.textDisabled),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Burn \$BET chips and receive USDC. 1 \$BET = 1 USDC.',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                GlassmorphicContainer(
                  borderRadius: 8,
                  blur: 4,
                  opacity: 0.05,
                  borderColor: AppTheme.gainrGreen.withValues(alpha: 0.15),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.account_balance_wallet,
                            color: AppTheme.gainrGreen, size: 16),
                        const SizedBox(width: 8),
                        NeonText(
                          text:
                              'Available: ${wallet.betBalance.toStringAsFixed(2)} \$BET',
                          style: const TextStyle(
                            color: AppTheme.gainrGreen,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          glowColor: AppTheme.gainrGreen,
                          glowRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Amount Input
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: 'Amount (\$BET)',
                    hintText: '0.00',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppTheme.gainrGreen,
                              Color(0xFF00B894),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.gainrGreen.withValues(alpha: 0.3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('\$',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    suffixIcon: TextButton(
                      onPressed: () {
                        _amountController.text =
                            wallet.betBalance.toStringAsFixed(2);
                      },
                      child: const ShimmerEffect(
                        baseColor: AppTheme.gainrGreen,
                        highlightColor: AppTheme.neonCyan,
                        child: Text('MAX',
                            style: TextStyle(
                                color: AppTheme.gainrGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.black.withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppTheme.neonCyan.withValues(alpha: 0.1),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppTheme.neonCyan.withValues(alpha: 0.1),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppTheme.neonCyan.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                const GlowPulse(
                  glowColor: Color(0xFF2775CA),
                  glowRadius: 8,
                  child: Icon(Icons.arrow_downward,
                      color: Color(0xFF2775CA), size: 24),
                ),
                const SizedBox(height: 16),

                // Conversion Preview
                GlassmorphicContainer(
                  borderRadius: 16,
                  blur: 6,
                  opacity: 0.08,
                  borderColor: const Color(0xFF2775CA).withValues(alpha: 0.25),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('You receive:',
                            style: TextStyle(color: AppTheme.textSecondary)),
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _amountController,
                          builder: (context, value, _) {
                            final amount = double.tryParse(value.text) ?? 0.0;
                            return NeonText(
                              text: '${amount.toStringAsFixed(2)} USDC',
                              style: const TextStyle(
                                color: Color(0xFF2775CA),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              glowColor: const Color(0xFF2775CA),
                              glowRadius: 6,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  height: 56,
                  child: _isProcessing
                      ? AnimatedGradientShift(
                          colors: [
                            AppTheme.gainrGreen.withValues(alpha: 0.5),
                            AppTheme.neonCyan.withValues(alpha: 0.5),
                            AppTheme.gainrGreen.withValues(alpha: 0.5),
                          ],
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: AppTheme.gainrGreen.withValues(alpha: 0.3),
                            ),
                            child: const Center(
                              child: SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              ),
                            ),
                          ),
                        )
                      : HoverScaleGlow(
                          glowColor: AppTheme.gainrGreen,
                          child: ElevatedButton(
                            onPressed: _handleWithdraw,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.gainrGreen,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text(
                              'Confirm Withdrawal',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WithdrawSuccessView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(48),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF2775CA).withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GlowPulse(
                glowColor: const Color(0xFF2775CA),
                glowRadius: 25,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF2775CA).withValues(alpha: 0.2),
                        const Color(0xFF2775CA).withValues(alpha: 0.08),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2775CA).withValues(alpha: 0.2),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check_circle,
                      color: Color(0xFF2775CA), size: 40),
                ),
              ),
              const SizedBox(height: 24),
              NeonText(
                text: 'Withdrawal Complete!',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                glowColor: const Color(0xFF2775CA),
                glowRadius: 10,
              ),
              const SizedBox(height: 12),
              const Text(
                'Your \$BET chips have been burned and USDC sent to your wallet.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


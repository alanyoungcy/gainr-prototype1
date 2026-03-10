import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'package:gainr_solana/gainr_solana.dart';
class DepositModal extends ConsumerStatefulWidget {
  const DepositModal({super.key});

  @override
  ConsumerState<DepositModal> createState() => _DepositModalState();
}

class _DepositModalState extends ConsumerState<DepositModal> {
  final _amountController = TextEditingController();
  bool _isProcessing = false;
  bool _isSuccess = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleDeposit() async {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) return;

    setState(() => _isProcessing = true);
    await ref.read(walletProvider.notifier).deposit(amount);

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
    if (_isSuccess) {
      return _DepositSuccessView();
    }

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: AnimatedGradientBorder(
          borderWidth: 1.5,
          borderRadius: 24,
          colors: const [
            AppTheme.gainrGreen,
            AppTheme.neonCyan,
            AppTheme.gainrGreen,
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
                        text: 'Deposit USDC',
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
                  'Convert USDC to \$BET chips instantly. 1 USDC = 1 \$BET.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 24),

                // Amount Input with neon border
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: 'Amount (USDC)',
                    hintText: '0.00',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF2775CA),
                              Color(0xFF3D9BE9),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2775CA)
                                  .withValues(alpha: 0.3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('S',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ),
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
                  glowColor: AppTheme.gainrGreen,
                  glowRadius: 8,
                  child: Icon(Icons.arrow_downward,
                      color: AppTheme.gainrGreen, size: 24),
                ),
                const SizedBox(height: 16),

                // Conversion Preview with glassmorphism
                GlassmorphicContainer(
                  borderRadius: 16,
                  blur: 6,
                  opacity: 0.08,
                  borderColor: AppTheme.gainrGreen.withValues(alpha: 0.25),
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
                              text: '${amount.toStringAsFixed(2)} \$BET',
                              style: const TextStyle(
                                color: AppTheme.gainrGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              glowColor: AppTheme.gainrGreen,
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
                            onPressed: _handleDeposit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.gainrGreen,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text(
                              'Confirm Deposit',
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

class _DepositSuccessView extends StatelessWidget {
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
              color: AppTheme.gainrGreen.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GlowPulse(
                glowColor: AppTheme.gainrGreen,
                glowRadius: 25,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.gainrGreen.withValues(alpha: 0.2),
                        AppTheme.gainrGreen.withValues(alpha: 0.08),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.gainrGreen.withValues(alpha: 0.2),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.auto_awesome,
                      color: AppTheme.gainrGreen, size: 40),
                ),
              ),
              const SizedBox(height: 24),
              NeonText(
                text: 'Tokens Minted!',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                glowColor: AppTheme.gainrGreen,
                glowRadius: 10,
              ),
              const SizedBox(height: 12),
              const Text(
                'Your USDC has been converted to \$BET chips successfully.',
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


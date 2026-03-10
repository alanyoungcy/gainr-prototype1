import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'package:gainr_models/gainr_models.dart';
import 'package:gainr_mobile/features/betting/providers/bet_slip_provider.dart';
import 'package:gainr_mobile/features/betting/providers/placed_bets_provider.dart';
import 'package:gainr_solana/gainr_solana.dart';
class BetConfirmationModal extends ConsumerStatefulWidget {
  final List<Bet> bets;
  final double totalStake;
  final double totalReturn;

  const BetConfirmationModal({
    super.key,
    required this.bets,
    required this.totalStake,
    required this.totalReturn,
  });

  @override
  ConsumerState<BetConfirmationModal> createState() =>
      _BetConfirmationModalState();
}

class _BetConfirmationModalState extends ConsumerState<BetConfirmationModal> {
  bool _isConfirming = false;
  bool _isSuccess = false;

  Future<void> _placeBet() async {
    setState(() => _isConfirming = true);

    await Future.delayed(const Duration(milliseconds: 1500));

    final wallet = ref.read(walletProvider);
    if (wallet.betBalance < widget.totalStake) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Insufficient \$BET balance')),
        );
        setState(() => _isConfirming = false);
      }
      return;
    }

    await ref.read(walletProvider.notifier).deductBet(widget.totalStake);
    ref.read(placedBetsProvider.notifier).placeBets(widget.bets);

    setState(() {
      _isConfirming = false;
      _isSuccess = true;
    });

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      ref.read(betSlipControllerProvider.notifier).clear();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSuccess) {
      return _SuccessView();
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: AppTheme.neonCyan.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.neonCyan.withValues(alpha: 0.05),
                blurRadius: 30,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NeonText(
                text: 'Review Your Bet',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                glowColor: AppTheme.neonCyan,
                glowRadius: 6,
              ),
              const SizedBox(height: 24),

              // Bet List Summary
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: widget.bets.length,
                  separatorBuilder: (_, __) => Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppTheme.neonCyan.withValues(alpha: 0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  itemBuilder: (context, index) {
                    final bet = widget.bets[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bet.selectionName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.neonCyan,
                                    shadows: [
                                      Shadow(
                                        color: AppTheme.neonCyan
                                            .withValues(alpha: 0.3),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${bet.event.homeTeam.name} vs ${bet.event.awayTeam.name}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '\$${bet.stake.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),
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

              _SummaryRow(
                  label: 'Total Stake',
                  value: '\$${widget.totalStake.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              _SummaryRow(
                label: 'Potential Return',
                value: '\$${widget.totalReturn.toStringAsFixed(2)}',
                valueColor: AppTheme.gainrGreen,
              ),

              const SizedBox(height: 32),

              SizedBox(
                height: 56,
                child: _isConfirming
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
                          onPressed: _placeBet,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.gainrGreen,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text(
                            'Confirm & Place Bet',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _isConfirming ? null : () => Navigator.pop(context),
                child: const Text('Cancel',
                    style: TextStyle(color: AppTheme.textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow(
      {required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                const TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
        valueColor != null
            ? NeonText(
                text: value,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                glowColor: valueColor!,
                glowRadius: 6,
              )
            : Text(
                value,
                style: TextStyle(
                  color: valueColor ?? AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ],
    );
  }
}

class _SuccessView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GlowPulse(
                glowColor: AppTheme.gainrGreen,
                glowRadius: 25,
                child: Container(
                  padding: const EdgeInsets.all(20),
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
                  child: const Icon(Icons.check_circle,
                      color: AppTheme.gainrGreen, size: 64),
                ),
              ),
              const SizedBox(height: 24),
              NeonText(
                text: 'Bet Placed!',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                glowColor: AppTheme.gainrGreen,
                glowRadius: 10,
              ),
              const SizedBox(height: 12),
              const Text(
                'Your transaction is being confirmed on the blockchain.',
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


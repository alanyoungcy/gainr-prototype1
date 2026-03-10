import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'package:gainr_models/gainr_models.dart';
import 'package:gainr_mobile/features/betting/providers/bet_slip_provider.dart';
import 'package:gainr_solana/gainr_solana.dart';
import 'package:gainr_mobile/features/betting/widgets/bet_confirmation_modal.dart';

class BetSlipSheet extends ConsumerWidget {
  const BetSlipSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bets = ref.watch(betSlipControllerProvider);
    final wallet = ref.watch(walletProvider);

    final totalStake = bets.fold(0.0, (sum, bet) => sum + bet.stake);
    final totalReturn = bets.fold(0.0, (sum, bet) => sum + bet.potentialReturn);

    return GlassmorphicContainer(
      borderRadius: 24,
      blur: 8,
      opacity: 0.08,
      borderColor: AppTheme.neonCyan.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NeonText(
                  text: 'Bet Slip (${bets.length})',
                  style: Theme.of(context).textTheme.titleLarge!,
                  glowColor: AppTheme.neonCyan,
                  glowRadius: 4,
                ),
                if (bets.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      ref.read(betSlipControllerProvider.notifier).clear();
                    },
                    child: const Text('Clear All',
                        style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (bets.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Column(
                    children: [
                      GlowPulse(
                        glowColor: AppTheme.neonCyan,
                        glowRadius: 10,
                        child: Icon(Icons.receipt_long,
                            color: Colors.white.withValues(alpha: 0.15),
                            size: 40),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your bet slip is empty',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: bets.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return StaggeredFadeSlide(
                      index: index,
                      child: _BetSlipItem(bet: bets[index]),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            if (bets.isNotEmpty) ...[
              // Gradient divider
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
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Stake',
                      style: TextStyle(color: AppTheme.textSecondary)),
                  Text('\$${totalStake.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('SOL Equivalent',
                      style: TextStyle(
                          color: AppTheme.textDisabled, fontSize: 12)),
                  Text('${(totalStake / 100).toStringAsFixed(4)} SOL',
                      style: const TextStyle(
                          color: AppTheme.textDisabled, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Potential Return',
                      style: TextStyle(color: AppTheme.gainrGreen)),
                  NeonText(
                    text: '\$${totalReturn.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.gainrGreen,
                        fontSize: 18),
                    glowColor: AppTheme.gainrGreen,
                    glowRadius: 6,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: HoverScaleGlow(
                  glowColor: AppTheme.gainrGreen,
                  child: ElevatedButton(
                    onPressed: (wallet.isConnected && totalStake >= 5.0)
                        ? () {
                            HapticFeedback.selectionClick();
                            Navigator.of(context).pop();
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => BetConfirmationModal(
                                bets: bets,
                                totalStake: totalStake,
                                totalReturn: totalReturn,
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.gainrGreen,
                      disabledBackgroundColor: AppTheme.surfaceColor,
                    ),
                    child: Text(wallet.isConnected
                        ? (totalStake > 0 && totalStake < 5.0)
                            ? 'Min. Stake \$5'
                            : 'Place Bet'
                        : 'Connect Wallet First'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BetSlipItem extends ConsumerStatefulWidget {
  final Bet bet;

  const _BetSlipItem({required this.bet});

  @override
  ConsumerState<_BetSlipItem> createState() => _BetSlipItemState();
}

class _BetSlipItemState extends ConsumerState<_BetSlipItem> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.bet.stake.toStringAsFixed(0));
  }

  @override
  void didUpdateWidget(_BetSlipItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentVal = double.tryParse(_controller.text) ?? 0.0;
    if (widget.bet.stake != currentVal && !_controller.selection.isValid) {
      _controller.text = widget.bet.stake.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isInvalid = widget.bet.stake < 5 || widget.bet.stake > 1000000;

    return GlassmorphicContainer(
      borderRadius: 12,
      blur: 4,
      opacity: 0.04,
      borderColor: isInvalid
          ? Colors.redAccent.withValues(alpha: 0.3)
          : AppTheme.neonCyan.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.bet.selectionName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.gainrGreen,
                          shadows: [
                            Shadow(
                              color: AppTheme.gainrGreen.withValues(alpha: 0.3),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${widget.bet.event.homeTeam.name} vs ${widget.bet.event.awayTeam.name}',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close,
                      size: 18, color: AppTheme.textDisabled),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ref
                        .read(betSlipControllerProvider.notifier)
                        .removeBet(widget.bet.id);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Stake:',
                    style:
                        TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        prefixText: '\$ ',
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
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
                            color: AppTheme.neonCyan.withValues(alpha: 0.08),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppTheme.neonCyan.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        final stake = double.tryParse(value) ?? 0.0;
                        ref
                            .read(betSlipControllerProvider.notifier)
                            .updateStake(widget.bet.id, stake);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ShimmerEffect(
                  baseColor: AppTheme.gainrGreen,
                  highlightColor: AppTheme.neonCyan,
                  child: TextButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      const maxStake = 1000000.0;
                      _controller.text = maxStake.toStringAsFixed(0);
                      ref
                          .read(betSlipControllerProvider.notifier)
                          .updateStake(widget.bet.id, maxStake);
                    },
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      foregroundColor: AppTheme.gainrGreen,
                    ),
                    child: const Text('MAX',
                        style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${widget.bet.odd.toStringAsFixed(2)}x',
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    NeonText(
                      text:
                          'Ret: \$${widget.bet.potentialReturn.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.gainrGreen,
                          fontSize: 14),
                      glowColor: AppTheme.gainrGreen,
                      glowRadius: 4,
                    ),
                  ],
                ),
              ],
            ),
            if (widget.bet.stake > 0 && widget.bet.stake < 5)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Min stake is \$5.00',
                  style: TextStyle(color: Colors.redAccent, fontSize: 10),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


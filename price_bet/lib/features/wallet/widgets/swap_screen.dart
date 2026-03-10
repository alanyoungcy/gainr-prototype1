import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'package:gainr_solana/gainr_solana.dart';
import 'dart:ui';

enum _SwapStatus {
  burning,
  releasing,
  routing,
  finalizing,
}

class SwapScreen extends ConsumerStatefulWidget {
  const SwapScreen({super.key});

  @override
  ConsumerState<SwapScreen> createState() => _SwapScreenState();
}

class _SwapScreenState extends ConsumerState<SwapScreen> {
  final TextEditingController _amountController = TextEditingController();
  String _fromToken = 'USDC';
  String _toToken = '\$GBET';
  bool _isSwapping = false;

  SwapResult get _swapResult {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    return ref
        .read(walletProvider.notifier)
        .calculateSwap(_fromToken == '\$GBET' ? 'BET' : _fromToken, _toToken == '\$GBET' ? 'BET' : _toToken, amount);
  }

  void _flipTokens() {
    HapticFeedback.mediumImpact();
    setState(() {
      final temp = _fromToken;
      _fromToken = _toToken;
      _toToken = temp;
    });
  }

  void _showReviewModal() {
    final amountText = _amountController.text;
    if (amountText.isEmpty) return;

    final amount = double.tryParse(amountText) ?? 0.0;
    if (amount <= 0) return;

    final result = _swapResult;
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ReviewSwapModal(
        fromToken: _fromToken,
        toToken: _toToken,
        fromAmount: amount,
        swapResult: result,
        onConfirm: () {
          Navigator.pop(context);
          _handleSwap(amount, result.output);
        },
      ),
    );
  }

  Future<void> _handleSwap(double fromAmount, double toAmount) async {
    HapticFeedback.selectionClick();

    final completed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _SwapProcessingDialog(),
    );

    if (completed == true && mounted) {
      setState(() => _isSwapping = true);

      await ref
          .read(walletProvider.notifier)
          .swap(
            _fromToken == '\$GBET' ? 'BET' : _fromToken,
            _toToken == '\$GBET' ? 'BET' : _toToken,
            fromAmount,
            toAmount,
          );

      if (mounted) {
        setState(() => _isSwapping = false);
        _amountController.clear();
        HapticFeedback.heavyImpact();

        showDialog(
          context: context,
          builder: (context) => _SwapSuccessDialog(
            fromToken: _fromToken,
            toToken: _toToken,
            fromAmount: fromAmount,
            toAmount: toAmount,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider);
    final result = _swapResult;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black.withValues(alpha: 0.8),
              Colors.black.withValues(alpha: 0.6),
              const Color(0xFF0A0A0A).withValues(alpha: 0.4),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios,
                          color: Colors.white, size: 20),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                    ),
                    NeonText(
                      text: 'Swap Tokens',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      glowColor: AppTheme.neonCyan,
                      glowRadius: 6,
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Swap Cards
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      children: [
                        _SwapInputCard(
                          label: 'From',
                          token: _fromToken,
                          balance: _getTokenBalance(wallet, _fromToken),
                          controller: _amountController,
                          onTokenSelect: (t) {
                            HapticFeedback.selectionClick();
                            setState(() => _fromToken = t);
                          },
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 8),
                        _SwapInputCard(
                          label: 'To (Estimated)',
                          token: _toToken,
                          balance: _getTokenBalance(wallet, _toToken),
                          value: result.output.toStringAsFixed(2),
                          isInput: false,
                          onTokenSelect: (t) {
                            HapticFeedback.selectionClick();
                            setState(() => _toToken = t);
                          },
                        ),
                      ],
                    ),

                    // Flip Button
                    GlowPulse(
                      glowColor: AppTheme.gainrGreen,
                      glowRadius: 10,
                      child: GestureDetector(
                        onTap: _flipTokens,
                        child: AnimatedGradientBorder(
                          borderWidth: 2,
                          borderRadius: 100,
                          colors: const [
                            AppTheme.gainrGreen,
                            AppTheme.neonCyan,
                            AppTheme.gainrGreen,
                          ],
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFF1E1E1E),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.swap_vert,
                                color: AppTheme.gainrGreen, size: 24),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Swap Details
                _SwapDetailRow(
                    label: 'Rate',
                    value:
                        '1 $_fromToken ≈ ${result.rate.toStringAsFixed(4)} $_toToken'),
                const _SwapDetailRow(
                    label: 'Slippage Tolerance', value: '0.0%'),
                const _SwapDetailRow(
                  label: 'Price Impact',
                  value: '0.00%',
                  valueColor: AppTheme.gainrGreen,
                ),

                const Spacer(),

                // Swap Button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: _isSwapping
                      ? AnimatedGradientShift(
                          colors: [
                            AppTheme.gainrGreen.withValues(alpha: 0.3),
                            AppTheme.neonCyan.withValues(alpha: 0.3),
                            AppTheme.gainrGreen.withValues(alpha: 0.3),
                          ],
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: AppTheme.gainrGreen.withValues(alpha: 0.2),
                            ),
                            child: const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              ),
                            ),
                          ),
                        )
                      : HoverScaleGlow(
                          glowColor: AppTheme.gainrGreen,
                          child: ElevatedButton(
                            onPressed: wallet.isConnected &&
                                    result.output > 0 &&
                                    (double.tryParse(_amountController.text) ??
                                            0) <=
                                        _getTokenBalance(wallet, _fromToken)
                                ? _showReviewModal
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.gainrGreen,
                              foregroundColor: Colors.black,
                              disabledBackgroundColor:
                                  Colors.white.withValues(alpha: 0.05),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            child: Text(
                              wallet.isConnected
                                  ? ((double.tryParse(_amountController.text) ??
                                              0) >
                                          _getTokenBalance(wallet, _fromToken)
                                      ? 'INSUFFICIENT BALANCE'
                                      : 'REVIEW SWAP')
                                  : 'CONNECT WALLET',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
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

  double _getTokenBalance(dynamic wallet, String token) {
    if (token == 'USDC') return wallet.usdcBalance;
    if (token == '\$GBET') return wallet.betBalance;
    if (token == 'GAINR') return wallet.gainrBalance;
    return 0.0;
  }
}

class _ReviewSwapModal extends StatelessWidget {
  final String fromToken;
  final String toToken;
  final double fromAmount;
  final SwapResult swapResult;
  final VoidCallback onConfirm;

  const _ReviewSwapModal({
    required this.fromToken,
    required this.toToken,
    required this.fromAmount,
    required this.swapResult,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: GlassmorphicContainer(
        borderRadius: 32,
        blur: 10,
        opacity: 0.12,
        borderColor: AppTheme.neonCyan.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  NeonText(
                    text: 'Review Swap',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    glowColor: AppTheme.neonCyan,
                    glowRadius: 6,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              GlassmorphicContainer(
                borderRadius: 20,
                blur: 4,
                opacity: 0.04,
                borderColor: AppTheme.neonCyan.withValues(alpha: 0.08),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _ReviewRow(
                        label: 'From',
                        amount: fromAmount.toStringAsFixed(2),
                        token: fromToken,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: GlowPulse(
                          glowColor: AppTheme.gainrGreen,
                          glowRadius: 6,
                          child: Icon(Icons.arrow_downward,
                              color: AppTheme.gainrGreen, size: 20),
                        ),
                      ),
                      _ReviewRow(
                        label: 'To (Estimated)',
                        amount: swapResult.output.toStringAsFixed(2),
                        token: toToken,
                        isHighlight: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _SwapDetailRow(
                  label: 'Exchange Rate',
                  value:
                      '1 $fromToken = ${swapResult.rate.toStringAsFixed(4)} $toToken'),
              _SwapDetailRow(
                  label: 'Protocol Fee (0.0%)',
                  value: '0.00 $toToken'),
              const _SwapDetailRow(
                label: 'Price Impact',
                value: '0.00%',
                valueColor: AppTheme.gainrGreen,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: HoverScaleGlow(
                  glowColor: AppTheme.gainrGreen,
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.gainrGreen,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      fromToken == '\$GBET' && toToken == 'GAINR'
                          ? 'CONFIRM BRIDGE'
                          : 'CONFIRM SWAP',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwapProcessingDialog extends StatefulWidget {
  const _SwapProcessingDialog();

  @override
  State<_SwapProcessingDialog> createState() => _SwapProcessingDialogState();
}

class _SwapProcessingDialogState extends State<_SwapProcessingDialog> {
  _SwapStatus _status = _SwapStatus.burning;

  @override
  void initState() {
    super.initState();
    _startSimulation();
  }

  Future<void> _startSimulation() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _status = _SwapStatus.releasing);
    HapticFeedback.lightImpact();

    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _status = _SwapStatus.routing);
    HapticFeedback.mediumImpact();

    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _status = _SwapStatus.finalizing);
    HapticFeedback.selectionClick();

    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: AnimatedGradientBorder(
          borderWidth: 1.5,
          borderRadius: 28,
          colors: const [
            AppTheme.gainrGreen,
            AppTheme.neonCyan,
            AppTheme.gainrGreen,
          ],
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF161616),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const GlowPulse(
                    glowColor: AppTheme.gainrGreen,
                    glowRadius: 20,
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation(AppTheme.gainrGreen),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  NeonText(
                    text: _getStatusTitle(),
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    glowColor: AppTheme.neonCyan,
                    glowRadius: 6,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getStatusSubtitle(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _StepIndicator(
                      label: 'Burning \$GBET',
                      isActive: _status == _SwapStatus.burning,
                      isDone: _status.index > _SwapStatus.burning.index),
                  _StepIndicator(
                      label: 'Releasing USDC',
                      isActive: _status == _SwapStatus.releasing,
                      isDone: _status.index > _SwapStatus.releasing.index),
                  _StepIndicator(
                      label: 'AMM Buy (Raydium)',
                      isActive: _status == _SwapStatus.routing,
                      isDone: _status.index > _SwapStatus.routing.index),
                  _StepIndicator(
                      label: 'Settlement',
                      isActive: _status == _SwapStatus.finalizing,
                      isDone: false),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getStatusTitle() {
    switch (_status) {
      case _SwapStatus.burning:
        return 'Burning Assets';
      case _SwapStatus.releasing:
        return 'Releasing Liquidity';
      case _SwapStatus.routing:
        return 'Routing via AMM';
      case _SwapStatus.finalizing:
        return 'Finalizing';
    }
  }

  String _getStatusSubtitle() {
    switch (_status) {
      case _SwapStatus.burning:
        return 'Removing non-transferable chips from vault...';
      case _SwapStatus.releasing:
        return 'Unlocking USDC peg from treasury...';
      case _SwapStatus.routing:
        return 'Executing buy-order on Raydium LP...';
      case _SwapStatus.finalizing:
        return 'Updating on-chain wallet balance...';
    }
  }
}

class _StepIndicator extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isDone;

  const _StepIndicator({
    required this.label,
    required this.isActive,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone
                  ? AppTheme.gainrGreen
                  : (isActive
                      ? AppTheme.gainrGreen.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.1)),
              boxShadow: isDone || isActive
                  ? [
                      BoxShadow(
                        color: AppTheme.gainrGreen.withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(
              color: isDone || isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.3),
              fontSize: 13,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              shadows: isActive
                  ? [
                      Shadow(
                        color: AppTheme.gainrGreen.withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ]
                  : null,
            ),
          ),
          const Spacer(),
          if (isDone)
            const Icon(Icons.check, color: AppTheme.gainrGreen, size: 14),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String amount;
  final String token;
  final bool isHighlight;

  const _ReviewRow({
    required this.label,
    required this.amount,
    required this.token,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            isHighlight
                ? NeonText(
                    text: amount,
                    style: GoogleFonts.outfit(
                      color: AppTheme.gainrGreen,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    glowColor: AppTheme.gainrGreen,
                    glowRadius: 6,
                  )
                : Text(
                    amount,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.neonCyan.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              _TokenIcon(token: token, size: 24),
              const SizedBox(width: 8),
              Text(
                token,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SwapSuccessDialog extends StatelessWidget {
  final String fromToken;
  final String toToken;
  final double fromAmount;
  final double toAmount;

  const _SwapSuccessDialog({
    required this.fromToken,
    required this.toToken,
    required this.fromAmount,
    required this.toAmount,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF161616),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: AppTheme.gainrGreen.withValues(alpha: 0.15),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
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
                          AppTheme.gainrGreen,
                          AppTheme.gainrGreen.withValues(alpha: 0.8),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.gainrGreen.withValues(alpha: 0.3),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child:
                        const Icon(Icons.check, color: Colors.black, size: 40),
                  ),
                ),
                const SizedBox(height: 24),
                NeonText(
                  text: 'Swap Successful!',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  glowColor: AppTheme.gainrGreen,
                  glowRadius: 10,
                ),
                const SizedBox(height: 12),
                Text(
                  'Swapped ${fromAmount.toStringAsFixed(2)} $fromToken for ${toAmount.toStringAsFixed(2)} $toToken',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.05),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Close'),
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

class _SwapInputCard extends StatelessWidget {
  final String label;
  final String token;
  final double balance;
  final TextEditingController? controller;
  final String? value;
  final bool isInput;
  final Function(String)? onTokenSelect;
  final Function(String)? onChanged;

  const _SwapInputCard({
    required this.label,
    required this.token,
    required this.balance,
    this.controller,
    this.value,
    this.isInput = true,
    this.onTokenSelect,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      borderRadius: 24,
      blur: 8,
      opacity: 0.06,
      borderColor: AppTheme.neonCyan.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 13)),
                Text('Balance: ${balance.toStringAsFixed(2)}',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 13)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: isInput
                      ? TextField(
                          controller: controller,
                          onChanged: onChanged,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: const InputDecoration(
                            hintText: '0.00',
                            hintStyle: TextStyle(color: Colors.white12),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        )
                      : Text(
                          value ?? '0.00',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                _TokenSelector(
                  token: token,
                  onTap: () => _showTokenPicker(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTokenPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _TokenPickerModal(
        onSelected: onTokenSelect,
        selectedToken: token,
      ),
    );
  }
}

class _TokenSelector extends StatelessWidget {
  final String token;
  final VoidCallback onTap;

  const _TokenSelector({required this.token, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return HoverScaleGlow(
      glowColor: AppTheme.neonCyan,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              _TokenIcon(token: token, size: 24),
              const SizedBox(width: 8),
              Text(
                token,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down,
                  color: Colors.white54, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _TokenPickerModal extends StatelessWidget {
  final Function(String)? onSelected;
  final String selectedToken;

  const _TokenPickerModal({this.onSelected, required this.selectedToken});

  @override
  Widget build(BuildContext context) {
    final tokens = ['USDC', '\$GBET', 'GAINR'];

    return GlassmorphicContainer(
      borderRadius: 24,
      blur: 15,
      opacity: 0.1,
      borderColor: Colors.white10,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Select Token',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...tokens.map((t) => ListTile(
                leading: _TokenIcon(token: t, size: 32),
                title: Text(t, style: const TextStyle(color: Colors.white)),
                trailing: t == selectedToken
                    ? const Icon(Icons.check, color: AppTheme.gainrGreen)
                    : null,
                onTap: () {
                  onSelected?.call(t);
                  Navigator.pop(context);
                },
              )),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _TokenIcon extends StatelessWidget {
  final String token;
  final double size;

  const _TokenIcon({required this.token, required this.size});

  @override
  Widget build(BuildContext context) {
    Color color = AppTheme.gainrGreen;
    String letter = 'B';

    if (token == 'USDC') {
      color = const Color(0xFF2775CA);
      letter = 'S';
    } else if (token == 'GAINR') {
      color = Colors.purpleAccent;
      letter = 'G';
    } else if (token == '\$GBET') {
      color = AppTheme.gainrGreen;
      letter = 'B';
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withValues(alpha: 0.6),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _SwapDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SwapDetailRow(
      {required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

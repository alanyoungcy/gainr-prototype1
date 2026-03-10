import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'package:gainr_solana/gainr_solana.dart';
class WalletConnectModal extends ConsumerStatefulWidget {
  const WalletConnectModal({super.key});

  @override
  ConsumerState<WalletConnectModal> createState() => _WalletConnectModalState();
}

class _WalletConnectModalState extends ConsumerState<WalletConnectModal>
    with SingleTickerProviderStateMixin {
  bool _isConnecting = false;
  bool _isSuccess = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _connectPhantom() async {
    setState(() => _isConnecting = true);
    await ref.read(walletProvider.notifier).connect();
    if (mounted) {
      setState(() {
        _isConnecting = false;
        _isSuccess = true;
      });
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletProvider);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: AnimatedGradientBorder(
          borderWidth: 1.5,
          borderRadius: 24,
          colors: const [
            Color(0xFFAB9FF2),
            AppTheme.neonCyan,
            AppTheme.gainrGreen,
            Color(0xFFAB9FF2),
          ],
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1B23),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: NeonText(
                        text: 'Connect Wallet',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        glowColor: AppTheme.neonCyan,
                        glowRadius: 6,
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.close,
                            color: Colors.white.withValues(alpha: 0.4),
                            size: 16),
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                Text(
                  'Connect your Solana wallet to start betting',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 28),

                // Connection state
                if (_isConnecting)
                  _buildConnectingView()
                else if (_isSuccess)
                  _buildSuccessView(walletState.displayAddress)
                else ...[
                  // Phantom — Primary
                  _PhantomWalletOption(onTap: _connectPhantom),
                  const SizedBox(height: 10),
                  const _WalletOption(
                    name: 'Solflare',
                    iconColor: Color(0xFFFC8E03),
                    iconLetter: 'S',
                    isDisabled: true,
                  ),
                  const SizedBox(height: 10),
                  const _WalletOption(
                    name: 'Backpack',
                    iconColor: Color(0xFFE33E3F),
                    iconLetter: 'B',
                    isDisabled: true,
                  ),
                  const SizedBox(height: 10),
                  const _WalletOption(
                    name: 'Glow',
                    iconColor: Color(0xFF00D18C),
                    iconLetter: 'G',
                    isDisabled: true,
                  ),
                ],

                if (walletState.hasError) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.neonMagenta.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.redAccent, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            walletState.errorMessage ?? 'Connection failed',
                            style: const TextStyle(
                                color: Colors.redAccent, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 28),

                // Powered by Solana badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShimmerEffect(
                      baseColor: const Color(0xFF9945FF),
                      highlightColor: const Color(0xFF14F195),
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF9945FF), Color(0xFF14F195)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Center(
                          child: Text('◆',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Powered by Solana',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConnectingView() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.1),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFAB9FF2).withValues(
                            alpha: 0.2 + _pulseController.value * 0.15),
                        const Color(0xFF6C5CE7).withValues(
                            alpha: 0.2 + _pulseController.value * 0.15),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFAB9FF2)
                            .withValues(alpha: 0.3 * _pulseController.value),
                        blurRadius: 30,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('👻', style: TextStyle(fontSize: 32)),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const NeonText(
            text: 'Approving in Phantom...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            glowColor: Color(0xFFAB9FF2),
            glowRadius: 6,
          ),
          const SizedBox(height: 8),
          Text(
            'Confirm the connection in your wallet',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 120,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                backgroundColor: Colors.white.withValues(alpha: 0.05),
                valueColor: const AlwaysStoppedAnimation(Color(0xFFAB9FF2)),
                minHeight: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(String address) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          GlowPulse(
            glowColor: AppTheme.gainrGreen,
            glowRadius: 20,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.gainrGreen.withValues(alpha: 0.2),
                    AppTheme.gainrGreen.withValues(alpha: 0.08),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.check_circle,
                    color: AppTheme.gainrGreen, size: 40),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const NeonText(
            text: 'Connected!',
            style: TextStyle(
              color: AppTheme.gainrGreen,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            glowColor: AppTheme.gainrGreen,
            glowRadius: 8,
          ),
          const SizedBox(height: 8),
          GlassmorphicContainer(
            borderRadius: 8,
            blur: 4,
            opacity: 0.05,
            borderColor: AppTheme.neonCyan.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                address,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 13,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhantomWalletOption extends StatelessWidget {
  final VoidCallback onTap;

  const _PhantomWalletOption({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return HoverScaleGlow(
      glowColor: const Color(0xFFAB9FF2),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFAB9FF2).withValues(alpha: 0.08),
                const Color(0xFF6C5CE7).withValues(alpha: 0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFAB9FF2).withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFAB9FF2), Color(0xFF6C5CE7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFAB9FF2).withValues(alpha: 0.2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('👻', style: TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Phantom',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Solana • Auto-detected',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              ShimmerEffect(
                baseColor: AppTheme.gainrGreen,
                highlightColor: AppTheme.neonCyan,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.gainrGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppTheme.gainrGreen.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Text(
                    'Popular',
                    style: TextStyle(
                      color: AppTheme.gainrGreen,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withValues(alpha: 0.3),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalletOption extends StatelessWidget {
  final String name;
  final Color iconColor;
  final String iconLetter;
  final bool isDisabled;

  const _WalletOption({
    required this.name,
    required this.iconColor,
    required this.iconLetter,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                iconLetter,
                style: TextStyle(
                  color: iconColor.withValues(alpha: 0.7),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Soon',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.2),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


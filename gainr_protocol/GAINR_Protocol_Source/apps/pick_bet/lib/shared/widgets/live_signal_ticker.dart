import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:pick_bet/features/dashboard/providers/leaderboard_provider.dart';

class LiveSignalTicker extends ConsumerStatefulWidget {
  const LiveSignalTicker({super.key});

  @override
  ConsumerState<LiveSignalTicker> createState() => _LiveSignalTickerState();
}

class _LiveSignalTickerState extends ConsumerState<LiveSignalTicker> {
  late ScrollController _scrollController;
  late Timer _timer;
  final List<String> _signals = [
    'TRUMP_WIN_PA @ 51.2% (PROB_SURGE)',
    'FED_Pivot_Nov @ 68.0% (ALPHA_PLAY)',
    'SENATE_GOP_Control @ 55.4% (WHALE_STAKE)',
    'ABORTION_RIGHTS_REF @ 58.1% (VOLATILITY)',
    'CA_Reparations_Yes @ 12.4% (SHORT_INTEREST)',
    'Student_Loan_Forgiveness @ 45% (RECOVERY)',
    'NATO_Expansion_Yes @ 38.5% (STABLE)',
    'TARIFF_Implementation @ 62% (TRENDING)',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  void _startScrolling() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_scrollController.hasClients) {
        double maxScroll = _scrollController.position.maxScrollExtent;
        double currentScroll = _scrollController.offset;
        if (currentScroll >= maxScroll) {
          _scrollController.jumpTo(0);
        } else {
          _scrollController.animateTo(
            currentScroll + 1,
            duration: const Duration(milliseconds: 50),
            curve: Curves.linear,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for new signals and add to the list
    ref.listen(signalStreamProvider, (previous, next) {
      if (next.hasValue) {
        setState(() {
          _signals.insert(0, next.value!);
          if (_signals.length > 50) _signals.removeLast();
        });
      }
    });

    return Container(
      height: 32,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.symmetric(
          horizontal:
              BorderSide(color: AppColors.neonOrange.withValues(alpha: 0.1)),
        ),
      ),
      child: ShimmerEffect(
        baseColor: Colors.white.withValues(alpha: 0.05),
        highlightColor: AppColors.neonOrange.withValues(alpha: 0.1),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              color: AppColors.neonOrange,
              child: const Center(
                child: NeonText(
                  text: 'LIVE_ALPHA',
                  glowColor: Colors.black,
                  glowRadius: 2,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const GlowPulse(
              glowColor: AppColors.neonOrange,
              glowRadius: 4,
              child: Icon(LucideIcons.radio,
                  color: AppColors.neonOrange, size: 12),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final signal = _signals[index % _signals.length];
                  return Padding(
                    padding: const EdgeInsets.only(right: 48),
                    child: Center(
                      child: Text(
                        signal.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white30,
                          fontSize: 10,
                          fontFamily: 'monospace',
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

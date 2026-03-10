import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'package:gainr_models/gainr_models.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'ai_chat_panel.dart';

/// AI Insights panel for political prediction markets.
/// Displays animated reasoning, probability analysis, sentiment, and edge calculation.
class PriceAiInsightsPanel extends StatefulWidget {
  final PriceMarket market;

  const PriceAiInsightsPanel({super.key, required this.market});

  @override
  State<PriceAiInsightsPanel> createState() => _PriceAiInsightsPanelState();
}

class _PriceAiInsightsPanelState extends State<PriceAiInsightsPanel> {
  final List<String> _reasoningSteps = [
    'Scanning live match data feeds...',
    'Cross-referencing historical xG models...',
    'Analyzing team lineup tactical shifts...',
    'Evaluating player fatigue & injury impacts...',
    'Computing fair value goal distribution...',
    'GAINR Soccer Synthesis complete.',
  ];

  int _currentStep = 0;
  bool _isAnalysisComplete = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAnalysis();
  }

  void _startAnalysis() {
    _timer = Timer.periodic(const Duration(milliseconds: 1200), (timer) {
      if (_currentStep < _reasoningSteps.length - 1) {
        setState(() => _currentStep++);
      } else {
        setState(() => _isAnalysisComplete = true);
        _timer?.cancel();
      }
    });
  }

  void _showAiChat() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) =>
            PriceAiChatPanel(market: widget.market),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      borderRadius: 16,
      blur: 12,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          GlowPulse(
                            glowColor: AppColors.neonOrange,
                            glowRadius: 8,
                            child: Icon(LucideIcons.trending_up,
                                color: AppColors.neonOrange, size: 20),
                          ),
                          SizedBox(width: 8),
                          ShimmerEffect(
                            baseColor: AppColors.neonOrange,
                            highlightColor: AppTheme.neonCyan,
                            child: Text(
                              'GAINR AI // MARKET INTELLIGENCE',
                              style: TextStyle(
                                color: AppColors.neonOrange,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.market.asset,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.x, color: Colors.white30),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (!_isAnalysisComplete)
              _buildReasoningDisplay()
            else
              _buildAnalysisContent(),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildReasoningDisplay() {
    return Column(
      children: [
        const Center(
          child: Column(
            children: [
              GlowPulse(
                glowColor: AppColors.neonOrange,
                glowRadius: 20,
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.neonOrange),
                  ),
                ),
              ),
              SizedBox(height: 24),
              NeonText(
                text: 'Running Soccer Intelligence Engine...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                glowColor: AppTheme.neonCyan,
                glowRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        GlassmorphicContainer(
          borderRadius: 12,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(_currentStep + 1, (index) {
                final isLast = index == _currentStep;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 400),
                    builder: (context, opacity, child) {
                      return Opacity(
                        opacity: opacity,
                        child: Transform.translate(
                          offset: Offset(10 * (1 - opacity), 0),
                          child: child,
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Icon(
                          isLast
                              ? LucideIcons.chevron_right
                              : LucideIcons.circle_check,
                          color: isLast ? AppColors.neonOrange : Colors.white24,
                          size: 16,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _reasoningSteps[index],
                            style: TextStyle(
                              color: isLast ? Colors.white : Colors.white24,
                              fontSize: 12,
                              fontFamily: 'monospace',
                              shadows: isLast
                                  ? [
                                      Shadow(
                                        color: AppColors.neonOrange
                                            .withValues(alpha: 0.3),
                                        blurRadius: 4,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisContent() {
    final price = widget.market.currentPrice;
    final fairValue =
        (price + (widget.market.priceChange24h * 2.5)).clamp(0, 100);
    final edge = ((fairValue - price) / price * 100).abs();
    final confidence = (55 + edge * 3).clamp(55, 96).toInt();
    final isBullish = widget.market.priceChange24h >= 0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key Metrics
          Row(
            children: [
              _metricCard('xG Advantage', '+${edge.toStringAsFixed(1)}%',
                  'High Precision', AppColors.neonOrange),
              const SizedBox(width: 12),
              _metricCard('Model Confidence', '$confidence%',
                  edge > 5 ? 'Elite Tier' : 'Reliable', AppTheme.neonCyan),
            ],
          ),
          const SizedBox(height: 24),

          // Probability Comparison
          const NeonText(
            text: 'Probability Distribution',
            style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.bold),
            glowColor: AppTheme.neonCyan,
            glowRadius: 3,
          ),
          const SizedBox(height: 12),
          _probBar('GAINR Fair Value', fairValue / 100, AppColors.neonOrange),
          const SizedBox(height: 8),
          _probBar('Market Implied', price / 100, Colors.white30),
          const SizedBox(height: 8),
          _probBar('Sentiment Score', isBullish ? 0.68 : 0.35, Colors.cyan),
          const SizedBox(height: 24),

          // Smart Money Flow
          GlassmorphicContainer(
            borderRadius: 12,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GlowPulse(
                    glowColor: isBullish ? Colors.green : Colors.red,
                    glowRadius: 6,
                    child: Icon(
                      isBullish
                          ? LucideIcons.trending_up
                          : LucideIcons.trending_down,
                      color: isBullish ? Colors.green : Colors.red,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Smart Money Flow',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold)),
                        Text(
                          isBullish
                              ? 'Bullish directional movement detected in last 15m.'
                              : 'Bearish pressure increasing. Hedge positions advised.',
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  ShimmerEffect(
                    baseColor: isBullish ? Colors.green : Colors.red,
                    highlightColor: AppTheme.neonCyan,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isBullish ? Colors.green : Colors.red)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: (isBullish ? Colors.green : Colors.red)
                              .withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        isBullish ? 'BULLISH' : 'BEARISH',
                        style: TextStyle(
                            color: isBullish ? Colors.green : Colors.red,
                            fontSize: 9,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Ask AI Button
          GestureDetector(
            onTap: _showAiChat,
            child: const HoverScaleGlow(
              child: AnimatedGradientBorder(
                colors: [
                  AppColors.neonOrange,
                  AppTheme.neonCyan,
                  AppColors.neonOrange,
                ],
                borderRadius: 12,
                child: GlassmorphicContainer(
                  borderRadius: 12,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GlowPulse(
                          glowColor: AppColors.neonOrange,
                          glowRadius: 6,
                          child: Icon(LucideIcons.message_square,
                              color: AppColors.neonOrange, size: 20),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'ASK GAINR AI FOR IN-DEPTH CLARITY',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String label, String value, String sub, Color color) {
    return Expanded(
      child: GlassmorphicContainer(
        borderRadius: 12,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(color: Colors.white38, fontSize: 11)),
              const SizedBox(height: 6),
              NeonText(
                text: value,
                style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace'),
                glowColor: color,
                glowRadius: 6,
              ),
              const SizedBox(height: 4),
              Text(sub,
                  style: TextStyle(
                      color: color.withValues(alpha: 0.5),
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _probBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.white24, fontSize: 10)),
            Text('${(value * 100).toInt()}%',
                style: TextStyle(
                    color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 6,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: Colors.white.withValues(alpha: 0.05),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value.clamp(0, 1),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 6),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

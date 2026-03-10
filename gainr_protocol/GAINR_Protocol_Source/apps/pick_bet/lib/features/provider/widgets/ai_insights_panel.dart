import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'package:gainr_models/gainr_models.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'ai_chat_panel.dart';

/// AI Insights panel for signal provider analysis.
/// Displays animated reasoning, provider alpha metrics, signal quality, and conviction score.
class PickAiInsightsPanel extends StatefulWidget {
  final PickProvider provider;

  const PickAiInsightsPanel({super.key, required this.provider});

  @override
  State<PickAiInsightsPanel> createState() => _PickAiInsightsPanelState();
}

class _PickAiInsightsPanelState extends State<PickAiInsightsPanel> {
  final List<String> _reasoningSteps = [
    'Analyzing provider signal history...',
    'Cross-referencing ROI with market benchmarks...',
    'Evaluating consistency and drawdown patterns...',
    'Scanning subscriber growth velocity...',
    'Computing alpha generation score...',
    'GAINR Provider Intelligence complete.',
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
            PickAiChatPanel(provider: widget.provider),
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
      child: SingleChildScrollView(
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
                              glowColor: AppTheme.neonOrange,
                              glowRadius: 8,
                              child: Icon(LucideIcons.brain,
                                  color: AppTheme.neonOrange, size: 20),
                            ),
                            SizedBox(width: 8),
                            ShimmerEffect(
                              baseColor: AppTheme.neonOrange,
                              highlightColor: AppTheme.neonCyan,
                              child: Text(
                                'GAINR AI // PROVIDER INTEL',
                                style: TextStyle(
                                  color: AppTheme.neonOrange,
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
                          widget.provider.name.toUpperCase(),
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
                glowColor: AppTheme.neonOrange,
                glowRadius: 20,
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppTheme.neonOrange),
                  ),
                ),
              ),
              SizedBox(height: 24),
              NeonText(
                text: 'Analyzing Provider Alpha...',
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
                          color: isLast ? AppTheme.neonOrange : Colors.white24,
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
                                        color: AppTheme.neonOrange
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
    final winRate = widget.provider.winRate;
    final roi = widget.provider.roi;
    final alphaScore = (winRate * 40 + (roi / 100).clamp(0, 60)).clamp(0, 100);
    final conviction = winRate > 0.65
        ? 'HIGH'
        : winRate > 0.55
            ? 'MODERATE'
            : 'LOW';

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
              _metricCard('Alpha Score', alphaScore.toStringAsFixed(0),
                  'Out of 100', AppTheme.neonOrange),
              const SizedBox(width: 12),
              _metricCard(
                  'Conviction',
                  conviction,
                  '${(winRate * 100).toStringAsFixed(0)}% Win Rate',
                  conviction == 'HIGH' ? Colors.green : AppTheme.neonCyan),
            ],
          ),
          const SizedBox(height: 24),

          // Performance Analysis
          const NeonText(
            text: 'Performance Analysis',
            style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.bold),
            glowColor: AppTheme.neonCyan,
            glowRadius: 3,
          ),
          const SizedBox(height: 12),
          _qualityBar('Signal Accuracy', winRate, Colors.green),
          const SizedBox(height: 8),
          _qualityBar('Consistency', _consistencyScore(), AppTheme.neonOrange),
          const SizedBox(height: 8),
          _qualityBar('Risk Management', _riskScore(), AppTheme.neonCyan),
          const SizedBox(height: 8),
          _qualityBar('Subscriber Trust',
              (widget.provider.followers / 7000).clamp(0, 1), Colors.purple),
          const SizedBox(height: 24),

          // AI Recommendation
          AnimatedGradientBorder(
            borderWidth: 1.5,
            borderRadius: 12,
            colors: const [
              AppTheme.neonOrange,
              AppTheme.neonCyan,
              AppTheme.neonMagenta,
              AppTheme.neonOrange,
            ],
            duration: const Duration(seconds: 4),
            child: GlassmorphicContainer(
              borderRadius: 12,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const GlowPulse(
                      glowColor: AppTheme.neonOrange,
                      glowRadius: 6,
                      child: Icon(LucideIcons.sparkles,
                          color: AppTheme.neonOrange, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('AI Recommendation',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            _getRecommendation(),
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: ShimmerEffect(
                        baseColor: AppTheme.neonOrange,
                        highlightColor: AppTheme.neonCyan,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.neonOrange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: AppTheme.neonOrange.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            alphaScore > 70 ? 'SUBSCRIBE' : 'WATCH',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: AppTheme.neonOrange,
                                fontSize: 9,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
                  AppTheme.neonOrange,
                  AppTheme.neonCyan,
                  AppTheme.neonOrange,
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
                          glowColor: AppTheme.neonOrange,
                          glowRadius: 6,
                          child: Icon(LucideIcons.message_square,
                              color: AppTheme.neonOrange, size: 20),
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

  double _consistencyScore() {
    final history = widget.provider.performanceHistory;
    if (history.length < 2) return 0.5;
    double variance = 0;
    final avg = history.reduce((a, b) => a + b) / history.length;
    for (final h in history) {
      variance += (h - avg) * (h - avg);
    }
    variance /= history.length;
    return (1 - variance).clamp(0, 1);
  }

  double _riskScore() {
    return widget.provider.winRate > 0.6 ? 0.78 : 0.52;
  }

  String _getRecommendation() {
    if (widget.provider.winRate > 0.7) {
      return 'Elite-tier provider. Consistent alpha generation with strong risk-adjusted returns.';
    } else if (widget.provider.winRate > 0.6) {
      return 'Solid performer with above-average signal quality. Consider allocating 5-10% of portfolio.';
    } else {
      return 'Developing provider. Monitor for 30 more signals before committing capital.';
    }
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

  Widget _qualityBar(String label, double value, Color color) {
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

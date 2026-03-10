import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'package:gainr_models/gainr_models.dart';
import 'package:gainr_mobile/features/betting/widgets/ai_chat_panel.dart';

class AiInsightsPanel extends StatefulWidget {
  final Event event;

  const AiInsightsPanel({super.key, required this.event});

  @override
  State<AiInsightsPanel> createState() => _AiInsightsPanelState();
}

class _AiInsightsPanelState extends State<AiInsightsPanel> {
  final List<String> _reasoningSteps = [
    'Scanning historical head-to-head data...',
    'Analyzing recent team form and momentum...',
    'Evaluating injury reports and lineup changes...',
    'Aggregating global market sentiment...',
    'Calculating implied vs. fair value probability...',
    'System 2 Logic Synthesis complete.',
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
        setState(() {
          _currentStep++;
        });
      } else {
        setState(() {
          _isAnalysisComplete = true;
        });
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      borderRadius: 32,
      blur: 10,
      opacity: 0.1,
      borderColor: AppTheme.neonCyan.withValues(alpha: 0.08),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const GlowPulse(
                          glowColor: AppTheme.gainrGreen,
                          glowRadius: 8,
                          child: Icon(Icons.psychology,
                              color: AppTheme.gainrGreen, size: 20),
                        ),
                        const SizedBox(width: 8),
                        ShimmerEffect(
                          baseColor: AppTheme.gainrGreen,
                          highlightColor: AppTheme.neonCyan,
                          child: Text(
                            'GAINR AI INSIGHTS',
                            style: GoogleFonts.outfit(
                              color: AppTheme.gainrGreen,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.event.homeTeam.name} vs ${widget.event.awayTeam.name}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppTheme.textDisabled),
                ),
              ],
            ),
            const SizedBox(height: 32),

            if (!_isAnalysisComplete)
              _buildReasoningDisplay()
            else
              _buildDeepAnalysisContent(),

            const SizedBox(height: 20),

            // Ask AI Chat Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: HoverScaleGlow(
                glowColor: AppTheme.gainrGreen,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => AiChatPanel(event: widget.event),
                    );
                  },
                  icon: const Text('💬', style: TextStyle(fontSize: 16)),
                  label: const Text(
                    'Ask GAINR AI',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.gainrGreen,
                    side: BorderSide(
                        color: AppTheme.gainrGreen.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildReasoningDisplay() {
    return Column(
      children: [
        Center(
          child: Column(
            children: [
              const GlowPulse(
                glowColor: AppTheme.gainrGreen,
                glowRadius: 20,
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppTheme.gainrGreen),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              NeonText(
                text: 'Running Neural Simulation...',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                glowColor: AppTheme.neonCyan,
                glowRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        GlassmorphicContainer(
          borderRadius: 16,
          blur: 4,
          opacity: 0.04,
          borderColor: AppTheme.neonCyan.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(_currentStep + 1, (index) {
                final isLast = index == _currentStep;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
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
                              ? Icons.arrow_right
                              : Icons.check_circle_outline,
                          color: isLast
                              ? AppTheme.gainrGreen
                              : AppTheme.textDisabled,
                          size: 16,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _reasoningSteps[index],
                            style: TextStyle(
                              color:
                                  isLast ? Colors.white : AppTheme.textDisabled,
                              fontSize: 13,
                              fontFamily: 'monospace',
                              shadows: isLast
                                  ? [
                                      Shadow(
                                        color: AppTheme.gainrGreen
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

  Widget _buildDeepAnalysisContent() {
    final fairProxy = widget.event.fairProbabilities;
    final impliedProxy = widget.event.impliedProbabilities;

    // Convert map to list [home, draw, away] for existing UI structure
    // If 2-way, draw is 0.0
    final gainr = [fairProxy['home']!, fairProxy['draw']!, fairProxy['away']!];

    final market = [
      impliedProxy['home']!,
      impliedProxy['draw']!,
      impliedProxy['away']!
    ];

    final edgePercent = widget.event.aiEdge.toStringAsFixed(1);

    // Determine confidence label based on edge or sentiment
    String confLabel = 'Moderate';
    if (widget.event.aiEdge > 5.0) confLabel = 'High Quality';
    if (widget.event.aiEdge > 10.0) confLabel = 'Elite Value';

    // Mock confidence score visualization
    final confidence = (60 + (widget.event.aiEdge * 4)).clamp(60, 98).toInt();

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
          // Key Metrics Row
          Row(
            children: [
              _buildMetricCard(
                'Calculated Edge',
                '+$edgePercent%',
                'EV Positive',
                AppTheme.gainrGreen,
              ),
              const SizedBox(width: 16),
              _buildMetricCard(
                'Confidence',
                '$confidence%',
                confLabel,
                AppTheme.gainrBlue,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Probability Chart
          const NeonText(
            text: 'Outcome Probability Distribution',
            style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.bold),
            glowColor: AppTheme.neonCyan,
            glowRadius: 3,
          ),
          const SizedBox(height: 16),
          _buildProbabilityBar(
              'GAINR Prediction', gainr[0], gainr[1], gainr[2]),
          const SizedBox(height: 12),
          _buildProbabilityBar(
              'Market Implied', market[0], market[1], market[2]),
          const SizedBox(height: 32),

          // Market Sentiment
          GlassmorphicContainer(
            borderRadius: 12,
            blur: 4,
            opacity: 0.04,
            borderColor: AppTheme.gainrGreen.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const GlowPulse(
                    glowColor: AppTheme.gainrGreen,
                    glowRadius: 6,
                    child: Icon(Icons.trending_up,
                        color: AppTheme.gainrGreen, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Smart Money Flow',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Directional movement detected on ${widget.event.homeTeam.name} in last 15m.',
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  ShimmerEffect(
                    baseColor: AppTheme.gainrGreen,
                    highlightColor: AppTheme.neonCyan,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.gainrGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppTheme.gainrGreen.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        widget.event.sentiment.name.toUpperCase(),
                        style: const TextStyle(
                            color: AppTheme.gainrGreen,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
      String label, String value, String subtext, Color color) {
    return Expanded(
      child: GlassmorphicContainer(
        borderRadius: 16,
        blur: 4,
        opacity: 0.04,
        borderColor: color.withValues(alpha: 0.15),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12)),
              const SizedBox(height: 8),
              NeonText(
                text: value,
                style: GoogleFonts.outfit(
                  color: color,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                glowColor: color,
                glowRadius: 8,
              ),
              const SizedBox(height: 4),
              Text(subtext,
                  style: TextStyle(
                      color: color.withValues(alpha: 0.6),
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProbabilityBar(
      String label, double home, double draw, double away) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: AppTheme.textDisabled, fontSize: 11)),
        const SizedBox(height: 8),
        Container(
          height: 12,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: Colors.white10,
            boxShadow: [
              BoxShadow(
                color: AppTheme.gainrGreen.withValues(alpha: 0.05),
                blurRadius: 4,
              ),
            ],
          ),
          child: Row(
            children: [
              Flexible(
                  flex: (home * 100).toInt(),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.gainrGreen,
                          Color(0xFF00B894),
                        ],
                      ),
                    ),
                  )),
              Flexible(
                  flex: (draw * 100).toInt(),
                  child: Container(color: AppTheme.gainrBlue)),
              Flexible(
                  flex: (away * 100).toInt(),
                  child: Container(color: Colors.white.withValues(alpha: 0.2))),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('1: ${(home * 100).toInt()}%',
                style: const TextStyle(color: Colors.white60, fontSize: 9)),
            Text('X: ${(draw * 100).toInt()}%',
                style: const TextStyle(color: Colors.white60, fontSize: 9)),
            Text('2: ${(away * 100).toInt()}%',
                style: const TextStyle(color: Colors.white60, fontSize: 9)),
          ],
        ),
      ],
    );
  }
}


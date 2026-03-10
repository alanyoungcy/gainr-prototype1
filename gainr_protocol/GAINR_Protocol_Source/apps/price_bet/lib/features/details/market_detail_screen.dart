import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'package:gainr_models/gainr_models.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:price_bet/features/dashboard/providers/market_provider.dart';
import 'package:price_bet/features/dashboard/widgets/ai_insights_panel.dart';

class MarketDetailScreen extends ConsumerStatefulWidget {
  final String marketId;
  const MarketDetailScreen({super.key, required this.marketId});

  @override
  ConsumerState<MarketDetailScreen> createState() => _MarketDetailScreenState();
}

class _MarketDetailScreenState extends ConsumerState<MarketDetailScreen> {
  WhaleAlert? _currentWhaleAlert;
  final double _sentimentValue = 0.72; // Mock value
  String _selectedTimeframe = '1M';
  bool _showExtraNews = false;

  final Map<String, List<FlSpot>> _probabilityData = {
    '1M': [
      const FlSpot(0, 48),
      const FlSpot(2, 50),
      const FlSpot(4, 49),
      const FlSpot(6, 52),
      const FlSpot(8, 51),
      const FlSpot(10, 54),
      const FlSpot(12, 53),
    ],
    '5M': [
      const FlSpot(0, 40),
      const FlSpot(2, 45),
      const FlSpot(4, 42),
      const FlSpot(6, 48),
      const FlSpot(8, 50),
      const FlSpot(10, 52),
      const FlSpot(12, 55),
    ],
  };

  @override
  void initState() {
    super.initState();
    // Simulate a whale alert after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _currentWhaleAlert = WhaleAlert(
            asset: 'US_PRES_2024',
            amount: '2,450,000',
            type: 'YES',
            timestamp: DateTime.now(),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final marketsAsync = ref.watch(marketsProvider);

    // Listen for terminal events to show whale alerts
    ref.listen(intelStreamProvider, (previous, next) {
      if (next.hasValue) {
        final event = next.value!;
        if (event.type == TerminalEventType.whaleAlert && event.data != null) {
          setState(() {
            _currentWhaleAlert = WhaleAlert(
              asset: event.data!['asset'] ?? 'Unknown',
              amount: event.data!['amount'] ?? '0',
              type: event.data!['type'] ?? 'LONG',
              timestamp: event.timestamp,
            );
          });
        }
      }
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 900;
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              marketsAsync.when(
                data: (markets) {
                  final market = markets.firstWhere(
                      (m) => m.id == widget.marketId,
                      orElse: () => markets.first);
                  return _buildDetailContent(context, ref, market, isNarrow);
                },
                loading: () => const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.neonOrange)),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
              if (_currentWhaleAlert != null)
                Positioned(
                  bottom: 100,
                  left: 24,
                  child: WhaleAlertOverlay(
                    alert: _currentWhaleAlert!,
                    onDismiss: () => setState(() => _currentWhaleAlert = null),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailContent(
      BuildContext context, WidgetRef ref, PriceMarket market, bool isNarrow) {
    final livePrice = ref.watch(priceStreamProvider(market.asset));

    final mainContent = isNarrow
        ? Column(
            children: [
              _buildProbabilityChart(market, livePrice, isNarrow),
              Column(
                children: [
                  LiveSentimentGauge(
                    value: _sentimentValue,
                    assetName: market.asset,
                  ),
                  const SizedBox(height: 16),
                  // AI Insights Button
                  _buildAiInsightsButton(context, market),
                  const SizedBox(height: 16),
                  _buildOrderPanel(context, market),
                ],
              ),
              const SizedBox(height: 32),
              _buildNewsFeed(),
              const SizedBox(height: 48),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Probability Chart & News Feed
              Expanded(
                child: Column(
                  children: [
                    _buildProbabilityChart(market, livePrice, isNarrow),
                    _buildNewsFeed(),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Right: Sidebar (Gauge + Order Panel)
              SizedBox(
                width: 320,
                child: Column(
                  children: [
                    LiveSentimentGauge(
                      value: _sentimentValue,
                      assetName: market.asset,
                    ),
                    const SizedBox(height: 16),
                    // AI Insights Button
                    _buildAiInsightsButton(context, market),
                    const SizedBox(height: 16),
                    _buildOrderPanel(context, market),
                  ],
                ),
              ),
            ],
          );

    return SingleChildScrollView(
      child: Column(
        children: [
          // 1. Header Terminal
          _buildHeader(context, market, isNarrow),

          const SizedBox(height: 24),

          // 2. Main Content
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: mainContent,
              ),
            ),
          ),

          GainrFooter(
            systemId: 'PRICE_INTEL_v1.4',
            extraLinks: [
              FooterLink(label: 'MARKET_RULES', onTap: () {}),
              FooterLink(label: 'INTEL_DATA_SOURCE', onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAiInsightsButton(BuildContext context, PriceMarket market) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: HoverScaleGlow(
        glowColor: AppColors.neonOrange,
        child: OutlinedButton.icon(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.1,
                ),
                child: PriceAiInsightsPanel(market: market),
              ),
            );
          },
          icon: const Icon(LucideIcons.brain, size: 18),
          label: const Text(
            'AI INTELLIGENCE',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              fontSize: 11,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.neonOrange,
            side: BorderSide(
              color: AppColors.neonOrange.withValues(alpha: 0.5),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, PriceMarket market, bool isNarrow) {
    final stats = [
      _buildStat(
          'TOT_VOLUME', '\$${(market.totalStaked / 100).toStringAsFixed(1)}M'),
      const SizedBox(width: 24),
      _buildStat('SENTIMENT', 'BULLISH', color: Colors.green),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF0A0A0A),
        border: Border(bottom: BorderSide(color: Colors.white12)),
      ),
      child: isNarrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.arrow_left,
                          color: Colors.white),
                      onPressed: () => context.go('/'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: NeonText(
                        text:
                            'POLITICAL_ODDS // ${market.asset.toUpperCase()}_v.24',
                        glowColor: AppColors.neonOrange,
                        glowRadius: 4,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.neonOrange,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: stats,
                ),
              ],
            )
          : Row(
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.arrow_left, color: Colors.white),
                  onPressed: () => context.go('/'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: NeonText(
                    text:
                        'POLITICAL_ODDS // ${market.asset.toUpperCase()}_v.24',
                    glowColor: AppColors.neonOrange,
                    glowRadius: 4,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.neonOrange,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ...stats,
              ],
            ),
    );
  }

  Widget _buildProbabilityChart(
      PriceMarket market, AsyncValue<double> livePrice, bool isNarrow) {
    final spots =
        _probabilityData[_selectedTimeframe] ?? _probabilityData['1M']!;

    return GlassmorphicContainer(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      borderRadius: 12,
      blur: 15,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isNarrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('WIN_PROBABILITY',
                                style: TextStyle(
                                    color: Colors.white30, fontSize: 10)),
                            const SizedBox(height: 4),
                            livePrice.when(
                              data: (p) => NeonText(
                                text: '${p.toStringAsFixed(1)}%',
                                glowColor: AppColors.neonOrange,
                                glowRadius: 10,
                                style: AppTextStyles.h1.copyWith(fontSize: 32),
                              ),
                              loading: () => NeonText(
                                text: '54.2%',
                                glowColor: AppColors.neonOrange,
                                glowRadius: 10,
                                style: AppTextStyles.h1.copyWith(fontSize: 32),
                              ),
                              error: (_, __) => const Text('ERR'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _timeframeBtn('1M'),
                          _timeframeBtn('5M'),
                          _timeframeBtn('15M'),
                          _timeframeBtn('1H'),
                        ],
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('WIN_PROBABILITY',
                            style:
                                TextStyle(color: Colors.white30, fontSize: 10)),
                        const SizedBox(height: 4),
                        livePrice.when(
                          data: (p) => NeonText(
                            text: '${p.toStringAsFixed(1)}%',
                            glowColor: AppColors.neonOrange,
                            glowRadius: 10,
                            style: AppTextStyles.h1.copyWith(fontSize: 32),
                          ),
                          loading: () => NeonText(
                            text: '54.2%',
                            glowColor: AppColors.neonOrange,
                            glowRadius: 10,
                            style: AppTextStyles.h1.copyWith(fontSize: 32),
                          ),
                          error: (_, __) => const Text('ERR'),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _timeframeBtn('1M'),
                        _timeframeBtn('5M'),
                        _timeframeBtn('15M'),
                        _timeframeBtn('1H'),
                      ],
                    ),
                  ],
                ),
          const SizedBox(height: 32),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.neonOrange,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.neonOrange.withValues(alpha: 0.1),
                          Colors.transparent
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
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

  Widget _timeframeBtn(String label) {
    final active = _selectedTimeframe == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedTimeframe = label),
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.neonOrange : Colors.transparent,
          border:
              Border.all(color: active ? Colors.transparent : Colors.white24),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label,
            style: TextStyle(
                color: active ? Colors.black : Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildNewsFeed() {
    return GlassmorphicContainer(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      borderRadius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              GlowPulse(
                glowColor: AppColors.neonOrange,
                glowRadius: 6,
                child: Icon(LucideIcons.radio,
                    color: AppColors.neonOrange, size: 16),
              ),
              SizedBox(width: 12),
              NeonText(
                text: 'POLITICAL_INTEL // NEWS_FEED',
                glowColor: AppColors.neonOrange,
                glowRadius: 4,
                style: TextStyle(
                    color: AppColors.neonOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _newsItem(
              '09:42', 'New swing state polls show tightening race in PA/MI.',
              source: 'POLL_WATCH'),
          _newsItem(
              '08:15', 'Labour Party announces new energy policy initiative.',
              source: 'REUTERS'),
          _newsItem('06:30',
              'Unexpected candidate withdrawal in EU regional election.',
              source: 'EURO_NEWS'),
          if (_showExtraNews) ...[
            _newsItem(
                '04:45', 'US Fed Chair hints at data-dependent rate strategy.',
                source: 'CNBC'),
            _newsItem('02:10',
                'Early voting numbers surpass 2020 records in Georgia.',
                source: 'AP'),
          ],
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              setState(() => _showExtraNews = true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('FETCHING_ADDITIONAL_INTEL…'),
                    backgroundColor: AppColors.neonOrange,
                    behavior: SnackBarBehavior.floating),
              );
            },
            child: const Text('LOAD_MORE_INTEL_',
                style: TextStyle(color: AppColors.neonOrange, fontSize: 10)),
          ),
        ],
      ),
    );
  }

  Widget _newsItem(String time, String headline, {required String source}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(time,
              style: const TextStyle(
                  color: AppColors.neonOrange,
                  fontSize: 10,
                  fontFamily: 'monospace')),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(headline,
                    style: const TextStyle(color: Colors.white, fontSize: 13)),
                const SizedBox(height: 4),
                Text('SOURCE: $source',
                    style: const TextStyle(color: Colors.white24, fontSize: 9)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderPanel(BuildContext context, PriceMarket market) {
    return AnimatedGradientBorder(
      borderRadius: 12,
      borderWidth: 1.5,
      colors: const [
        Colors.green,
        AppColors.neonOrange,
        Colors.red,
        AppColors.neonOrange,
      ],
      child: GlassmorphicContainer(
        padding: const EdgeInsets.all(24),
        borderRadius: 12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const NeonText(
              text: 'EXECUTE_PREDICTION',
              glowColor: Colors.white,
              glowRadius: 2,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 24),
            const _OrderInput(label: 'STAKE_USDC', value: '2,500'),
            const SizedBox(height: 32),
            _payoutRow('POTENTIAL_WIN', '\$4,875.20'),
            _payoutRow('EST_PROBABILITY', '54.2%'),
            const SizedBox(height: 32),
            _actionBtn(context, 'PREDICT_YES', Colors.green, market),
            const SizedBox(height: 12),
            _actionBtn(context, 'PREDICT_NO', Colors.red, market),
            const SizedBox(height: 24),
            const Text(
              'WARNING: POLITICAL MARKETS ARE HIGHLY VOLATILE. EXPIRE IN 42M.',
              style: TextStyle(color: Colors.white24, fontSize: 9),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _payoutRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(label,
                style: const TextStyle(color: Colors.white24, fontSize: 12),
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 8),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Widget _actionBtn(
      BuildContext context, String label, Color color, PriceMarket market) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        onPressed: () => _showConfirmDialog(context, label, market),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showConfirmDialog(
      BuildContext context, String action, PriceMarket market) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0A0A0A),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(color: Colors.white10)),
        title: Text('CONFIRM // ${action.toUpperCase()}',
            style: const TextStyle(
                color: AppColors.neonOrange,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        content: Text(
          'Confirm prediction for: ${market.asset}\n\nStake: 2,500 USDC\nEstimated Outcome: 54.2%\n\nThis action will be written to the blockchain.',
          style:
              const TextStyle(color: Colors.white54, fontSize: 13, height: 1.6),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL',
                  style: TextStyle(color: Colors.white24))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('PREDICTION_EXECUTED: ${market.asset}'),
                    backgroundColor: Colors.green),
              );
            },
            child: const Text('CONFIRM',
                style: TextStyle(
                    color: AppColors.neonOrange, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white30, fontSize: 10)),
        Text(value,
            style: TextStyle(
                color: color ?? Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _OrderInput extends StatelessWidget {
  final String label;
  final String value;
  const _OrderInput({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white30, fontSize: 10)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white12),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(value,
                    style: AppTextStyles.bodyLarge,
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              const Text('USDC', style: TextStyle(color: Colors.white30)),
            ],
          ),
        ),
      ],
    );
  }
}

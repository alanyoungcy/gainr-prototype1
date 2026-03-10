import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class MarketDataScreen extends ConsumerWidget {
  const MarketDataScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final horizontalPadding = gainrPadding(screenWidth);
        final heroFontSize = gainrHeroFontSize(screenWidth);

        return SingleChildScrollView(
          padding:
              EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero
              NeonText(
                text: 'MARKET_DATA',
                glowColor: AppTheme.neonOrange,
                glowRadius: 12,
                style: AppTextStyles.h1.copyWith(
                  fontSize: heroFontSize,
                  color: AppTheme.neonOrange,
                  letterSpacing: -2,
                  height: 0.9,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                  'REAL-TIME AGGREGATED FEED | MULTI-EXCHANGE | 14 ACTIVE MARKETS',
                  style: TextStyle(
                      color: Colors.white30,
                      fontSize: 12,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 48),

              // ── Live Ticker Panel ──────────────────────────────────
              GlassmorphicContainer(
                borderRadius: 12,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GlowPulse(
                            glowColor: AppTheme.neonOrange,
                            glowRadius: 6,
                            child: Icon(LucideIcons.radio,
                                color: AppTheme.neonOrange, size: 16),
                          ),
                          SizedBox(width: 12),
                          NeonText(
                            text: 'LIVE_TICKER // POLITICAL_ODDS',
                            glowColor: AppTheme.neonOrange,
                            glowRadius: 4,
                            style: TextStyle(
                                color: AppTheme.neonOrange,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),

                      // Ticker Grid — US Politics
                      Text('US_POLITICS',
                          style: TextStyle(
                              color: Colors.white24,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1)),
                      SizedBox(height: 12),
                      Wrap(
                        spacing: 16,
                        runSpacing: 12,
                        children: [
                          _TickerChip(
                              symbol: 'US_PRES/USDC',
                              price: '52.4¢',
                              change: '+1.2%',
                              positive: true),
                          _TickerChip(
                              symbol: 'HOUSE_MAJ/USDC',
                              price: '46.8¢',
                              change: '-0.9%',
                              positive: false),
                          _TickerChip(
                              symbol: 'GOP_SEN/USDC',
                              price: '58.7¢',
                              change: '+0.4%',
                              positive: true),
                          _TickerChip(
                              symbol: 'PA_TRUMP/USDC',
                              price: '51.1¢',
                              change: '+2.3%',
                              positive: true),
                          _TickerChip(
                              symbol: 'MI_HARRIS/USDC',
                              price: '49.2¢',
                              change: '-1.1%',
                              positive: false),
                        ],
                      ),
                      SizedBox(height: 24),

                      // Ticker Grid — Policy
                      Text('POLICY_&_REGULATION',
                          style: TextStyle(
                              color: Colors.white24,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1)),
                      SizedBox(height: 12),
                      Wrap(
                        spacing: 16,
                        runSpacing: 12,
                        children: [
                          _TickerChip(
                              symbol: 'FED_CUT/USDC',
                              price: '65.1¢',
                              change: '-2.4%',
                              positive: false),
                          _TickerChip(
                              symbol: 'SCOTUS/USDC',
                              price: '15.2¢',
                              change: '+3.8%',
                              positive: true),
                          _TickerChip(
                              symbol: 'STUDENT_LOAN/USDC',
                              price: '28.5¢',
                              change: '-4.2%',
                              positive: false),
                          _TickerChip(
                              symbol: 'CRYPTO_REG/USDC',
                              price: '42.3¢',
                              change: '+5.6%',
                              positive: true),
                        ],
                      ),
                      SizedBox(height: 24),

                      // Ticker Grid — EU & Geopolitics
                      Text('EU_ELECTIONS_&_GEOPOLITICS',
                          style: TextStyle(
                              color: Colors.white24,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1)),
                      SizedBox(height: 12),
                      Wrap(
                        spacing: 16,
                        runSpacing: 12,
                        children: [
                          _TickerChip(
                              symbol: 'LABOUR/USDC',
                              price: '85.2¢',
                              change: '+0.9%',
                              positive: true),
                          _TickerChip(
                              symbol: 'FR_LEFT/USDC',
                              price: '38.4¢',
                              change: '-1.7%',
                              positive: false),
                          _TickerChip(
                              symbol: 'DE_COAL/USDC',
                              price: '22.9¢',
                              change: '+7.1%',
                              positive: true),
                          _TickerChip(
                              symbol: 'UKR_CEASE/USDC',
                              price: '12.4¢',
                              change: '-0.5%',
                              positive: false),
                          _TickerChip(
                              symbol: 'TAIWAN/USDC',
                              price: '8.6¢',
                              change: '+1.2%',
                              positive: true),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ── Volume Analytics Panel ─────────────────────────────
              GlassmorphicContainer(
                borderRadius: 12,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          GlowPulse(
                            glowColor: Colors.cyan,
                            glowRadius: 6,
                            child: Icon(LucideIcons.chart_bar,
                                color: Colors.cyan, size: 16),
                          ),
                          SizedBox(width: 12),
                          NeonText(
                            text: 'VOLUME_ANALYTICS // 24H',
                            glowColor: Colors.cyan,
                            glowRadius: 4,
                            style: TextStyle(
                                color: Colors.cyan,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 24,
                        runSpacing: 16,
                        children: [
                          _volumeStat(
                              'TOTAL_VOLUME_24H', '\$67.2M', Colors.cyan),
                          _volumeStat(
                              'ACTIVE_MARKETS', '14', AppTheme.neonOrange),
                          _volumeStat('UNIQUE_TRADERS', '8,420', Colors.green),
                          _volumeStat(
                              'AVG_POSITION', '\$2,840', Colors.white70),
                          _volumeStat(
                              'TOP_MOVER', 'DE_COAL +7.1%', Colors.green),
                          _volumeStat(
                              'WORST_MOVER', 'STUDENT_LOAN -4.2%', Colors.red),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ── Sentiment Heatmap ──────────────────────────────────
              GlassmorphicContainer(
                borderRadius: 12,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          GlowPulse(
                            glowColor: Colors.purple,
                            glowRadius: 6,
                            child: Icon(LucideIcons.brain,
                                color: Colors.purple, size: 16),
                          ),
                          SizedBox(width: 12),
                          NeonText(
                            text: 'SENTIMENT_AGGREGATOR // ON-CHAIN',
                            glowColor: Colors.purple,
                            glowRadius: 4,
                            style: TextStyle(
                                color: Colors.purple,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _sentimentRow('US_PRES_2024', 0.52, 'BULLISH'),
                      _sentimentRow('FED_RATE_CUT', 0.35, 'BEARISH'),
                      _sentimentRow('GOP_SENATE', 0.58, 'BULLISH'),
                      _sentimentRow('UK_LABOUR', 0.85, 'STRONG_BULL'),
                      _sentimentRow('CRYPTO_REG', 0.62, 'BULLISH'),
                      _sentimentRow('UKRAINE_CEASEFIRE', 0.12, 'STRONG_BEAR'),
                      _sentimentRow('DE_COALITION', 0.43, 'NEUTRAL'),
                      _sentimentRow('TAIWAN_STRAIT', 0.08, 'EXTREME_BEAR'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ── Data Sources Panel ─────────────────────────────────
              GlassmorphicContainer(
                borderRadius: 12,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GlowPulse(
                            glowColor: AppTheme.neonOrange,
                            glowRadius: 6,
                            child: Icon(LucideIcons.database,
                                color: AppTheme.neonOrange, size: 16),
                          ),
                          SizedBox(width: 12),
                          NeonText(
                            text: 'DATA_SOURCES // VERIFIED',
                            glowColor: AppTheme.neonOrange,
                            glowRadius: 4,
                            style: TextStyle(
                                color: AppTheme.neonOrange,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      Wrap(
                        spacing: 24,
                        runSpacing: 12,
                        children: [
                          _SourceChip(name: 'POLYMARKET', status: 'LIVE'),
                          _SourceChip(name: 'METACULUS', status: 'LIVE'),
                          _SourceChip(name: 'PREDICTIT', status: 'SYNCING'),
                          _SourceChip(name: 'MANIFOLD', status: 'LIVE'),
                          _SourceChip(name: 'KALSHI', status: 'LIVE'),
                          _SourceChip(name: 'AUGUR_V2', status: 'ARCHIVE'),
                          _SourceChip(name: 'REUTERS_POLLING', status: 'LIVE'),
                          _SourceChip(name: 'AP_ELECTION_DATA', status: 'LIVE'),
                          _SourceChip(
                              name: 'FIVETHIRTYEIGHT', status: 'SYNCING'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  Widget _volumeStat(String label, String value, Color color) {
    return SizedBox(
      width: 180,
      child: GlassmorphicContainer(
        borderRadius: 8,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.white24,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1)),
            const SizedBox(height: 8),
            NeonText(
              text: value,
              glowColor: color,
              glowRadius: 4,
              style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sentimentRow(String market, double score, String label) {
    final color = score > 0.6
        ? Colors.green
        : score > 0.4
            ? AppTheme.neonOrange
            : Colors.red;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Text(market,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace'))),
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: score,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                            color: color.withValues(alpha: 0.4), blurRadius: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
              width: 100,
              child: Text(label,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1))),
        ],
      ),
    );
  }
}

class _TickerChip extends StatelessWidget {
  final String symbol;
  final String price;
  final String change;
  final bool positive;

  const _TickerChip({
    required this.symbol,
    required this.price,
    required this.change,
    required this.positive,
  });

  @override
  Widget build(BuildContext context) {
    return HoverScaleGlow(
      scaleFactor: 1.05,
      glowRadius: 15,
      glowColor: positive ? AppTheme.neonOrange : Colors.red,
      child: GlassmorphicContainer(
        borderRadius: 8,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(symbol,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1)),
              const SizedBox(width: 16),
              Text(price,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontFamily: 'monospace')),
              const SizedBox(width: 12),
              Text(change,
                  style: TextStyle(
                      color: positive ? AppTheme.neonOrange : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SourceChip extends StatelessWidget {
  final String name;
  final String status;

  const _SourceChip({required this.name, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == 'LIVE'
        ? Colors.green
        : status == 'SYNCING'
            ? AppTheme.neonOrange
            : Colors.white24;
    return HoverScaleGlow(
      scaleFactor: 1.03,
      glowRadius: 10,
      glowColor: color,
      child: GlassmorphicContainer(
        borderRadius: 6,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(name,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1)),
              const SizedBox(width: 12),
              Text(status,
                  style: TextStyle(
                      color: color, fontSize: 9, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

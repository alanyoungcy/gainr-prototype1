import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'package:gainr_models/gainr_models.dart';
import 'package:go_router/go_router.dart';
import 'package:price_bet/features/dashboard/providers/market_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _selectedCategory = 'ALL';

  @override
  Widget build(BuildContext context) {
    final marketsAsync = ref.watch(marketsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Ticker Hub
          _buildTrendingTicker(),
          const SizedBox(height: 32),

          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              NeonText(
                text: 'POLITICAL_PREDICTION // TERMINAL',
                glowColor: AppColors.neonOrange,
                glowRadius: 10,
                style: AppTextStyles.h1.copyWith(
                  color: AppColors.neonOrange,
                  fontFamily: 'monospace',
                ),
              ),
              _buildWalletButton(context),
            ],
          ),
          const SizedBox(height: 32),

          // 2. Category Filters
          _buildCategoryFilters(),
          const SizedBox(height: 40),

          Text(
            'ACTIVE_MARKETS // LIVE_ODDS',
            style: AppTextStyles.bodySmall
                .copyWith(color: Colors.white30, letterSpacing: 2),
          ),
          const SizedBox(height: 16),

          // 3. Responsive Wrap Grid
          marketsAsync.when(
            data: (markets) {
              final filteredMarkets = _selectedCategory == 'ALL'
                  ? markets
                  : markets
                      .where((m) => _getCategory(m.id) == _selectedCategory)
                      .toList();

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                switchInCurve: Curves.easeOutCubic,
                child: LayoutBuilder(
                  key: ValueKey(_selectedCategory),
                  builder: (context, constraints) {
                    final columnCount = constraints.maxWidth > 1100
                        ? 4
                        : constraints.maxWidth > 800
                            ? 3
                            : (constraints.maxWidth > 500 ? 2 : 1);

                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1600),
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children:
                              filteredMarkets.asMap().entries.map((entry) {
                            final market = entry.value;
                            final cardWidth = (constraints.maxWidth -
                                    (columnCount - 1) * 16) /
                                columnCount;

                            return SizedBox(
                              width: cardWidth,
                              height: 220,
                              child: StaggeredFadeSlide(
                                index: entry.key,
                                baseDelayMs: 80,
                                child: HoverScaleGlow(
                                  scaleFactor: 1.03,
                                  glowRadius: 20,
                                  glowColor: AppColors.neonOrange,
                                  child: AnimatedGradientBorder(
                                    borderWidth: 1.5,
                                    borderRadius: 12,
                                    colors: const [
                                      AppTheme.neonOrange,
                                      AppTheme.neonMagenta,
                                      AppTheme.neonCyan,
                                      AppTheme.neonOrange,
                                    ],
                                    duration: const Duration(seconds: 4),
                                    child: _MarketCard(market: market),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.neonOrange)),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
          const SizedBox(height: 60),
          GainrFooter(
            systemId: 'PRICE_INTEL_v1.1',
            extraLinks: [
              FooterLink(label: 'POLITICAL_LEGAL', onTap: () {}),
              FooterLink(label: 'DATA_SOURCES', onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingTicker() {
    return Container(
      height: 40,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.neonOrange.withValues(alpha: 0.05),
        border: Border.all(color: AppColors.neonOrange.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          _buildHotBadge(),
          const SizedBox(width: 12),
          const Text('TERMINAL_INTEL: ',
              style: TextStyle(
                  color: AppColors.neonOrange,
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _tickerItem('US_ELECTION_2024 (ODDS: 52% TRUMP / 48% HARRIS)',
                      isHot: true),
                  _tickerItem('FED_RATE_HIKE (PROBABILITY: 12% UP)'),
                  _tickerItem('UK_LABOUR_MAJORITY (ODDS: 85%)', isHot: true),
                  _tickerItem('GDP_GROWTH_UK (FORECAST: 1.2%)'),
                  _tickerItem('X_PLATFORM_POLICY (BULLISH_SENTIMENT: 64%)'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tickerItem(String text, {bool isHot = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 32),
      child: Row(
        children: [
          if (isHot)
            Container(
              margin: const EdgeInsets.only(right: 8),
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          Text(text,
              style: TextStyle(
                  color: isHot ? Colors.white : Colors.white30,
                  fontSize: 10,
                  fontFamily: 'monospace',
                  fontWeight: isHot ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildHotBadge() {
    return GlowPulse(
      glowColor: Colors.red,
      glowRadius: 4,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(2),
        ),
        child: const Text('HOT',
            style: TextStyle(
                color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    final categories = [
      'ALL',
      'US_POLITICS',
      'EU_ELECTIONS',
      'POLICY',
      'GEOPOLITICS',
      'SWING_STATES',
      'CRYPTO',
    ];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: categories.map((cat) {
        final active = _selectedCategory == cat;
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = cat),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.neonOrange.withValues(alpha: 0.1)
                  : Colors.transparent,
              border: Border.all(
                  color: active ? AppColors.neonOrange : Colors.white10),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(cat,
                style: TextStyle(
                    color: active ? AppColors.neonOrange : Colors.white30,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWalletButton(BuildContext context) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'WALLET_CONNECT_INITIATED…',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1),
            ),
            backgroundColor: AppColors.neonOrange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border:
              Border.all(color: AppColors.neonOrange.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'CONNECT WALLET',
          style: TextStyle(
              color: AppColors.neonOrange, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  String _getCategory(String id) {
    // Swing states
    if (id.contains('swing') || id == 'us_swing_pa' || id == 'us_swing_mi') {
      return 'SWING_STATES';
    }
    // Crypto
    if (id.contains('crypto')) {
      return 'CRYPTO';
    }
    // EU Elections
    if (id.startsWith('eu_')) {
      return 'EU_ELECTIONS';
    }
    // Geopolitics / War
    if (id.startsWith('war_')) {
      return 'GEOPOLITICS';
    }
    // Policy
    if (id.contains('fed') ||
        id.contains('scotus') ||
        id.startsWith('policy')) {
      return 'POLICY';
    }
    // US Politics (default for remaining US-related)
    return 'US_POLITICS';
  }
}

class _MarketCard extends ConsumerWidget {
  final PriceMarket market;
  const _MarketCard({required this.market});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final livePrice = ref.watch(priceStreamProvider(market.asset));

    Widget cardContent = GlassmorphicContainer(
      borderRadius: 12,
      blur: 10,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID: ${market.id.toUpperCase()}',
                          style: const TextStyle(
                              color: Colors.white24, fontSize: 10)),
                      Text(market.asset,
                          style: AppTextStyles.bodyLarge
                              .copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: market.priceChange24h >= 0
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${market.priceChange24h >= 0 ? '+' : ''}${market.priceChange24h}%',
                    style: TextStyle(
                      color: market.priceChange24h >= 0
                          ? Colors.green
                          : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            livePrice.when(
              data: (price) => Text(
                '${price.toStringAsFixed(1)}¢',
                style: const TextStyle(
                  color: AppColors.neonOrange,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              loading: () => Text(
                '${market.currentPrice.toStringAsFixed(1)}¢',
                style: const TextStyle(color: Colors.white30, fontSize: 28),
              ),
              error: (_, __) => const Text('ERR'),
            ),
            const SizedBox(height: 8),
            Text(
              _getMarketTag(market.id),
              style: const TextStyle(
                  color: Colors.white24, fontSize: 8, letterSpacing: 1),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'VOL: \$${(market.totalStaked / 1000).toStringAsFixed(1)}K',
                    style:
                        AppTextStyles.bodySmall.copyWith(color: Colors.white30),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'EXP: ${market.timeLeft.inDays > 0 ? '${market.timeLeft.inDays}d' : '${market.timeLeft.inHours}h'}',
                  style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.neonOrange.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return InkWell(
      onTap: () => context.go('/market/${market.id}'),
      borderRadius: BorderRadius.circular(12),
      child: cardContent,
    );
  }

  String _getMarketTag(String id) {
    if (id.contains('us_') || id.contains('senate')) {
      return 'CATEGORY: US_POLITICS // TRADING_ENABLED';
    }
    if (id.contains('eu_')) {
      return 'CATEGORY: EU_ELECTIONS // LIVE_ODDS';
    }
    if (id.contains('policy') || id.contains('fed') || id.contains('scotus')) {
      return 'CATEGORY: POLICY // HIGH_IMPACT';
    }
    if (id.contains('war')) {
      return 'CATEGORY: GEOPOLITICS // VOLATILE';
    }
    return 'CATEGORY: GLOBAL // ACTIVE';
  }
}

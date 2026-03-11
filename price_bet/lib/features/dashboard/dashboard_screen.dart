import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'package:gainr_models/gainr_models.dart';
import 'package:go_router/go_router.dart';
import 'package:price_bet/features/dashboard/providers/market_provider.dart';
import 'package:price_bet/features/wallet/widgets/connect_wallet_button.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _selectedCategory = 'ALL';

  @override
  Widget build(BuildContext context) {
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
              _buildHeader(context),
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
          ref.watch(marketsProvider).when(
            data: (markets) {
              final filteredMarkets = _selectedCategory == 'ALL'
                  ? markets
                  : markets
                      .where((m) => _getCategory(m.id) == _selectedCategory)
                      .toList();

              // Group markets by matchId prefix (everything before the last underscore)
              final groupedMarkets = <String, List<PriceMarket>>{};
              for (var market in filteredMarkets) {
                final lastUnderscore = market.id.lastIndexOf('_');
                if (lastUnderscore == -1) continue;
                final matchId = market.id.substring(0, lastUnderscore);
                groupedMarkets.putIfAbsent(matchId, () => []).add(market);
              }

              if (groupedMarkets.isEmpty) {
                return Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Icon(Icons.sports_soccer_outlined, 
                        size: 48, color: Colors.white.withValues(alpha: 0.1)),
                      const SizedBox(height: 16),
                      Text('No active matches in this category',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.3))),
                    ],
                  ),
                );
              }

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                switchInCurve: Curves.easeOutCubic,
                child: LayoutBuilder(
                  key: ValueKey(_selectedCategory),
                  builder: (context, constraints) {
                    final columnCount = constraints.maxWidth > 1100
                        ? 2
                        : 1;

                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1600),
                        child: Wrap(
                          spacing: 24,
                          runSpacing: 24,
                          children: groupedMarkets.entries.map((entry) {
                            final matchId = entry.key;
                            final markets = entry.value;
                            final cardWidth = columnCount == 2 
                                ? (constraints.maxWidth - 24) / 2
                                : constraints.maxWidth;

                            return SizedBox(
                              width: cardWidth,
                              child: StaggeredFadeSlide(
                                index: groupedMarkets.keys.toList().indexOf(matchId),
                                baseDelayMs: 80,
                                child: _MatchCard(matchId: matchId, markets: markets),
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
                child: CircularProgressIndicator(color: AppTheme.neonOrange)),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
          const SizedBox(height: 60),
          GainrFooter(
            systemId: 'SOCCER_INTEL_v1.2 // SPORTS_EDITION',
            extraLinks: [
              FooterLink(label: 'SPORTS_TRADING_LEGAL', onTap: () {}),
              FooterLink(label: 'FIXED_ODDS_TERMS', onTap: () {}),
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
                  _tickerItem('UCL_FINAL: (ODDS: 52% MAN_CITY / 48% INTER)',
                      isHot: true),
                  _tickerItem('ARS_vs_LIV: (PROBABILITY: 64% OVER_2.5_GOALS)'),
                  _tickerItem('REAL_MADRID_LA_LIGA_TITLE (ODDS: 85%)',
                      isHot: true),
                  _tickerItem('EPL_RELEGATION_BATTLE (FORECAST: EVE_1.2%)'),
                  _tickerItem('MBAPPE_TRANSFER_ODDS (BULLISH_SENTIMENT: 64%)'),
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
      'PREMIER_LEAGUE',
      'CHAMPIONS_LEAGUE',
      'LA_LIGA',
      'BUNDESLIGA',
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

  Widget _buildHeader(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  AnimatedGradientBorder(
                    borderRadius: 12,
                    borderWidth: 1.5,
                    colors: const [
                      AppTheme.neonOrange,
                      AppTheme.neonMagenta,
                      AppTheme.neonCyan,
                      AppTheme.neonOrange,
                    ],
                    duration: const Duration(seconds: 4),
                    child: GlassmorphicContainer(
                      borderRadius: 12,
                      blur: 10,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Image.asset(
                        'assets/images/GAINR_Logo.png',
                        height: isMobile ? 32 : 48,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Hero(
                      tag: 'dashboard_header',
                      child: NeonText(
                        text: 'SOCCER_INTELLIGENCE // TERMINAL',
                        glowColor: AppColors.neonOrange,
                        glowRadius: 8,
                        style: (isMobile ? AppTextStyles.bodyLarge : AppTextStyles.h1).copyWith(
                          color: AppColors.neonOrange,
                          fontFamily: 'monospace',
                          fontSize: isMobile ? 14 : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (!isMobile) const SizedBox(width: 16),
            const ConnectWalletButton(),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _getCategory(String id) {
    if (id.startsWith('epl_')) {
      return 'PREMIER_LEAGUE';
    }
    if (id.startsWith('ucl_')) {
      return 'CHAMPIONS_LEAGUE';
    }
    if (id.startsWith('liga_')) {
      return 'LA_LIGA';
    }
    if (id.startsWith('bund_')) {
      return 'BUNDESLIGA';
    }
    return 'PREMIER_LEAGUE';
  }
}

class _MatchCard extends ConsumerWidget {
  final String matchId;
  final List<PriceMarket> markets;
  
  const _MatchCard({required this.matchId, required this.markets});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (markets.isEmpty) return const SizedBox.shrink();
    
    // Sort markets to ensure order: home, away, draw
    final orderedMarkets = [...markets];
    orderedMarkets.sort((a, b) {
       final aIsDraw = a.id.endsWith('_draw');
       final bIsDraw = b.id.endsWith('_draw');
       if (aIsDraw && !bIsDraw) return 1;
       if (!aIsDraw && bIsDraw) return -1;
       return a.id.compareTo(b.id); 
    });

    final totalStaked = markets.fold<double>(0, (sum, m) => sum + m.totalStaked);
    final expiry = markets.first.expiry;
    
    final formattedDate = '${_getMonth(expiry.month)} ${expiry.day} @ ${expiry.hour > 12 ? expiry.hour - 12 : (expiry.hour == 0 ? 12 : expiry.hour)}:${expiry.minute.toString().padLeft(2, '0')}${expiry.hour >= 12 ? 'PM' : 'AM'}';

    return AnimatedGradientBorder(
      borderRadius: 16,
      borderWidth: 1.5,
      colors: const [
        AppTheme.neonOrange,
        AppTheme.neonMagenta,
        AppTheme.neonCyan,
        AppTheme.neonOrange,
      ],
      duration: const Duration(seconds: 4),
      child: GlassmorphicContainer(
        padding: const EdgeInsets.all(16), // Reduced from 24
        borderRadius: 16,
        blur: 12, // Liquid glass blur
        opacity: 0.1, // Glass opacity
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Expanded(
                   child: Text(_getMatchTitle(matchId), 
                     style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 16), // Reduced from 20
                     overflow: TextOverflow.ellipsis,
                   ),
                 ),
                 const Icon(Icons.settings_outlined, color: Colors.white24, size: 18), // Reduced size
               ],
             ),
             const SizedBox(height: 6),
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Text(
                   formattedDate,
                   style: const TextStyle(color: Colors.white30, fontSize: 11), // Reduced from 13
                 ),
                 Text(
                   '\$${(totalStaked / 1000).toStringAsFixed(1)}K vol',
                   style: const TextStyle(color: Colors.white30, fontSize: 11), // Reduced from 13
                   overflow: TextOverflow.ellipsis,
                 ),
               ]
             ),
             const SizedBox(height: 16), // Reduced from 24
             ...orderedMarkets.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 12), // Reduced from 16
                child: _OutcomeRow(market: m),
             )),
          ]
        )
      ),
    );
  }
  
  String _getMatchTitle(String matchId) {
     final parts = matchId.split('_');
     if (parts.length >= 3) {
       final homeTeam = parts[1].toUpperCase();
       final awayTeam = parts[2].toUpperCase();
       
       return '${_formatTeamName(homeTeam)} vs ${_formatTeamName(awayTeam)}';
     }
     return matchId.toUpperCase();
  }

  String _formatTeamName(String name) {
    switch (name) {
      case 'MANCITY': return 'MAN CITY';
      case 'GALATASARAY': return 'GALATASARAY';
      case 'LIVERPOOL': return 'LIVERPOOL';
      case 'NEWCASTLE': return 'NEWCASTLE';
      case 'BARCELONA': return 'BARCELONA';
      case 'ATLETICO': return 'ATL. MADRID';
      case 'TOTTENHAM': return 'TOTTENHAM';
      case 'ATALANTA': return 'ATALANTA';
      case 'BAYERN': return 'BAYERN MUNICH';
      case 'LEVERKUSEN': return 'BAYER LEVERKUSEN';
      case 'ARSENAL': return 'ARSENAL';
      case 'REALMADRID': return 'REAL MADRID';
      case 'PSG': return 'PSG';
      case 'CHELSEA': return 'CHELSEA';
      case 'BODOGLIMT': return 'BODO/GLIMT';
      case 'SPORTING': return 'SPORTING CP';
      default: return name;
    }
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}

class _OutcomeRow extends ConsumerWidget {
  final PriceMarket market;
  const _OutcomeRow({required this.market});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final livePriceAsync = ref.watch(priceStreamProvider(market.asset));
    final livePrice = livePriceAsync.when(
      data: (price) => price,
      loading: () => market.currentPrice,
      error: (_, __) => market.currentPrice,
    );
    
    final probability = livePrice.toInt().clamp(1, 99);

    return InkWell(
      onTap: () {
        debugPrint('Tapped outcome: ${market.id}');
        context.go('/market/${market.id}');
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: Colors.transparent, // Ensure hit testing
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Row(
          children: [
            // Team Icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.neonCyan.withValues(alpha: 0.2),
                    AppTheme.neonCyan.withValues(alpha: 0.05)
                  ],
                ),
                border: Border.all(color: AppTheme.neonCyan.withValues(alpha: 0.2)),
              ),
              child: const Icon(Icons.shield, size: 16, color: AppTheme.neonCyan),
            ),
            const SizedBox(width: 16),
            
            // Team Name and Probability Bar
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(market.asset, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  Stack(
                    children: [
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: probability / 100.0,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.neonCyan, AppTheme.gainrGreen],
                            ),
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.neonCyan.withValues(alpha: 0.5),
                                blurRadius: 4,
                              )
                            ]
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            // Probability Button
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.gainrGreen),
                  ),
                  child: Text('$probability%', 
                    style: const TextStyle(color: AppTheme.gainrGreen, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

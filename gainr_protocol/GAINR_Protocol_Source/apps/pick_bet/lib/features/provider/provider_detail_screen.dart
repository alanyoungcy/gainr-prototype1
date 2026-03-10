import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'package:gainr_models/gainr_models.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:pick_bet/features/dashboard/providers/leaderboard_provider.dart';
import 'package:pick_bet/features/provider/widgets/ai_insights_panel.dart';

class ProviderDetailScreen extends ConsumerStatefulWidget {
  final String providerId;
  const ProviderDetailScreen({super.key, required this.providerId});

  @override
  ConsumerState<ProviderDetailScreen> createState() =>
      _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends ConsumerState<ProviderDetailScreen> {
  String _selectedFilter = '1W';
  final bool _showExtraSignals = false;

  static const _chartDataMap = {
    '1D': [
      FlSpot(0, 6),
      FlSpot(2, 5.5),
      FlSpot(4, 7),
      FlSpot(6, 6.8),
      FlSpot(8, 7.5),
      FlSpot(10, 7.2),
      FlSpot(12, 8),
    ],
    '1W': [
      FlSpot(0, 3),
      FlSpot(2, 2),
      FlSpot(4, 5),
      FlSpot(6, 4),
      FlSpot(8, 7),
      FlSpot(10, 6),
      FlSpot(12, 10),
    ],
    '1M': [
      FlSpot(0, 1),
      FlSpot(2, 3),
      FlSpot(4, 2.5),
      FlSpot(6, 6),
      FlSpot(8, 5),
      FlSpot(10, 8),
      FlSpot(12, 12),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return leaderboardAsync.when(
      data: (providers) {
        final provider = providers.firstWhere((p) => p.id == widget.providerId,
            orElse: () => providers.first);
        return DefaultTabController(
          length: 4,
          child: SingleChildScrollView(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 800;
                return Column(
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1400),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: isNarrow ? 16 : 48, vertical: 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. Profile Header Section
                              _buildProfileHeader(provider, isNarrow),

                              const SizedBox(height: 24),

                              // AI Insights Button
                              SizedBox(
                                width: isNarrow ? double.infinity : 280,
                                height: 48,
                                child: HoverScaleGlow(
                                  glowColor: AppTheme.neonOrange,
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (_) => Padding(
                                          padding: EdgeInsets.only(
                                            top: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.1,
                                          ),
                                          child: PickAiInsightsPanel(
                                              provider: provider),
                                        ),
                                      );
                                    },
                                    icon:
                                        const Icon(LucideIcons.brain, size: 18),
                                    label: const Text(
                                      'AI PROVIDER INTELLIGENCE',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                        fontSize: 11,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppTheme.neonOrange,
                                      side: BorderSide(
                                        color: AppTheme.neonOrange
                                            .withValues(alpha: 0.5),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 32),

                              // 2. Tab Navigation
                              _buildTabBar(),

                              const SizedBox(height: 32),
                              // 3. Tab Content
                              SizedBox(
                                height: 600,
                                child: TabBarView(
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: [
                                    _buildPerformanceSection(provider),
                                    _buildRiskAnalysis(provider),
                                    _buildAssetMix(provider),
                                    _buildSignalHistoryTable(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 4. Footer
                    GainrFooter(
                      systemId: 'PICK_ALPHA_PRO_v2.1',
                      extraLinks: [
                        FooterLink(label: 'PROVIDER_TERMS', onTap: () {}),
                        FooterLink(label: 'EXECUTION_LOGS', onTap: () {}),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.neonOrange)),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildProfileHeader(PickProvider provider, bool isNarrow) {
    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.neonOrange, width: 2),
                  borderRadius: BorderRadius.circular(4),
                  image: const DecorationImage(
                    image: NetworkImage(
                        'https://api.dicebear.com/7.x/pixel-art/png?seed=Alpha'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        '@${provider.name.toUpperCase()}_V${provider.id.substring(1)}',
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.h1
                            .copyWith(fontSize: 24, letterSpacing: -1)),
                    const SizedBox(height: 12),
                    const TerminalBridgeButton(
                      label: 'SUBSCRIBE',
                      onPressed: null,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'high-frequency algorithmic trading specializing in political alpha. 84.2% historical win-rate over 1,500 signals.',
            style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              border: Border.all(color: Colors.white10),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Wrap(
              spacing: 24,
              runSpacing: 16,
              children: [
                _metricBoxNarrow('PNL', '+${provider.roi}%',
                    color: AppTheme.neonOrange),
                _metricBoxNarrow('WIN', '84.2%'),
                _metricBoxNarrow('COPIERS', '1.02K'),
              ],
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        AnimatedGradientBorder(
          borderRadius: 8,
          borderWidth: 2,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              image: const DecorationImage(
                image: NetworkImage(
                    'https://api.dicebear.com/7.x/pixel-art/png?seed=Alpha'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(width: 32),
        // Handle & Bio
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NeonText(
                text:
                    '@${provider.name.toUpperCase()}_V${provider.id.substring(1)}',
                glowColor: AppTheme.neonOrange,
                glowRadius: 8,
                style:
                    AppTextStyles.h1.copyWith(fontSize: 40, letterSpacing: -1),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const TerminalBridgeButton(
                    label: 'SUBSCRIBE_BRIDGE',
                    onPressed: null,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.neonOrange),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const Text('VERIFIED_STREAK',
                        style: TextStyle(
                            color: AppTheme.neonOrange,
                            fontSize: 8,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: const Text(
                  'high-frequency algorithmic trading specializing in crypto-assets. focused on mean reversion and momentum-based execution. 84.2% historical win-rate over 1.500 signals.',
                  style: TextStyle(
                      color: Colors.white54, fontSize: 14, height: 1.5),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 24,
                runSpacing: 12,
                children: [
                  _statusTag('RANK: #01_GLOBAL'),
                  _statusTag('UPTIME: 99.8%'),
                  _statusTag('STATUS: ',
                      value: 'ACTIVE_EXECUTION', valueColor: Colors.green),
                ],
              ),
            ],
          ),
        ),
        // Metrics Ribbon
        GlassmorphicContainer(
          borderRadius: 12,
          blur: 10,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Wrap(
            spacing: 0,
            runSpacing: 0,
            children: [
              _metricBox('TOTAL_PNL', '+${provider.roi}%',
                  color: AppTheme.neonOrange),
              _metricBox('AVG_SIZE', '84.2%'),
              _metricBox('A/D_RR', '1:3.2'),
              _metricBox('COPIERS', '1,024'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: const TabBar(
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        dividerColor: Colors.transparent,
        indicatorColor: AppTheme.neonOrange,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppTheme.neonOrange,
        unselectedLabelColor: Colors.white24,
        labelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 1,
            fontFamily: 'monospace'),
        tabs: [
          Tab(text: 'PERFORMANCE_ANALYSIS'),
          Tab(text: 'RISK_VITALITY'),
          Tab(text: 'ASSET_ALLOCATION'),
          Tab(text: 'SIGNAL_HISTORY'),
        ],
      ),
    );
  }

  Widget _buildRiskAnalysis(PickProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Wrap(
          spacing: 48,
          runSpacing: 24,
          children: [
            _riskMetric('MAX_DRAWDOWN', '12.4%', Colors.red),
            _riskMetric('SHARPE_RATIO', '2.84', Colors.green),
            _riskMetric('RECOVERY_FACTOR', '4.2', AppTheme.neonOrange),
          ],
        ),
        const SizedBox(height: 48),
        const Text('EXPOSURE_MAP',
            style: TextStyle(
                color: Colors.white24,
                fontWeight: FontWeight.bold,
                fontSize: 10,
                letterSpacing: 1)),
        const SizedBox(height: 24),
        Expanded(
          child: Row(
            children: [
              _exposureBar('ELECTIONS', 0.45),
              const SizedBox(width: 12),
              _exposureBar('MACRO_POLICY', 0.30),
              const SizedBox(width: 12),
              _exposureBar('GEOPOLITICS', 0.15),
              const SizedBox(width: 12),
              _exposureBar('LOCAL_BALLOT', 0.10),
            ],
          ),
        ),
      ],
    );
  }

  Widget _riskMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white24,
                fontSize: 8,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(value,
            style: TextStyle(
                color: color, fontSize: 32, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _exposureBar(String asset, double percentage) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('${(percentage * 100).toInt()}%',
              style: const TextStyle(color: Colors.white54, fontSize: 10)),
          const SizedBox(height: 8),
          Container(
            height: 200 * percentage,
            decoration: BoxDecoration(
              color: AppTheme.neonOrange
                  .withValues(alpha: 0.2 + (percentage * 0.5)),
              border: const Border(top: BorderSide(color: AppTheme.neonOrange)),
            ),
          ),
          const SizedBox(height: 12),
          Text(asset,
              style: const TextStyle(
                  color: AppTheme.neonOrange,
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _statusTag(String label, {String? value, Color? valueColor}) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
              text: label,
              style: const TextStyle(
                  color: AppTheme.neonOrange,
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
          if (value != null)
            TextSpan(
                text: value,
                style: TextStyle(
                    color: valueColor ?? Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _metricBox(String label, String value, {Color? color}) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white24,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  color: color ?? Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _metricBoxNarrow(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white24,
                fontSize: 8,
                fontWeight: FontWeight.bold,
                letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: color ?? Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPerformanceSection(PickProvider provider) {
    final spots = _chartDataMap[_selectedFilter] ?? _chartDataMap['1W']!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 8, height: 8, color: AppTheme.neonOrange),
                const SizedBox(width: 12),
                const Text('HISTORICAL_PERFORMANCE',
                    style: TextStyle(
                        color: AppTheme.neonOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 1)),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _chartFilter('1D'),
                _chartFilter('1W'),
                _chartFilter('1M'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 32),
        Container(
          height: 400,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.01),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const titles = [
                        'JAN_23',
                        'MAR_23',
                        'MAY_23',
                        'JUL_23',
                        'SEP_23',
                        'NOV_23',
                        'JAN_24'
                      ];
                      if (value % 2 == 0 && value < titles.length * 2) {
                        return Text(titles[(value / 2).toInt()],
                            style: const TextStyle(
                                color: Colors.white24, fontSize: 10));
                      }
                      return const SizedBox();
                    },
                    interval: 1,
                  ),
                ),
                leftTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: AppTheme.neonOrange,
                  barWidth: 4,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.neonOrange.withValues(alpha: 0.2),
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
    );
  }

  Widget _chartFilter(String label) {
    final active = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: 40,
          height: 30,
          margin: const EdgeInsets.only(left: 8),
          decoration: BoxDecoration(
            color: active
                ? AppTheme.neonOrange.withValues(alpha: 0.1)
                : Colors.black,
            border: Border.all(
                color: active ? AppTheme.neonOrange : Colors.white12),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    color: active ? AppTheme.neonOrange : Colors.white30,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildSignalHistoryTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            GlowPulse(
              glowColor: AppTheme.neonOrange,
              glowRadius: 4,
              child:
                  Icon(LucideIcons.radio, color: AppTheme.neonOrange, size: 16),
            ),
            SizedBox(width: 12),
            NeonText(
              text: 'SIGNAL_HISTORY',
              glowColor: AppTheme.neonOrange,
              glowRadius: 4,
              style: TextStyle(
                  color: AppTheme.neonOrange,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 1),
            ),
          ],
        ),
        const SizedBox(height: 32),
        // Table Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              _tableHeader('DATE_TIME', flex: 2),
              _tableHeader('ASSET_ID', flex: 2),
              _tableHeader('TYPE', flex: 2),
              _tableHeader('ENTRY', flex: 1),
              _tableHeader('EXIT', flex: 1),
              _tableHeader('RESULT', flex: 1),
            ],
          ),
        ),
        const Divider(color: Colors.white10, height: 1),
        // Table rows
        _signalRow('2024.11.04_14:22', 'US_PRES_2024', 'YES_ELECTION', '51.2',
            '52.4', 'WON'),
        _signalRow('2024.11.04_11:05', 'FED_RATE_CUT', 'NO_Pivot', '65.1',
            '62.0', 'LOST'),
        _signalRow('2024.11.03_22:15', 'GOP_SENATE', 'YES_Control', '57.4',
            '58.8', 'WON'),
        _signalRow('2024.11.03_18:40', 'TX_BORDER_BILL', 'YES_Passage', '45.2',
            '52.4', 'WON'),
        _signalRow('2024.11.03_09:12', 'CA_HOUSING_INIT', 'NO_Referendum',
            '38.4', '32.1', 'WON'),
        // Extra signals loaded on demand
        if (_showExtraSignals) ...[
          _signalRow('2024.11.02_16:30', 'UK_LEADERSHIP', 'YES_Winner', '42.5',
              '45.8', 'WON'),
          _signalRow('2024.11.02_10:15', 'NATO_ADMISSION', 'NO_Entry', '35.4',
              '38.2', 'LOST'),
          _signalRow('2024.11.01_23:45', 'EU_TARIFFS', 'YES_Implement', '54.8',
              '51.2', 'LOST'),
        ],
      ],
    );
  }

  Widget _tableHeader(String label, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(label,
          style: const TextStyle(
              color: Colors.white24,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1)),
    );
  }

  Widget _signalRow(String time, String asset, String type, String entry,
      String exit, String result) {
    bool isWon = result == 'WON';
    return HoverScaleGlow(
      scaleFactor: 1.01,
      glowRadius: 10,
      glowColor: isWon ? AppTheme.neonOrange : Colors.white10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border(
              bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
        ),
        child: Row(
          children: [
            Expanded(
                flex: 2,
                child: Text(time,
                    style:
                        const TextStyle(color: Colors.white30, fontSize: 12))),
            Expanded(
                flex: 2,
                child: Text(asset,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12))),
            Expanded(
                flex: 2,
                child: Text(type,
                    style: const TextStyle(
                        color: AppTheme.neonOrange,
                        fontSize: 11,
                        fontWeight: FontWeight.bold))),
            Expanded(
                flex: 1,
                child: Text(entry,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12))),
            Expanded(
                flex: 1,
                child: Text(exit,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12))),
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 60,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: isWon ? AppTheme.neonOrange : Colors.transparent,
                    border: isWon ? null : Border.all(color: Colors.white30),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Center(
                    child: isWon
                        ? GlowPulse(
                            glowColor: AppTheme.neonOrange,
                            glowRadius: 8,
                            child: Text(result,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          )
                        : Text(result,
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetMix(PickProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text('ASSET_ALLOCATION_MATRIX',
            style: TextStyle(
                color: AppTheme.neonOrange,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 1)),
        const SizedBox(height: 32),
        Expanded(
          child: Row(
            children: [
              _exposureBar('ELECTION', 0.45),
              const SizedBox(width: 12),
              _exposureBar('POLICY', 0.30),
              const SizedBox(width: 12),
              _exposureBar('MACRO', 0.15),
              const SizedBox(width: 12),
              _exposureBar('REFERENDUM', 0.10),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.02),
            border: Border.all(color: Colors.white10),
          ),
          child: const Row(
            children: [
              Icon(Icons.terminal, color: AppTheme.neonOrange, size: 16),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'ALGORITHMIC_REBALANCING_ACTIVE: COMPOSITE_INDEX_v2.0_DEPLOYED',
                  style: TextStyle(
                      color: Colors.white30,
                      fontSize: 10,
                      fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(builder: (context, constraints) {
      final horizontalPadding = gainrPadding(constraints.maxWidth);
      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Metrics Ribbon
                  _buildMetricsRibbon(),

                  const SizedBox(height: 48),

                  // 2. Copied Trades Terminal
                  _buildTradesTerminal(context),
                ],
              ),
            ),
          ),

          // 3. Console Log Footer
          _buildConsoleLog(context, constraints.maxWidth),
        ],
      );
    });
  }

  Widget _buildMetricsRibbon() {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: [
        _metricCard('ACTIVE_SESSIONS', '12',
            suffix: 'LIVE', suffixColor: AppTheme.neonOrange),
        _metricCard('NET_EQUITY', '\$48,250.82'),
        _metricCard('TOTAL_UNREALIZED_PNL', '+\$4,894.50',
            valueColor: AppTheme.neonOrange),
        _metricCard('MARGIN_USAGE', '34.5%'),
        _metricCard('WIN_RATE_24H', '72.4%', valueColor: Colors.green),
        _metricCard('TOTAL_PROVIDERS', '08',
            suffix: 'ACTIVE', suffixColor: AppTheme.neonOrange),
      ],
    );
  }

  Widget _metricCard(String label, String value,
      {String? suffix, Color? suffixColor, Color? valueColor}) {
    return GlassmorphicContainer(
      borderRadius: 12,
      child: Container(
        constraints: const BoxConstraints(minWidth: 160, maxWidth: 200),
        height: 98,
        padding: const EdgeInsets.all(20),
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
            const SizedBox(height: 12),
            Row(
              children: [
                Text(value,
                    style: TextStyle(
                        color: valueColor ?? Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1)),
                if (suffix != null) ...[
                  const SizedBox(width: 8),
                  Text(suffix,
                      style: TextStyle(
                          color: suffixColor ?? Colors.white30,
                          fontSize: 8,
                          fontWeight: FontWeight.bold)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTradesTerminal(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(builder: (context, constraints) {
          return const Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GlowPulse(
                    glowColor: AppTheme.neonOrange,
                    glowRadius: 6,
                    child: Icon(LucideIcons.layout_panel_top,
                        color: AppTheme.neonOrange, size: 20),
                  ),
                  SizedBox(width: 16),
                  NeonText(
                    text: 'COPIED_TRADES_TERMINAL',
                    glowColor: AppTheme.neonOrange,
                    glowRadius: 4,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 1),
                  ),
                ],
              ),
              Text('AUTO-REFRESH: 2S  #PS_V3_ONLINE',
                  style: TextStyle(
                      color: AppTheme.neonOrange,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1)),
            ],
          );
        }),
        const SizedBox(height: 32),
        // Table Layout
        GlassmorphicContainer(
          borderRadius: 12,
          child: Column(
            children: [
              _tableHeader(),
              const Divider(color: Colors.white10, height: 1),
              _tradeRow(context, 'PolitiQuantitative', 'US_PRES_2024', '51.2',
                  '52.4', '+\$891.80', true, 0),
              _tradeRow(context, 'MacroAlpha', 'FED_RATE_CUT', '65.1', '62.0',
                  '-\$24.75', false, 1),
              _tradeRow(context, 'DC_Insider', 'GOP_SENATE', '57.4', '58.8',
                  '+\$13.50', true, 2),
              _tradeRow(context, 'PolicyWhale', 'UK_LABOUR_MAJ', '85.2', '86.1',
                  '+\$11.95', true, 3),
              _tradeRow(context, 'SwingStateBot', 'PA_TRUMP_WIN', '50.5',
                  '51.1', '+\$42.30', true, 4),
              _tradeRow(context, 'CryptoGov', 'CRYPTO_REG', '38.2', '42.3',
                  '+\$284.60', true, 5),
              _tradeRow(context, 'GeoPol_Engine', 'UKR_CEASEFIRE', '14.0',
                  '12.4', '-\$112.00', false, 6),
              _tradeRow(context, 'EuroVision_AI', 'FR_SNAP_LEFT', '36.8',
                  '38.4', '+\$56.20', true, 7),
              _tradeRow(context, 'HillStats', 'SCOTUS_VACANCY', '12.1', '15.2',
                  '+\$198.40', true, 8),
              _tradeRow(context, 'DefenseHawk', 'TAIWAN_STRAIT', '9.2', '8.6',
                  '-\$18.90', false, 9),
              _tradeRow(context, 'CapitolMetrics', 'MI_HARRIS_WIN', '48.1',
                  '49.2', '+\$67.50', true, 10),
              _tradeRow(context, 'SenateAlpha', 'STUDENT_LOAN', '30.4', '28.5',
                  '-\$95.00', false, 11),
              const SizedBox(height: 48),
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(
                    child: Text('--- END OF ACTIVE LISTING // 12 TRADES ---',
                        style: TextStyle(
                            color: Colors.white10,
                            fontSize: 10,
                            letterSpacing: 2))),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white.withValues(alpha: 0.05),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 800),
          child: Row(
            children: [
              _hItem('PROVIDER', flex: 2),
              _hItem('ASSET', flex: 2),
              _hItem('ENTRY_PRICE', flex: 2),
              _hItem('CURRENT_PRICE', flex: 2),
              _hItem('UNREALIZED_PNL', flex: 2),
              _hItem('ACTION', flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hItem(String label, {int flex = 1}) {
    return Expanded(
        flex: flex,
        child: Text(label,
            style: const TextStyle(
                color: Colors.white24,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1)));
  }

  Widget _tradeRow(BuildContext context, String provider, String asset,
      String entry, String current, String pnl, bool positive, int index) {
    return StaggeredFadeSlide(
      index: index,
      child: HoverScaleGlow(
        scaleFactor: 1.01,
        glowRadius: 10,
        glowColor: positive ? AppTheme.neonOrange : Colors.red,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            border: const Border(bottom: BorderSide(color: Colors.white10)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 800),
              child: Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: Row(children: [
                        const GlowPulse(
                          glowColor: AppTheme.neonOrange,
                          glowRadius: 6,
                          child: Icon(LucideIcons.circle,
                              color: AppTheme.neonOrange, size: 8),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(provider,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        )
                      ])),
                  Expanded(
                      flex: 2,
                      child: Text(asset,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16))),
                  Expanded(
                      flex: 2,
                      child: Text(entry,
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontFamily: 'monospace'))),
                  Expanded(
                      flex: 2,
                      child: Text(current,
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontFamily: 'monospace'))),
                  Expanded(
                      flex: 2,
                      child: Text(pnl,
                          style: TextStyle(
                              color:
                                  positive ? AppTheme.neonOrange : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontFamily: 'monospace'))),
                  Expanded(
                      flex: 1,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () =>
                              _showCloseTradeDialog(context, provider, asset),
                          child: Container(
                            height: 32,
                            decoration: BoxDecoration(
                                border: Border.all(color: AppTheme.neonOrange),
                                borderRadius: BorderRadius.circular(2)),
                            child: const Center(
                                child: Text('CLOSE TRADE',
                                    style: TextStyle(
                                        color: AppTheme.neonOrange,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold))),
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCloseTradeDialog(
      BuildContext context, String provider, String asset) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0A0A0A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: Colors.white10),
        ),
        title: const Text('CONFIRM_CLOSE_TRADE',
            style: TextStyle(
                color: AppTheme.neonOrange,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1)),
        content: Text(
          'Close active position:\n\nPROVIDER: $provider\nASSET: $asset\n\nThis action cannot be undone.',
          style:
              const TextStyle(color: Colors.white54, fontSize: 13, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL',
                style: TextStyle(color: Colors.white30, letterSpacing: 1)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'TRADE_CLOSED: $provider — $asset',
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1),
                  ),
                  backgroundColor: AppTheme.neonOrange,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('CONFIRM_CLOSE',
                style: TextStyle(
                    color: AppTheme.neonOrange,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1)),
          ),
        ],
      ),
    );
  }

  Widget _buildConsoleLog(BuildContext context, double screenWidth) {
    return Container(
      height: screenWidth < 600 ? 150 : 200,
      width: double.infinity,
      color: const Color(0xFF030303),
      padding: EdgeInsets.all(screenWidth < 600 ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 32,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('TERMINAL_STATUS: ',
                      style: TextStyle(
                          color: Colors.white24,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1)),
                  Text('READY',
                      style: TextStyle(
                          color: AppTheme.neonOrange,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1)),
                ],
              ),
              const Text('LATENCY: 24MS',
                  style: TextStyle(
                      color: Colors.white24, fontSize: 10, letterSpacing: 1)),
              const Text('REGION: US-EAST-1',
                  style: TextStyle(
                      color: Colors.white24, fontSize: 10, letterSpacing: 1)),
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'EXPORTING_LOGS… FORMAT: JSON | DESTINATION: LOCAL',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1),
                      ),
                      backgroundColor: AppTheme.neonOrange,
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text('EXPORT LOGS',
                    style: TextStyle(
                        color: Colors.white24,
                        fontSize: 10,
                        decoration: TextDecoration.underline)),
              ),
              InkWell(
                onTap: () => _showTerminateDialog(context),
                child: const Text('TERMINATE_ALL',
                    style: TextStyle(
                        color: Colors.white24,
                        fontSize: 10,
                        decoration: TextDecoration.underline)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                _logLine('09:42:01',
                    'Executing sync with PolitiQuantitative provider...',
                    color: Colors.white30),
                _logLine(
                    '09:43:03', 'Intel update received: US_PRES_2024 +1.25%',
                    color: AppTheme.neonOrange),
                _logLine('09:43:05',
                    'WARNING: Election volatility surge detected on PA ballot.',
                    color: Colors.orange),
                _logLine('09:44:00', 'Polling consensus cluster status: OK',
                    color: Colors.white30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showTerminateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0A0A0A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: Colors.white10),
        ),
        title: const Text('⚠ TERMINATE_ALL_SESSIONS',
            style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1)),
        content: const Text(
          'This will close ALL active sessions and positions.\n\n'
          'Active sessions: 4\n'
          'Open positions: 4\n\n'
          'This action cannot be undone.',
          style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('ABORT',
                style: TextStyle(color: Colors.white30, letterSpacing: 1)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'ALL_SESSIONS_TERMINATED — 4 POSITIONS CLOSED',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1),
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 3),
                ),
              );
            },
            child: const Text('CONFIRM_TERMINATE',
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1)),
          ),
        ],
      ),
    );
  }

  Widget _logLine(String time, String message, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
                text: '$time ',
                style: const TextStyle(
                    color: AppTheme.neonOrange,
                    fontSize: 11,
                    fontFamily: 'monospace')),
            TextSpan(
                text: message,
                style: TextStyle(
                    color: color, fontSize: 11, fontFamily: 'monospace')),
          ],
        ),
      ),
    );
  }
}

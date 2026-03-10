import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(gainrPadding(MediaQuery.sizeOf(context).width)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPortfolioHeader(),
          const SizedBox(height: 16),
          _buildHeaderStats(),
          const SizedBox(height: 48),
          Text(
            'ACTIVE_PREDICTIONS // OPEN_POSITIONS',
            style: AppTextStyles.bodySmall
                .copyWith(color: Colors.white30, letterSpacing: 2),
          ),
          const SizedBox(height: 16),
          _buildPositionTable(context),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildPortfolioHeader() {
    return LayoutBuilder(builder: (context, constraints) {
      bool isNarrow = constraints.maxWidth < 600;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: NeonText(
              text: 'PORTFOLIO // OVERVIEW',
              glowColor: AppColors.neonOrange,
              glowRadius: 4,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.neonOrange, letterSpacing: 2),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.neonOrange.withValues(alpha: 0.1),
              border: Border.all(color: AppColors.neonOrange),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.download,
                    size: 12, color: AppColors.neonOrange),
                if (!isNarrow) ...[
                  const SizedBox(width: 8),
                  const Text('EXPORT_REPORT',
                      style: TextStyle(
                          color: AppColors.neonOrange,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ],
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildHeaderStats() {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: [
        _statItem('ACCOUNT_VALUE', '\$142,850.20', isPrimary: true),
        _statItem('TOTAL_PROFIT', '+\$18,310.80', color: Colors.green),
        _statItem('ACTIVE_STAKE', '\$32,700.00'),
      ],
    );
  }

  Widget _statItem(String label, String value,
      {bool isPrimary = false, Color? color}) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 180, maxWidth: 280),
      child: GlassmorphicContainer(
        padding: const EdgeInsets.all(24),
        borderRadius: 12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.white24, fontSize: 10, letterSpacing: 1)),
            const SizedBox(height: 12),
            if (isPrimary || color != null)
              NeonText(
                text: value,
                glowColor: color ?? AppColors.neonOrange,
                glowRadius: isPrimary ? 8 : 4,
                style: TextStyle(
                  color: color ?? AppColors.neonOrange,
                  fontSize: isPrimary ? 32 : 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              )
            else
              Text(value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionTable(BuildContext context) {
    return GlassmorphicContainer(
      borderRadius: 12,
      child: Column(
        children: [
          _tableHeader(),
          _positionRow(
              'US_ELECTION_TRUMP_WIN', 'YES', '\$5,000', '+12.4%', '42M'),
          _divider(),
          _positionRow(
              'UK_LABOUR_MAJORITY', 'YES', '\$2,500', '+8.1%', '2H 15M'),
          _divider(),
          _positionRow('FED_RATE_HIKE_SEP', 'NO', '\$5,000', '-3.2%', '14D'),
          _divider(),
          _positionRow('GOP_SENATE_CONTROL', 'YES', '\$3,200', '+5.7%', '250D'),
          _divider(),
          _positionRow(
              'TRUMP_WINS_PENNSYLVANIA', 'YES', '\$1,800', '+4.2%', '248D'),
          _divider(),
          _positionRow(
              'HARRIS_WINS_MICHIGAN', 'NO', '\$2,100', '-1.8%', '248D'),
          _divider(),
          _positionRow('CRYPTO_REG_PASSED', 'YES', '\$4,500', '+18.3%', '180D'),
          _divider(),
          _positionRow('UKRAINE_CEASEFIRE', 'YES', '\$1,200', '-6.4%', '150D'),
          _divider(),
          _positionRow('FRANCE_SNAP_LEFT_WIN', 'NO', '\$3,800', '+2.9%', '60D'),
          _divider(),
          _positionRow('SCOTUS_VACANCY', 'YES', '\$900', '+22.1%', '300D'),
          _divider(),
          _positionRow(
              'STUDENT_LOAN_FORGIVENESS', 'NO', '\$2,700', '-8.5%', '120D'),
        ],
      ),
    );
  }

  Widget _tableHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white.withValues(alpha: 0.05),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 700),
          child: const Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Text('MARKET_ID',
                      style: TextStyle(color: Colors.white24, fontSize: 10))),
              Expanded(
                  child: Text('SIDE',
                      style: TextStyle(color: Colors.white24, fontSize: 10))),
              Expanded(
                  child: Text('STAKE',
                      style: TextStyle(color: Colors.white24, fontSize: 10))),
              Expanded(
                  child: Text('P/L',
                      style: TextStyle(color: Colors.white24, fontSize: 10))),
              Expanded(
                  child: Text('EXPIRES',
                      style: TextStyle(color: Colors.white24, fontSize: 10))),
              SizedBox(width: 40), // Narrower action spacer
            ],
          ),
        ),
      ),
    );
  }

  Widget _positionRow(
      String market, String side, String stake, String pl, String expiry) {
    final isPositive = pl.startsWith('+');
    return HoverScaleGlow(
      scaleFactor: 1.01,
      glowRadius: 10,
      glowColor: isPositive ? Colors.green : Colors.red,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 700),
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text(market,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            fontFamily: 'monospace'))),
                Expanded(
                    child: Text(side,
                        style: TextStyle(
                            color: side == 'YES' ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12))),
                Expanded(
                    child: Text(stake, style: const TextStyle(fontSize: 12))),
                Expanded(
                    child: Text(pl,
                        style: TextStyle(
                            color: isPositive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12))),
                Expanded(
                    child: Text(expiry,
                        style: const TextStyle(
                            color: Colors.white30, fontSize: 12))),
                _buildRowAction(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRowAction() {
    return SizedBox(
      width: 40,
      child: IconButton(
        icon: const Icon(LucideIcons.ellipsis,
            size: 16, color: AppColors.neonOrange),
        onPressed: () {},
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _divider() =>
      Container(height: 1, color: Colors.white.withValues(alpha: 0.05));
}

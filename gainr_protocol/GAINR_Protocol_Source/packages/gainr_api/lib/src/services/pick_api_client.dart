import 'dart:math';
import 'package:gainr_models/gainr_models.dart';

class PickApiClient {
  Future<List<PickProvider>> getTopProviders() async {
    await Future.delayed(const Duration(milliseconds: 1000));

    return const [
      PickProvider(
        id: 'p1',
        name: 'PolitiQuantitative',
        roi: 1250.40,
        winRate: 0.68,
        followers: 1240,
        totalProfit: 450000.0,
        performanceHistory: [0.1, 0.4, 0.2, 0.8, 0.7, 0.9, 1.0],
        latestSignal: 'TRUMP_WIN @ 52%',
        isVerified: true,
      ),
      PickProvider(
        id: 'p2',
        name: 'HillStats',
        roi: 840.20,
        winRate: 0.72,
        followers: 850,
        totalProfit: 125000.0,
        performanceHistory: [0.5, 0.6, 0.5, 0.7, 0.8, 0.85, 0.9],
        latestSignal: 'FED_RATE_CUT @ 65%',
      ),
      PickProvider(
        id: 'p3',
        name: 'SenateAlpha',
        roi: 420.15,
        winRate: 0.55,
        followers: 2100,
        totalProfit: 89000.0,
        performanceHistory: [0.8, 0.7, 0.75, 0.6, 0.5, 0.4, 0.45],
        latestSignal: 'ABORTION_RIGHTS_REF_YES @ 58%',
        isVerified: true,
      ),
      PickProvider(
        id: 'p4',
        name: 'DC_Insider',
        roi: 680.30,
        winRate: 0.64,
        followers: 3200,
        totalProfit: 312000.0,
        performanceHistory: [0.3, 0.5, 0.6, 0.65, 0.7, 0.8, 0.85],
        latestSignal: 'GOP_HOUSE_FLIP @ 47%',
        isVerified: true,
      ),
      PickProvider(
        id: 'p5',
        name: 'MacroAlpha',
        roi: 510.80,
        winRate: 0.61,
        followers: 1580,
        totalProfit: 198000.0,
        performanceHistory: [0.2, 0.3, 0.55, 0.6, 0.7, 0.72, 0.8],
        latestSignal: 'FED_PIVOT_DEC @ 71%',
      ),
      PickProvider(
        id: 'p6',
        name: 'PolicyWhale',
        roi: 920.60,
        winRate: 0.75,
        followers: 4500,
        totalProfit: 520000.0,
        performanceHistory: [0.4, 0.6, 0.7, 0.8, 0.85, 0.88, 0.92],
        latestSignal: 'UK_LABOUR_MAJ @ 85%',
        isVerified: true,
      ),
      PickProvider(
        id: 'p7',
        name: 'GeoPol_Engine',
        roi: 340.20,
        winRate: 0.58,
        followers: 920,
        totalProfit: 67000.0,
        performanceHistory: [0.6, 0.5, 0.55, 0.48, 0.52, 0.58, 0.62],
        latestSignal: 'UKRAINE_CEASEFIRE @ 12%',
      ),
      PickProvider(
        id: 'p8',
        name: 'SwingStateBot',
        roi: 1580.90,
        winRate: 0.71,
        followers: 6800,
        totalProfit: 890000.0,
        performanceHistory: [0.3, 0.5, 0.7, 0.75, 0.8, 0.85, 0.9],
        latestSignal: 'PA_TRUMP_WIN @ 51%',
        isVerified: true,
      ),
      PickProvider(
        id: 'p9',
        name: 'EuroVision_AI',
        roi: 290.40,
        winRate: 0.52,
        followers: 740,
        totalProfit: 45000.0,
        performanceHistory: [0.4, 0.45, 0.5, 0.48, 0.52, 0.55, 0.58],
        latestSignal: 'FRANCE_LEFT_WIN @ 38%',
      ),
      PickProvider(
        id: 'p10',
        name: 'CryptoGov',
        roi: 1120.75,
        winRate: 0.66,
        followers: 2900,
        totalProfit: 410000.0,
        performanceHistory: [0.2, 0.4, 0.5, 0.6, 0.65, 0.7, 0.75],
        latestSignal: 'CRYPTO_REG_PASSED @ 42%',
        isVerified: true,
      ),
      PickProvider(
        id: 'p11',
        name: 'DefenseHawk',
        roi: 480.15,
        winRate: 0.59,
        followers: 1100,
        totalProfit: 92000.0,
        performanceHistory: [0.5, 0.55, 0.6, 0.58, 0.62, 0.64, 0.66],
        latestSignal: 'TAIWAN_ESCALATION @ 9%',
      ),
      PickProvider(
        id: 'p12',
        name: 'CapitolMetrics',
        roi: 730.50,
        winRate: 0.63,
        followers: 1850,
        totalProfit: 275000.0,
        performanceHistory: [0.35, 0.45, 0.55, 0.6, 0.65, 0.7, 0.72],
        latestSignal: 'MI_HARRIS_WIN @ 49%',
        isVerified: true,
      ),
    ];
  }

  Stream<String> getSignalStream() async* {
    final signals = [
      'TRUMP_WIN_PA @ 51.5%',
      'HARRIS_WIN_MI @ 49.2%',
      'FED_Pivot_Nov @ 68%',
      'TAX_CUT_Extension @ 42%',
      'SENATE_GOP_Control @ 55%',
      'UK_LABOUR_85% → CONFIRMED',
      'CRYPTO_REG_BILL → COMMITTEE',
      'FRANCE_SNAP → LEFT_SURGE +4pts',
      'TAIWAN_STRAIT → STABLE',
      'DE_COALITION → FRAGILE',
    ];
    final random = Random();
    while (true) {
      await Future.delayed(Duration(seconds: random.nextInt(10) + 5));
      yield signals[random.nextInt(signals.length)];
    }
  }
}

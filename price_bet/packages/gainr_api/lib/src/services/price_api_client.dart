import 'dart:math';
import 'package:gainr_models/gainr_models.dart';

class PriceApiClient {
  Future<List<PriceMarket>> getMarkets() async {
    await Future.delayed(const Duration(milliseconds: 800));

    final now = DateTime.now();
    return [
      // 1. Burnley vs Bournemouth
      PriceMarket(
        id: 'epl_burnley_bournemouth_home',
        asset: 'BURNLEY',
        currentPrice: 23.00,
        priceChange24h: 1.2,
        expiry: now.add(const Duration(hours: 48)),
        totalStaked: 1250000.0,
      ),
      PriceMarket(
        id: 'epl_burnley_bournemouth_draw',
        asset: 'DRAW',
        currentPrice: 26.00,
        priceChange24h: -0.5,
        expiry: now.add(const Duration(hours: 48)),
        totalStaked: 850000.0,
      ),
      PriceMarket(
        id: 'epl_burnley_bournemouth_away',
        asset: 'BOURNEMOUTH',
        currentPrice: 52.00,
        priceChange24h: -0.7,
        expiry: now.add(const Duration(hours: 48)),
        totalStaked: 2200000.0,
      ),

      // 2. Sunderland vs Brighton
      PriceMarket(
        id: 'epl_sunderland_brighton_home',
        asset: 'SUNDERLAND',
        currentPrice: 29.00,
        priceChange24h: 2.1,
        expiry: now.add(const Duration(hours: 49)),
        totalStaked: 1100000.0,
      ),
      PriceMarket(
        id: 'epl_sunderland_brighton_draw',
        asset: 'DRAW',
        currentPrice: 28.00,
        priceChange24h: -1.2,
        expiry: now.add(const Duration(hours: 49)),
        totalStaked: 950000.0,
      ),
      PriceMarket(
        id: 'epl_sunderland_brighton_away',
        asset: 'BRIGHTON',
        currentPrice: 43.00,
        priceChange24h: -0.9,
        expiry: now.add(const Duration(hours: 49)),
        totalStaked: 1800000.0,
      ),

      // 3. Arsenal vs Everton
      PriceMarket(
        id: 'epl_arsenal_everton_home',
        asset: 'ARSENAL',
        currentPrice: 69.00,
        priceChange24h: 3.5,
        expiry: now.add(const Duration(hours: 50)),
        totalStaked: 4500000.0,
      ),
      PriceMarket(
        id: 'epl_arsenal_everton_draw',
        asset: 'DRAW',
        currentPrice: 21.00,
        priceChange24h: -1.5,
        expiry: now.add(const Duration(hours: 50)),
        totalStaked: 1200000.0,
      ),
      PriceMarket(
        id: 'epl_arsenal_everton_away',
        asset: 'EVERTON',
        currentPrice: 10.00,
        priceChange24h: -2.0,
        expiry: now.add(const Duration(hours: 50)),
        totalStaked: 500000.0,
      ),

      // 4. Chelsea vs Newcastle
      PriceMarket(
        id: 'epl_chelsea_newcastle_home',
        asset: 'CHELSEA',
        currentPrice: 53.00,
        priceChange24h: 1.8,
        expiry: now.add(const Duration(hours: 51)),
        totalStaked: 3200000.0,
      ),
      PriceMarket(
        id: 'epl_chelsea_newcastle_draw',
        asset: 'DRAW',
        currentPrice: 22.00,
        priceChange24h: -0.8,
        expiry: now.add(const Duration(hours: 51)),
        totalStaked: 1500000.0,
      ),
      PriceMarket(
        id: 'epl_chelsea_newcastle_away',
        asset: 'NEWCASTLE',
        currentPrice: 25.00,
        priceChange24h: -1.0,
        expiry: now.add(const Duration(hours: 51)),
        totalStaked: 1800000.0,
      ),

      // 5. West Ham vs Man City
      PriceMarket(
        id: 'epl_westham_mancity_home',
        asset: 'WEST HAM',
        currentPrice: 20.00,
        priceChange24h: -1.5,
        expiry: now.add(const Duration(hours: 52)),
        totalStaked: 1100000.0,
      ),
      PriceMarket(
        id: 'epl_westham_mancity_draw',
        asset: 'DRAW',
        currentPrice: 21.00,
        priceChange24h: -0.5,
        expiry: now.add(const Duration(hours: 52)),
        totalStaked: 1300000.0,
      ),
      PriceMarket(
        id: 'epl_westham_mancity_away',
        asset: 'MAN CITY',
        currentPrice: 59.00,
        priceChange24h: 2.0,
        expiry: now.add(const Duration(hours: 52)),
        totalStaked: 5500000.0,
      ),

      // 6. Crystal Palace vs Leeds
      PriceMarket(
        id: 'epl_crystalpalace_leeds_home',
        asset: 'CRYSTAL PALACE',
        currentPrice: 41.00,
        priceChange24h: 1.2,
        expiry: now.add(const Duration(hours: 53)),
        totalStaked: 1600000.0,
      ),
      PriceMarket(
        id: 'epl_crystalpalace_leeds_draw',
        asset: 'DRAW',
        currentPrice: 28.00,
        priceChange24h: 0.1,
        expiry: now.add(const Duration(hours: 53)),
        totalStaked: 1200000.0,
      ),
      PriceMarket(
        id: 'epl_crystalpalace_leeds_away',
        asset: 'LEEDS',
        currentPrice: 31.00,
        priceChange24h: -1.3,
        expiry: now.add(const Duration(hours: 53)),
        totalStaked: 1400000.0,
      ),

      // 7. Man Utd vs Aston Villa
      PriceMarket(
        id: 'epl_manutd_astonvilla_home',
        asset: 'MAN UTD',
        currentPrice: 54.00,
        priceChange24h: 2.5,
        expiry: now.add(const Duration(hours: 54)),
        totalStaked: 4200000.0,
      ),
      PriceMarket(
        id: 'epl_manutd_astonvilla_draw',
        asset: 'DRAW',
        currentPrice: 25.00,
        priceChange24h: -1.0,
        expiry: now.add(const Duration(hours: 54)),
        totalStaked: 1800000.0,
      ),
      PriceMarket(
        id: 'epl_manutd_astonvilla_away',
        asset: 'ASTON VILLA',
        currentPrice: 22.00,
        priceChange24h: -1.5,
        expiry: now.add(const Duration(hours: 54)),
        totalStaked: 1600000.0,
      ),

      // 8. Nottm Forest vs Fulham
      PriceMarket(
        id: 'epl_nottmforest_fulham_home',
        asset: 'NOTTM FOREST',
        currentPrice: 44.00,
        priceChange24h: 1.8,
        expiry: now.add(const Duration(hours: 55)),
        totalStaked: 1500000.0,
      ),
      PriceMarket(
        id: 'epl_nottmforest_fulham_draw',
        asset: 'DRAW',
        currentPrice: 27.00,
        priceChange24h: -0.2,
        expiry: now.add(const Duration(hours: 55)),
        totalStaked: 1100000.0,
      ),
      PriceMarket(
        id: 'epl_nottmforest_fulham_away',
        asset: 'FULHAM',
        currentPrice: 29.00,
        priceChange24h: -1.6,
        expiry: now.add(const Duration(hours: 55)),
        totalStaked: 1200000.0,
      ),

      // 9. Liverpool vs Tottenham
      PriceMarket(
        id: 'epl_liverpool_tottenham_home',
        asset: 'LIVERPOOL',
        currentPrice: 70.00,
        priceChange24h: 4.0,
        expiry: now.add(const Duration(hours: 56)),
        totalStaked: 5800000.0,
      ),
      PriceMarket(
        id: 'epl_liverpool_tottenham_draw',
        asset: 'DRAW',
        currentPrice: 19.00,
        priceChange24h: -2.0,
        expiry: now.add(const Duration(hours: 56)),
        totalStaked: 1600000.0,
      ),
      PriceMarket(
        id: 'epl_liverpool_tottenham_away',
        asset: 'TOTTENHAM',
        currentPrice: 11.00,
        priceChange24h: -2.0,
        expiry: now.add(const Duration(hours: 56)),
        totalStaked: 1100000.0,
      ),

      // 10. Brentford vs Wolverhampton
      PriceMarket(
        id: 'epl_brentford_wolverhampton_home',
        asset: 'BRENTFORD',
        currentPrice: 61.00,
        priceChange24h: 2.2,
        expiry: now.add(const Duration(hours: 57)),
        totalStaked: 2800000.0,
      ),
      PriceMarket(
        id: 'epl_brentford_wolverhampton_draw',
        asset: 'DRAW',
        currentPrice: 24.00,
        priceChange24h: -1.0,
        expiry: now.add(const Duration(hours: 57)),
        totalStaked: 1300000.0,
      ),
      PriceMarket(
        id: 'epl_brentford_wolverhampton_away',
        asset: 'WOLVERHAMPTON',
        currentPrice: 16.00,
        priceChange24h: -1.2,
        expiry: now.add(const Duration(hours: 57)),
        totalStaked: 900000.0,
      ),
    ];
  }

  Stream<double> getPriceStream(String asset) async* {
    double price = asset.contains('ELECTION')
        ? 52.40
        : asset.contains('LABOUR')
            ? 85.20
            : asset.contains('CEASEFIRE')
                ? 12.40
                : asset.contains('BTC')
                    ? 71.40
                    : 65.10;
    while (true) {
      await Future.delayed(const Duration(seconds: 2));
      final change = (Random().nextDouble() - 0.5) * 2;
      price += change;
      if (price < 0) price = 0;
      if (price > 100) price = 100;
      yield price;
    }
  }
}

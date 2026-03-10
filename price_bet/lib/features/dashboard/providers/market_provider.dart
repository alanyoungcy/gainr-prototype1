import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gainr_api/gainr_api.dart';
import 'package:gainr_models/gainr_models.dart';

final priceApiClientProvider = Provider((ref) => PriceApiClient());

final marketsProvider = FutureProvider<List<PriceMarket>>((ref) async {
  final client = ref.watch(priceApiClientProvider);
  final realMarkets = await client.getMarkets();
  
  // Mock Champions League Matchups
  final mockUclMarkets = [
    // Galatasaray vs Liverpool
    PriceMarket(id: 'ucl_galatasaray_liverpool_home', asset: 'Galatasaray', currentPrice: 23.0, totalStaked: 15400.0, expiry: DateTime(2026, 3, 15, 20), priceChange24h: 0.0),
    PriceMarket(id: 'ucl_galatasaray_liverpool_draw', asset: 'Draw', currentPrice: 24.0, totalStaked: 8200.0, expiry: DateTime(2026, 3, 15, 20), priceChange24h: 0.0),
    PriceMarket(id: 'ucl_galatasaray_liverpool_away', asset: 'Liverpool', currentPrice: 53.0, totalStaked: 42100.0, expiry: DateTime(2026, 3, 15, 20), priceChange24h: 0.0),

    // Newcastle vs Barcelona
    PriceMarket(id: 'ucl_newcastle_barcelona_home', asset: 'Newcastle', currentPrice: 36.0, totalStaked: 12100.0, expiry: DateTime(2026, 3, 15, 20), priceChange24h: 0.0),
    PriceMarket(id: 'ucl_newcastle_barcelona_draw', asset: 'Draw', currentPrice: 25.0, totalStaked: 5400.0, expiry: DateTime(2026, 3, 15, 20), priceChange24h: 0.0),
    PriceMarket(id: 'ucl_newcastle_barcelona_away', asset: 'Barcelona', currentPrice: 38.0, totalStaked: 28900.0, expiry: DateTime(2026, 3, 15, 20), priceChange24h: 0.0),

    // Atl. Madrid vs Tottenham
    PriceMarket(id: 'ucl_atletico_tottenham_home', asset: 'Atl. Madrid', currentPrice: 54.0, totalStaked: 19800.0, expiry: DateTime(2026, 3, 16, 20), priceChange24h: 0.0),
    PriceMarket(id: 'ucl_atletico_tottenham_draw', asset: 'Draw', currentPrice: 26.0, totalStaked: 7200.0, expiry: DateTime(2026, 3, 16, 20), priceChange24h: 0.0),
    PriceMarket(id: 'ucl_atletico_tottenham_away', asset: 'Tottenham', currentPrice: 20.0, totalStaked: 11500.0, expiry: DateTime(2026, 3, 16, 20), priceChange24h: 0.0),

    // Atalanta vs Bayern Munich
    PriceMarket(id: 'ucl_atalanta_bayern_home', asset: 'Atalanta', currentPrice: 21.0, totalStaked: 8500.0, expiry: DateTime(2026, 3, 16, 20), priceChange24h: 0.0),
    PriceMarket(id: 'ucl_atalanta_bayern_draw', asset: 'Draw', currentPrice: 21.0, totalStaked: 4200.0, expiry: DateTime(2026, 3, 16, 20), priceChange24h: 0.0),
    PriceMarket(id: 'ucl_atalanta_bayern_away', asset: 'Bayern Munich', currentPrice: 58.0, totalStaked: 35600.0, expiry: DateTime(2026, 3, 16, 20), priceChange24h: 0.0),

    // Bayer Leverkusen vs Arsenal
    PriceMarket(id: 'ucl_leverkusen_arsenal_home', asset: 'Bayer Leverkusen', currentPrice: 17.0, totalStaked: 9200.0, expiry: DateTime(2026, 3, 17, 20), priceChange24h: 0.0),
    PriceMarket(id: 'ucl_leverkusen_arsenal_draw', asset: 'Draw', currentPrice: 23.0, totalStaked: 6100.0, expiry: DateTime(2026, 3, 17, 20), priceChange24h: 0.0),
    PriceMarket(id: 'ucl_leverkusen_arsenal_away', asset: 'Arsenal', currentPrice: 60.0, totalStaked: 48500.0, expiry: DateTime(2026, 3, 17, 20), priceChange24h: 0.0),

    // Real Madrid vs Man City
    PriceMarket(id: 'ucl_realmadrid_mancity_home', asset: 'Real Madrid', currentPrice: 27.0, totalStaked: 31200.0, expiry: DateTime(2026, 3, 17, 20), priceChange24h: 0.0),
    PriceMarket(id: 'ucl_realmadrid_mancity_draw', asset: 'Draw', currentPrice: 26.0, totalStaked: 15400.0, expiry: DateTime(2026, 3, 17, 20), priceChange24h: 0.0),
    PriceMarket(id: 'ucl_realmadrid_mancity_away', asset: 'Man City', currentPrice: 47.0, totalStaked: 62800.0, expiry: DateTime(2026, 3, 17, 20), priceChange24h: 0.0),

    // PSG vs Chelsea
    PriceMarket(id: 'ucl_psg_chelsea_home', asset: 'PSG', currentPrice: 49.0, totalStaked: 22400.0, expiry: DateTime(2026, 3, 18, 20), priceChange24h: 0.0),
    PriceMarket(id: 'ucl_psg_chelsea_draw', asset: 'Draw', currentPrice: 25.0, totalStaked: 9100.0, expiry: DateTime(2026, 3, 18, 20), priceChange24h: 0.0),
    PriceMarket(id: 'ucl_psg_chelsea_away', asset: 'Chelsea', currentPrice: 26.0, totalStaked: 14500.0, expiry: DateTime(2026, 3, 18, 20), priceChange24h: 0.0),

    // Bodo/Glimt vs Sporting CP
    PriceMarket(id: 'ucl_bodoglimt_sporting_home', asset: 'Bodo/Glimt', currentPrice: 37.0, totalStaked: 7800.0, expiry: DateTime(2026, 3, 18, 20), priceChange24h: 0.0),
    PriceMarket(id: 'ucl_bodoglimt_sporting_draw', asset: 'Draw', currentPrice: 26.0, totalStaked: 4500.0, expiry: DateTime(2026, 3, 18, 20), priceChange24h: 0.0),
    PriceMarket(id: 'ucl_bodoglimt_sporting_away', asset: 'Sporting CP', currentPrice: 37.0, totalStaked: 11200.0, expiry: DateTime(2026, 3, 18, 20), priceChange24h: 0.0),
  ];

  return [...realMarkets, ...mockUclMarkets];
});

final priceStreamProvider = StreamProvider.family<double, String>((ref, asset) {
  final client = ref.watch(priceApiClientProvider);
  return client.getPriceStream(asset);
});

final globalIntelligenceProvider = Provider((ref) {
  final service = GlobalIntelligenceService();
  service.startSimulation();
  ref.onDispose(() => service.dispose());
  return service;
});

final intelStreamProvider = StreamProvider<TerminalEvent>((ref) {
  final service = ref.watch(globalIntelligenceProvider);
  return service.eventStream;
});

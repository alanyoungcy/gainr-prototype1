import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gainr_api/gainr_api.dart';
import 'package:gainr_models/gainr_models.dart';

final priceApiClientProvider = Provider((ref) => PriceApiClient());

final marketsProvider = FutureProvider<List<PriceMarket>>((ref) async {
  final client = ref.watch(priceApiClientProvider);
  return client.getMarkets();
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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gainr_api/gainr_api.dart';
import 'package:gainr_models/gainr_models.dart';

final pickApiClientProvider = Provider((ref) => PickApiClient());

final leaderboardProvider = FutureProvider<List<PickProvider>>((ref) async {
  final client = ref.watch(pickApiClientProvider);
  return client.getTopProviders();
});

final signalStreamProvider = StreamProvider<String>((ref) {
  final client = ref.watch(pickApiClientProvider);
  return client.getSignalStream();
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

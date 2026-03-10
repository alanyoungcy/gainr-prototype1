import 'dart:async';
import 'dart:math';
import 'package:gainr_models/gainr_models.dart';

class GlobalIntelligenceService {
  final _controller = StreamController<TerminalEvent>.broadcast();
  Timer? _timer;
  final _random = Random();

  Stream<TerminalEvent> get eventStream => _controller.stream;

  void startSimulation() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      final event = _generateRandomEvent();
      _controller.add(event);
    });
  }

  void stopSimulation() {
    _timer?.cancel();
  }

  TerminalEvent _generateRandomEvent() {
    const types = TerminalEventType.values;
    final type = types[_random.nextInt(types.length)];
    final id = 'evt_${_random.nextInt(10000)}';

    switch (type) {
      case TerminalEventType.whaleAlert:
        final items = [
          'US_PRESIDENTIAL_PROBABILITY',
          'FED_RATE_DECISION',
          'SENATE_CONTROL_GOP',
          'CA_REPARATIONS_BALLOT'
        ];
        final item = items[_random.nextInt(items.length)];
        final amount = (_random.nextInt(50) + 10) * 100000;
        final isYes = _random.nextBool();
        return TerminalEvent(
          id: id,
          type: type,
          title: 'POLITICAL_WHALE_DETECTION',
          message:
              '${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} USDC stake on $item [${isYes ? "YES" : "NO"}]',
          timestamp: DateTime.now(),
          data: {
            'asset': item,
            'amount': amount.toString(),
            'type': isYes ? 'YES' : 'NO',
          },
        );
      case TerminalEventType.volumeSpike:
        return TerminalEvent(
          id: id,
          type: type,
          title: 'INTEL_SURGE',
          message:
              'Anomalous trading activity detected in SWING_STATE_POLLING markets.',
          timestamp: DateTime.now(),
        );
      case TerminalEventType.topSignal:
        return TerminalEvent(
          id: id,
          type: type,
          title: 'POLITI_ALPHA_SIGNAL',
          message:
              'Top-tier provider PolitiQuantitative just executed a high-confidence trade on FED_PIVOT.',
          timestamp: DateTime.now(),
        );
      case TerminalEventType.marketVolatility:
        return TerminalEvent(
          id: id,
          type: type,
          title: 'ELECTION_VOLATILITY',
          message:
              'Debate performance causing high volatility. Recalibrating state-level probabilities.',
          timestamp: DateTime.now(),
        );
    }
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}

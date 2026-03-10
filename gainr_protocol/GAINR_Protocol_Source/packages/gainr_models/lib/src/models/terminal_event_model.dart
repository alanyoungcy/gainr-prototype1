enum TerminalEventType {
  whaleAlert,
  volumeSpike,
  topSignal,
  marketVolatility,
}

class WhaleAlert {
  final String asset;
  final String amount;
  final String type; // 'LONG' or 'SHORT'
  final DateTime timestamp;

  WhaleAlert({
    required this.asset,
    required this.amount,
    required this.type,
    required this.timestamp,
  });
}

class TerminalEvent {
  final String id;
  final TerminalEventType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic>? data;

  TerminalEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.data,
  });
}

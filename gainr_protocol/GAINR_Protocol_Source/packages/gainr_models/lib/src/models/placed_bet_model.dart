enum BetStatus { pending, won, lost }

class PlacedBet {
  final String id;
  final String eventName;
  final String selectionName;
  final String sport;
  final double odds;
  final double stake;
  final double potentialReturn;
  final BetStatus status;
  final DateTime placedAt;
  final DateTime? settledAt;
  final DateTime settlementTime; // When auto-settlement will trigger

  const PlacedBet({
    required this.id,
    required this.eventName,
    required this.selectionName,
    required this.sport,
    required this.odds,
    required this.stake,
    required this.potentialReturn,
    required this.status,
    required this.placedAt,
    required this.settlementTime,
    this.settledAt,
  });

  PlacedBet copyWith({
    BetStatus? status,
    DateTime? settledAt,
  }) {
    return PlacedBet(
      id: id,
      eventName: eventName,
      selectionName: selectionName,
      sport: sport,
      odds: odds,
      stake: stake,
      potentialReturn: potentialReturn,
      status: status ?? this.status,
      placedAt: placedAt,
      settlementTime: settlementTime,
      settledAt: settledAt ?? this.settledAt,
    );
  }

  // Duration remaining until settlement
  Duration get timeUntilSettlement {
    final remaining = settlementTime.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool get isPending => status == BetStatus.pending;
  bool get isWon => status == BetStatus.won;
  bool get isLost => status == BetStatus.lost;
  bool get isSettled => status != BetStatus.pending;

  // JSON serialization for SharedPreferences persistence
  Map<String, dynamic> toJson() => {
        'id': id,
        'eventName': eventName,
        'selectionName': selectionName,
        'sport': sport,
        'odds': odds,
        'stake': stake,
        'potentialReturn': potentialReturn,
        'status': status.name,
        'placedAt': placedAt.toIso8601String(),
        'settlementTime': settlementTime.toIso8601String(),
        'settledAt': settledAt?.toIso8601String(),
      };

  factory PlacedBet.fromJson(Map<String, dynamic> json) => PlacedBet(
        id: json['id'] as String,
        eventName: json['eventName'] as String,
        selectionName: json['selectionName'] as String,
        sport: json['sport'] as String,
        odds: (json['odds'] as num).toDouble(),
        stake: (json['stake'] as num).toDouble(),
        potentialReturn: (json['potentialReturn'] as num).toDouble(),
        status: BetStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => BetStatus.pending,
        ),
        placedAt: DateTime.parse(json['placedAt'] as String),
        settlementTime: DateTime.parse(json['settlementTime'] as String),
        settledAt: json['settledAt'] != null
            ? DateTime.parse(json['settledAt'] as String)
            : null,
      );
}

// Wallet connection status
enum WalletConnection {
  disconnected,
  connecting,
  connected,
  error,
}

// Wallet state model
class WalletState {
  final WalletConnection status;
  final String? address;
  final double solBalance;
  final double betBalance;
  final double gainrBalance;
  final double usdcBalance;
  final List<WalletTransaction> transactions;
  final String? errorMessage;

  const WalletState({
    this.status = WalletConnection.disconnected,
    this.address,
    this.solBalance = 0.0,
    this.betBalance = 0.0,
    this.gainrBalance = 0.0,
    this.usdcBalance = 0.0,
    this.transactions = const [],
    this.errorMessage,
  });

  bool get isConnected => status == WalletConnection.connected;
  bool get isConnecting => status == WalletConnection.connecting;
  bool get hasError => status == WalletConnection.error;

  // Truncate address for display (e.g., "9xQe...abc1")
  String get displayAddress {
    if (address == null || address!.length < 8) return address ?? '';
    return '${address!.substring(0, 4)}...${address!.substring(address!.length - 4)}';
  }

  WalletState copyWith({
    WalletConnection? status,
    String? address,
    double? solBalance,
    double? betBalance,
    double? gainrBalance,
    double? usdcBalance,
    List<WalletTransaction>? transactions,
    String? errorMessage,
  }) {
    return WalletState(
      status: status ?? this.status,
      address: address ?? this.address,
      solBalance: solBalance ?? this.solBalance,
      betBalance: betBalance ?? this.betBalance,
      gainrBalance: gainrBalance ?? this.gainrBalance,
      usdcBalance: usdcBalance ?? this.usdcBalance,
      transactions: transactions ?? this.transactions,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // JSON serialization for localStorage
  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'address': address,
      'solBalance': solBalance,
      'betBalance': betBalance,
      'gainrBalance': gainrBalance,
      'usdcBalance': usdcBalance,
      'transactions': transactions.map((t) => t.toJson()).toList(),
    };
  }

  factory WalletState.fromJson(Map<String, dynamic> json) {
    return WalletState(
      status: WalletConnection.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => WalletConnection.disconnected,
      ),
      address: json['address'] as String?,
      solBalance: (json['solBalance'] as num?)?.toDouble() ?? 0.0,
      betBalance: (json['betBalance'] as num?)?.toDouble() ?? 0.0,
      gainrBalance: (json['gainrBalance'] as num?)?.toDouble() ?? 0.0,
      usdcBalance: (json['usdcBalance'] as num?)?.toDouble() ?? 0.0,
      transactions: (json['transactions'] as List? ?? [])
          .map((t) => WalletTransaction.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }
}

enum TransactionType { deposit, withdraw, swap, reward }

class WalletTransaction {
  final String id;
  final TransactionType type;
  final double amount;
  final String token;
  final DateTime timestamp;
  final String? details;

  const WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.token,
    required this.timestamp,
    this.details,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'amount': amount,
        'token': token,
        'timestamp': timestamp.toIso8601String(),
        'details': details,
      };

  factory WalletTransaction.fromJson(Map<String, dynamic> json) =>
      WalletTransaction(
        id: json['id'],
        type: TransactionType.values.firstWhere((e) => e.name == json['type']),
        amount: (json['amount'] as num).toDouble(),
        token: json['token'],
        timestamp: DateTime.parse(json['timestamp']),
        details: json['details'],
      );
}

class SwapResult {
  final double output;
  final double fee;
  final double priceImpact;
  final double rate;

  const SwapResult({
    required this.output,
    required this.fee,
    required this.priceImpact,
    required this.rate,
  });
}

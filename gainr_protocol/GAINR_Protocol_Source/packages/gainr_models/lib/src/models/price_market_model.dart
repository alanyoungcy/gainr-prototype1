enum PriceMarketType { binary, range, digital }

class PriceMarket {
  final String id;
  final String asset; // e.g., 'BTC/USD'
  final double currentPrice;
  final double priceChange24h;
  final DateTime expiry;
  final PriceMarketType type;
  final double totalStaked;
  final double payoutMultiplier;

  const PriceMarket({
    required this.id,
    required this.asset,
    required this.currentPrice,
    required this.priceChange24h,
    required this.expiry,
    this.type = PriceMarketType.binary,
    required this.totalStaked,
    this.payoutMultiplier = 1.90,
  });

  bool get isExpired => DateTime.now().isAfter(expiry);

  Duration get timeLeft => expiry.difference(DateTime.now());

  PriceMarket copyWith({
    double? currentPrice,
    double? priceChange24h,
    double? totalStaked,
  }) {
    return PriceMarket(
      id: id,
      asset: asset,
      currentPrice: currentPrice ?? this.currentPrice,
      priceChange24h: priceChange24h ?? this.priceChange24h,
      expiry: expiry,
      type: type,
      totalStaked: totalStaked ?? this.totalStaked,
      payoutMultiplier: payoutMultiplier,
    );
  }
}

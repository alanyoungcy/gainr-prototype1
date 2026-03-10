class PickProvider {
  final String id;
  final String name;
  final String avatarUrl;
  final double roi;
  final double winRate;
  final int followers;
  final double totalProfit;
  final List<double> performanceHistory; // 7-day trend
  final String? latestSignal;
  final bool isVerified;

  const PickProvider({
    required this.id,
    required this.name,
    this.avatarUrl = '',
    required this.roi,
    required this.winRate,
    required this.followers,
    required this.totalProfit,
    this.performanceHistory = const [],
    this.latestSignal,
    this.isVerified = false,
  });

  PickProvider copyWith({
    double? roi,
    double? winRate,
    int? followers,
    double? totalProfit,
    List<double>? performanceHistory,
    String? latestSignal,
  }) {
    return PickProvider(
      id: id,
      name: name,
      avatarUrl: avatarUrl,
      roi: roi ?? this.roi,
      winRate: winRate ?? this.winRate,
      followers: followers ?? this.followers,
      totalProfit: totalProfit ?? this.totalProfit,
      performanceHistory: performanceHistory ?? this.performanceHistory,
      latestSignal: latestSignal ?? this.latestSignal,
      isVerified: isVerified,
    );
  }
}

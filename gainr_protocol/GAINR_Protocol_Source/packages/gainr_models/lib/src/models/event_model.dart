import '../math/probability_engine.dart';

class Event {
  final String id;
  final String sport;
  final String league;
  final Team homeTeam;
  final Team awayTeam;
  final DateTime startTime;
  final bool isLive;
  final BettingOdds odds;

  final double expectedGoalsHome;
  final double expectedGoalsAway;
  final MarketType marketType;
  final MarketSentiment sentiment;

  const Event({
    required this.id,
    required this.sport,
    required this.league,
    required this.homeTeam,
    required this.awayTeam,
    required this.startTime,
    required this.isLive,
    required this.odds,
    this.expectedGoalsHome = 1.5,
    this.expectedGoalsAway = 1.2,
    this.marketType = MarketType.threeWay,
    this.sentiment = MarketSentiment.neutral,
  });

  /// Calculate "Fair" probabilities using Poisson Distribution
  Map<String, double> get fairProbabilities {
    return ProbabilityEngine.calculateMatchProbabilities(
        homeXG: expectedGoalsHome, awayXG: expectedGoalsAway);
  }

  /// Calculate "Implied" probabilities from Market Odds (removing Vig)
  Map<String, double> get impliedProbabilities {
    return ProbabilityEngine.removeVig(odds.toMap());
  }

  /// Calculate the AI Edge (Percentage difference between Fair vs Implied)
  /// Returns +5.0 for a 5% edge
  double get aiEdge {
    final fair = fairProbabilities;
    final implied = impliedProbabilities;

    // Find the max edge across all outcomes
    double maxEdge = 0.0;

    // Check Home
    if (fair['home']! > implied['home']!) {
      final edge = (fair['home']! - implied['home']!) * 100;
      if (edge > maxEdge) maxEdge = edge;
    }

    // Check Away (and Draw if 3-way)
    if (fair['away']! > implied['away']!) {
      final edge = (fair['away']! - implied['away']!) * 100;
      if (edge > maxEdge) maxEdge = edge;
    }

    if (marketType == MarketType.threeWay) {
      if (fair['draw']! > implied['draw']!) {
        final edge = (fair['draw']! - implied['draw']!) * 100;
        if (edge > maxEdge) maxEdge = edge;
      }
    }

    return maxEdge;
  }

  /// Get the Recommended Kelly Stake for the best value bet
  double get kellyStake {
    // Identify best bet
    final fair = fairProbabilities;
    final implied = impliedProbabilities;

    double bestEdge = -1.0;
    String bestSelection = '';

    if (fair['home']! > implied['home']!) {
      bestEdge = fair['home']! - implied['home']!;
      bestSelection = 'home';
    } else if (fair['away']! > implied['away']!) {
      if ((fair['away']! - implied['away']!) > bestEdge) {
        bestEdge = fair['away']! - implied['away']!;
        bestSelection = 'away';
      }
    }

    if (bestEdge <= 0) return 0.0;

    // Calculate Kelly
    double odds = 2.0;
    if (bestSelection == 'home') odds = this.odds.homeWin;
    if (bestSelection == 'away') odds = this.odds.awayWin;

    return ProbabilityEngine.calculateKellyStake(
        probability: fair[bestSelection]!, decimalOdds: odds);
  }

  bool get isValueBet => aiEdge > 3.0; // Threshold for "Value" badge
}

enum MarketType { twoWay, threeWay }

enum MarketSentiment { bearish, neutral, bullish, accumulation }

class Team {
  final String name;
  final String logoUrl;
  final String? score;

  const Team({
    required this.name,
    required this.logoUrl,
    this.score,
  });
}

class BettingOdds {
  final double homeWin;
  final double awayWin;
  final double draw; // 0 for 2-way markets
  final double? spreadHome;
  final double? spreadAway;
  final double? totalOver;
  final double? totalUnder;

  const BettingOdds({
    required this.homeWin,
    required this.awayWin,
    this.draw = 0,
    this.spreadHome,
    this.spreadAway,
    this.totalOver,
    this.totalUnder,
  });

  Map<String, double> toMap() {
    return {
      'home': homeWin,
      'draw': draw,
      'away': awayWin,
    };
  }
}

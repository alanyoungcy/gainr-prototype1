import 'dart:math';

/// Advanced Probability Engine for GAINR AI
/// Implements Poisson Distribution, Market Vig Removal, and Kelly Criterion
class ProbabilityEngine {
  /// Calculate Poisson probability P(k; lambda)
  /// lambda: Expected number of goals/points
  /// k: Actual number of goals/points
  static double poisson(double lambda, int k) {
    return (pow(lambda, k) * exp(-lambda)) / _factorial(k);
  }

  /// Factorial helper with memoization for small numbers
  static int _factorial(int n) {
    if (n < 0) return 1;
    if (n <= 1) return 1;
    int result = 1;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }

  /// Calculate Win/Draw/Loss probabilities for a match based on expected goals (xG)
  /// Returns a map with 'home', 'draw', 'away' probabilities (0.0 - 1.0)
  static Map<String, double> calculateMatchProbabilities({
    required double homeXG,
    required double awayXG,
    int maxGoals = 10,
  }) {
    double homeWinProb = 0.0;
    double drawProb = 0.0;
    double awayWinProb = 0.0;

    for (int i = 0; i <= maxGoals; i++) {
      final homeProb = poisson(homeXG, i);
      for (int j = 0; j <= maxGoals; j++) {
        final awayProb = poisson(awayXG, j);
        final matchProb = homeProb * awayProb;

        if (i > j) {
          homeWinProb += matchProb;
        } else if (i == j) {
          drawProb += matchProb;
        } else {
          awayWinProb += matchProb;
        }
      }
    }

    // Normalize to ensure sum is exactly 1.0 (handling simulation truncation)
    final total = homeWinProb + drawProb + awayWinProb;
    return {
      'home': homeWinProb / total,
      'draw': drawProb / total,
      'away': awayWinProb / total,
    };
  }

  /// Calculate Win/Loss probabilities for 2-way sports (Basketball, NFL, Tennis)
  /// Uses a simplified Log5 method or similar rating-based probability
  static Map<String, double> calculateTwoWayProbabilities({
    required double homeRating,
    required double awayRating,
  }) {
    // Log5 formula: Pa = (A - A*B) / (A + B - 2*A*B)
    // Here we use a standard ELO-like win probability function:
    // P(A) = 1 / (1 + 10^((Rb - Ra) / 400))
    // We'll use a simplified strength ratio for this engine version

    final totalStrength = homeRating + awayRating;
    return {
      'home': homeRating / totalStrength,
      'away': awayRating / totalStrength,
    };
  }

  /// Remove "Vig" (Bookmaker Margin) from market odds to get Implied Probabilities
  /// Returns probabilities summing to ~1.0 representing the market's true opinion
  static Map<String, double> removeVig(Map<String, double> marketOdds) {
    double overround = 0.0;
    final implied = <String, double>{};

    marketOdds.forEach((key, odds) {
      if (odds > 0) {
        overround += 1.0 / odds;
      }
    });

    marketOdds.forEach((key, odds) {
      if (odds > 0) {
        implied[key] = (1.0 / odds) / overround;
      } else {
        implied[key] = 0.0;
      }
    });

    return implied;
  }

  /// Calculate Kelly Criterion optimal stake percentage
  /// Returns decimal (e.g., 0.025 for 2.5% stake)
  /// Uses fractional Kelly (default 0.5) for safety
  static double calculateKellyStake({
    required double probability, // Your estimated probability (0.0 - 1.0)
    required double decimalOdds, // The market odds offered
    double fractionalKelly = 0.5, // Safety factor (1.0 = Full Kelly)
  }) {
    if (decimalOdds <= 1.0) return 0.0;

    final b = decimalOdds - 1.0; // Net odds
    final q = 1.0 - probability; // Probability of losing
    final p = probability; // Probability of winning

    final f = (b * p - q) / b;

    // If edge is negative or zero, don't bet
    if (f <= 0) return 0.0;

    // Apply safety fraction and cap at 5% max stake for responsible AI advice
    return min(f * fractionalKelly, 0.05);
  }

  /// Format Probability as Percentage String
  static String toPercent(double prob) {
    return '${(prob * 100).toStringAsFixed(1)}%';
  }
}

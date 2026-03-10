import 'package:flutter/material.dart';

/// Maps team names to their brand-like colors for avatar rendering.
/// Used throughout the app for consistent team identity.
class TeamBranding {
  static const Map<String, int> _teamColors = {
    // Premier League
    'Manchester City': 0xFF6CABDD,
    'Man City': 0xFF6CABDD,
    'Arsenal': 0xFFEF0107,
    'Liverpool': 0xFFC8102E,
    'Chelsea': 0xFF034694,
    'Tottenham': 0xFF132257,
    'Manchester United': 0xFFDA291C,
    'Man Utd': 0xFFDA291C,
    'Newcastle': 0xFF241F20,
    'Aston Villa': 0xFF95BFE5,
    'Brighton': 0xFF0057B8,
    'West Ham': 0xFF7A263A,
    'Everton': 0xFF003399,
    'Fulham': 0xFF000000,

    // La Liga
    'Real Madrid': 0xFFFEBE10,
    'Barcelona': 0xFFA50044,
    'Atletico Madrid': 0xFFCB3524,

    // Bundesliga
    'Bayern Munich': 0xFFDC052D,
    'Borussia Dortmund': 0xFFFDE100,

    // Serie A
    'Juventus': 0xFF000000,
    'AC Milan': 0xFFFB090B,
    'Inter Milan': 0xFF010E80,
    'Napoli': 0xFF12A0D7,
    'Roma': 0xFF8E1F2F,

    // Ligue 1
    'PSG': 0xFF004170,
    'Marseille': 0xFF2FAEE0,
    'Lyon': 0xFF1A3B73,

    // NBA
    'Lakers': 0xFF552583,
    'Warriors': 0xFF1D428A,
    'Celtics': 0xFF007A33,
    'Heat': 0xFF98002E,
    'Bucks': 0xFF00471B,
    'Nets': 0xFF000000,
    '76ers': 0xFF006BB6,

    // NFL
    'Chiefs': 0xFFE31837,
    'Ravens': 0xFF241773,
    '49ers': 0xFFAA0000,
    'Cowboys': 0xFF003594,
    'Eagles': 0xFF004C54,
    'Bills': 0xFF00338D,
    'Dolphins': 0xFF008E97,
    'Patriots': 0xFF002244,

    // Tennis
    'Player 1': 0xFF1DB954,
    'Player 2': 0xFFFF6B35,
  };

  static const Map<String, String> _leagueColors = {
    'Champions League': '0xFF0053A0',
    'Premier League': '0xFF3D195B',
    'La Liga': '0xFFEE8707',
    'Bundesliga': '0xFFD20515',
    'Serie A': '0xFF024494',
    'Ligue 1': '0xFFDAE025',
    'NBA': '0xFF17408B',
    'NFL': '0xFF013369',
    'ATP': '0xFF1E6036',
  };

  /// Get the brand color for a team
  static Color getTeamColor(String teamName) {
    final colorValue = _teamColors[teamName];
    if (colorValue != null) return Color(colorValue);

    // Fallback: deterministic color from name hash
    final hash = teamName.codeUnits.fold<int>(0, (sum, c) => sum + c);
    final hue = (hash * 137) % 360;
    return HSLColor.fromAHSL(1.0, hue.toDouble(), 0.65, 0.45).toColor();
  }

  /// Get the team initial(s) for avatar
  static String getTeamInitial(String teamName) {
    final words = teamName.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return teamName
        .substring(0, teamName.length >= 3 ? 3 : teamName.length)
        .toUpperCase();
  }

  /// Get league badge color
  static Color getLeagueColor(String league) {
    final hex = _leagueColors[league];
    if (hex != null) return Color(int.parse(hex));
    return const Color(0xFF666666);
  }

  /// Build a team avatar widget
  static Widget buildTeamAvatar(String teamName, {double size = 36}) {
    final color = getTeamColor(teamName);
    final initials = getTeamInitial(teamName);
    final fontSize = size * 0.35;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color,
            Color.lerp(color, Colors.black, 0.3)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.25),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }

  /// Build a league badge widget
  static Widget buildLeagueBadge(String league) {
    final color = getLeagueColor(league);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        league.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

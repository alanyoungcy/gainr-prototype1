// ignore_for_file: unused_field, unused_element
import 'package:flutter/foundation.dart';
import 'package:gainr_models/gainr_models.dart';

/// Sports data client using The Odds API (free tier)
/// API Docs: https://the-odds-api.com/
class SportsApiClient {
  // Free API key - replace with your own from https://the-odds-api.com/
  // In production, load from environment variables or secure storage
  static const String _apiKey = 'YOUR_API_KEY_HERE';
  static const String _baseUrl = 'https://api.the-odds-api.com/v4';

  /// Fetch upcoming and live sports events
  Future<List<Event>> getEvents({String sport = 'all'}) async {
    debugPrint(
        '🔍 [SportsApiClient] Fetching events (NETWORK BYPASSED for debug)');
    return _filterBySport(_getMockEvents(), sport);
    /*
    try {
      // For demo, use soccer (football) data
      final sportKey = sport == 'all' ? 'soccer_epl' : _mapSportToKey(sport);

      final url = Uri.parse(
        '$_baseUrl/sports/$sportKey/odds?apiKey=$_apiKey&regions=us,uk&markets=h2h',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return _parseEvents(data);
      } else if (response.statusCode == 401) {
        // API key issue - fallback to mock data
        debugPrint('⚠️ The Odds API: Invalid API key, using mock data');
        return _filterBySport(_getMockEvents(), sport);
      } else {
        throw Exception('Failed to load events: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('⚠️ Sports API Error: $e - Using mock data');
      return _filterBySport(_getMockEvents(), sport);
    }
    */
  }

  /// Filter events by sport for mock data
  List<Event> _filterBySport(List<Event> events, String sport) {
    if (sport == 'all') return events;
    return events
        .where((e) => e.sport.toLowerCase() == sport.toLowerCase())
        .toList();
  }

  /// Parse API response to Event models
  List<Event> _parseEvents(List<dynamic> data) {
    // The following lines appear to be markdown table content and are not valid Dart code.
    // As per instructions, changes must result in syntactically correct code.
    // Therefore, this content cannot be inserted directly into the Dart file.
    // | 4 | **Sidebar nav items 1, 2 (Live Events, Casino) lead to default MainContent** — no unique screens | `main_layout.dart` |
    // | 5 | **Bottom nav "Search" and "My Bets" items in `home_screen.dart` are dead** — `home_screen.dart` appears unused (MainLayout is the active entry point) | `home_screen.dart` |
    // | 6 | **Live Match cards in list are non-functional** — clicking odds buttons does not add bets to slip | `main_content.dart` |
    final events = <Event>[];

    for (var item in data.take(10)) {
      try {
        final homeTeam = item['home_team'] as String;
        final awayTeam = item['away_team'] as String;
        final startTime = DateTime.parse(item['commence_time']);

        // Extract bookmaker odds (use first available)
        final bookmakers = item['bookmakers'] as List;
        if (bookmakers.isEmpty) continue;

        final markets = bookmakers[0]['markets'] as List;
        final h2hMarket = markets.firstWhere(
          (m) => m['key'] == 'h2h',
          orElse: () => null,
        );

        if (h2hMarket == null) continue;

        final outcomes = h2hMarket['outcomes'] as List;

        // Extract odds
        double homeOdds = 2.0;
        double awayOdds = 2.0;
        double drawOdds = 3.0;

        for (var outcome in outcomes) {
          final name = outcome['name'] as String;
          final price = (outcome['price'] as num).toDouble();

          if (name == homeTeam) {
            homeOdds = price;
          } else if (name == awayTeam) {
            awayOdds = price;
          } else if (name.toLowerCase() == 'draw') {
            drawOdds = price;
          }
        }

        events.add(Event(
          id: item['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          sport: 'Soccer',
          homeTeam: Team(
            name: homeTeam,
            logoUrl: 'https://via.placeholder.com/50',
          ),
          awayTeam: Team(
            name: awayTeam,
            logoUrl: 'https://via.placeholder.com/50',
          ),
          league: 'Premier League',
          startTime: startTime,
          isLive: startTime.isBefore(DateTime.now()) &&
              startTime
                  .isAfter(DateTime.now().subtract(const Duration(hours: 2))),
          odds: BettingOdds(
            homeWin: homeOdds,
            draw: drawOdds,
            awayWin: awayOdds,
          ),
        ));
      } catch (e) {
        debugPrint('Error parsing event: $e');
        continue;
      }
    }

    return events.isNotEmpty ? events : _getMockEvents();
  }

  /// Map sport names to API keys
  String _mapSportToKey(String sport) {
    switch (sport.toLowerCase()) {
      case 'football':
      case 'soccer':
        return 'soccer_epl';
      case 'basketball':
        return 'basketball_nba';
      case 'tennis':
        return 'tennis_atp';
      default:
        return 'soccer_epl';
    }
  }

  List<Event> _getMockEvents() {
    final now = DateTime.now();
    return [
      // ═══════════════════════ LIVE MATCHES ═══════════════════════
      Event(
        id: 'ucl_live_1',
        sport: 'Soccer',
        homeTeam: const Team(name: 'Manchester City', logoUrl: '', score: '2'),
        awayTeam: const Team(name: 'Inter Milan', logoUrl: '', score: '1'),
        league: 'Champions League',
        startTime: now.subtract(const Duration(minutes: 67)),
        isLive: true,
        odds: const BettingOdds(homeWin: 1.70, draw: 3.50, awayWin: 4.75),
        expectedGoalsHome: 2.1,
        expectedGoalsAway: 0.8,
        sentiment: MarketSentiment.bullish,
      ),
      Event(
        id: 'epl_live_1',
        sport: 'Soccer',
        homeTeam: const Team(name: 'Arsenal', logoUrl: '', score: '1'),
        awayTeam: const Team(name: 'Liverpool', logoUrl: '', score: '1'),
        league: 'Premier League',
        startTime: now.subtract(const Duration(minutes: 38)),
        isLive: true,
        odds: const BettingOdds(homeWin: 2.10, draw: 3.20, awayWin: 3.40),
      ),
      Event(
        id: 'liga_live_1',
        sport: 'Soccer',
        homeTeam: const Team(name: 'Real Madrid', logoUrl: '', score: '3'),
        awayTeam: const Team(name: 'Atletico Madrid', logoUrl: '', score: '2'),
        league: 'La Liga',
        startTime: now.subtract(const Duration(minutes: 75)),
        isLive: true,
        odds: const BettingOdds(homeWin: 1.30, draw: 5.50, awayWin: 8.00),
      ),
      Event(
        id: 'l1_live_1',
        sport: 'Soccer',
        homeTeam: const Team(name: 'PSG', logoUrl: '', score: '0'),
        awayTeam: const Team(name: 'Marseille', logoUrl: '', score: '0'),
        league: 'Ligue 1',
        startTime: now.subtract(const Duration(minutes: 22)),
        isLive: true,
        odds: const BettingOdds(homeWin: 1.75, draw: 3.60, awayWin: 4.50),
      ),
      Event(
        id: 'nba_live_1',
        sport: 'Basketball',
        homeTeam: const Team(name: 'Lakers', logoUrl: '', score: '88'),
        awayTeam: const Team(name: 'Warriors', logoUrl: '', score: '92'),
        league: 'NBA',
        startTime: now.subtract(const Duration(minutes: 90)),
        isLive: true,
        odds: const BettingOdds(homeWin: 2.20, draw: 0, awayWin: 1.70),
        marketType: MarketType.twoWay,
        expectedGoalsHome: 112.5,
        expectedGoalsAway: 115.0,
        sentiment: MarketSentiment.bearish,
      ),
      Event(
        id: 'nba_live_2',
        sport: 'Basketball',
        homeTeam: const Team(name: 'Celtics', logoUrl: '', score: '64'),
        awayTeam: const Team(name: 'Bucks', logoUrl: '', score: '61'),
        league: 'NBA',
        startTime: now.subtract(const Duration(minutes: 55)),
        isLive: true,
        odds: const BettingOdds(homeWin: 1.60, draw: 0, awayWin: 2.35),
        marketType: MarketType.twoWay,
        expectedGoalsHome: 108.0,
        expectedGoalsAway: 102.5,
      ),
      Event(
        id: 'epl_live_2',
        sport: 'Soccer',
        homeTeam: const Team(name: 'Chelsea', logoUrl: '', score: '2'),
        awayTeam: const Team(name: 'Tottenham', logoUrl: '', score: '0'),
        league: 'Premier League',
        startTime: now.subtract(const Duration(minutes: 52)),
        isLive: true,
        odds: const BettingOdds(homeWin: 1.20, draw: 6.50, awayWin: 11.00),
      ),
      Event(
        id: 'bund_live_1',
        sport: 'Soccer',
        homeTeam: const Team(name: 'Bayern Munich', logoUrl: '', score: '1'),
        awayTeam: const Team(name: 'RB Leipzig', logoUrl: '', score: '1'),
        league: 'Bundesliga',
        startTime: now.subtract(const Duration(minutes: 41)),
        isLive: true,
        odds: const BettingOdds(homeWin: 1.75, draw: 3.60, awayWin: 4.50),
      ),

      // ═══════════════════════ UPCOMING — PREMIER LEAGUE ═══════════════════════
      Event(
        id: 'epl_up_1',
        sport: 'Soccer',
        homeTeam: const Team(name: 'Manchester United', logoUrl: ''),
        awayTeam: const Team(name: 'Newcastle', logoUrl: ''),
        league: 'Premier League',
        startTime: now.add(const Duration(hours: 1, minutes: 30)),
        isLive: false,
        odds: const BettingOdds(homeWin: 2.25, draw: 3.30, awayWin: 3.20),
      ),
      Event(
        id: 'epl_up_2',
        sport: 'Soccer',
        homeTeam: const Team(name: 'Aston Villa', logoUrl: ''),
        awayTeam: const Team(name: 'Brighton', logoUrl: ''),
        league: 'Premier League',
        startTime: now.add(const Duration(hours: 3)),
        isLive: false,
        odds: const BettingOdds(homeWin: 2.00, draw: 3.40, awayWin: 3.70),
      ),
      Event(
        id: 'epl_up_3',
        sport: 'Soccer',
        homeTeam: const Team(name: 'West Ham', logoUrl: ''),
        awayTeam: const Team(name: 'Everton', logoUrl: ''),
        league: 'Premier League',
        startTime: now.add(const Duration(hours: 5)),
        isLive: false,
        odds: const BettingOdds(homeWin: 1.75, draw: 3.60, awayWin: 4.80),
      ),

      // ═══════════════════════ UPCOMING — LA LIGA ═══════════════════════
      Event(
        id: 'liga_up_1',
        sport: 'Soccer',
        homeTeam: const Team(name: 'Barcelona', logoUrl: ''),
        awayTeam: const Team(name: 'Sevilla', logoUrl: ''),
        league: 'La Liga',
        startTime: now.add(const Duration(hours: 4)),
        isLive: false,
        odds: const BettingOdds(homeWin: 1.45, draw: 4.40, awayWin: 6.50),
      ),
      Event(
        id: 'liga_up_2',
        sport: 'Soccer',
        homeTeam: const Team(name: 'Villarreal', logoUrl: ''),
        awayTeam: const Team(name: 'Real Sociedad', logoUrl: ''),
        league: 'La Liga',
        startTime: now.add(const Duration(hours: 6)),
        isLive: false,
        odds: const BettingOdds(homeWin: 2.20, draw: 3.30, awayWin: 3.20),
      ),
      Event(
        id: 'liga_up_3',
        sport: 'Soccer',
        homeTeam: const Team(name: 'Athletic Bilbao', logoUrl: ''),
        awayTeam: const Team(name: 'Valencia', logoUrl: ''),
        league: 'La Liga',
        startTime: now.add(const Duration(hours: 8)),
        isLive: false,
        odds: const BettingOdds(homeWin: 1.90, draw: 3.40, awayWin: 4.00),
      ),

      // ═══════════════════════ UPCOMING — BUNDESLIGA ═══════════════════════
      Event(
        id: 'bund_up_1',
        sport: 'Soccer',
        homeTeam: const Team(name: 'Borussia Dortmund', logoUrl: ''),
        awayTeam: const Team(name: 'Bayer Leverkusen', logoUrl: ''),
        league: 'Bundesliga',
        startTime: now.add(const Duration(hours: 2, minutes: 45)),
        isLive: false,
        odds: const BettingOdds(homeWin: 2.50, draw: 3.30, awayWin: 2.80),
      ),
      Event(
        id: 'bund_up_2',
        sport: 'Soccer',
        homeTeam: const Team(name: 'Wolfsburg', logoUrl: ''),
        awayTeam: const Team(name: 'Freiburg', logoUrl: ''),
        league: 'Bundesliga',
        startTime: now.add(const Duration(hours: 7)),
        isLive: false,
        odds: const BettingOdds(homeWin: 2.10, draw: 3.30, awayWin: 3.50),
      ),

      // ═══════════════════════ UPCOMING — SERIE A ═══════════════════════
      Event(
        id: 'seria_up_1',
        sport: 'Soccer',
        homeTeam: const Team(name: 'Juventus', logoUrl: ''),
        awayTeam: const Team(name: 'AC Milan', logoUrl: ''),
        league: 'Serie A',
        startTime: now.add(const Duration(hours: 2)),
        isLive: false,
        odds: const BettingOdds(homeWin: 2.35, draw: 3.20, awayWin: 3.00),
      ),
      Event(
        id: 'seria_up_2',
        sport: 'Soccer',
        homeTeam: const Team(name: 'Napoli', logoUrl: ''),
        awayTeam: const Team(name: 'Roma', logoUrl: ''),
        league: 'Serie A',
        startTime: now.add(const Duration(hours: 4, minutes: 30)),
        isLive: false,
        odds: const BettingOdds(homeWin: 1.70, draw: 3.60, awayWin: 4.80),
      ),
      Event(
        id: 'seria_up_3',
        sport: 'Soccer',
        homeTeam: const Team(name: 'Lazio', logoUrl: ''),
        awayTeam: const Team(name: 'Atalanta', logoUrl: ''),
        league: 'Serie A',
        startTime: now.add(const Duration(hours: 9)),
        isLive: false,
        odds: const BettingOdds(homeWin: 2.60, draw: 3.20, awayWin: 2.70),
      ),

      // ═══════════════════════ UPCOMING — MLS ═══════════════════════
      Event(
        id: 'mls_up_1',
        sport: 'Soccer',
        homeTeam: const Team(name: 'Inter Miami', logoUrl: ''),
        awayTeam: const Team(name: 'LA Galaxy', logoUrl: ''),
        league: 'MLS',
        startTime: now.add(const Duration(hours: 10)),
        isLive: false,
        odds: const BettingOdds(homeWin: 1.95, draw: 3.40, awayWin: 3.80),
      ),
      Event(
        id: 'mls_up_2',
        sport: 'Soccer',
        homeTeam: const Team(name: 'NYCFC', logoUrl: ''),
        awayTeam: const Team(name: 'Atlanta United', logoUrl: ''),
        league: 'MLS',
        startTime: now.add(const Duration(hours: 12)),
        isLive: false,
        odds: const BettingOdds(homeWin: 2.05, draw: 3.30, awayWin: 3.50),
      ),

      // ═══════════════════════ UPCOMING — NBA ═══════════════════════
      Event(
        id: 'nba_up_1',
        sport: 'Basketball',
        homeTeam: const Team(name: 'Mavericks', logoUrl: ''),
        awayTeam: const Team(name: 'Nuggets', logoUrl: ''),
        league: 'NBA',
        startTime: now.add(const Duration(hours: 5, minutes: 30)),
        isLive: false,
        odds: const BettingOdds(homeWin: 2.10, draw: 0, awayWin: 1.80),
        marketType: MarketType.twoWay,
        expectedGoalsHome: 110.0,
        expectedGoalsAway: 114.5,
        sentiment: MarketSentiment.accumulation,
      ),
      Event(
        id: 'nba_up_2',
        sport: 'Basketball',
        homeTeam: const Team(name: 'Heat', logoUrl: ''),
        awayTeam: const Team(name: 'Knicks', logoUrl: ''),
        league: 'NBA',
        startTime: now.add(const Duration(hours: 7, minutes: 30)),
        isLive: false,
        odds: const BettingOdds(homeWin: 1.90, draw: 0, awayWin: 1.95),
      ),
      Event(
        id: 'nba_up_3',
        sport: 'Basketball',
        homeTeam: const Team(name: 'Suns', logoUrl: ''),
        awayTeam: const Team(name: 'Clippers', logoUrl: ''),
        league: 'NBA',
        startTime: now.add(const Duration(hours: 11)),
        isLive: false,
        odds: const BettingOdds(homeWin: 1.80, draw: 0, awayWin: 2.05),
      ),

      // ═══════════════════════ UPCOMING — NFL ═══════════════════════
      Event(
        id: 'nfl_up_1',
        sport: 'Football',
        homeTeam: const Team(name: 'Chiefs', logoUrl: ''),
        awayTeam: const Team(name: 'Ravens', logoUrl: ''),
        league: 'NFL',
        startTime: now.add(const Duration(hours: 8)),
        isLive: false,
        odds: const BettingOdds(
            homeWin: 1.85, awayWin: 2.05, spreadHome: -3.5, spreadAway: 3.5),
        marketType: MarketType.twoWay,
        expectedGoalsHome: 24.5,
        expectedGoalsAway: 21.0,
        sentiment: MarketSentiment.bullish,
      ),
      Event(
        id: 'nfl_up_2',
        sport: 'Football',
        homeTeam: const Team(name: '49ers', logoUrl: ''),
        awayTeam: const Team(name: 'Cowboys', logoUrl: ''),
        league: 'NFL',
        startTime: now.add(const Duration(hours: 12)),
        isLive: false,
        odds: const BettingOdds(homeWin: 1.60, awayWin: 2.40),
      ),
      Event(
        id: 'nfl_up_3',
        sport: 'Football',
        homeTeam: const Team(name: 'Eagles', logoUrl: ''),
        awayTeam: const Team(name: 'Bills', logoUrl: ''),
        league: 'NFL',
        startTime: now.add(const Duration(hours: 14)),
        isLive: false,
        odds: const BettingOdds(homeWin: 1.75, awayWin: 2.15),
      ),

      // ═══════════════════════ UPCOMING — TENNIS ═══════════════════════
      Event(
        id: 'atp_up_1',
        sport: 'Tennis',
        homeTeam: const Team(name: 'C. Alcaraz', logoUrl: ''),
        awayTeam: const Team(name: 'J. Sinner', logoUrl: ''),
        league: 'ATP Finals',
        startTime: now.add(const Duration(hours: 3, minutes: 15)),
        isLive: false,
        odds: const BettingOdds(homeWin: 1.90, awayWin: 1.95, draw: 0),
        marketType: MarketType.twoWay,
        expectedGoalsHome: 12.5, // Game rating
        expectedGoalsAway: 12.2,
      ),
      Event(
        id: 'wta_up_1',
        sport: 'Tennis',
        homeTeam: const Team(name: 'I. Swiatek', logoUrl: ''),
        awayTeam: const Team(name: 'A. Sabalenka', logoUrl: ''),
        league: 'WTA Tour',
        startTime: now.add(const Duration(hours: 6, minutes: 45)),
        isLive: false,
        odds: const BettingOdds(homeWin: 2.10, awayWin: 1.80, draw: 0),
      ),

      // ═══════════════════════ UPCOMING — CRICKET ═══════════════════════
      Event(
        id: 'cri_up_1',
        sport: 'Cricket',
        homeTeam: const Team(name: 'India', logoUrl: ''),
        awayTeam: const Team(name: 'Pakistan', logoUrl: ''),
        league: 'ICC Champions Trophy',
        startTime: now.add(const Duration(hours: 18)),
        isLive: false,
        odds: const BettingOdds(homeWin: 1.62, awayWin: 2.30, draw: 0),
        marketType: MarketType.twoWay,
        expectedGoalsHome: 280, // Projected runs
        expectedGoalsAway: 245,
        sentiment: MarketSentiment.bullish,
      ),
      Event(
        id: 'cri_up_2',
        sport: 'Cricket',
        homeTeam: const Team(name: 'Australia', logoUrl: ''),
        awayTeam: const Team(name: 'England', logoUrl: ''),
        league: 'The Ashes',
        startTime: now.add(const Duration(hours: 48)),
        isLive: false,
        odds: const BettingOdds(homeWin: 1.85, awayWin: 2.10, draw: 3.40),
      ),
      Event(
        id: 'cri_up_3',
        sport: 'Cricket',
        homeTeam: const Team(name: 'Mumbai Indians', logoUrl: ''),
        awayTeam: const Team(name: 'Chennai Super Kings', logoUrl: ''),
        league: 'IPL',
        startTime: now.add(const Duration(hours: 24)),
        isLive: false,
        odds: const BettingOdds(homeWin: 1.90, awayWin: 1.95, draw: 0),
      ),
      Event(
        id: 'cri_up_4',
        sport: 'Cricket',
        homeTeam: const Team(name: 'South Africa', logoUrl: ''),
        awayTeam: const Team(name: 'New Zealand', logoUrl: ''),
        league: 'ODI World Cup',
        startTime: now.add(const Duration(hours: 36)),
        isLive: false,
        odds: const BettingOdds(homeWin: 2.10, awayWin: 1.80, draw: 0),
      ),
      Event(
        id: 'cri_up_5',
        sport: 'Cricket',
        homeTeam: const Team(name: 'Royal Challengers', logoUrl: ''),
        awayTeam: const Team(name: 'Gujarat Titans', logoUrl: ''),
        league: 'IPL',
        startTime: now.add(const Duration(hours: 15)),
        isLive: false,
        odds: const BettingOdds(homeWin: 2.20, awayWin: 1.70, draw: 0),
      ),
      Event(
        id: 'cri_up_6',
        sport: 'Cricket',
        homeTeam: const Team(name: 'Kolkata Knight Riders', logoUrl: ''),
        awayTeam: const Team(name: 'Delhi Capitals', logoUrl: ''),
        league: 'IPL',
        startTime: now.add(const Duration(hours: 20)),
        isLive: false,
        odds: const BettingOdds(homeWin: 1.85, awayWin: 2.15, draw: 0),
      ),
      Event(
        id: 'cri_up_7',
        sport: 'Cricket',
        homeTeam: const Team(name: 'West Indies', logoUrl: ''),
        awayTeam: const Team(name: 'Sri Lanka', logoUrl: ''),
        league: 'T20 International',
        startTime: now.add(const Duration(hours: 14)),
        isLive: false,
        odds: const BettingOdds(homeWin: 2.50, awayWin: 1.55, draw: 0),
      ),
      Event(
        id: 'cri_up_8',
        sport: 'Cricket',
        homeTeam: const Team(name: 'Perth Scorchers', logoUrl: ''),
        awayTeam: const Team(name: 'Sydney Sixers', logoUrl: ''),
        league: 'Big Bash League',
        startTime: now.add(const Duration(hours: 8)),
        isLive: false,
        odds: const BettingOdds(homeWin: 1.75, awayWin: 2.10, draw: 0),
      ),
      Event(
        id: 'cri_up_9',
        sport: 'Cricket',
        homeTeam: const Team(name: 'Lucknow Super Giants', logoUrl: ''),
        awayTeam: const Team(name: 'Rajasthan Royals', logoUrl: ''),
        league: 'IPL',
        startTime: now.add(const Duration(hours: 22)),
        isLive: false,
        odds: const BettingOdds(homeWin: 2.00, awayWin: 1.85, draw: 0),
      ),
      Event(
        id: 'cri_up_10',
        sport: 'Cricket',
        homeTeam: const Team(name: 'Afghanistan', logoUrl: ''),
        awayTeam: const Team(name: 'Bangladesh', logoUrl: ''),
        league: 'Asia Cup',
        startTime: now.add(const Duration(hours: 12)),
        isLive: false,
        odds: const BettingOdds(homeWin: 2.30, awayWin: 1.60, draw: 0),
      ),

      // ═══════════════════════ UPCOMING — HORSE RACING ═══════════════════════
      Event(
        id: 'hrs_up_1',
        sport: 'Horse Racing',
        homeTeam: const Team(name: 'City of Troy', logoUrl: ''),
        awayTeam: const Team(name: 'Auguste Rodin', logoUrl: ''),
        league: 'The Derby (Match Bet)',
        startTime: now.add(const Duration(hours: 24)),
        isLive: false,
        odds: const BettingOdds(homeWin: 1.87, awayWin: 1.95, draw: 0),
        marketType: MarketType.twoWay,
        expectedGoalsHome: 110, // Speed rating
        expectedGoalsAway: 108,
      ),
      Event(
        id: 'hrs_up_2',
        sport: 'Horse Racing',
        homeTeam: const Team(name: 'Corach Rambler', logoUrl: ''),
        awayTeam: const Team(name: 'I Am Maximus', logoUrl: ''),
        league: 'Grand National (Match Bet)',
        startTime: now.add(const Duration(hours: 48)),
        isLive: false,
        odds: const BettingOdds(homeWin: 2.00, awayWin: 1.87, draw: 0),
      ),
      Event(
        id: 'hrs_up_3',
        sport: 'Horse Racing',
        homeTeam: const Team(name: 'Highfield Princess', logoUrl: ''),
        awayTeam: const Team(name: 'Bradsell', logoUrl: ''),
        league: 'King\'s Stand Stakes',
        startTime: now.add(const Duration(hours: 32)),
        isLive: false,
        odds: const BettingOdds(homeWin: 1.72, awayWin: 2.20, draw: 0),
      ),
      Event(
        id: 'hrs_up_4',
        sport: 'Horse Racing',
        homeTeam: const Team(name: 'Paddington', logoUrl: ''),
        awayTeam: const Team(name: 'Tahiyra', logoUrl: ''),
        league: 'St James\'s Palace',
        startTime: now.add(const Duration(hours: 15)),
        isLive: false,
        odds: const BettingOdds(homeWin: 1.77, awayWin: 2.10, draw: 0),
      ),
      Event(
        id: 'hrs_up_5',
        sport: 'Horse Racing',
        homeTeam: const Team(name: 'Nobutaka', logoUrl: ''),
        awayTeam: const Team(name: 'Kitasan Black', logoUrl: ''),
        league: 'Japan Cup',
        startTime: now.add(const Duration(hours: 20)),
        isLive: false,
        odds: const BettingOdds(homeWin: 2.30, awayWin: 1.62, draw: 0),
      ),
      Event(
        id: 'hrs_up_6',
        sport: 'Horse Racing',
        homeTeam: const Team(name: 'Flightline', logoUrl: ''),
        awayTeam: const Team(name: 'Life Is Good', logoUrl: ''),
        league: 'Breeders\' Cup Classic',
        startTime: now.add(const Duration(hours: 50)),
        isLive: false,
        odds: const BettingOdds(homeWin: 1.30, awayWin: 3.80, draw: 0),
      ),
      Event(
        id: 'hrs_up_7',
        sport: 'Horse Racing',
        homeTeam: const Team(name: 'Nashwa', logoUrl: ''),
        awayTeam: const Team(name: 'Inspiral', logoUrl: ''),
        league: 'Nassau Stakes',
        startTime: now.add(const Duration(hours: 12)),
        isLive: false,
        odds: const BettingOdds(homeWin: 2.05, awayWin: 1.82, draw: 0),
      ),
      Event(
        id: 'hrs_up_8',
        sport: 'Horse Racing',
        homeTeam: const Team(name: 'Kyprios', logoUrl: ''),
        awayTeam: const Team(name: 'Trawlerman', logoUrl: ''),
        league: 'Ascot Gold Cup',
        startTime: now.add(const Duration(hours: 18)),
        isLive: false,
        odds: const BettingOdds(homeWin: 1.53, awayWin: 2.65, draw: 0),
      ),
      Event(
        id: 'hrs_up_9',
        sport: 'Horse Racing',
        homeTeam: const Team(name: 'Constitution Hill', logoUrl: ''),
        awayTeam: const Team(name: 'State Man', logoUrl: ''),
        league: 'Champion Hurdle',
        startTime: now.add(const Duration(hours: 42)),
        isLive: false,
        odds: const BettingOdds(homeWin: 1.20, awayWin: 5.00, draw: 0),
      ),
      Event(
        id: 'hrs_up_10',
        sport: 'Horse Racing',
        homeTeam: const Team(name: 'Vaideni', logoUrl: ''),
        awayTeam: const Team(name: 'Bay Bridge', logoUrl: ''),
        league: 'Prix de l\'Arc',
        startTime: now.add(const Duration(hours: 60)),
        isLive: false,
        odds: const BettingOdds(homeWin: 1.95, awayWin: 1.92, draw: 0),
      ),
    ];
  }
}

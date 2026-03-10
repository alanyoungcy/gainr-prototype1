import 'package:gainr_models/gainr_models.dart';
class MockEventService {
  Future<List<Event>> getEvents({String sport = 'all'}) async {
    await Future.delayed(const Duration(milliseconds: 600)); // Simulate API

    final now = DateTime.now();

    final List<Event> allEvents = [
      // Live NBA
      Event(
        id: 'nba_1',
        sport: 'Basketball',
        league: 'NBA',
        homeTeam: const Team(name: 'Lakers', logoUrl: '', score: '88'),
        awayTeam: const Team(name: 'Warriors', logoUrl: '', score: '92'),
        startTime: now.subtract(const Duration(minutes: 90)),
        isLive: true,
        odds: const BettingOdds(
          homeWin: 2.10,
          awayWin: 1.75,
          totalOver: 1.90,
          totalUnder: 1.90,
        ),
      ),
      // Live Soccer
      Event(
        id: 'epl_1',
        sport: 'Soccer',
        league: 'Premier League',
        homeTeam: const Team(name: 'Man City', logoUrl: '', score: '2'),
        awayTeam: const Team(name: 'Arsenal', logoUrl: '', score: '1'),
        startTime: now.subtract(const Duration(minutes: 45)),
        isLive: true,
        odds: const BettingOdds(
          homeWin: 1.50,
          awayWin: 4.50,
          draw: 3.80,
        ),
      ),
      // Upcoming NFL
      Event(
        id: 'nfl_1',
        sport: 'Football',
        league: 'NFL',
        homeTeam: const Team(name: 'Chiefs', logoUrl: ''),
        awayTeam: const Team(name: 'Ravens', logoUrl: ''),
        startTime: now.add(const Duration(hours: 3)),
        isLive: false,
        odds: const BettingOdds(
          homeWin: 1.85,
          awayWin: 2.05,
          spreadHome: -3.5,
          spreadAway: 3.5,
        ),
      ),
      Event(
        id: 'nfl_2',
        sport: 'Football',
        league: 'NFL',
        homeTeam: const Team(name: '49ers', logoUrl: ''),
        awayTeam: const Team(name: 'Cowboys', logoUrl: ''),
        startTime: now.add(const Duration(hours: 6)),
        isLive: false,
        odds: const BettingOdds(
          homeWin: 1.60,
          awayWin: 2.40,
        ),
      ),
    ];

    if (sport == 'all') return allEvents;
    return allEvents
        .where((e) => e.sport.toLowerCase() == sport.toLowerCase())
        .toList();
  }
}


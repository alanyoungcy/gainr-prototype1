import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gainr_api/gainr_api.dart';
import 'package:gainr_models/gainr_models.dart';
part 'event_provider.g.dart';

@riverpod
SportsApiClient sportsApiClient(Ref ref) {
  return SportsApiClient();
}

@riverpod
Future<List<Event>> events(Ref ref, {String sport = 'all'}) async {
  debugPrint('📡 [eventsProvider] Fetching events for sport: $sport');
  final client = ref.watch(sportsApiClientProvider);
  final allEvents = await client.getEvents(sport: sport);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();

  if (searchQuery.isEmpty) return allEvents;

  return allEvents.where((event) {
    return event.homeTeam.name.toLowerCase().contains(searchQuery) ||
        event.awayTeam.name.toLowerCase().contains(searchQuery) ||
        event.league.toLowerCase().contains(searchQuery) ||
        event.sport.toLowerCase().contains(searchQuery);
  }).toList();
}

@riverpod
class SelectedSport extends _$SelectedSport {
  @override
  String build() => 'all';

  void setSport(String sport) => state = sport;
}

@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}


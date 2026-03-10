import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gainr_mobile/features/betting/providers/event_provider.dart';
import 'package:gainr_mobile/features/betting/widgets/event_card.dart';
import 'package:gainr_ui/gainr_ui.dart';
class EventList extends ConsumerWidget {
  final String sportFilter;

  const EventList({super.key, this.sportFilter = 'all'});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider(sport: sportFilter));

    return AsyncValueWidget(
      value: eventsAsync,
      data: (events) {
        if (events.isEmpty) {
          return const Center(child: Text('No events found'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: events.length,
          itemBuilder: (context, index) {
            return EventCard(event: events[index]);
          },
        );
      },
    );
  }
}


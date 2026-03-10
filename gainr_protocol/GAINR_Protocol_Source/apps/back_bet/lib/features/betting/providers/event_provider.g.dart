// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sportsApiClient)
final sportsApiClientProvider = SportsApiClientProvider._();

final class SportsApiClientProvider extends $FunctionalProvider<SportsApiClient,
    SportsApiClient, SportsApiClient> with $Provider<SportsApiClient> {
  SportsApiClientProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'sportsApiClientProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sportsApiClientHash();

  @$internal
  @override
  $ProviderElement<SportsApiClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SportsApiClient create(Ref ref) {
    return sportsApiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SportsApiClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SportsApiClient>(value),
    );
  }
}

String _$sportsApiClientHash() => r'233dfd6579ae6d5b7e8479405d8bbb98d1af3f78';

@ProviderFor(events)
final eventsProvider = EventsFamily._();

final class EventsProvider extends $FunctionalProvider<AsyncValue<List<Event>>,
        List<Event>, FutureOr<List<Event>>>
    with $FutureModifier<List<Event>>, $FutureProvider<List<Event>> {
  EventsProvider._(
      {required EventsFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'eventsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$eventsHash();

  @override
  String toString() {
    return r'eventsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Event>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Event>> create(Ref ref) {
    final argument = this.argument as String;
    return events(
      ref,
      sport: argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EventsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventsHash() => r'cb881882c4bd6240c8db1dce76575505e6ad4789';

final class EventsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Event>>, String> {
  EventsFamily._()
      : super(
          retry: null,
          name: r'eventsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  EventsProvider call({
    String sport = 'all',
  }) =>
      EventsProvider._(argument: sport, from: this);

  @override
  String toString() => r'eventsProvider';
}

@ProviderFor(SelectedSport)
final selectedSportProvider = SelectedSportProvider._();

final class SelectedSportProvider
    extends $NotifierProvider<SelectedSport, String> {
  SelectedSportProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'selectedSportProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$selectedSportHash();

  @$internal
  @override
  SelectedSport create() => SelectedSport();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$selectedSportHash() => r'092a6546205b3a3bb9f5fe23659c23baf4905150';

abstract class _$SelectedSport extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<String, String>, String, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(SearchQuery)
final searchQueryProvider = SearchQueryProvider._();

final class SearchQueryProvider extends $NotifierProvider<SearchQuery, String> {
  SearchQueryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'searchQueryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$searchQueryHash();

  @$internal
  @override
  SearchQuery create() => SearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$searchQueryHash() => r'3c36752ee11b18a9f1e545eb1a7209a7222d91c9';

abstract class _$SearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<String, String>, String, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}


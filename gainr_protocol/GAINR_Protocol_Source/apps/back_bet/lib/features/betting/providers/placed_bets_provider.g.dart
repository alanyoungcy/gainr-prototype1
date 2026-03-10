// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'placed_bets_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlacedBets)
final placedBetsProvider = PlacedBetsProvider._();

final class PlacedBetsProvider
    extends $NotifierProvider<PlacedBets, List<PlacedBet>> {
  PlacedBetsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'placedBetsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$placedBetsHash();

  @$internal
  @override
  PlacedBets create() => PlacedBets();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PlacedBet> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PlacedBet>>(value),
    );
  }
}

String _$placedBetsHash() => r'056a693639597f83d346612faae0617beea93ec5';

abstract class _$PlacedBets extends $Notifier<List<PlacedBet>> {
  List<PlacedBet> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<PlacedBet>, List<PlacedBet>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<List<PlacedBet>, List<PlacedBet>>,
        List<PlacedBet>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(activeBets)
final activeBetsProvider = ActiveBetsProvider._();

final class ActiveBetsProvider extends $FunctionalProvider<List<PlacedBet>,
    List<PlacedBet>, List<PlacedBet>> with $Provider<List<PlacedBet>> {
  ActiveBetsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'activeBetsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$activeBetsHash();

  @$internal
  @override
  $ProviderElement<List<PlacedBet>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<PlacedBet> create(Ref ref) {
    return activeBets(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PlacedBet> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PlacedBet>>(value),
    );
  }
}

String _$activeBetsHash() => r'20725d4d9e47af29b0c81e4bcd85aa967d81f96c';

@ProviderFor(settledBets)
final settledBetsProvider = SettledBetsProvider._();

final class SettledBetsProvider extends $FunctionalProvider<List<PlacedBet>,
    List<PlacedBet>, List<PlacedBet>> with $Provider<List<PlacedBet>> {
  SettledBetsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'settledBetsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$settledBetsHash();

  @$internal
  @override
  $ProviderElement<List<PlacedBet>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<PlacedBet> create(Ref ref) {
    return settledBets(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PlacedBet> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PlacedBet>>(value),
    );
  }
}

String _$settledBetsHash() => r'ddbfa0e83d1396dca245f294a45ea2dca2762db3';


// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bet_slip_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BetSlipController)
final betSlipControllerProvider = BetSlipControllerProvider._();

final class BetSlipControllerProvider
    extends $NotifierProvider<BetSlipController, List<Bet>> {
  BetSlipControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'betSlipControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$betSlipControllerHash();

  @$internal
  @override
  BetSlipController create() => BetSlipController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Bet> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Bet>>(value),
    );
  }
}

String _$betSlipControllerHash() => r'2bbee4bd48cd79fdaf1beaa685b790e63c2dfa22';

abstract class _$BetSlipController extends $Notifier<List<Bet>> {
  List<Bet> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<Bet>, List<Bet>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<List<Bet>, List<Bet>>, List<Bet>, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}


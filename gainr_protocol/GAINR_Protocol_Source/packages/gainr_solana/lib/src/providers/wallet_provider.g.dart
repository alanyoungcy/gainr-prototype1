// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Wallet)
final walletProvider = WalletProvider._();

final class WalletProvider extends $NotifierProvider<Wallet, WalletState> {
  WalletProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'walletProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$walletHash();

  @$internal
  @override
  Wallet create() => Wallet();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WalletState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WalletState>(value),
    );
  }
}

String _$walletHash() => r'77e86baa974be515ceb061116d0cc35f24e943d6';

abstract class _$Wallet extends $Notifier<WalletState> {
  WalletState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<WalletState, WalletState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<WalletState, WalletState>, WalletState, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

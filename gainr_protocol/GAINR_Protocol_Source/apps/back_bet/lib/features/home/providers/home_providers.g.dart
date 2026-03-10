// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SelectedScreen)
final selectedScreenProvider = SelectedScreenProvider._();

final class SelectedScreenProvider
    extends $NotifierProvider<SelectedScreen, int> {
  SelectedScreenProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'selectedScreenProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$selectedScreenHash();

  @$internal
  @override
  SelectedScreen create() => SelectedScreen();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$selectedScreenHash() => r'b28ab97cf07ecdf83393b0e62ce0a606806a2dc8';

abstract class _$SelectedScreen extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element = ref.element
        as $ClassProviderElement<AnyNotifier<int, int>, int, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}


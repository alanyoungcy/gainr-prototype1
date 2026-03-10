import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_providers.g.dart';

@riverpod
class SelectedScreen extends _$SelectedScreen {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}


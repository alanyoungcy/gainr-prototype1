import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gainr_models/gainr_models.dart';
part 'bet_slip_provider.g.dart';

@riverpod
class BetSlipController extends _$BetSlipController {
  @override
  List<Bet> build() {
    return [];
  }

  void addBet(Event event, String selection, String selectionName, double odd) {
    if (state.any((b) => b.event.id == event.id)) {
      // For simplicity, replace existing bet for same event
      state = state.where((b) => b.event.id != event.id).toList();
    }
    
    final newBet = Bet(
      id: '${event.id}_$selection',
      event: event,
      selection: selection,
      selectionName: selectionName,
      odd: odd,
      stake: 10.0, // Default stake
    );
    
    state = [...state, newBet];
  }

  void removeBet(String betId) {
    state = state.where((b) => b.id != betId).toList();
  }

  void updateStake(String betId, double newStake) {
    state = state.map((b) {
      if (b.id == betId) {
        return b.copyWith(stake: newStake);
      }
      return b;
    }).toList();
  }

  void clear() {
    state = [];
  }
}


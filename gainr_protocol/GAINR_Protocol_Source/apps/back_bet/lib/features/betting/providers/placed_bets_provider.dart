import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gainr_models/gainr_models.dart';
import 'package:gainr_solana/gainr_solana.dart';
part 'placed_bets_provider.g.dart';

// ─── Storage Key ─────────────────────────────────────────────────────
const String _placedBetsStorageKey = 'gainr_placed_bets';

@Riverpod(keepAlive: true)
class PlacedBets extends _$PlacedBets {
  final Map<String, Timer> _settlementTimers = {};
  final Random _random = Random();

  @override
  List<PlacedBet> build() {
    _loadFromStorage();
    ref.onDispose(() {
      for (final timer in _settlementTimers.values) {
        timer.cancel();
      }
      _settlementTimers.clear();
    });
    return [];
  }

  // ── Load persisted bets from SharedPreferences ──
  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_placedBetsStorageKey);
      if (stored != null) {
        final List<dynamic> jsonList = jsonDecode(stored) as List<dynamic>;
        final bets = jsonList
            .map((e) => PlacedBet.fromJson(e as Map<String, dynamic>))
            .toList();
        state = bets;

        // Restart timers for any still-pending bets
        for (final bet in bets.where((b) => b.isPending)) {
          _startSettlementTimer(bet);
        }
      }
    } catch (e) {
      // Ignore storage errors, start fresh
    }
  }

  // ── Save all bets to SharedPreferences ──
  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(state.map((b) => b.toJson()).toList());
      await prefs.setString(_placedBetsStorageKey, json);
    } catch (e) {
      // Ignore storage errors
    }
  }

  // ── Place a bet from the bet slip ──
  void placeBet(Bet bet) {
    final placedBet = PlacedBet(
      id: '${bet.id}_${DateTime.now().millisecondsSinceEpoch}',
      eventName: '${bet.event.homeTeam.name} vs ${bet.event.awayTeam.name}',
      selectionName: bet.selectionName,
      sport: bet.event.sport,
      odds: bet.odd,
      stake: bet.stake,
      potentialReturn: bet.potentialReturn,
      status: BetStatus.pending,
      placedAt: DateTime.now(),
      settlementTime: DateTime.now().add(const Duration(seconds: 30)),
    );

    state = [placedBet, ...state];
    _saveToStorage();
    _startSettlementTimer(placedBet);
  }

  // ── Place multiple bets at once (from bet slip) ──
  void placeBets(List<Bet> bets) {
    for (final bet in bets) {
      placeBet(bet);
    }
  }

  // ── Start auto-settlement timer (30 seconds) ──
  void _startSettlementTimer(PlacedBet bet) {
    // Cancel any existing timer for this bet
    _settlementTimers[bet.id]?.cancel();

    final remaining = bet.timeUntilSettlement;
    final delay = remaining.isNegative || remaining == Duration.zero
        ? const Duration(milliseconds: 500) // Settle immediately if past due
        : remaining;

    _settlementTimers[bet.id] = Timer(delay, () => _settleBet(bet.id));
  }

  // ── Settle a bet (40% win, 60% loss for demo realism) ──
  void _settleBet(String betId) {
    final betIndex = state.indexWhere((b) => b.id == betId);
    if (betIndex == -1) return;

    final bet = state[betIndex];
    if (bet.isSettled) return; // Already settled

    final isWin = _random.nextDouble() < 0.4; // 40% win rate
    final newStatus = isWin ? BetStatus.won : BetStatus.lost;

    final settledBet = bet.copyWith(
      status: newStatus,
      settledAt: DateTime.now(),
    );

    // Update the bet in state
    final newState = List<PlacedBet>.from(state);
    newState[betIndex] = settledBet;
    state = newState;

    // If won, credit winnings to wallet
    if (isWin) {
      ref.read(walletProvider.notifier).addWinnings(bet.potentialReturn);
    }

    // Clean up timer
    _settlementTimers.remove(betId);

    _saveToStorage();
  }

  // ── Clear all bets (for dev/debug) ──
  void clearAll() {
    for (final timer in _settlementTimers.values) {
      timer.cancel();
    }
    _settlementTimers.clear();
    state = [];
    _saveToStorage();
  }
}

// Convenience providers for filtered views
@riverpod
List<PlacedBet> activeBets(Ref ref) {
  return ref.watch(placedBetsProvider).where((b) => b.isPending).toList();
}

@riverpod
List<PlacedBet> settledBets(Ref ref) {
  return ref.watch(placedBetsProvider).where((b) => b.isSettled).toList()
    ..sort((a, b) =>
        (b.settledAt ?? b.placedAt).compareTo(a.settledAt ?? a.placedAt));
}


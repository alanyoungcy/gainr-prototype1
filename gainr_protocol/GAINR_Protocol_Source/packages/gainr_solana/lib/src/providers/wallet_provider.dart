import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wallet_state.dart';

part 'wallet_provider.g.dart';

const String _storageKey = 'gainr_wallet_state';

@riverpod
class Wallet extends _$Wallet {
  @override
  WalletState build() {
    debugPrint('💼 [Wallet] Building state...');
    _loadFromStorage();
    return const WalletState();
  }

  // Load saved wallet state from SharedPreferences
  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_storageKey);
      if (stored != null) {
        final json = jsonDecode(stored) as Map<String, dynamic>;
        state = WalletState.fromJson(json);
      }
    } catch (e) {
      // Ignore storage errors
    }
  }

  // Save wallet state to SharedPreferences
  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(state.toJson());
      await prefs.setString(_storageKey, json);
    } catch (e) {
      // Ignore storage errors
    }
  }

  // Generate random Solana address for demo
  String _generateMockAddress() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz123456789';
    final random = Random();
    return List.generate(44, (_) => chars[random.nextInt(chars.length)]).join();
  }

  void _addTransaction(TransactionType type, double amount, String token,
      {String? details}) {
    final transaction = WalletTransaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      amount: amount,
      token: token,
      timestamp: DateTime.now(),
      details: details,
    );
    state = state.copyWith(
      transactions: [transaction, ...state.transactions].take(50).toList(),
    );
  }

  // Simulate wallet connection
  Future<void> connect() async {
    state = state.copyWith(
      status: WalletConnection.connecting,
      errorMessage: null,
    );

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 1500));

      // Generate mock wallet data
      final address = _generateMockAddress();
      final solBalance = 2.5 + Random().nextDouble() * 5; // 2.5-7.5 SOL

      state = state.copyWith(
        status: WalletConnection.connected,
        address: address,
        solBalance: solBalance,
        // Start with 1,000 mock USDC for testing swaps
        usdcBalance: 1000000.0,
        betBalance: 0.0,
        gainrBalance: 0.0,
      );

      _addTransaction(TransactionType.deposit, 1000000.0, 'USDC',
          details: 'Mock initial balance');

      await _saveToStorage();
    } catch (e) {
      state = state.copyWith(
        status: WalletConnection.error,
        errorMessage: 'Failed to connect wallet',
      );
    }
  }

  // Disconnect wallet
  Future<void> disconnect() async {
    state = const WalletState();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  // Simulate USDC → $BET deposit
  Future<void> deposit(double usdcAmount) async {
    if (!state.isConnected || state.usdcBalance < usdcAmount) return;

    try {
      // Simulate transaction delay
      await Future.delayed(const Duration(seconds: 1));

      state = state.copyWith(
        usdcBalance: state.usdcBalance - usdcAmount,
        betBalance: state.betBalance + usdcAmount,
      );

      _addTransaction(TransactionType.deposit, usdcAmount, 'BET',
          details: 'USDC -> BET Deposit');
      await _saveToStorage();
    } catch (e) {
      // Handle error
    }
  }

  // Deduct $BET when placing bet
  Future<void> deductBet(double amount) async {
    if (!state.isConnected || state.betBalance < amount) return;

    state = state.copyWith(
      betBalance: state.betBalance - amount,
    );

    _addTransaction(TransactionType.withdraw, amount, 'BET',
        details: 'Bet Placement');
    await _saveToStorage();
  }

  // Add winnings when bet settles
  Future<void> addWinnings(double amount) async {
    if (!state.isConnected) return;

    state = state.copyWith(
      betBalance: state.betBalance + amount,
    );

    _addTransaction(TransactionType.reward, amount, 'BET',
        details: 'Bet Winnings');
    await _saveToStorage();
  }

  // Mock rates
  static const double betPrice = 1.0; // Pegged to USDC
  static const double gainrPrice = 0.85; // 1 GAINR = $0.85
  static const double usdcPrice = 1.0;

  SwapResult calculateSwap(String from, String to, double amount) {
    if (amount <= 0) {
      return const SwapResult(output: 0, fee: 0, priceImpact: 0, rate: 1.0);
    }

    final fromPrice =
        from == 'BET' ? betPrice : (from == 'GAINR' ? gainrPrice : usdcPrice);
    final toPrice =
        to == 'BET' ? betPrice : (to == 'GAINR' ? gainrPrice : usdcPrice);

    final rate = fromPrice / toPrice;
    final rawOutput = amount * rate;
    final fee = rawOutput * 0.003; // 0.3% protocol fee

    // Simulate price impact: 0.1% base + 0.5% per $10,000 swapped (capped at 15%)
    final priceImpact = (0.001 + (amount / 10000) * 0.005).clamp(0.001, 0.15);

    return SwapResult(
      output: (rawOutput - fee) * (1 - priceImpact),
      fee: fee,
      priceImpact: priceImpact,
      rate: rate,
    );
  }

  // Proper $BET <-> $GAINR <-> USDC Swap
  Future<void> swap(String fromToken, String toToken, double fromAmount,
      double toAmount) async {
    if (!state.isConnected) return;

    final result = calculateSwap(fromToken, toToken, fromAmount);

    // Initial deduction (Stage 1 for Burn-to-Swap)
    double newUsdc = state.usdcBalance;
    double newBet = state.betBalance;
    double newGainr = state.gainrBalance;

    // Deduct immediately
    if (fromToken == 'USDC') newUsdc -= fromAmount;
    if (fromToken == 'BET') newBet -= fromAmount;
    if (fromToken == 'GAINR') newGainr -= fromAmount;

    state = state.copyWith(
      usdcBalance: newUsdc,
      betBalance: newBet,
      gainrBalance: newGainr,
    );

    // Check if this is a BET -> GAINR swap (The "Burn-to-Swap" Protocol)
    if (fromToken == 'BET' && toToken == 'GAINR') {
      // Stage 1: Burn Log
      _addTransaction(
        TransactionType.swap,
        fromAmount,
        'BET',
        details: 'Stage 1: Burned ${fromAmount.toStringAsFixed(2)} BET',
      );
      await _saveToStorage();

      // Stage 2: Simulate Bridge/AMM Delay
      await Future.delayed(const Duration(milliseconds: 2000));

      // Stage 3: Settlement (Buy GAINR)
      newGainr += result.output;

      state = state.copyWith(gainrBalance: newGainr);

      _addTransaction(
        TransactionType.swap,
        result.output,
        'GAINR',
        details:
            'Stage 3: Settled ${result.output.toStringAsFixed(2)} GAINR (via AMM)',
      );
    } else {
      // Standard Swap Settlement
      if (toToken == 'USDC') newUsdc += result.output;
      if (toToken == 'BET') newBet += result.output;
      if (toToken == 'GAINR') newGainr += result.output;

      state = state.copyWith(
        usdcBalance: newUsdc,
        betBalance: newBet,
        gainrBalance: newGainr,
      );

      _addTransaction(
        TransactionType.swap,
        result.output,
        toToken,
        details:
            'Swap: ${fromAmount.toStringAsFixed(2)} $fromToken -> ${result.output.toStringAsFixed(2)} $toToken',
      );
    }

    await _saveToStorage();
  }

  // Simulate $BET → USDC withdrawal
  Future<void> withdraw(double betAmount) async {
    if (!state.isConnected || state.betBalance < betAmount) return;

    try {
      // Simulate transaction delay
      await Future.delayed(const Duration(seconds: 1));

      state = state.copyWith(
        betBalance: state.betBalance - betAmount,
        usdcBalance: state.usdcBalance + betAmount,
      );

      _addTransaction(TransactionType.withdraw, betAmount, 'USDC',
          details: 'BET -> USDC Withdrawal');
      await _saveToStorage();
    } catch (e) {
      // Handle error
    }
  }

  // Update $GAINR balance (for staking demo)
  Future<void> updateGainrBalance(double amount) async {
    state = state.copyWith(gainrBalance: amount);
    await _saveToStorage();
  }
}

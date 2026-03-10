import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SocialWin {
  final String user;
  final double amount;
  final double multiplier;
  final String event;

  SocialWin({
    required this.user,
    required this.amount,
    required this.multiplier,
    required this.event,
  });
}

final socialWinProvider =
    NotifierProvider<SocialWinNotifier, SocialWin?>(SocialWinNotifier.new);

class SocialWinNotifier extends Notifier<SocialWin?> {
  final Random _random = Random();
  Timer? _timer;

  final List<String> _users = [
    'sol_whale',
    'gainr_pro',
    'degen_king',
    'bet_wiz',
    'pixel_master',
    'sol_lion'
  ];
  final List<String> _events = [
    'Lakers vs Warriors',
    'Man City vs Arsenal',
    'Real Madrid vs Barca',
    'Nadal vs Djokovic'
  ];

  @override
  SocialWin? build() {
    _startRandomWins();
    ref.onDispose(() {
      _timer?.cancel();
    });
    return null;
  }

  void _startRandomWins() {
    // Show first win after 10s, then every 45s
    Future.delayed(const Duration(seconds: 10), () {
      _triggerRandomWin();
    });

    _timer = Timer.periodic(const Duration(seconds: 45), (timer) {
      _triggerRandomWin();
    });
  }

  void _triggerRandomWin() {
    state = SocialWin(
      user: _users[_random.nextInt(_users.length)],
      amount: (100 + _random.nextInt(1000)).toDouble(),
      multiplier: (2 + _random.nextDouble() * 5),
      event: _events[_random.nextInt(_events.length)],
    );

    // Clear after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      state = null;
    });
  }
}


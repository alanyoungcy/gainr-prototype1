import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'package:pick_bet/features/dashboard/dashboard_screen.dart';
import 'package:pick_bet/features/provider/provider_detail_screen.dart';
import 'package:pick_bet/features/history/history_screen.dart';
import 'package:pick_bet/features/market_data/market_data_screen.dart';
import 'package:pick_bet/features/signals_api/signals_api_screen.dart';

import 'package:pick_bet/shared/widgets/pick_main_layout.dart';

void main() {
  debugPrint('🚀 [MAIN] Starting PICK.BET app...');

  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProviderScope(child: PickBetApp()));
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return PickMainLayout(
          activePath: state.matchedLocation,
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const PickDashboardScreen(),
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => const HistoryScreen(),
        ),
        GoRoute(
          path: '/market-data',
          builder: (context, state) => const MarketDataScreen(),
        ),
        GoRoute(
          path: '/signals-api',
          builder: (context, state) => const SignalsApiScreen(),
        ),
        GoRoute(
          path: '/provider/:id',
          builder: (context, state) =>
              ProviderDetailScreen(providerId: state.pathParameters['id']!),
        ),
      ],
    ),
  ],
);

class PickBetApp extends ConsumerWidget {
  const PickBetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Pick.bet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme.copyWith(
        scaffoldBackgroundColor: Colors.black,
        textTheme: AppTheme.darkTheme.textTheme.apply(
          fontFamily: 'monospace',
        ),
      ),
      routerConfig: _router,
    );
  }
}

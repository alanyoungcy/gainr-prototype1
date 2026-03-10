import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'package:price_bet/features/dashboard/dashboard_screen.dart';
import 'package:price_bet/features/details/market_detail_screen.dart';
import 'package:price_bet/features/portfolio/portfolio_screen.dart';
import 'package:price_bet/shared/widgets/price_main_layout.dart';

void main() {
  debugPrint('🚀 [MAIN] Starting PRICE.BET app...');

  // Set pure black backend for high-contrast terminal feel
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProviderScope(child: PriceBetApp()));
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return PriceMainLayout(
          activePath: state.matchedLocation,
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardScreen(),
          routes: [
            GoRoute(
              path: 'market/:id',
              builder: (context, state) =>
                  MarketDetailScreen(marketId: state.pathParameters['id']!),
            ),
            GoRoute(
              path: 'portfolio',
              builder: (context, state) => const PortfolioScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

class PriceBetApp extends ConsumerWidget {
  const PriceBetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Price.bet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme.copyWith(
        scaffoldBackgroundColor: Colors.black,
        // Override for terminal feel
        textTheme: AppTheme.darkTheme.textTheme.apply(
          fontFamily: 'monospace',
        ),
      ),
      routerConfig: _router,
    );
  }
}

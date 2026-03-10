import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'package:gainr_mobile/features/home/main_layout.dart';

void main() {
  debugPrint('🚀 [MAIN] Starting GAINR app...');

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('🛑 [FATAL] Flutter Error: ${details.exception}');
  };

  runApp(const ProviderScope(child: GainrApp()));
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainLayout(),
    ),
  ],
);

class GainrApp extends ConsumerWidget {
  const GainrApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('🚀 [GainrApp] Building MaterialApp.router...');
    return MaterialApp.router(
      title: 'GAINR',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: _router,
    );
  }
}


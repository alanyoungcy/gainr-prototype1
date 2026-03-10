import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'package:gainr_mobile/features/home/widgets/sidebar.dart';
import 'package:gainr_mobile/features/home/widgets/main_content.dart';
import 'package:gainr_mobile/features/home/widgets/bet_slip_panel.dart';
import 'package:gainr_mobile/features/betting/screens/bet_history_screen.dart';
import 'package:gainr_mobile/features/wallet/widgets/swap_screen.dart';
import 'package:gainr_mobile/features/wallet/widgets/profile_screen.dart';
import 'package:gainr_mobile/features/betting/widgets/social_win_notification.dart';
import 'package:gainr_mobile/features/betting/widgets/live_bet_ticker.dart';
import 'package:gainr_mobile/features/home/widgets/mobile_header.dart';
import 'package:gainr_mobile/features/home/widgets/bottom_nav_bar.dart';
import 'package:gainr_mobile/features/home/widgets/coming_soon_screen.dart';
import 'package:gainr_mobile/features/home/providers/home_providers.dart';

class MainLayout extends ConsumerWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('📱 [MainLayout] Building UI...');
    final selectedIndex = ref.watch(selectedScreenProvider);
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppTheme.darkBackground,
      // Drawer for mobile/tablet navigation
      drawer: Drawer(
        backgroundColor: const Color(0xFF0D0D0F),
        child: Sidebar(
          selectedIndex: selectedIndex,
          onIndexChanged: (index) {
            ref.read(selectedScreenProvider.notifier).setIndex(index);
            Navigator.pop(context);
          },
        ),
      ),
      // Bottom Bar for mobile primary actions
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 600) return const SizedBox.shrink();
          return BottomNavBar(
            selectedIndex: selectedIndex,
            onIndexChanged: (index) =>
                ref.read(selectedScreenProvider.notifier).setIndex(index),
          );
        },
      ),
      // Floating Action Button for Bet Slip on mobile
      floatingActionButton: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 1100) return const SizedBox.shrink();
          return GlowPulse(
            glowColor: AppTheme.gainrGreen,
            glowRadius: 16,
            duration: const Duration(milliseconds: 2000),
            child: FloatingActionButton(
              onPressed: () => _showBetSlipSheet(context),
              backgroundColor: AppTheme.gainrGreen,
              child:
                  const Icon(Icons.shopping_cart_outlined, color: Colors.black),
            ),
          );
        },
      ),
      body: Stack(
        children: [
          // Ambient floating particles behind everything
          const Positioned.fill(
            child: IgnorePointer(
              child: FloatingParticles(
                particleCount: 20,
                particleColor: AppTheme.gainrGreen,
                maxSize: 2.0,
                speed: 0.2,
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final showSidebar = constraints.maxWidth >= 900;
              final showBetSlip = constraints.maxWidth >= 1100;

              return Row(
                children: [
                  // Left Sidebar (hide on small screens)
                  if (showSidebar)
                    SizedBox(
                      width: 240,
                      child: Sidebar(
                        selectedIndex: selectedIndex,
                        onIndexChanged: (index) {
                          ref
                              .read(selectedScreenProvider.notifier)
                              .setIndex(index);
                        },
                      ),
                    ),

                  // Main Content Area with Enhanced Transitions
                  Expanded(
                    child: Column(
                      children: [
                        // Mobile Header
                        if (!showSidebar)
                          MobileHeader(
                            onMenuPressed: () =>
                                scaffoldKey.currentState?.openDrawer(),
                          ),
                        // Live Bet Ticker (social proof bar)
                        if (selectedIndex == 0 || selectedIndex == 1)
                          const LiveBetTicker(),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: CurvedAnimation(
                                  parent: animation,
                                  curve: const Interval(0.0, 0.8),
                                ),
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.03, 0.02),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                  )),
                                  child: ScaleTransition(
                                    scale: Tween<double>(
                                      begin: 0.97,
                                      end: 1.0,
                                    ).animate(CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOutCubic,
                                    )),
                                    child: child,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              key: ValueKey(selectedIndex),
                              child: _getScreen(selectedIndex),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right Bet Slip Panel (hide on small screens)
                  if (showBetSlip)
                    Container(
                      width: 320,
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        border: Border(
                          left: BorderSide(
                            color: Colors.white.withValues(alpha: 0.05),
                            width: 1,
                          ),
                        ),
                      ),
                      child: const BetSlipPanel(),
                    ),
                ],
              );
            },
          ),
          const SocialWinOverlay(),
        ],
      ),
    );
  }

  void _showBetSlipSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: const BetSlipPanel(),
        ),
      ),
    );
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 0: // Sportsbook
        return const MainContent();
      case 1: // Live Events — filtered to live only
        return const MainContent(liveOnly: true);
      case 2: // Casino — Coming Soon
        return const ComingSoonScreen(
          title: 'Casino',
          subtitle:
              'Decentralized casino games powered by\nverifiable random functions on Solana.',
          icon: Icons.casino_outlined,
        );
      case 3: // My Bets
      case 5: // History
        return const BetHistoryScreen();
      case 4: // Wallet
        return const ProfileScreen();
      case 6: // Swap
        return const SwapScreen();
      default:
        return const MainContent();
    }
  }
}


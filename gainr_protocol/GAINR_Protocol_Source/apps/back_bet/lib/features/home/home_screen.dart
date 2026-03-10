import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'package:gainr_mobile/features/wallet/widgets/connect_wallet_button.dart';
import 'package:gainr_mobile/features/betting/widgets/event_list.dart';
import 'package:gainr_mobile/features/betting/providers/bet_slip_provider.dart';
import 'package:gainr_mobile/features/betting/widgets/bet_slip_sheet.dart';
import 'package:gainr_mobile/features/wallet/widgets/profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  String _selectedSport = 'all';

  final List<String> _sports = [
    'All',
    'Live',
    'Football',
    'Basketball',
    'Soccer'
  ];

  @override
  Widget build(BuildContext context) {
    final bets = ref.watch(betSlipControllerProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: bets.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const BetSlipSheet(),
                );
              },
              backgroundColor: AppTheme.gainrGreen,
              foregroundColor: Colors.black,
              icon: const Icon(Icons.receipt_long),
              label: Text('Bet Slip (${bets.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.gainrGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.flash_on,
                  color: AppTheme.gainrGreen, size: 20),
            ),
            const SizedBox(width: 8),
            Text(
              'GAINR',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: ConnectWalletButton(),
          ),
        ],
      ),
      body: _selectedIndex == 3
          ? const ProfileScreen()
          : Column(
              children: [
                // Sport Filter Tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: _sports.map((sport) {
                      final isSelected =
                          _selectedSport.toLowerCase() == sport.toLowerCase();
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(sport),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedSport = sport.toLowerCase();
                            });
                          },
                          backgroundColor: AppTheme.surfaceColor,
                          selectedColor: AppTheme.gainrGreen,
                          checkmarkColor: Colors.black,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.black
                                : AppTheme.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.transparent
                                  : Colors.transparent,
                            ),
                          ),
                          showCheckmark: false,
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Event List
                Expanded(
                  child: EventList(sportFilter: _selectedSport),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppTheme.cardBackground,
        selectedItemColor: AppTheme.gainrGreen,
        unselectedItemColor: AppTheme.textSecondary,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), label: 'My Bets'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

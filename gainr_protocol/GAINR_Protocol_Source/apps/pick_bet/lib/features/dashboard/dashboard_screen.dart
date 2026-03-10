import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'package:gainr_models/gainr_models.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:pick_bet/features/dashboard/providers/leaderboard_provider.dart';
import 'package:pick_bet/shared/widgets/pick_app_bar.dart';
import 'package:pick_bet/shared/widgets/live_signal_ticker.dart';

class PickDashboardScreen extends ConsumerStatefulWidget {
  const PickDashboardScreen({super.key});

  @override
  ConsumerState<PickDashboardScreen> createState() =>
      _PickDashboardScreenState();
}

class _PickDashboardScreenState extends ConsumerState<PickDashboardScreen> {
  int _currentPage = 1;
  static const int _totalPages = 42;
  WhaleAlert? _currentWhaleAlert;

  @override
  Widget build(BuildContext context) {
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final horizontalPadding = gainrPadding(screenWidth);

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    // 0. Live Alpha Ticker
                    const LiveSignalTicker(),

                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1400),
                        child: Column(
                          children: [
                            // 1. Hero Section
                            _buildHero(context, screenWidth),

                            // 2. Leaderboard Table
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding),
                              child: Column(
                                children: [
                                  _buildTableHeaders(),
                                  leaderboardAsync.when(
                                    data: (providers) => Column(
                                      children: List.generate(
                                        providers.length,
                                        (index) => StaggeredFadeSlide(
                                          index: index,
                                          baseDelayMs: 100,
                                          child: HoverScaleGlow(
                                            child: _LeaderboardRow(
                                              rank: index + 1,
                                              provider: providers[index],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    loading: () => const Center(
                                        child: CircularProgressIndicator(
                                            color: AppTheme.neonOrange)),
                                    error: (err, stack) =>
                                        Center(child: Text('Error: $err')),
                                  ),
                                  const SizedBox(height: 32),

                                  // Pagination
                                  _buildPagination(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 100),

                    // 3. Footer
                    GainrFooter(
                      systemId: 'PICK_ALPHA_v1.2',
                      extraLinks: [
                        FooterLink(label: 'LEGAL', onTap: () {}),
                        FooterLink(label: 'RISK_DISCLOSURE', onTap: () {}),
                      ],
                    ),
                  ],
                ),
              ),
              if (_currentWhaleAlert != null)
                Positioned(
                  bottom: 100,
                  left: 24,
                  child: WhaleAlertOverlay(
                    alert: _currentWhaleAlert!,
                    onDismiss: () => setState(() => _currentWhaleAlert = null),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHero(BuildContext context, double screenWidth) {
    final padding = gainrPadding(screenWidth);
    return Container(
      width: double.infinity,
      padding:
          EdgeInsets.only(left: padding, top: 80, bottom: 40, right: padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 24,
            runSpacing: 12,
            children: [
              NeonText(
                text: 'LEADERBOARD',
                glowColor: AppTheme.neonOrange,
                glowRadius: 12,
                style: AppTextStyles.h1.copyWith(
                  fontSize: gainrHeroFontSize(screenWidth),
                  color: AppTheme.neonOrange,
                  letterSpacing: -2,
                  height: 0.9,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: NeonText(
                  text: 'STATUS: LIVE_FEED',
                  glowColor: AppTheme.neonOrange,
                  glowRadius: 4,
                  style: TextStyle(
                      color: Colors.white30,
                      fontSize: 12,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: const Text(
              'Real-time performance metrics of top-tier political & macro signal providers.\nVerification protocol: ON-CHAIN_GOVERNANCE_AUDITED.',
              style:
                  TextStyle(color: Colors.white54, fontSize: 16, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeaders() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 800),
          child: Row(
            children: [
              _headerItem('RANK', flex: 1),
              _headerItem('PROVIDER', flex: 3),
              _headerItem('WIN_RATE', flex: 2),
              _headerItem('SUBSCRIBERS', flex: 2),
              _headerItem('ROI_TOTAL', flex: 2),
              _headerItem('ACCESS', flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerItem(String label, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(label,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white24,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          )),
    );
  }

  Widget _buildPagination() {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 24,
      runSpacing: 16,
      children: [
        Text('PAGE $_currentPage OF $_totalPages | SHOWING TOP PERFORMERS',
            style: const TextStyle(
                color: Colors.white24, fontSize: 12, letterSpacing: 1)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _pageIcon(LucideIcons.chevron_left, onTap: () {
              if (_currentPage > 1) setState(() => _currentPage--);
            }),
            _pageButton('1', active: _currentPage == 1, onTap: () {
              setState(() => _currentPage = 1);
            }),
            _pageButton('2', active: _currentPage == 2, onTap: () {
              setState(() => _currentPage = 2);
            }),
            _pageButton('3', active: _currentPage == 3, onTap: () {
              setState(() => _currentPage = 3);
            }),
            _pageButton('...', isText: true),
            _pageIcon(LucideIcons.chevron_right, onTap: () {
              if (_currentPage < _totalPages) setState(() => _currentPage++);
            }),
          ],
        ),
      ],
    );
  }

  Widget _pageButton(String label,
      {bool active = false, bool isText = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor:
            onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.only(left: 8),
          decoration: BoxDecoration(
            color: active ? AppTheme.neonOrange : Colors.black,
            border: Border.all(color: Colors.white12),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                  color: active ? Colors.black : Colors.white30,
                  fontWeight: FontWeight.bold,
                )),
          ),
        ),
      ),
    );
  }

  Widget _pageIcon(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.only(left: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white12),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(child: Icon(icon, color: Colors.white30, size: 16)),
        ),
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final int rank;
  final PickProvider provider;
  const _LeaderboardRow({required this.rank, required this.provider});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () => context.go('/provider/${provider.id}'),
        hoverColor: Colors.white.withValues(alpha: 0.05),
        child: Container(
          height: 100,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white10)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 800),
              child: Row(
                children: [
                  // Rank
                  Expanded(
                    flex: 1,
                    child: Text(rank.toString().padLeft(3, '0'),
                        style: const TextStyle(
                            color: AppTheme.neonOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'monospace')),
                  ),
                  // Provider
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(LucideIcons.user,
                              color: Colors.white70, size: 20),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(provider.name.toUpperCase(),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 1)),
                        ),
                      ],
                    ),
                  ),
                  // Win Rate
                  Expanded(
                    flex: 2,
                    child: Text(
                        '${(provider.winRate * 100).toStringAsFixed(1)}%',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ),
                  // Subscribers
                  Expanded(
                    flex: 2,
                    child: Text(
                        provider.followers.toString().replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                            (Match m) => '${m[1]},'),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ),
                  // ROI
                  Expanded(
                    flex: 2,
                    child: Text('+${provider.roi.toStringAsFixed(1)}%',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppTheme.neonOrange,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ),
                  // Access
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: PickHeaderButton(
                          label: 'SUBSCRIBE',
                          isPrimary: true,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'SUBSCRIBING_TO: ${provider.name.toUpperCase()}…',
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      letterSpacing: 1),
                                ),
                                backgroundColor: AppTheme.neonOrange,
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                            Future.delayed(const Duration(milliseconds: 800),
                                () {
                              if (context.mounted) {
                                context.go('/provider/${provider.id}');
                              }
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FadeInWidget extends StatefulWidget {
  final Widget child;
  const _FadeInWidget({required this.child});

  @override
  _FadeInWidgetState createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<_FadeInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _animation, child: widget.child);
  }
}

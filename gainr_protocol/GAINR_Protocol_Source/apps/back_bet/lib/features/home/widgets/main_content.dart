import 'package:gainr_ui/gainr_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gainr_models/gainr_models.dart';
import 'package:gainr_mobile/features/betting/providers/event_provider.dart';
import 'package:gainr_mobile/features/betting/providers/bet_slip_provider.dart';
import 'package:gainr_mobile/features/wallet/widgets/connect_wallet_button.dart';
import 'package:gainr_mobile/features/betting/widgets/ai_insights_panel.dart';
import 'package:gainr_mobile/features/betting/widgets/ai_badge.dart';

class MainContent extends ConsumerStatefulWidget {
  final bool liveOnly;
  const MainContent({super.key, this.liveOnly = false});

  @override
  ConsumerState<MainContent> createState() => _MainContentState();
}

class _MainContentState extends ConsumerState<MainContent> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(searchQueryProvider.notifier).setQuery('');
  }

  @override
  Widget build(BuildContext context) {
    final selectedSport = ref.watch(selectedSportProvider);
    final eventsAsync = ref.watch(eventsProvider(sport: selectedSport));
    final searchQuery = ref.watch(searchQueryProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < GainrBreakpoints.mobile;
    final horizontalPadding = gainrPadding(screenWidth);
    final crossAxisCount = screenWidth < GainrBreakpoints.mobile
        ? 1
        : screenWidth < GainrBreakpoints.tablet
            ? 2
            : 3;
    final childAspectRatio = screenWidth < GainrBreakpoints.mobile ? 1.4 : 1.1;

    return Column(
      children: [
        // Header
        Container(
          height: isMobile ? 64 : 72,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.05),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Search Bar
              Expanded(
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Row(
                    children: [
                      Icon(Icons.search,
                          color: Colors.white.withValues(alpha: 0.4), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            ref
                                .read(searchQueryProvider.notifier)
                                .setQuery(value);
                          },
                          decoration: InputDecoration(
                            hintText: isMobile
                                ? 'Search...'
                                : 'Search events, teams or leagues',
                            hintStyle: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4)),
                            border: InputBorder.none,
                            suffixIcon: searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    color: Colors.white.withValues(alpha: 0.4),
                                    onPressed: _clearSearch,
                                  )
                                : null,
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (!isMobile) ...[
                const SizedBox(width: 12),
                // Connect Button
                const Flexible(child: ConnectWalletButton()),
              ],
            ],
          ),
        ),

        // Content
        Expanded(
          child: AsyncValueWidget(
            value: eventsAsync,
            data: (events) {
              final liveEvents = events.where((e) => e.isLive).toList();
              final upcomingEvents = events.where((e) => !e.isLive).toList();

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Hero & Filters
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                        horizontalPadding, 32, horizontalPadding, 0),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (events.isNotEmpty &&
                              !widget.liveOnly &&
                              searchQuery.isEmpty)
                            AnimatedGradientBorder(
                              borderWidth: 2,
                              borderRadius: 24,
                              colors: const [
                                AppTheme.neonCyan,
                                AppTheme.gainrGreen,
                                Color(0xFF6C5CE7),
                                AppTheme.neonMagenta,
                                AppTheme.neonCyan,
                              ],
                              duration: const Duration(seconds: 4),
                              child: _HeroEventCard(event: events.first),
                            ),
                          if (events.isEmpty) _buildEmptyState(),
                          const SizedBox(height: 32),
                          _buildSportFilters(selectedSport),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),

                  // Live Matches Section
                  SliverPadding(
                    padding:
                        EdgeInsets.symmetric(horizontal: horizontalPadding),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              widget.liveOnly ? 'Live Matches' : 'Live Betting',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // Live Match Cards Grid (Sliver)
                  SliverPadding(
                    padding:
                        EdgeInsets.symmetric(horizontal: horizontalPadding),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: childAspectRatio,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final liveEvent = liveEvents[index];
                          return StaggeredFadeSlide(
                            index: index,
                            baseDelayMs: 300,
                            staggerMs: 100,
                            child: HoverScaleGlow(
                              glowColor: liveEvent.isValueBet
                                  ? AppTheme.gainrGreen
                                  : const Color(0xFF6C5CE7),
                              scaleFactor: 1.03,
                              child: _LiveMatchCard(event: liveEvent),
                            ),
                          );
                        },
                        childCount: liveEvents.length,
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 48)),

                  // Upcoming Events Section
                  if (upcomingEvents.isNotEmpty && !widget.liveOnly) ...[
                    SliverPadding(
                      padding:
                          EdgeInsets.symmetric(horizontal: horizontalPadding),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          children: [
                            Icon(Icons.schedule,
                                color: Colors.white.withValues(alpha: 0.5),
                                size: 20),
                            const SizedBox(width: 10),
                            const Flexible(
                              child: Text(
                                'Upcoming Events',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Spacer(),
                            _buildEventCountBadge(upcomingEvents.length),
                          ],
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 20)),

                    // Upcoming Events List (Sliver)
                    SliverPadding(
                      padding:
                          EdgeInsets.symmetric(horizontal: horizontalPadding),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final event = upcomingEvents[index];
                            return StaggeredFadeSlide(
                              index: index,
                              baseDelayMs: 250,
                              staggerMs: 70,
                              child: HoverScaleGlow(
                                glowColor: event.isValueBet
                                    ? AppTheme.gainrGreen
                                    : const Color(0xFF6C5CE7),
                                scaleFactor: 1.015,
                                glowRadius: 16,
                                child: _UpcomingEventCard(event: event),
                              ),
                            );
                          },
                          childCount: upcomingEvents.length,
                        ),
                      ),
                    ),
                  ],

                  const SliverToBoxAdapter(child: SizedBox(height: 48)),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 64),
        child: Column(
          children: [
            Icon(Icons.search_off,
                size: 64, color: Colors.white.withValues(alpha: 0.1)),
            const SizedBox(height: 16),
            Text(
              'No matching events found',
              style: GoogleFonts.outfit(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _clearSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.surfaceColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Clear Search'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSportFilters(String selectedSport) {
    final sports = [
      {'label': 'All Sports', 'icon': Icons.apps, 'id': 'all'},
      {'label': 'Soccer', 'icon': Icons.sports_soccer, 'id': 'soccer'},
      {
        'label': 'Basketball',
        'icon': Icons.sports_basketball,
        'id': 'basketball'
      },
      {'label': 'Tennis', 'icon': Icons.sports_tennis, 'id': 'tennis'},
      {'label': 'Football', 'icon': Icons.sports_football, 'id': 'football'},
      {'label': 'Cricket', 'icon': Icons.sports_cricket, 'id': 'cricket'},
      {'label': 'Racing', 'icon': Icons.stadium, 'id': 'horse racing'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: sports
            .map((s) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _SportChip(
                    label: s['label'] as String,
                    icon: s['icon'] as IconData,
                    isSelected: selectedSport == s['id'],
                    onTap: () => ref
                        .read(selectedSportProvider.notifier)
                        .setSport(s['id'] as String),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildEventCountBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$count events',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.4),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SportChip extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SportChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SportChip> createState() => _SportChipState();
}

class _SportChipState extends State<_SportChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppTheme.animFast,
          curve: AppTheme.animCurve,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? Colors.white
                : _isHovered
                    ? AppTheme.surfaceColor.withValues(alpha: 0.8)
                    : AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.15),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ]
                : _isHovered
                    ? [
                        BoxShadow(
                          color: AppTheme.neonCyan.withValues(alpha: 0.1),
                          blurRadius: 12,
                        ),
                      ]
                    : null,
            border: _isHovered && !widget.isSelected
                ? Border.all(
                    color: AppTheme.neonCyan.withValues(alpha: 0.15),
                    width: 1,
                  )
                : null,
          ),
          child: AnimatedScale(
            scale: _isHovered ? 1.05 : 1.0,
            duration: AppTheme.animFast,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.icon,
                  color: widget.isSelected
                      ? Colors.black
                      : Colors.white.withValues(alpha: 0.6),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.isSelected
                        ? Colors.black
                        : Colors.white.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroEventCard extends ConsumerWidget {
  final dynamic event;

  const _HeroEventCard({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 500;
        final cardHeight = isNarrow ? 400.0 : 430.0;
        final titleFontSize = isNarrow ? 36.0 : 46.0;
        final subtitleFontSize = isNarrow ? 11.0 : 15.0;
        final topSpacing = isNarrow ? 6.0 : 8.0;
        final midSpacing = isNarrow ? 8.0 : 10.0;
        final bottomSpacing = isNarrow ? 12.0 : 14.0;

        return Container(
          height: cardHeight,
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            image: const DecorationImage(
              image: NetworkImage(
                  'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800'),
              fit: BoxFit.cover,
              opacity: 0.15,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.8),
                ],
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      ShimmerEffect(
                        duration: const Duration(milliseconds: 2500),
                        baseColor: const Color(0x55FFFFFF),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withValues(alpha: 0.4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Text(
                            'LIVE NOW',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          event.league.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Spacer(),
                      // AI Insight Trigger (Pulsing Badge)
                      AiBadge(onTap: () => _showAiInsights(context)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Match Title with Team Avatars
                  Row(
                    children: [
                      TeamBranding.buildTeamAvatar(event.homeTeam.name,
                          size: isNarrow ? 40 : 48),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          event.homeTeam.name,
                          style: GoogleFonts.outfit(
                            fontSize: titleFontSize * 0.65,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.1,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text('  VS  ',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      TeamBranding.buildTeamAvatar(event.awayTeam.name,
                          size: isNarrow ? 40 : 48),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          event.awayTeam.name,
                          style: GoogleFonts.outfit(
                            fontSize: titleFontSize * 0.65,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.1,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TeamBranding.buildLeagueBadge(event.league),
                    ],
                  ),

                  SizedBox(height: topSpacing),

                  Flexible(
                    child: Text(
                      'Highest odds guaranteed on the\ndecentralized network.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: subtitleFontSize,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  SizedBox(height: midSpacing),

                  // Odds Row
                  Row(
                    children: [
                      Expanded(
                        child: _OddsBox(
                          label: 'HOME',
                          odd: event.odds.homeWin,
                          onTap: () => ref
                              .read(betSlipControllerProvider.notifier)
                              .addBet(
                                event,
                                'Home',
                                event.homeTeam.name,
                                event.odds.homeWin,
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _OddsBox(
                          label: 'DRAW',
                          odd: event.odds.draw,
                          onTap: () => ref
                              .read(betSlipControllerProvider.notifier)
                              .addBet(
                                event,
                                'Draw',
                                'Draw',
                                event.odds.draw,
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _OddsBox(
                          label: 'AWAY',
                          odd: event.odds.awayWin,
                          onTap: () => ref
                              .read(betSlipControllerProvider.notifier)
                              .addBet(
                                event,
                                'Away',
                                event.awayTeam.name,
                                event.odds.awayWin,
                              ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: bottomSpacing),

                  ElevatedButton(
                    onPressed: () => _showAiInsights(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B00),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'AI Probability Deep Dive',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(width: 12),
                        Icon(Icons.query_stats, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAiInsights(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AiInsightsPanel(event: event),
    );
  }
}

class _OddsBox extends StatelessWidget {
  final String label;
  final double odd;
  final VoidCallback onTap;

  const _OddsBox({
    required this.label,
    required this.odd,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              odd.toStringAsFixed(2),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveMatchCard extends ConsumerWidget {
  final Event event;

  const _LiveMatchCard({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isValue = event.isValueBet;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isValue
              ? [
                  const Color(0xFF1A2332),
                  const Color(0xFF162218),
                ]
              : [
                  const Color(0xFF1E2028),
                  const Color(0xFF16171C),
                ],
        ),
        border: Border.all(
          color: isValue
              ? AppTheme.gainrGreen.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.06),
          width: 1,
        ),
        boxShadow: [
          if (isValue)
            BoxShadow(
              color: AppTheme.gainrGreen.withValues(alpha: 0.08),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Subtle top gradient accent
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 3,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isValue
                        ? [
                            AppTheme.gainrGreen.withValues(alpha: 0.6),
                            AppTheme.gainrGreen.withValues(alpha: 0.1),
                          ]
                        : [
                            const Color(0xFF6C5CE7).withValues(alpha: 0.4),
                            Colors.transparent,
                          ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // League Header
                  Row(
                    children: [
                      // Live dot
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withValues(alpha: 0.15),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          event.league.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.45),
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isValue)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.gainrGreen.withValues(alpha: 0.2),
                                AppTheme.gainrGreen.withValues(alpha: 0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color:
                                    AppTheme.gainrGreen.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: AppTheme.gainrGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '+${event.aiEdge.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  color: AppTheme.gainrGreen,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => _showAiInsights(context),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            size: 12,
                            color: AppTheme.gainrGreen,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Match Display — Teams Face-off
                  Expanded(
                    child: Row(
                      children: [
                        // Home Team
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TeamBranding.buildTeamAvatar(event.homeTeam.name,
                                  size: 36),
                              const SizedBox(height: 6),
                              Text(
                                event.homeTeam.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // Score / VS
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (event.homeTeam.score != null)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      event.homeTeam.score ?? '0',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      child: Text(
                                        ':',
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.3),
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      event.awayTeam.score ?? '0',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Text(
                                  'VS',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2,
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'LIVE',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 7,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Away Team
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TeamBranding.buildTeamAvatar(event.awayTeam.name,
                                  size: 36),
                              const SizedBox(height: 6),
                              Text(
                                event.awayTeam.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Odds Strip
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        _SmallOdd(
                          label: '1',
                          odd: event.odds.homeWin,
                          isHighlighted: isValue,
                          onTap: () => ref
                              .read(betSlipControllerProvider.notifier)
                              .addBet(
                                event,
                                'Home',
                                event.homeTeam.name,
                                event.odds.homeWin,
                              ),
                        ),
                        Container(
                          width: 1,
                          height: 20,
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                        _SmallOdd(
                          label: 'X',
                          odd: event.odds.draw,
                          onTap: () => ref
                              .read(betSlipControllerProvider.notifier)
                              .addBet(
                                event,
                                'Draw',
                                'Draw',
                                event.odds.draw,
                              ),
                        ),
                        Container(
                          width: 1,
                          height: 20,
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                        _SmallOdd(
                          label: '2',
                          odd: event.odds.awayWin,
                          onTap: () => ref
                              .read(betSlipControllerProvider.notifier)
                              .addBet(
                                event,
                                'Away',
                                event.awayTeam.name,
                                event.odds.awayWin,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAiInsights(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AiInsightsPanel(event: event),
    );
  }
}

class _SmallOdd extends StatelessWidget {
  final String label;
  final double odd;
  final bool isHighlighted;
  final VoidCallback onTap;

  const _SmallOdd({
    required this.label,
    required this.odd,
    required this.onTap,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                odd.toStringAsFixed(2),
                style: TextStyle(
                  color: isHighlighted
                      ? AppTheme.gainrGreen
                      : Colors.white.withValues(alpha: 0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// _UpcomingEventCard — a premium card for non-live (upcoming) events
// ══════════════════════════════════════════════════════════════════════
class _UpcomingEventCard extends ConsumerWidget {
  final Event event;
  const _UpcomingEventCard({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isValue = event.isValueBet;
    final kickoff = TimeOfDay.fromDateTime(event.startTime);
    final kickoffStr =
        '${kickoff.hour.toString().padLeft(2, '0')}:${kickoff.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isValue
              ? [
                  const Color(0xFF1E2633),
                  const Color(0xFF141D16),
                ]
              : [
                  const Color(0xFF1E1F26),
                  const Color(0xFF14151A),
                ],
        ),
        border: Border.all(
          color: isValue
              ? AppTheme.gainrGreen.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.06),
          width: 1,
        ),
        boxShadow: [
          if (isValue)
            BoxShadow(
              color: AppTheme.gainrGreen.withValues(alpha: 0.05),
              blurRadius: 12,
              spreadRadius: 0,
            ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showAiInsights(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        _getSportIcon(event.sport),
                        size: 12,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event.league.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isValue) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.gainrGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppTheme.gainrGreen.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.auto_awesome,
                                size: 10, color: AppTheme.gainrGreen),
                            const SizedBox(width: 4),
                            Text(
                              '+${event.aiEdge.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                color: AppTheme.gainrGreen,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 10,
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            kickoffStr,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Teams
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          TeamBranding.buildTeamAvatar(event.homeTeam.name,
                              size: 32),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              event.homeTeam.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'VS',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.2),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              event.awayTeam.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                            ),
                          ),
                          const SizedBox(width: 10),
                          TeamBranding.buildTeamAvatar(event.awayTeam.name,
                              size: 32),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Odds Strip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.04),
                    ),
                  ),
                  child: Row(
                    children: [
                      _UpcomingOdd(
                        label: '1',
                        odd: event.odds.homeWin,
                        isHighlighted: isValue,
                        onTap: () => ref
                            .read(betSlipControllerProvider.notifier)
                            .addBet(event, 'Home', event.homeTeam.name,
                                event.odds.homeWin),
                      ),
                      _buildDivider(),
                      if (event.odds.draw > 0) ...[
                        _UpcomingOdd(
                          label: 'X',
                          odd: event.odds.draw,
                          onTap: () => ref
                              .read(betSlipControllerProvider.notifier)
                              .addBet(event, 'Draw', 'Draw', event.odds.draw),
                        ),
                        _buildDivider(),
                      ],
                      _UpcomingOdd(
                        label: '2',
                        odd: event.odds.awayWin,
                        onTap: () => ref
                            .read(betSlipControllerProvider.notifier)
                            .addBet(event, 'Away', event.awayTeam.name,
                                event.odds.awayWin),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Colors.white.withValues(alpha: 0.06),
    );
  }

  void _showAiInsights(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AiInsightsPanel(event: event),
    );
  }

  IconData _getSportIcon(String sport) {
    switch (sport.toLowerCase()) {
      case 'football':
        return Icons.sports_football;
      case 'basketball':
        return Icons.sports_basketball;
      case 'soccer':
        return Icons.sports_soccer;
      case 'tennis':
        return Icons.sports_tennis;
      case 'cricket':
        return Icons.sports_cricket;
      case 'horse racing':
        return Icons.stadium;
      default:
        return Icons.sports;
    }
  }
}

class _UpcomingOdd extends StatelessWidget {
  final String label;
  final double odd;
  final VoidCallback onTap;
  final bool isHighlighted;

  const _UpcomingOdd({
    required this.label,
    required this.odd,
    required this.onTap,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  odd.toStringAsFixed(2),
                  style: TextStyle(
                    color: isHighlighted
                        ? AppTheme.gainrGreen
                        : Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

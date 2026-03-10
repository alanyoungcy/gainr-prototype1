import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'package:gainr_models/gainr_models.dart';
/// ChatGPT-style AI assistant for betting insights
class AiChatPanel extends StatefulWidget {
  final Event? event;

  const AiChatPanel({super.key, this.event});

  @override
  State<AiChatPanel> createState() => _AiChatPanelState();
}

class _AiChatPanelState extends State<AiChatPanel> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    final greeting = event != null
        ? 'Hi! I\'m GAINR AI 🤖. I\'ve analyzed ${event.homeTeam.name} vs ${event.awayTeam.name}. Ask me about value bets, predictions, or risk management.'
        : 'Hi! I\'m GAINR AI 🤖. Ask me about value bets, predictions, risk management, or odds analysis.';

    _messages.add(_ChatMessage(
      text: greeting,
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty || _isTyping) return;

    setState(() {
      _messages.add(_ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    final delay = 1000 + Random().nextInt(1500);
    Timer(Duration(milliseconds: delay), () {
      if (!mounted) return;
      final response = _getAiResponse(text);
      setState(() {
        _messages.add(_ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isTyping = false;
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getAiResponse(String query) {
    final lower = query.toLowerCase();
    final event = widget.event;
    final home = event?.homeTeam.name ?? 'the home team';
    final away = event?.awayTeam.name ?? 'the away team';
    final edge = event?.aiEdge.toStringAsFixed(1) ?? '6.2';

    if (lower.contains('value') || lower.contains('edge')) {
      final isValue = event?.isValueBet ?? false;
      final fairOdds = 1 /
          (event?.fairProbabilities[event.kellyStake > 0 ? 'home' : 'away'] ??
              0.5);

      return '📊 **Value Bet Analysis**\n\n'
          '${isValue ? "✅ **YES**" : "❌ **NO**"} - This ${isValue ? "is" : "is not"} a value bet.\n\n'
          '• **Calculated Edge**: +$edge%\n'
          '• **Fair Odds**: ${fairOdds.toStringAsFixed(2)}\n'
          '• **Implied Probability Gap**: ${(event?.aiEdge ?? 0.0).toStringAsFixed(1)}%\n\n'
          '${isValue ? "The market is underpricing this outcome based on our Poisson model." : "The current lines are efficient. No significant edge detected."}';
    }

    if (lower.contains('risk') ||
        lower.contains('bankroll') ||
        lower.contains('money')) {
      final stake = (event?.kellyStake ?? 0) * 100;
      final stakeAmount = stake * 1000; // Assuming $1000 bankroll

      return '💰 **Bankroll Management (Kelly Criterion)**\n\n'
          'Based on a +$edge% edge, the fractional Kelly recommendation is:\n\n'
          '• **Optimal Stake**: ${stake.toStringAsFixed(1)}% of bankroll\n'
          '• **Amount**: \$${stakeAmount.toStringAsFixed(0)} (based on \$1k balance)\n'
          '• **Risk Level**: ${stake > 2.0 ? "Aggressive" : "Conservative"}\n\n'
          '${stake > 0 ? "⚡ confidence is high. A position is warranted." : "⚠️ No edge detected. Recommended stake is 0%."}';
    }

    if (lower.contains('predict') ||
        lower.contains('win') ||
        lower.contains('who')) {
      final fair = event?.fairProbabilities ??
          {'home': 0.33, 'draw': 0.33, 'away': 0.33};
      final homeProb = (fair['home']! * 100).toStringAsFixed(0);
      final awayProb = (fair['away']! * 100).toStringAsFixed(0);

      String prediction = "Too close to call";
      if (fair['home']! > 0.55) prediction = "$home to Win";
      if (fair['away']! > 0.55) prediction = "$away to Win";

      return '🎯 **Model Prediction**\n\n'
          '**$prediction**\n\n'
          '• **$home Win**: $homeProb% probability\n'
          '• **$away Win**: $awayProb% probability\n'
          '• **Expected Goals**: ${event?.expectedGoalsHome} - ${event?.expectedGoalsAway}\n\n'
          '⚠️ ${event?.sentiment == MarketSentiment.bearish ? "Warning: Market sentiment is bearish on this outcome." : "Market sentiment aligns with this prediction."}';
    }

    if (lower.contains('odds') ||
        lower.contains('line') ||
        lower.contains('market')) {
      return '📈 **Odds Analysis**\n\n'
          'Current market efficiency for $home vs $away:\n\n'
          '• **Home**: ${event?.odds.homeWin}\n'
          '• **Away**: ${event?.odds.awayWin}\n'
          '${event?.marketType == MarketType.threeWay ? "• **Draw**: ${event?.odds.draw}" : ""}\n\n'
          '🔍 Market Sentiment: **${event?.sentiment.name.toUpperCase()}**';
    }

    if (lower.contains('hello') ||
        lower.contains('hi') ||
        lower.contains('hey')) {
      final prob = event?.fairProbabilities['home'] ?? 0.0;
      return '👋 Hi! I\'m GAINR AI. I run a Poisson simulation on every match.\n\n'
          'Match: $home vs $away\n'
          'My Edge: +$edge%\n'
          'My Prediction: ${prob > 0.5 ? home : away}\n\n'
          'Ask me about **Expected Goals (xG)**, **Kelly Stake**, or **Fair Odds**.';
    }

    if (lower.contains('thank')) {
      return '🙏 You\'re welcome! Trade responsibly. Remember, my models are probabilistic, not prophetic.';
    }

    return '🤖 I can analyze the verified probability data for this event.\n\n'
        'Try asking:\n'
        '• "Is there an edge?"\n'
        '• "What is the xG?"\n'
        '• "What is the Kelly stake?"\n'
        '• "Show me fair odds"';
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1B23).withValues(alpha: 0.92),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: AppTheme.neonCyan.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.neonCyan.withValues(alpha: 0.05),
                blurRadius: 30,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle bar with glow
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.neonCyan.withValues(alpha: 0.3),
                        AppTheme.gainrGreen.withValues(alpha: 0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GlowPulse(
                      glowColor: AppTheme.gainrGreen,
                      glowRadius: 12,
                      child: AnimatedGradientBorder(
                        borderWidth: 1.5,
                        borderRadius: 10,
                        colors: const [
                          AppTheme.gainrGreen,
                          AppTheme.neonCyan,
                          AppTheme.gainrGreen,
                        ],
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.gainrGreen, Color(0xFF00B894)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text('🤖', style: TextStyle(fontSize: 18)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          NeonText(
                            text: 'GAINR AI',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            glowColor: AppTheme.gainrGreen,
                            glowRadius: 6,
                          ),
                          Row(
                            children: [
                              GlowPulse(
                                glowColor: AppTheme.gainrGreen,
                                glowRadius: 6,
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.gainrGreen,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Online • System 2 Logic',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close,
                          color: Colors.white.withValues(alpha: 0.4), size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Gradient divider
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppTheme.neonCyan.withValues(alpha: 0.15),
                      AppTheme.gainrGreen.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // Messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isTyping) {
                      return _TypingIndicator();
                    }
                    return _MessageBubble(message: _messages[index]);
                  },
                ),
              ),

              // Input with glassmorphism
              ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      border: Border(
                          top: BorderSide(
                              color:
                                  AppTheme.neonCyan.withValues(alpha: 0.08))),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Ask GAINR AI...',
                                hintStyle: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  fontSize: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppTheme.neonCyan
                                        .withValues(alpha: 0.1),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppTheme.neonCyan
                                        .withValues(alpha: 0.08),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppTheme.neonCyan
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.05),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GlowPulse(
                            glowColor: AppTheme.gainrGreen,
                            glowRadius: 8,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppTheme.gainrGreen,
                                    Color(0xFF00B894)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.gainrGreen
                                        .withValues(alpha: 0.3),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.send_rounded,
                                    color: Colors.black, size: 20),
                                onPressed: _sendMessage,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Message Model ──────────────────────────────────────────────────

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  _ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

// ─── Message Bubble ─────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.gainrGreen, Color(0xFF00B894)],
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.gainrGreen.withValues(alpha: 0.2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Center(
                child: Text('🤖', style: TextStyle(fontSize: 14)),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppTheme.neonCyan.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 16),
                ),
                border: Border.all(
                  color: message.isUser
                      ? AppTheme.neonCyan.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.05),
                ),
                boxShadow: message.isUser
                    ? [
                        BoxShadow(
                          color: AppTheme.neonCyan.withValues(alpha: 0.05),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (message.isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

// ─── Typing Indicator ───────────────────────────────────────────────

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _dotControllers;

  @override
  void initState() {
    super.initState();
    _dotControllers = List.generate(3, (i) {
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) controller.repeat(reverse: true);
      });
      return controller;
    });
  }

  @override
  void dispose() {
    for (final c in _dotControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.gainrGreen, Color(0xFF00B894)],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.gainrGreen.withValues(alpha: 0.2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: const Center(
              child: Text('🤖', style: TextStyle(fontSize: 14)),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _dotControllers[i],
                  builder: (context, child) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.neonCyan.withValues(
                                alpha: 0.3 + _dotControllers[i].value * 0.7),
                            AppTheme.gainrGreen.withValues(
                                alpha: 0.3 + _dotControllers[i].value * 0.7),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.neonCyan.withValues(
                                alpha: _dotControllers[i].value * 0.3),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}


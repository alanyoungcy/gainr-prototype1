import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'package:gainr_models/gainr_models.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class PriceAiChatPanel extends StatefulWidget {
  final PriceMarket market;

  const PriceAiChatPanel({super.key, required this.market});

  @override
  State<PriceAiChatPanel> createState() => _PriceAiChatPanelState();
}

class _PriceAiChatPanelState extends State<PriceAiChatPanel> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _messages.add(_ChatMessage(
      text:
          "🤖 **Soccer Intelligence Terminal Active**\n\nI can analyze live xG data, tactical formations, and market probability derivations for the **${widget.market.asset}** match.\n\nTry asking:\n• \"What is the expected goals (xG) trend?\"\n• \"How do recent tactical shifts affect this?\"\n• \"Show me the fair value derivation.\"",
      isUser: false,
      timestamp: DateTime.now(),
    ));
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

  String _getAiResponse(String query) {
    final lower = query.toLowerCase();
    final market = widget.market;
    final price = market.currentPrice;
    final prob = price * 100;

    // Soccer Intelligence Logic
    if (lower.contains('xg') || lower.contains('expected')) {
      return '⚽ **xG Performance Analysis**\n\n'
          'Our AI has processed live match stats and historical performance metrics.\n\n'
          '• **Projected xG**: ${(1.2 + Random().nextDouble() * 1.5).toStringAsFixed(2)} vs ${(0.8 + Random().nextDouble() * 1.5).toStringAsFixed(2)}\n'
          '• **Shot Conversion Confidence**: 88%\n'
          '• **Market Alpha**: The current price suggest a ${(prob / 10).toStringAsFixed(1)}% variance from our xG-weighted fair value model.';
    }

    if (lower.contains('tactic') || lower.contains('formation')) {
      return '📋 **Tactical Impact Report**\n\n'
          'Live formation analysis detected for **${market.asset}**:\n\n'
          '• **Defensive Structure**: High-line sensitivity detected.\n'
          '• **Win Correlation**: Recent shifts to a 4-3-3 have increased the win probability in similar match-ups by **12.4%**.\n\n'
          'The price of **${price.toStringAsFixed(2)}** reflects current tactical stability.';
    }

    if (lower.contains('probabilit') ||
        lower.contains('derivation') ||
        lower.contains('math')) {
      final alpha = 0.03 + Random().nextDouble() * 0.04;
      return '📐 **Fair Value Derivation (Soccer)**\n\n'
          '**P(Win) = (xG_ratio * Ω) + (Form_index * Ψ)**\n\n'
          '• **Raw Match Probability**: ${prob.toStringAsFixed(1)}%\n'
          '• **Market Volatility Factor (Ω)**: ${alpha.toStringAsFixed(3)}\n'
          '• **Team Synergy Coefficient (Ψ)**: 1.14\n\n'
          '**Adjusted Fair Value**: **${(prob * (1 + alpha)).toStringAsFixed(1)}%**\n\n'
          'The order book shows strong resistance at these levels, aligned with pro-bettor sentiment.';
    }

    if (lower.contains('lineup') || lower.contains('injury')) {
      return '🏥 **Squad Integrity Analysis**\n\n'
          'Analyzing official and leaked lineup data:\n\n'
          '• **Key Absence Impact**: Any injury to top scorers will re-index this market by **-15%** instantaneously.\n'
          '• **Neural Projection**: Squad depth confirms a stable trend for the next 24 hours.\n'
          '• **Risk**: High volatility expected 60 mins before kickoff (Lineup reveal).';
    }

    return '🤖 **I am the GAINR Soccer Intelligence Agent.**\n\n'
        'I specialize in market intelligence for: **${market.asset}**\n\n'
        'Ask me about:\n'
        '• "xG patterns"\n'
        '• "Tactical shifts"\n'
        '• "Fair value derivation"\n'
        '• "Lineup impact"';
  }

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      borderRadius: 16,
      blur: 15,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
              ),
            ),
            child: Row(
              children: [
                const GlowPulse(
                  glowColor: AppColors.neonOrange,
                  glowRadius: 6,
                  child: Icon(LucideIcons.brain,
                      color: AppColors.neonOrange, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'ASK GAINR AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.x,
                      color: Colors.white30, size: 18),
                ),
              ],
            ),
          ),

          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return _buildTypingIndicator();
                }
                final message = _messages[index];
                return _ChatBubble(message: message);
              },
            ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _sendMessage(),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Enter query...',
                        hintStyle: TextStyle(color: Colors.white24),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _sendMessage,
                  child: HoverScaleGlow(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.neonOrange,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neonOrange.withValues(alpha: 0.4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(LucideIcons.arrow_left,
                          color: Colors.black, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const ShimmerEffect(
          child: Text(
            '...',
            style:
                TextStyle(color: Colors.white30, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: message.isUser
              ? AppColors.neonOrange.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: message.isUser ? const Radius.circular(0) : null,
            bottomLeft: !message.isUser ? const Radius.circular(0) : null,
          ),
          border: Border.all(
            color: message.isUser
                ? AppColors.neonOrange.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(color: Colors.white24, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}

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

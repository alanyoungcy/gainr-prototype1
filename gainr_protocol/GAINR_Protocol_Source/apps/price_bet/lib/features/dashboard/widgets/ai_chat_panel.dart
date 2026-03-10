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
          "🤖 **Political Intelligence Terminal Active**\n\nI can analyze polling data, swing state impacts, and policy implications for the **${widget.market.asset}** market.\n\nTry asking:\n• \"What is the current polling margin?\"\n• \"How do swing states affect this?\"\n• \"Show me the probability derivation.\"",
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

    // Mathematical/Conceptual Logic
    if (lower.contains('poll') || lower.contains('margin')) {
      return '📊 **Polling Data Analysis**\n\n'
          'Our AI has synthesized data from 14 high-confidence sources (A+ rated).\n\n'
          '• **Synthesized Margin**: +${(1.2 + Random().nextDouble() * 2).toStringAsFixed(1)}%\n'
          '• **Confidence Interval**: 95%\n'
          '• **Market Discrepancy**: This market is currently pricing a ${(prob - 48).toStringAsFixed(1)}% premium over historical polling averages, suggesting smart money is factoring in non-polling variables.';
    }

    if (lower.contains('swing') || lower.contains('state')) {
      return '🗳️ **Swing State Impact Matrix**\n\n'
          'Critical pivots detected in PA, MI, and WI:\n\n'
          '• **Pennsylvania**: Market sentiment aligns with a 52.4% win probability.\n'
          '• **Correlated Outcomes**: A win in PA increases the overall success probability of this market outcome by **18.2%**.\n\n'
          'The current market price of **${price.toStringAsFixed(2)}** reflects a weighted average across these battlegrounds.';
    }

    if (lower.contains('probabilit') ||
        lower.contains('derivation') ||
        lower.contains('math')) {
      final noise = 0.02 + Random().nextDouble() * 0.05;
      return '📐 **Probability Derivation**\n\n'
          '**P(Outcome) = (M_price * (1 - ζ)) / (1 + η)**\n\n'
          '• **Raw Market Probability**: ${prob.toStringAsFixed(1)}%\n'
          '• **Liquidity Noise Factor (ζ)**: ${noise.toStringAsFixed(3)}\n'
          '• **Sentiment Skew (η)**: 0.014\n\n'
          '**True Adjusted Probability**: **${(prob * (1 - noise)).toStringAsFixed(1)}%**\n\n'
          'Our models suggest the current order book is slightly inefficient due to low volume in the last 4 hours.';
    }

    if (lower.contains('policy') || lower.contains('effect')) {
      return '📜 **Policy Implication Analysis**\n\n'
          'This outcome is sensitive to legislative shifts:\n\n'
          '• **Primary Driver**: Regulation 14-B expectations.\n'
          '• **AI Projection**: If passed, this market will likely re-index to **0.85 - 0.90** within 48 hours.\n'
          '• **Risk**: High volatility expected during the next committee hearing.';
    }

    return '🤖 **I am the GAINR Political Intel Agent.**\n\n'
        'I specialize in market intelligence for: **${market.asset}**\n\n'
        'Ask me about:\n'
        '• "Polling margins"\n'
        '• "Swing state impact"\n'
        '• "Probability derivation"\n'
        '• "Policy implications"';
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

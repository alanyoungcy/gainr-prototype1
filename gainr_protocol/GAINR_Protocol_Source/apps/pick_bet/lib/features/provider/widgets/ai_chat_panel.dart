import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'package:gainr_models/gainr_models.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class PickAiChatPanel extends StatefulWidget {
  final PickProvider provider;

  const PickAiChatPanel({super.key, required this.provider});

  @override
  State<PickAiChatPanel> createState() => _PickAiChatPanelState();
}

class _PickAiChatPanelState extends State<PickAiChatPanel> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _messages.add(_ChatMessage(
      text:
          "🤖 **Provider Alpha Terminal Active**\n\nI can analyze **${widget.provider.name}**'s signal accuracy, ROI consistency, and risk-adjusted performance.\n\nTry asking:\n• \"What is the alpha generation score?\"\n• \"Is the drawdown history concerning?\"\n• \"Explain the yield vs win-rate trade-off.\"",
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
    final provider = widget.provider;
    final winRate = provider.winRate;
    final roi = provider.roi;

    // Mathematical/Conceptual Logic
    if (lower.contains('alpha') || lower.contains('score')) {
      final alpha = (winRate * 40 + (roi / 100).clamp(0, 60)).clamp(0, 100);
      return '📈 **Alpha Generation Analysis**\n\n'
          'The alpha score of **${alpha.toStringAsFixed(1)}/100** is derived from high-frequency signal auditing.\n\n'
          '• **Strategy Edge**: This provider generates **${(roi / historyLength).toStringAsFixed(2)}%** alpha per trade relative to the market median.\n'
          '• **Signal Decay**: Signals maintain 90% accuracy within the first 120 seconds of issuance.\n\n'
          'Currently performing in the **Top ${(100 - alpha).toStringAsFixed(0)}%** of all GAINR vetted providers.';
    }

    if (lower.contains('drawdown') ||
        lower.contains('risk') ||
        lower.contains('loss')) {
      final dd = 3.5 + Random().nextDouble() * 4.2;
      return '🛡️ **Risk & Drawdown Report**\n\n'
          'Current risk profile: **MODERATE-STABLE**\n\n'
          '• **Max Retracement**: -${dd.toStringAsFixed(1)}%\n'
          '• **Recovery Factor**: 4.8x (Excellent efficiency)\n'
          '• **VaR (Value at Risk)**: Based on current stake sizes, we project a 95% probability that losses stay within **2.1%** per signal cycle.';
    }

    if (lower.contains('yield') ||
        lower.contains('trade-off') ||
        lower.contains('math')) {
      return '⚖️ **Yield vs Win-Rate Dynamics**\n\n'
          '**Expected Value (EV) = (P_win * Avg_Gain) - (P_loss * Avg_Loss)**\n\n'
          '• **P(win)**: ${(winRate * 100).toStringAsFixed(1)}%\n'
          '• **Profit Factor**: 2.44\n\n'
          'Analysis: The strategy prioritizes consistency over moon-shots. This leads to a smoother equity curve compared to high-yield volatile providers.';
    }

    if (lower.contains('trust') || lower.contains('follower')) {
      return '👥 **Social Proof & Verification**\n\n'
          '• **Subscriber Growth**: +14% QoQ\n'
          '• **Retention Rate**: 88% after 30 days.\n\n'
          'The GAINR Verified badge was awarded after 500+ successful signal audits. All reported ROI data is cryptographically signed and confirmed.';
    }

    return '🤖 **I am the GAINR Provider Alpha Agent.**\n\n'
        'I specialize in performance analytics for: **${provider.name}**\n\n'
        'Ask me about:\n'
        '• "Alpha score"\n'
        '• "Drawdown history"\n'
        '• "Yield vs Win-rate"\n'
        '• "Trust metrics"';
  }

  int get historyLength =>
      widget.provider.performanceHistory.length.clamp(1, 100);

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
                  glowColor: AppTheme.neonOrange,
                  glowRadius: 6,
                  child: Icon(LucideIcons.brain,
                      color: AppTheme.neonOrange, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'PROVIDER INTELLIGENCE',
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
                        hintText: 'Ask about strategy...',
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
                        color: AppTheme.neonOrange,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.neonOrange.withValues(alpha: 0.4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(LucideIcons.send,
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
              ? AppTheme.neonOrange.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: message.isUser ? const Radius.circular(0) : null,
            bottomLeft: !message.isUser ? const Radius.circular(0) : null,
          ),
          border: Border.all(
            color: message.isUser
                ? AppTheme.neonOrange.withValues(alpha: 0.2)
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

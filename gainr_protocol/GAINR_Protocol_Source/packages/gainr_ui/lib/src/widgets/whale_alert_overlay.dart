import 'package:flutter/material.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'package:gainr_models/gainr_models.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class WhaleAlertOverlay extends StatefulWidget {
  final WhaleAlert alert;
  final VoidCallback onDismiss;

  const WhaleAlertOverlay({
    super.key,
    required this.alert,
    required this.onDismiss,
  });

  @override
  State<WhaleAlertOverlay> createState() => _WhaleAlertOverlayState();
}

class _WhaleAlertOverlayState extends State<WhaleAlertOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(-1.5, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _controller.forward();

    // Auto-dismiss after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLong = widget.alert.type == 'LONG';

    return SlideTransition(
      position: _offsetAnimation,
      child: Container(
        width: 300,
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(
            color: isLong ? Colors.green : Colors.red,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color:
                  (isLong ? Colors.green : Colors.red).withValues(alpha: 0.2),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.frown,
                    color: AppTheme.neonOrange,
                    size:
                        16), // Use a whale icon if available, using frown as placeholder
                const SizedBox(width: 8),
                Text(
                  'WHALE_ALERT_DETECTED',
                  style: TextStyle(
                    color: (isLong ? Colors.green : Colors.red),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                Text(
                  '${widget.alert.timestamp.hour}:${widget.alert.timestamp.minute}',
                  style: const TextStyle(color: Colors.white24, fontSize: 10),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${widget.alert.amount} ${widget.alert.asset}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'POSITION_TYPE: ${widget.alert.type}_EXECUTION',
              style: TextStyle(
                color: isLong
                    ? Colors.green.withValues(alpha: 0.7)
                    : Colors.red.withValues(alpha: 0.7),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: 1.0, // This could animate down for auto-dismiss
              backgroundColor: Colors.white10,
              color:
                  (isLong ? Colors.green : Colors.red).withValues(alpha: 0.3),
              minHeight: 2,
            ),
          ],
        ),
      ),
    );
  }
}

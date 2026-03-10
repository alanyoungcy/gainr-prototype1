import 'package:flutter/material.dart';
import 'dart:async';
import 'package:gainr_ui/gainr_ui.dart';

class TerminalBridgeButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;

  const TerminalBridgeButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  @override
  State<TerminalBridgeButton> createState() => _TerminalBridgeButtonState();
}

class _TerminalBridgeButtonState extends State<TerminalBridgeButton>
    with SingleTickerProviderStateMixin {
  bool _isConnecting = false;
  double _progress = 0.0;
  Timer? _timer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _handlePress() {
    if (_isConnecting) return;

    setState(() {
      _isConnecting = true;
      _progress = 0.0;
    });

    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _progress += 0.02;
        if (_progress >= 1.0) {
          _progress = 1.0;
          timer.cancel();
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() {
                _isConnecting = false;
              });
              widget.onPressed?.call();
            }
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _handlePress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          height: 50,
          decoration: BoxDecoration(
            color: _isConnecting
                ? Colors.white.withValues(alpha: 0.05)
                : AppTheme.neonOrange,
            border: Border.all(
              color: _isConnecting ? AppTheme.neonOrange : Colors.transparent,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              if (!_isConnecting)
                BoxShadow(
                  color: AppTheme.neonOrange.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: Stack(
            children: [
              if (_isConnecting)
                Positioned.fill(
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _progress,
                    child: Container(
                      color: AppTheme.neonOrange.withValues(alpha: 0.1),
                    ),
                  ),
                ),
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isConnecting) ...[
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.neonOrange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'BR_ESTABLISHING [${(_progress * 100).toInt()}%]...',
                          style: const TextStyle(
                            color: AppTheme.neonOrange,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ] else ...[
                        const Icon(Icons.bolt, color: Colors.black, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          widget.label,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ],
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

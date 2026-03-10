import 'dart:math';
import 'package:flutter/material.dart';

/// ─── Screen Shake ──────────────────────────────────────────────────────────
/// Shakes the child widget horizontally when [trigger] changes.
class ScreenShake extends StatefulWidget {
  final Widget child;
  final dynamic trigger;
  final double intensity;
  final Duration duration;

  const ScreenShake({
    super.key,
    required this.child,
    required this.trigger,
    this.intensity = 8.0,
    this.duration = const Duration(milliseconds: 400),
  });

  @override
  State<ScreenShake> createState() => _ScreenShakeState();
}

class _ScreenShakeState extends State<ScreenShake>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didUpdateWidget(ScreenShake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trigger != widget.trigger) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final sineValue = sin(_controller.value * 4 * pi);
        return Transform.translate(
          offset:
              Offset(sineValue * widget.intensity * (1 - _controller.value), 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// ─── Action Glow ───────────────────────────────────────────────────────────
/// Flashes a glow around the child widget when [trigger] changes.
class ActionGlow extends StatefulWidget {
  final Widget child;
  final dynamic trigger;
  final Color glowColor;
  final Duration duration;

  const ActionGlow({
    super.key,
    required this.child,
    required this.trigger,
    this.glowColor = const Color(0xFF00E676),
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<ActionGlow> createState() => _ActionGlowState();
}

class _ActionGlowState extends State<ActionGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didUpdateWidget(ActionGlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trigger != widget.trigger) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = (1 - _controller.value);
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              if (_controller.isAnimating)
                BoxShadow(
                  color: widget.glowColor.withValues(alpha: 0.5 * opacity),
                  blurRadius: 20 * _controller.value,
                  spreadRadius: 10 * _controller.value,
                ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

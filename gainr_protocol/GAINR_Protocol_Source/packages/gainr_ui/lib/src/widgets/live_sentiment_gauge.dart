import 'package:flutter/material.dart';
import 'package:gainr_ui/gainr_ui.dart';
import 'dart:math' as math;

class LiveSentimentGauge extends StatelessWidget {
  final double value; // 0.0 to 1.0 (0 = Bearish, 1 = Bullish)
  final String assetName;

  const LiveSentimentGauge({
    super.key,
    required this.value,
    this.assetName = 'BTC/USDT',
  });

  @override
  Widget build(BuildContext context) {
    final isBullish = value >= 0.5;
    final color = Color.lerp(Colors.red, Colors.green, value) ?? Colors.grey;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('SENT_INTEL',
                  style: TextStyle(
                      color: Colors.white24,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1)),
              Expanded(
                child: Text(
                  assetName,
                  style: const TextStyle(
                      color: AppTheme.neonOrange,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 120,
            width: 120,
            child: Stack(
              children: [
                // Background Track
                CustomPaint(
                  size: const Size(120, 120),
                  painter: _GaugePainter(
                    value: 1.0,
                    color: Colors.white10,
                    thickness: 8,
                  ),
                ),
                // Active Value
                CustomPaint(
                  size: const Size(120, 120),
                  painter: _GaugePainter(
                    value: value,
                    color: color,
                    thickness: 10,
                    glow: true,
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${(value * 100).toInt()}',
                          style: TextStyle(
                              color: color,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace')),
                      Text(isBullish ? 'BULLISH' : 'BEARISH',
                          style: TextStyle(
                              color: color.withValues(alpha: 0.5),
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('BEAR',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
              Expanded(
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
              const Text('BULL',
                  style: TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double value;
  final Color color;
  final double thickness;
  final bool glow;

  _GaugePainter({
    required this.value,
    required this.color,
    this.thickness = 8,
    this.glow = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - thickness) / 2;
    const startAngle = -math.pi * 1.25;
    final sweepAngle = math.pi * 1.5 * value;

    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (glow) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..strokeWidth = thickness + 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
          startAngle, sweepAngle, false, glowPaint);
    }

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle,
        sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

// ─── Glassmorphic Container ────────────────────────────────────────────────
// Frosted glass effect with backdrop blur, translucent fill, and luminous border.
class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final double borderRadius;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.blur = 12.0,
    this.opacity = 0.06,
    this.borderRadius = 16.0,
    this.borderColor,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              color: Colors.white.withValues(alpha: opacity),
              border: Border.all(
                color: borderColor ?? Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: opacity * 1.5),
                  Colors.white.withValues(alpha: opacity * 0.5),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ─── Animated Gradient Border ──────────────────────────────────────────────
// Continuously rotating neon gradient border around a child widget.
class AnimatedGradientBorder extends StatefulWidget {
  final Widget child;
  final double borderWidth;
  final double borderRadius;
  final List<Color> colors;
  final Duration duration;

  const AnimatedGradientBorder({
    super.key,
    required this.child,
    this.borderWidth = 2.0,
    this.borderRadius = 16.0,
    this.colors = const [
      Color(0xFF00F0FF),
      Color(0xFF00E676),
      Color(0xFF6C5CE7),
      Color(0xFFFF006E),
      Color(0xFF00F0FF),
    ],
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<AnimatedGradientBorder> createState() => _AnimatedGradientBorderState();
}

class _AnimatedGradientBorderState extends State<AnimatedGradientBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
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
        return CustomPaint(
          painter: _GradientBorderPainter(
            progress: _controller.value,
            borderWidth: widget.borderWidth,
            borderRadius: widget.borderRadius,
            colors: widget.colors,
          ),
          child: Padding(
            padding: EdgeInsets.all(widget.borderWidth),
            child: widget.child,
          ),
        );
      },
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  final double progress;
  final double borderWidth;
  final double borderRadius;
  final List<Color> colors;

  _GradientBorderPainter({
    required this.progress,
    required this.borderWidth,
    required this.borderRadius,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      borderWidth / 2,
      borderWidth / 2,
      size.width - borderWidth,
      size.height - borderWidth,
    );
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: 2 * pi,
        colors: colors,
        transform: GradientRotation(progress * 2 * pi),
      ).createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_GradientBorderPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ─── Shimmer Effect ────────────────────────────────────────────────────────
// Luminous sweep animation that passes over a child widget.
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color baseColor;
  final Color? highlightColor;

  const ShimmerEffect({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 2000),
    this.baseColor = const Color(0x33FFFFFF),
    this.highlightColor,
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shimmerColor = widget.highlightColor ?? widget.baseColor;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            final slidePosition = _controller.value * 2 - 0.5;
            return LinearGradient(
              begin: Alignment(slidePosition - 0.3, -0.3),
              end: Alignment(slidePosition + 0.3, 0.3),
              colors: [
                Colors.transparent,
                shimmerColor,
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// ─── Glow Pulse ────────────────────────────────────────────────────────────
// Pulsating glow effect around a child widget.
class GlowPulse extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double glowRadius;
  final Duration duration;

  const GlowPulse({
    super.key,
    required this.child,
    this.glowColor = const Color(0xFF00E676),
    this.glowRadius = 12.0,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<GlowPulse> createState() => _GlowPulseState();
}

class _GlowPulseState extends State<GlowPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
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
        final value = Curves.easeInOut.transform(_controller.value);
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withValues(alpha: 0.3 + value * 0.4),
                blurRadius: widget.glowRadius * (0.5 + value * 0.5),
                spreadRadius: value * 2,
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

// ─── Floating Particles ───────────────────────────────────────────────────
// Canvas-painted ambient particles drifting across the background.
class FloatingParticles extends StatefulWidget {
  final int particleCount;
  final Color particleColor;
  final double maxSize;
  final double speed;

  const FloatingParticles({
    super.key,
    this.particleCount = 30,
    this.particleColor = const Color(0xFF00E676),
    this.maxSize = 3.0,
    this.speed = 0.3,
  });

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _particles =
        List.generate(widget.particleCount, (_) => _generateParticle());
  }

  _Particle _generateParticle() {
    return _Particle(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      size: _random.nextDouble() * widget.maxSize + 0.5,
      speedX: (_random.nextDouble() - 0.5) * widget.speed * 0.01,
      speedY: -_random.nextDouble() * widget.speed * 0.005 - 0.001,
      opacity: _random.nextDouble() * 0.5 + 0.1,
    );
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
      builder: (context, _) {
        for (var p in _particles) {
          p.x += p.speedX;
          p.y += p.speedY;
          if (p.y < -0.05 || p.x < -0.05 || p.x > 1.05) {
            p.x = _random.nextDouble();
            p.y = 1.05;
            p.opacity = _random.nextDouble() * 0.5 + 0.1;
          }
        }
        return CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            color: widget.particleColor,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Particle {
  double x, y, size, speedX, speedY, opacity;
  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speedX,
    required this.speedY,
    required this.opacity,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Color color;

  _ParticlePainter({required this.particles, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = color.withValues(alpha: p.opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size);
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ─── Staggered Fade Slide ──────────────────────────────────────────────────
// Index-based staggered entrance animation (fade + slide up).
class StaggeredFadeSlide extends StatelessWidget {
  final Widget child;
  final int index;
  final int baseDelayMs;
  final int staggerMs;

  const StaggeredFadeSlide({
    super.key,
    required this.child,
    required this.index,
    this.baseDelayMs = 200,
    this.staggerMs = 80,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: baseDelayMs + (index * staggerMs)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// ─── Hover Scale Glow ──────────────────────────────────────────────────────
// Mouse hover effect: scales up the child and adds a neon glow.
class HoverScaleGlow extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double scaleFactor;
  final double glowRadius;

  const HoverScaleGlow({
    super.key,
    required this.child,
    this.glowColor = const Color(0xFF00E676),
    this.scaleFactor = 1.03,
    this.glowRadius = 20.0,
  });

  @override
  State<HoverScaleGlow> createState() => _HoverScaleGlowState();
}

class _HoverScaleGlowState extends State<HoverScaleGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleFactor)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: widget.glowColor
                        .withValues(alpha: 0.15 * _glowAnimation.value),
                    blurRadius: widget.glowRadius * _glowAnimation.value,
                    spreadRadius: 2 * _glowAnimation.value,
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

// ─── Animated Gradient Shift ──────────────────────────────────────────────
// Continuously shifting gradient background for buttons.
class AnimatedGradientShift extends StatefulWidget {
  final Widget child;
  final List<Color> colors;
  final double borderRadius;
  final Duration duration;
  final EdgeInsetsGeometry? padding;
  final List<BoxShadow>? boxShadow;

  const AnimatedGradientShift({
    super.key,
    required this.child,
    this.colors = const [
      Color(0xFF6C5CE7),
      Color(0xFF00F0FF),
      Color(0xFFA29BFE),
      Color(0xFF6C5CE7),
    ],
    this.borderRadius = 12.0,
    this.duration = const Duration(seconds: 3),
    this.padding,
    this.boxShadow,
  });

  @override
  State<AnimatedGradientShift> createState() => _AnimatedGradientShiftState();
}

class _AnimatedGradientShiftState extends State<AnimatedGradientShift>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
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
        final shift = _controller.value * 2;
        return Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(shift - 1, -1),
              end: Alignment(shift, 1),
              colors: widget.colors,
              tileMode: TileMode.mirror,
            ),
            boxShadow: widget.boxShadow,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// ─── Neon Text ────────────────────────────────────────────────────────────
// Text with a colored drop shadow to simulate neon glow.
class NeonText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color glowColor;
  final double glowRadius;

  const NeonText({
    super.key,
    required this.text,
    required this.style,
    this.glowColor = const Color(0xFF00E676),
    this.glowRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(
        shadows: [
          Shadow(
              color: glowColor.withValues(alpha: 0.6), blurRadius: glowRadius),
          Shadow(
              color: glowColor.withValues(alpha: 0.3),
              blurRadius: glowRadius * 2),
        ],
      ),
    );
  }
}

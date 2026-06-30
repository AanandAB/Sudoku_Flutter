
import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiOverlay extends StatefulWidget {
  final bool show;

  const ConfettiOverlay({super.key, required this.show});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_ConfettiParticle> _particles = [];
  final Random _random = Random();

  static const _colors = [
    Color(0xFFFF6B6B), // coral
    Color(0xFF4ECDC4), // teal
    Color(0xFFFFE66D), // gold
    Color(0xFFA78BFA), // purple
    Color(0xFF5B6ABF), // indigo
    Color(0xFF4CAF50), // green
    Color(0xFFFF9800), // orange
    Color(0xFFE91E63), // pink
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    // Generate particles
    for (int i = 0; i < 120; i++) {
      _particles.add(_ConfettiParticle(
        x: _random.nextDouble(),
        color: _colors[_random.nextInt(_colors.length)],
        size: 6.0 + _random.nextDouble() * 8,
        speed: 0.6 + _random.nextDouble() * 0.8,
        sway: (_random.nextDouble() - 0.5) * 0.06,
        rotation: _random.nextDouble() * 2 * pi,
        rotationSpeed: (_random.nextDouble() - 0.5) * 0.15,
        shape: _random.nextInt(3), // 0=rect, 1=circle, 2=line
      ));
    }

    _controller.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(ConfettiOverlay old) {
    super.didUpdateWidget(old);
    if (widget.show && !old.show) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.show && !_controller.isAnimating) return const SizedBox.shrink();

    return IgnorePointer(
      child: SizedBox.expand(
        child: CustomPaint(
          painter: _ConfettiPainter(
            particles: _particles,
            progress: _controller.value,
          ),
        ),
      ),
    );
  }
}

class _ConfettiParticle {
  final double x;
  final Color color;
  final double size;
  final double speed;
  final double sway;
  final double rotation;
  final double rotationSpeed;
  final int shape;

  _ConfettiParticle({
    required this.x,
    required this.color,
    required this.size,
    required this.speed,
    required this.sway,
    required this.rotation,
    required this.rotationSpeed,
    required this.shape,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      // Eased progress: particles accelerate then slow
      final eased = Curves.easeOutCubic.transform(progress.clamp(0.0, 1.0));

      final x = size.width * p.x + sin(eased * 8 + p.x * 10) * size.width * p.sway * eased;
      final y = -20 + eased * (size.height + 40) * p.speed;
      final alpha = (1.0 - eased).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = p.color.withAlpha((255 * alpha).round())
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + p.rotationSpeed * eased * 30);

      switch (p.shape) {
        case 0: // rectangle
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
              const Radius.circular(2),
            ),
            paint,
          );
          break;
        case 1: // circle
          canvas.drawCircle(Offset.zero, p.size * 0.5, paint);
          break;
        case 2: // line
          paint.strokeWidth = 2;
          paint.style = PaintingStyle.stroke;
          canvas.drawLine(
            Offset(-p.size * 0.5, 0),
            Offset(p.size * 0.5, 0),
            paint,
          );
          break;
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.progress != progress;
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

class GlassmorphicBackground extends StatefulWidget {
  final Widget child;
  final bool showParticles;
  final bool showLogo;

  const GlassmorphicBackground({
    super.key,
    required this.child,
    this.showParticles = true,
    this.showLogo = true,
  });

  @override
  State<GlassmorphicBackground> createState() => _GlassmorphicBackgroundState();
}

class _GlassmorphicBackgroundState extends State<GlassmorphicBackground>
    with TickerProviderStateMixin {
  late final AnimationController _particleController;
  late final AnimationController _logoController;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _particleController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1a1a2e),
              const Color(0xFF16213e),
              const Color(0xFF0f0f23),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Partículas de fondo
            if (widget.showParticles)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _particleController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _ParticlesPainter(_particleController.value),
                    );
                  },
                ),
              ),

            // Logo flotante en esquina superior
            if (widget.showLogo)
              Positioned(
                top: 60,
                right: 40,
                child: Animate(
                  effects: [
                    FadeEffect(delay: 200.ms),
                    ScaleEffect(delay: 200.ms),
                  ],
                  child: AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 0.6 + (_logoController.value * 0.1),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF9C27B0).withOpacity(0.8),
                                const Color(0xFF00E5FF).withOpacity(0.8),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF9C27B0).withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.trending_up_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

            // Contenido principal
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: widget.child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParticlesPainter extends CustomPainter {
  final double animationValue;
  _ParticlesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..blendMode = BlendMode.screen;

    // Partículas principales
    for (int i = 0; i < 12; i++) {
      final progress = (animationValue + i * 0.08) % 1.0;
      final opacity = (math.sin(progress * math.pi) * 0.4).abs();

      final colors = [
        const Color(0xFF9C27B0),
        const Color(0xFF673AB7),
        const Color(0xFF3F51B5),
        const Color(0xFF00BCD4),
        const Color(0xFF00E5FF),
      ];

      paint.color = colors[i % colors.length].withOpacity(opacity);

      final x =
          size.width * (0.1 + (i * 0.8 / 11)) +
          (40 * math.sin(progress * math.pi * 2 + i));
      final y =
          size.height * (0.2 + progress * 0.6) +
          (30 * math.cos(progress * math.pi * 3 + i * 0.5));

      final radius = 2.0 + (3.0 * math.sin(progress * math.pi * 4));
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Partículas secundarias más pequeñas
    for (int i = 0; i < 20; i++) {
      final progress = (animationValue * 0.7 + i * 0.05) % 1.0;
      final opacity = (1.0 - progress) * 0.2;

      paint.color = Colors.white.withOpacity(opacity);

      final x = size.width * (i / 19);
      final y =
          size.height * progress + (10 * math.sin(progress * math.pi * 6 + i));

      canvas.drawCircle(Offset(x, y), 1.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

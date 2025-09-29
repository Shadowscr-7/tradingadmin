import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import 'dart:async';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _particleController;
  late final AnimationController _progressController;
  late final AnimationController _textController;

  final List<String> _loadingTexts = [
    'Inicializando FluxTrader...',
    'Conectando con mercados globales...',
    'Optimizando algoritmos de trading...',
    'Sincronizando datos en tiempo real...',
    'Preparando tu experiencia de trading...',
  ];

  int _currentTextIndex = 0;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..forward();

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();

    // Cambiar texto cada segundo
    _startTextAnimation();

    // Cerrar loading automáticamente después de 5 segundos
    Future.delayed(const Duration(seconds: 5), () {
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
    });
  }

  void _startTextAnimation() {
    Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (mounted) {
        setState(() {
          _currentTextIndex = (_currentTextIndex + 1) % _loadingTexts.length;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _particleController.dispose();
    _progressController.dispose();
    _textController.dispose();
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
            // Partículas flotantes de fondo
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _particleController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _ModernParticlePainter(_particleController.value),
                  );
                },
              ),
            ),

            // Contenido principal
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo FluxTrader animado
                  Animate(
                    effects: [
                      FadeEffect(delay: 300.ms, duration: 800.ms),
                      ScaleEffect(delay: 300.ms, duration: 800.ms),
                    ],
                    child: AnimatedBuilder(
                      animation: _logoController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_logoController.value * 0.1),
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF9C27B0),
                                  const Color(0xFF673AB7),
                                  const Color(0xFF3F51B5),
                                  const Color(0xFF00BCD4),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF9C27B0,
                                  ).withOpacity(0.4),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.trending_up_rounded,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Título FluxTrader
                  Animate(
                    effects: [
                      FadeEffect(delay: 600.ms, duration: 800.ms),
                      SlideEffect(
                        begin: const Offset(0, 0.3),
                        delay: 600.ms,
                        duration: 800.ms,
                      ),
                    ],
                    child: ShaderMask(
                      shaderCallback:
                          (bounds) => LinearGradient(
                            colors: [
                              const Color(0xFF9C27B0),
                              const Color(0xFF00E5FF),
                            ],
                          ).createShader(bounds),
                      child: Text(
                        'FluxTrader',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtítulo
                  Animate(
                    effects: [FadeEffect(delay: 800.ms, duration: 800.ms)],
                    child: Text(
                      'Professional Trading Platform',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Barra de progreso moderna
                  Animate(
                    effects: [
                      FadeEffect(delay: 1000.ms, duration: 800.ms),
                      SlideEffect(
                        begin: const Offset(0, 0.5),
                        delay: 1000.ms,
                        duration: 800.ms,
                      ),
                    ],
                    child: _ModernProgressBar(controller: _progressController),
                  ),

                  const SizedBox(height: 32),

                  // Texto de carga animado
                  Animate(
                    effects: [FadeEffect(delay: 1200.ms, duration: 800.ms)],
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        _loadingTexts[_currentTextIndex],
                        key: ValueKey(_currentTextIndex),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Indicador de puntos animado
                  Animate(
                    effects: [FadeEffect(delay: 1400.ms, duration: 800.ms)],
                    child: _AnimatedDots(),
                  ),
                ],
              ),
            ),

            // Versión en la esquina inferior
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Animate(
                effects: [FadeEffect(delay: 2000.ms, duration: 800.ms)],
                child: Text(
                  'v1.0.0 • Powered by Flutter',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white38,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Partículas modernas para el fondo
class _ModernParticlePainter extends CustomPainter {
  final double animationValue;
  _ModernParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..blendMode = BlendMode.screen;

    for (int i = 0; i < 15; i++) {
      final progress = (animationValue + i * 0.1) % 1.0;
      final opacity = (1.0 - progress) * 0.6;

      final colors = [
        const Color(0xFF9C27B0),
        const Color(0xFF673AB7),
        const Color(0xFF3F51B5),
        const Color(0xFF00BCD4),
        const Color(0xFF00E5FF),
      ];

      paint.color = colors[i % colors.length].withOpacity(opacity);

      final x = (size.width * 0.1) + (i * size.width * 0.8 / 14);
      final y =
          size.height * 0.2 +
          (size.height * 0.6 * progress) +
          (30 * math.sin(progress * math.pi * 3 + i));

      final radius = 3.0 + (2.0 * math.sin(progress * math.pi * 2));
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ModernParticlePainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

// Barra de progreso moderna
class _ModernProgressBar extends StatelessWidget {
  final AnimationController controller;

  const _ModernProgressBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: Colors.white.withOpacity(0.1),
      ),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return Container(
                width: 280 * controller.value,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF9C27B0),
                      const Color(0xFF673AB7),
                      const Color(0xFF00BCD4),
                      const Color(0xFF00E5FF),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Puntos animados
class _AnimatedDots extends StatefulWidget {
  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots>
    with TickerProviderStateMixin {
  late final List<AnimationController> _dotControllers;

  @override
  void initState() {
    super.initState();
    _dotControllers = List.generate(
      3,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );

    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _dotControllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _dotControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _dotControllers[index],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.lerp(
                  Colors.white38,
                  const Color(0xFF00E5FF),
                  _dotControllers[index].value,
                ),
                boxShadow: [
                  if (_dotControllers[index].value > 0.5)
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withOpacity(0.6),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';

/// VITÓRIA: Tela do Tesouro Encontrado com raios de luz girando,
/// partículas douradas e o baú aberto.
class VictoryView extends StatefulWidget {
  const VictoryView({super.key});

  @override
  State<VictoryView> createState() => _VictoryViewState();
}

class _VictoryViewState extends State<VictoryView> with SingleTickerProviderStateMixin {
  late final AnimationController _spin;
  late final List<Particle> _particles;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    final rng = Random(42);
    _particles = List.generate(40, (_) => Particle(rng));
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            radius: 1.2,
            colors: [Color(0xFF3A2E10), Color(0xFF12100D)],
          ),
        ),
        child: Stack(
          children: [
            // Raios de luz girando atrás do baú
            Center(
              child: AnimatedBuilder(
                animation: _spin,
                builder: (context, child) => Transform.rotate(
                  angle: _spin.value * 2 * pi,
                  child: child,
                ),
                child: CustomPaint(
                  size: const Size(500, 500),
                  painter: _RaysPainter(),
                ),
              ),
            ),
            // Partículas de tesouro subindo
            AnimatedBuilder(
              animation: _spin,
              builder: (context, _) => CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _ParticlesPainter(_particles, _spin.value),
              ),
            ),
            // Conteúdo central
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.6, end: 1.0),
                      duration: const Duration(seconds: 2),
                      curve: Curves.elasticOut,
                      builder: (context, scale, child) =>
                          Transform.scale(scale: scale, child: child),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black26,
                              border: Border.all(color: const Color(0xFFD4AF37), width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFD4AF37).withAlpha(110),
                                  blurRadius: 60,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.emoji_events, size: 96, color: Color(0xFFFFD700)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFF5E6A8), Color(0xFFD4AF37)],
                      ).createShader(bounds),
                      child: const Text(
                        "TESOURO\nENCONTRADO!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                          height: 1.3,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "\"Pois onde estiver o teu tesouro,\naí estará também o teu coração.\"",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFFF0E6D2).withAlpha(220),
                        fontStyle: FontStyle.italic,
                        fontSize: 17,
                        height: 1.6,
                      ),
                    ),
                    const Text("— Lucas 12:34",
                        style: TextStyle(color: Color(0xFF9C8B6E), fontSize: 14)),
                    if (game.activeProjectName != null) ...[
                      const SizedBox(height: 24),
                      Chip(
                        backgroundColor: const Color(0xFFD4AF37).withAlpha(40),
                        side: const BorderSide(color: Color(0xFFD4AF37)),
                        label: Text(
                          "Equipe concluiu: ${game.activeProjectName!}",
                          style: const TextStyle(color: Color(0xFFF0E6D2)),
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: const Color(0xFF12100D),
                        minimumSize: const Size(260, 54),
                      ),
                      icon: const Icon(Icons.celebration),
                      label: const Text("VOLTAR AO INÍCIO", style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () => game.resetGame(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Pintor dos raios de luz girando
class _RaysPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 12; i++) {
      final angle = i * pi / 6;
      const startRadius = 90.0;
      final endRadius = size.width / 2 - 20;
      paint.color = const Color(0xFFD4AF37)
          .withAlpha(i.isEven ? 70 : 30);
      canvas.drawLine(
        center + Offset(cos(angle) * startRadius, sin(angle) * startRadius),
        center + Offset(cos(angle) * endRadius, sin(angle) * endRadius),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Partícula flutuante de tesouro
class Particle {
  final double x; // posição horizontal relativa (0..1)
  final double speed; // velocidade de subida
  final double size;
  final double phase;

  Particle(Random rng)
      : x = rng.nextDouble(),
        speed = 0.05 + rng.nextDouble() * 0.12,
        size = 2 + rng.nextDouble() * 5,
        phase = rng.nextDouble() * 2 * pi;
}

class _ParticlesPainter extends CustomPainter {
  final List<Particle> particles;
  final double t;

  _ParticlesPainter(this.particles, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFFFD700);
    for (final p in particles) {
      // Posição vertical sobe em loop, com leve balanço lateral senoidal
      final progress = (p.speed * t * 20 + p.phase) % 1.0;      final y = size.height * (1.15 - progress * 1.3);
      final x = size.width * p.x + sin(progress * 6 + p.phase) * 18;
      paint.color = const Color(0xFFFFD700)
          .withAlpha((progress * 200).clamp(0, 255).toInt());
      canvas.drawCircle(Offset(x, y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter old) => true;
}

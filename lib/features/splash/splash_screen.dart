// lib/features/splash/splash_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/cyberpunk_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberpunkTheme.pitchBlack,
      body: Stack(
        children: [
          // 1. Background Grid
          Positioned.fill(
            child: CustomPaint(
              painter: CyberGridPainter(),
            ),
          ),

          // 2. Inverted Ghost-to-Smoke Animated Layout
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Spacer(),

                // اوپر: دھوئیں کی ٹرانزیشن کے بعد ظاہر ہونے والا Text
                Text(
                  'GHOSTMESH',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 38,
                        color: Colors.white,
                        shadows: [
                          const Shadow(blurRadius: 15, color: CyberpunkTheme.neonCyan),
                          const Shadow(blurRadius: 20, color: CyberpunkTheme.flameOrange),
                        ],
                      ),
                )
                    .animate()
                    .fadeIn(delay: 1500.ms, duration: 1.seconds)
                    .scale(begin: const Offset(0.7, 0.7), end: const Offset(1.0, 1.0))
                    .shimmer(duration: 2.seconds, color: CyberpunkTheme.neonCyan),

                const SizedBox(height: 10),

                Text(
                  'P2P // HARDWARE_ENCLAVE // ZERO_SERVER',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: CyberpunkTheme.neonCyan,
                        fontSize: 11,
                        letterSpacing: 2,
                      ),
                ).animate().fadeIn(delay: 2.seconds),

                const SizedBox(height: 40),

                // درمیان: اوپر کی طرف اٹھتا ہوا دھواں (Circular Rotation Movement)
                AnimatedBuilder(
                  animation: _rotationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationController.value * 2 * math.pi,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: CyberpunkTheme.neonCyan.withOpacity(0.8),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: CyberpunkTheme.flameOrange.withOpacity(0.6),
                              blurRadius: 25,
                              spreadRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.blur_on_rounded,
                          size: 55,
                          color: CyberpunkTheme.flameOrange,
                        ),
                      ),
                    );
                  },
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .slideY(begin: 0.8, end: -0.3, duration: 2200.ms)
                    .fadeIn(duration: 800.ms),

                const SizedBox(height: 30),

                // نیچے: گھوسٹ ایمبلم (سگریٹ کی جگہ نچلے حصے پر)
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: CyberpunkTheme.darkCarbon,
                    border: Border.all(
                      color: CyberpunkTheme.ghostMagenta,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: CyberpunkTheme.flameOrange.withOpacity(0.6),
                        blurRadius: 30,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    size: 48,
                    color: CyberpunkTheme.flameOrange,
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05))
                    .shimmer(duration: 1800.ms, color: CyberpunkTheme.neonCyan),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Background Cyber Grid Painter
class CyberGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CyberpunkTheme.neonCyan.withOpacity(0.04)
      ..strokeWidth = 1.0;

    const double step = 30.0;

    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
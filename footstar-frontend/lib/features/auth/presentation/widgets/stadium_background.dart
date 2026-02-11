import 'dart:math' as math;
import 'package:flutter/material.dart';

class StadiumBackground extends StatelessWidget {
  const StadiumBackground({super.key});

  @override
  Widget build(BuildContext context) {
    // Colors from the CSS
    const pitchBlack = Color(0xFF0B0C10);
    const grassLight = Color.fromRGBO(16, 137, 62, 0.15);
    const grassLine = Color.fromRGBO(0, 112, 37, 0.5);
    const lightGlow = Color.fromRGBO(0, 112, 37, 0.15);

    return Container(
      color: pitchBlack,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // --- 1. VIGNETTE BACKGROUND ---
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.4), // approx 50% 30%
                radius: 1.2,
                colors: [
                  const Color(0xFF151922),
                  pitchBlack.withOpacity(0.8), // Smooth blend
                ],
                stops: const [0.0, 0.8],
              ),
            ),
          ),

          // --- 2. FLOODLIGHTS ---
          // Left Light
          Positioned(
            top: -150,
            left: -100, // approximated -50% width
            right: 100, // extend width
            height: 800,
            child: Transform.rotate(
              angle: 25 * (math.pi / 180),
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [
                      Colors.white.withOpacity(0.12),
                      lightGlow,
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.4, 0.7],
                  ),
                ),
              ),
            ),
          ),
          // Right Light
          Positioned(
            top: -150,
            right: -100,
            left: 100,
            height: 800,
            child: Transform.rotate(
              angle: -25 * (math.pi / 180),
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [
                      Colors.white.withOpacity(0.12),
                      lightGlow,
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.4, 0.7],
                  ),
                ),
              ),
            ),
          ),

          // --- 3. 3D PITCH PERSPECTIVE ---
          Positioned(
            top:
                250, // Moved down to simulate "bottom: -10%" relative to typical screen
            // or we use bottom positioning if we want it anchored there
            bottom: -100,
            left: -100,
            right: -100,
            child: Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // Perspective
                ..rotateX(
                  1.1,
                ), // ~63 deg, 75 might be too extreme for this view height
              alignment: Alignment.topCenter,
              child: CustomPaint(
                painter: _PitchPainter(
                  lineColor: grassLine,
                  grassColor: grassLight,
                ),
              ),
            ),
          ),

          // --- 4. FOG OVERLAY ---
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0B0C10).withOpacity(0.1),
                    const Color(0xFF0B0C10).withOpacity(0.6),
                    pitchBlack.withOpacity(0.9),
                  ],
                  stops: const [0.0, 0.5, 0.9],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PitchPainter extends CustomPainter {
  final Color lineColor;
  final Color grassColor;

  _PitchPainter({required this.lineColor, required this.grassColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = lineColor;

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = grassColor;

    // Draw Grass Stripes (Horizontal)
    // Simulates repeating-linear-gradient(90deg, transparent 0, transparent 49px, rgba... 50px)
    // but typically grass stripes on a pitch are horizontal or vertical.
    // The CSS had `repeating-linear-gradient(90deg...)` which makes VERTICAL stripes.
    // Let's draw vertical stripes.
    double stripeWidth = 50.0;
    for (double x = 0; x < size.width; x += stripeWidth * 2) {
      canvas.drawRect(
        Rect.fromLTWH(x + stripeWidth, 0, stripeWidth, size.height),
        fillPaint,
      );
    }

    // Draw Outer Border
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw Half Line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    // Draw Center Circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      200, // Radius matching CSS width/2
      paint,
    );

    // Draw Penalty Area (Top - mimics CSS "top: -2px")
    // In CSS it was top: -2px, meaning it attached to the top border.
    // But a half-pitch view usually implies we are looking at one goal.
    // The CSS has `half-line` at `top: 50%`. So this is a full pitch view?
    // CSS "penalty-area" was `top: -2px`. So it's at the very top of the div.
    double penaltyWidth = size.width * 0.4;
    double penaltyHeight = size.height * 0.15;

    // Top Goal Area
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - penaltyWidth) / 2,
        0,
        penaltyWidth,
        penaltyHeight,
      ),
      paint,
    );

    // Bottom Goal Area (Mirror for symmetry if we assume full pitch)
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - penaltyWidth) / 2,
        size.height - penaltyHeight,
        penaltyWidth,
        penaltyHeight,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

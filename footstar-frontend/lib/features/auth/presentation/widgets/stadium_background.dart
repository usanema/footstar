import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A sleek, modern gradient background for the login screen.
///
/// Replaces the literal stadium imagery with a premium abstract aesthetic
/// using the app's brand colors (Emerald Green, Gold, Deep Black).
class StadiumBackground extends StatelessWidget {
  const StadiumBackground({super.key});

  @override
  Widget build(BuildContext context) {
    const deepVoid = Color(0xFF05070A); // Almost black
    const emerald = Color(0xFF00A86B);
    const gold = Color(0xFFFFD700);

    return Container(
      color: deepVoid,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Base subtle emerald pulse from bottom-left
          Positioned(
            bottom: -200,
            left: -200,
            width: 600,
            height: 600,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [emerald.withOpacity(0.2), Colors.transparent],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
          ),

          // 2. Subtle gold glow from top-right (suggesting victory/light)
          Positioned(
            top: -150,
            right: -150,
            width: 500,
            height: 500,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [gold.withOpacity(0.15), Colors.transparent],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
          ),

          // 3. Main atmospheric overlay (Vignette + Noise simulation)
          // Using a gradient that darkens edges to focus attention on center content
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [
                  Colors.transparent,
                  Color(0xFF000000), // Pure black vignette
                ],
                stops: [0.6, 1.0],
              ),
            ),
          ),

          // 4. Mesh/Grid overlay (Optional technical feel)
          // Very subtle pattern to break the flatness
          CustomPaint(painter: _SubtleGridPainter()),
        ],
      ),
    );
  }
}

class _SubtleGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;

    const double spacing = 40.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

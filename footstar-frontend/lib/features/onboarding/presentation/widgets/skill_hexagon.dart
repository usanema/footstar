import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/app_theme.dart';

class SkillHexagon extends StatelessWidget {
  final Map<String, int> skills;
  final double size;

  // Neon Turf from Design Principles
  static const Color neonTurf = Color(0xFF66FCF1);
  static const Color carbonGrey = Color(0xFF1F2833);

  const SkillHexagon({super.key, required this.skills, this.size = 200});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HexagonPainter(
          skills: skills,
          primaryColor: neonTurf,
          backgroundColor: carbonGrey,
        ),
      ),
    );
  }
}

class _HexagonPainter extends CustomPainter {
  final Map<String, int> skills;
  final Color primaryColor;
  final Color backgroundColor;

  _HexagonPainter({
    required this.skills,
    required this.primaryColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.8; // Use 80% to leave room for labels
    final paint = Paint();

    // 1. Draw Background Web (Levels 1-5)
    paint.color = backgroundColor.withOpacity(0.5);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.0;

    for (int i = 1; i <= 5; i++) {
      final levelRadius = radius * (i / 5);
      _drawHexagon(canvas, center, levelRadius, paint);
    }

    // 2. Draw Connecting Lines (Spokes)
    final keys = skills.keys.toList();
    final angleStep = (2 * math.pi) / keys.length;

    for (int i = 0; i < keys.length; i++) {
      final angle = -math.pi / 2 + (i * angleStep);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), paint);

      // Draw Labels
      _drawLabel(canvas, center, radius, angle, keys[i]);
    }

    // 3. Draw Skills Shape
    final path = Path();
    for (int i = 0; i < keys.length; i++) {
      final value = skills[keys[i]] ?? 1;
      final valueRadius = radius * (value / 5);
      final angle = -math.pi / 2 + (i * angleStep);
      final x = center.dx + valueRadius * math.cos(angle);
      final y = center.dy + valueRadius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Fill
    paint.style = PaintingStyle.fill;
    paint.color = primaryColor.withOpacity(0.3);
    canvas.drawPath(path, paint);

    // Stroke
    paint.style = PaintingStyle.stroke;
    paint.color = primaryColor;
    paint.strokeWidth = 2.0;
    paint.strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, paint);

    // Points (Vertices)
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < keys.length; i++) {
      final value = skills[keys[i]] ?? 1;
      final valueRadius = radius * (value / 5);
      final angle = -math.pi / 2 + (i * angleStep);
      final x = center.dx + valueRadius * math.cos(angle);
      final y = center.dy + valueRadius * math.sin(angle);
      canvas.drawCircle(Offset(x, y), 4, paint);
    }
  }

  void _drawHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    // Wait, "Hexagon" usually means 6. Logic says 8 attributes (Speed, Technique, etc).
    // So it's an Octagon.

    // The user called it "Hexagon", design principles say "Hexagon/Radar Chart".
    // 8 attributes -> Octagon.
    // I will draw an N-gon based on skills.length.

    final sides = skills.length;
    final step = (2 * math.pi) / sides;

    for (int i = 0; i < sides; i++) {
      final angle = -math.pi / 2 + (i * step);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawLabel(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
    String text,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: AppTextStyles.labelSmall.copyWith(
          color: Colors.white.withOpacity(0.8),
          fontSize: 10,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Position label slightly outside the radius
    final padding = 15.0;
    final x =
        center.dx +
        (radius + padding) * math.cos(angle) -
        textPainter.width / 2;
    final y =
        center.dy +
        (radius + padding) * math.sin(angle) -
        textPainter.height / 2;

    textPainter.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

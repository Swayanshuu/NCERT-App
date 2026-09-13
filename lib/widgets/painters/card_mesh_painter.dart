import 'package:flutter/material.dart';

class CardMeshPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final bool isDark;

  CardMeshPainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Top-Right Radial Glow Orb
    final topRightCenter = Offset(size.width * 0.90, size.height * 0.15);
    final glowPaint1 = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryColor.withValues(alpha: isDark ? 0.25 : 0.35),
          primaryColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: topRightCenter, radius: size.width * 0.60));
    canvas.drawCircle(topRightCenter, size.width * 0.60, glowPaint1);

    // 2. Bottom-Left Radial Glow Orb
    final bottomLeftCenter = Offset(size.width * 0.10, size.height * 0.85);
    final glowPaint2 = Paint()
      ..shader = RadialGradient(
        colors: [
          secondaryColor.withValues(alpha: isDark ? 0.20 : 0.28),
          secondaryColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: bottomLeftCenter, radius: size.width * 0.50));
    canvas.drawCircle(bottomLeftCenter, size.width * 0.50, glowPaint2);

    // 3. Floating Vector Mesh Accents
    final strokePaint = Paint()
      ..color = Colors.white.withValues(alpha: isDark ? 0.08 : 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Geometric Orbit Rings
    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.25), 22, strokePaint);
    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.25), 10, strokePaint);

    // Floating Sparkles
    _drawSparkle(canvas, Offset(size.width * 0.15, size.height * 0.25), primaryColor.withValues(alpha: isDark ? 0.30 : 0.45), 6);
    _drawSparkle(canvas, Offset(size.width * 0.88, size.height * 0.75), secondaryColor.withValues(alpha: isDark ? 0.30 : 0.45), 5);

    // Curved Vector Line
    final wavePath = Path();
    wavePath.moveTo(0, size.height * 0.70);
    wavePath.quadraticBezierTo(size.width * 0.5, size.height * 0.50, size.width, size.height * 0.80);
    canvas.drawPath(wavePath, strokePaint);
  }

  void _drawSparkle(Canvas canvas, Offset center, Color color, double radius) {
    final paint = Paint()..color = color;
    final path = Path();
    path.moveTo(center.dx, center.dy - radius);
    path.lineTo(center.dx + radius * 0.3, center.dy - radius * 0.3);
    path.lineTo(center.dx + radius, center.dy);
    path.lineTo(center.dx + radius * 0.3, center.dy + radius * 0.3);
    path.lineTo(center.dx, center.dy + radius);
    path.lineTo(center.dx - radius * 0.3, center.dy + radius * 0.3);
    path.lineTo(center.dx - radius, center.dy);
    path.lineTo(center.dx - radius * 0.3, center.dy - radius * 0.3);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CardMeshPainter oldDelegate) {
    return oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.isDark != isDark;
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AppBackgroundPainter extends CustomPainter {
  final bool isDark;

  AppBackgroundPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Solid Background Base
    final bgPaint = Paint()
      ..color = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    canvas.drawRect(Offset.zero & size, bgPaint);

    // 2. Subtle Glowing Ambient Radial Spots
    final spot1Center = Offset(size.width * 0.85, size.height * 0.12);
    final spot1Paint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppTheme.primaryTeal.withValues(alpha: isDark ? 0.12 : 0.18),
          AppTheme.primaryTeal.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: spot1Center, radius: size.width * 0.55));
    canvas.drawCircle(spot1Center, size.width * 0.55, spot1Paint);

    final spot2Center = Offset(size.width * 0.12, size.height * 0.75);
    final spot2Paint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppTheme.primaryIndigo.withValues(alpha: isDark ? 0.10 : 0.15),
          AppTheme.primaryIndigo.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: spot2Center, radius: size.width * 0.50));
    canvas.drawCircle(spot2Center, size.width * 0.50, spot2Paint);

    // 3. Low-Contrast Vector Stroke Paint
    final strokeColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFF334155).withValues(alpha: 0.12);

    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    // Geometric Orbit Rings & Concentric Circles
    final orbit1 = Offset(size.width * 0.82, size.height * 0.20);
    canvas.drawCircle(orbit1, 36, strokePaint);
    canvas.drawCircle(orbit1, 18, strokePaint);
    canvas.drawCircle(orbit1, 3, Paint()..color = strokeColor);

    final orbit2 = Offset(size.width * 0.15, size.height * 0.62);
    canvas.drawCircle(orbit2, 28, strokePaint);

    // Sine Wave Vector Curve
    final wavePath = Path();
    wavePath.moveTo(0, size.height * 0.40);
    for (double x = 0; x <= size.width; x += 8) {
      final y = size.height * 0.40 + math.sin(x * 0.015) * 16;
      wavePath.lineTo(x, y);
    }
    canvas.drawPath(wavePath, strokePaint);

    // Floating Stars & Symbols
    _drawStar(canvas, Offset(size.width * 0.12, size.height * 0.18), AppTheme.accentAmber.withValues(alpha: isDark ? 0.25 : 0.40), 10);
    _drawStar(canvas, Offset(size.width * 0.88, size.height * 0.68), AppTheme.accentRose.withValues(alpha: isDark ? 0.22 : 0.38), 9);
    _drawStar(canvas, Offset(size.width * 0.82, size.height * 0.44), AppTheme.primaryTeal.withValues(alpha: isDark ? 0.22 : 0.38), 8);

    // Math/Science Symbols
    _drawSymbol(canvas, 'π', Offset(size.width * 0.08, size.height * 0.30), 22, strokeColor);
    _drawSymbol(canvas, 'Σ', Offset(size.width * 0.90, size.height * 0.35), 22, strokeColor);
    _drawSymbol(canvas, '∞', Offset(size.width * 0.16, size.height * 0.86), 20, strokeColor);

    // Open Book Vector Contour Line
    final bookCenter = Offset(size.width * 0.84, size.height * 0.88);
    final bookPath = Path();
    bookPath.moveTo(bookCenter.dx - 20, bookCenter.dy - 5);
    bookPath.quadraticBezierTo(bookCenter.dx - 10, bookCenter.dy - 12, bookCenter.dx, bookCenter.dy - 5);
    bookPath.quadraticBezierTo(bookCenter.dx + 10, bookCenter.dy - 12, bookCenter.dx + 20, bookCenter.dy - 5);
    bookPath.lineTo(bookCenter.dx + 20, bookCenter.dy + 10);
    bookPath.quadraticBezierTo(bookCenter.dx + 10, bookCenter.dy + 3, bookCenter.dx, bookCenter.dy + 10);
    bookPath.quadraticBezierTo(bookCenter.dx - 10, bookCenter.dy + 3, bookCenter.dx - 20, bookCenter.dy + 10);
    bookPath.close();
    canvas.drawPath(bookPath, strokePaint);
  }

  void _drawStar(Canvas canvas, Offset center, Color color, double radius) {
    final paint = Paint()..color = color;
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 4 * math.pi / 5) - (math.pi / 2);
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

  void _drawSymbol(Canvas canvas, String symbol, Offset offset, double fontSize, Color color) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: symbol,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(offset.dx - textPainter.width / 2, offset.dy - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant AppBackgroundPainter oldDelegate) => oldDelegate.isDark != isDark;
}

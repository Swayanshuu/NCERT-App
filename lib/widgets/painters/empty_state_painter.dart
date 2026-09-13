import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class EmptyStateIllustration extends StatelessWidget {
  final double size;
  final String title;

  const EmptyStateIllustration({
    super.key,
    this.size = 120.0,
    this.title = '',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: EmptyStatePainter(),
      ),
    );
  }
}

class EmptyStatePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Outer Soft Glowing Circle
    final glowPaint = Paint()
      ..color = AppTheme.duoGreen.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size.width * 0.45, glowPaint);

    // Book 1 (Bottom Stack Book)
    final book1Rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.20, size.height * 0.55, size.width * 0.60, size.height * 0.18),
      const Radius.circular(8),
    );
    canvas.drawRRect(book1Rect, Paint()..color = AppTheme.duoCyan);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.22, size.height * 0.57, size.width * 0.56, size.height * 0.14),
        const Radius.circular(6),
      ),
      Paint()..color = AppTheme.duoCyanShadow,
    );

    // Book 2 (Top Rotated Stack Book)
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-math.pi / 14);

    final book2Rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(0, -10), width: size.width * 0.55, height: size.height * 0.18),
      const Radius.circular(8),
    );
    canvas.drawRRect(book2Rect, Paint()..color = AppTheme.duoYellow);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(0, -10), width: size.width * 0.50, height: size.height * 0.14),
        const Radius.circular(6),
      ),
      Paint()..color = AppTheme.duoYellowShadow,
    );
    canvas.restore();

    // Floating Magnifying Glass
    final glassCenter = Offset(size.width * 0.65, size.height * 0.35);
    final glassPaint = Paint()
      ..color = AppTheme.duoPurple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    canvas.drawCircle(glassCenter, 18, glassPaint);
    canvas.drawCircle(glassCenter, 18, Paint()..color = AppTheme.duoPurple.withValues(alpha: 0.15));

    // Handle
    canvas.drawLine(
      Offset(glassCenter.dx + 12, glassCenter.dy + 12),
      Offset(glassCenter.dx + 26, glassCenter.dy + 26),
      Paint()
        ..color = AppTheme.duoPurpleShadow
        ..strokeWidth = 5.0
        ..strokeCap = StrokeCap.round,
    );

    // Floating Sparkles
    _drawSparkle(canvas, Offset(size.width * 0.20, size.height * 0.25), AppTheme.duoOrange);
    _drawSparkle(canvas, Offset(size.width * 0.82, size.height * 0.70), AppTheme.duoGreen);
  }

  void _drawSparkle(Canvas canvas, Offset offset, Color color) {
    final paint = Paint()..color = color;
    final path = Path();
    path.moveTo(offset.dx, offset.dy - 6);
    path.lineTo(offset.dx + 2, offset.dy - 2);
    path.lineTo(offset.dx + 6, offset.dy);
    path.lineTo(offset.dx + 2, offset.dy + 2);
    path.lineTo(offset.dx, offset.dy + 6);
    path.lineTo(offset.dx - 2, offset.dy + 2);
    path.lineTo(offset.dx - 6, offset.dy);
    path.lineTo(offset.dx - 2, offset.dy - 2);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

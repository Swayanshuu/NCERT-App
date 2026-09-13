import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SubjectBackgroundPainter extends CustomPainter {
  final String subject;
  final bool isDark;

  SubjectBackgroundPainter({
    required this.subject,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final themeColor = AppTheme.getSubjectColor(subject);
    final s = subject.toLowerCase();

    final bgGradient = LinearGradient(
      colors: [
        themeColor.withValues(alpha: isDark ? 0.25 : 0.15),
        themeColor.withValues(alpha: isDark ? 0.05 : 0.02),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = bgGradient.createShader(rect));

    final strokeColor = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : themeColor.withValues(alpha: 0.22);

    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    if (s.contains('sci') || s.contains('evs')) {
      // Draw Atomic Orbits
      final center = Offset(size.width * 0.80, size.height * 0.40);
      canvas.drawCircle(center, 8, Paint()..color = themeColor.withValues(alpha: 0.4));
      
      canvas.save();
      canvas.translate(center.dx, center.dy);
      for (double angle in [0.0, math.pi / 3, 2 * math.pi / 3]) {
        canvas.save();
        canvas.rotate(angle);
        final ellipseBounds = Rect.fromCenter(center: Offset.zero, width: 60, height: 20);
        canvas.drawOval(ellipseBounds, strokePaint);
        canvas.restore();
      }
      canvas.restore();
    } else if (s.contains('math')) {
      // Draw Math Geometry Grid & Coordinates
      final gridPath = Path();
      for (double x = 10; x < size.width; x += 25) {
        gridPath.moveTo(x, 0);
        gridPath.lineTo(x, size.height);
      }
      for (double y = 10; y < size.height; y += 25) {
        gridPath.moveTo(0, y);
        gridPath.lineTo(size.width, y);
      }
      canvas.drawPath(gridPath, Paint()..color = strokeColor.withValues(alpha: 0.4)..style = PaintingStyle.stroke..strokeWidth = 0.8);

      final curvePath = Path();
      curvePath.moveTo(0, size.height * 0.7);
      for (double x = 0; x <= size.width; x += 10) {
        curvePath.lineTo(x, size.height * 0.7 - math.sin(x * 0.05) * 20);
      }
      canvas.drawPath(curvePath, strokePaint..strokeWidth = 2.0);
    } else if (s.contains('eng') || s.contains('hin')) {
      // Draw Quill / Book lines
      final linePath = Path();
      for (int i = 1; i <= 4; i++) {
        final y = size.height * (0.2 * i);
        linePath.moveTo(size.width * 0.1, y);
        linePath.lineTo(size.width * 0.9, y);
      }
      canvas.drawPath(linePath, strokePaint);
    } else {
      // Globe Lines / Radial Arc
      final center = Offset(size.width * 0.85, size.height * 0.5);
      canvas.drawCircle(center, 40, strokePaint);
      canvas.drawCircle(center, 25, strokePaint);
      canvas.drawArc(Rect.fromCircle(center: center, radius: 40), 0, math.pi, false, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant SubjectBackgroundPainter oldDelegate) {
    return oldDelegate.subject != subject || oldDelegate.isDark != isDark;
  }
}

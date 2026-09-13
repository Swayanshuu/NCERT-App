import 'dart:math' as math;
import 'package:flutter/material.dart';

class LearningJourneyPathPainter extends CustomPainter {
  final Color pathColor;
  final double progress;

  LearningJourneyPathPainter({
    required this.pathColor,
    this.progress = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = pathColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = pathColor.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);

    final path = Path();
    final width = size.width;
    final height = size.height;

    path.moveTo(width * 0.15, height * 0.15);
    path.cubicTo(
      width * 0.85, height * 0.25,
      width * 0.15, height * 0.75,
      width * 0.85, height * 0.85,
    );

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);

    // Draw node connection dots
    final dotPaint = Paint()
      ..color = pathColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(width * 0.15, height * 0.15), 6, dotPaint);
    canvas.drawCircle(Offset(width * 0.50, height * 0.50), 6, dotPaint);
    canvas.drawCircle(Offset(width * 0.85, height * 0.85), 6, dotPaint);
  }

  @override
  bool shouldRepaint(covariant LearningJourneyPathPainter oldDelegate) {
    return oldDelegate.pathColor != pathColor || oldDelegate.progress != progress;
  }
}

class StarburstPainter extends CustomPainter {
  final Color color;

  StarburstPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final rayPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    const numRays = 12;
    const angleStep = (2 * math.pi) / numRays;

    for (int i = 0; i < numRays; i++) {
      if (i % 2 == 0) {
        final startAngle = i * angleStep;
        final endAngle = (i + 0.8) * angleStep;

        final path = Path()
          ..moveTo(center.dx, center.dy)
          ..lineTo(
            center.dx + radius * math.cos(startAngle),
            center.dy + radius * math.sin(startAngle),
          )
          ..lineTo(
            center.dx + radius * math.cos(endAngle),
            center.dy + radius * math.sin(endAngle),
          )
          ..close();

        canvas.drawPath(path, rayPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant StarburstPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class SubjectWorldPainter extends CustomPainter {
  final String subjectName;
  final Color themeColor;

  SubjectWorldPainter({
    required this.subjectName,
    required this.themeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = themeColor.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final fillPaint = Paint()
      ..color = themeColor.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;

    final s = subjectName.toLowerCase();

    if (s.contains('math')) {
      // Draw grid and geometric circles
      for (double x = 0; x < size.width; x += 24) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      }
      for (double y = 0; y < size.height; y += 24) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      }
      canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.3), 36, fillPaint);
      canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.3), 36, paint);
    } else if (s.contains('sci')) {
      // Draw atomic orbits
      final center = Offset(size.width * 0.75, size.height * 0.5);
      canvas.drawOval(
        Rect.fromCenter(center: center, width: 70, height: 24),
        paint,
      );
      canvas.drawOval(
        Rect.fromCenter(center: center, width: 24, height: 70),
        paint,
      );
      canvas.drawCircle(center, 8, Paint()..color = themeColor.withValues(alpha: 0.2));
    } else {
      // Draw ambient floating sparkle circles
      canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.2), 24, fillPaint);
      canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.7), 16, fillPaint);
      canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.8), 30, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SubjectWorldPainter oldDelegate) {
    return oldDelegate.subjectName != subjectName || oldDelegate.themeColor != themeColor;
  }
}

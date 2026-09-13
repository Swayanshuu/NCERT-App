import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class HeaderBannerArt extends StatelessWidget {
  final double height;
  final Widget child;

  const HeaderBannerArt({
    super.key,
    this.height = 110.0,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        gradient: LinearGradient(
          colors: [
            AppTheme.duoGreen.withValues(alpha: isDark ? 0.25 : 0.85),
            AppTheme.duoCyan.withValues(alpha: isDark ? 0.35 : 0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        child: CustomPaint(
          painter: HeaderBannerPainter(isDark: isDark),
          child: child,
        ),
      ),
    );
  }
}

class HeaderBannerPainter extends CustomPainter {
  final bool isDark;

  HeaderBannerPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: isDark ? 0.08 : 0.15)
      ..style = PaintingStyle.fill;

    // Smooth Vector Wave 1
    final wave1 = Path();
    wave1.moveTo(0, size.height * 0.4);
    wave1.quadraticBezierTo(size.width * 0.35, size.height * 0.1, size.width * 0.7, size.height * 0.5);
    wave1.quadraticBezierTo(size.width * 0.85, size.height * 0.7, size.width, size.height * 0.4);
    wave1.lineTo(size.width, size.height);
    wave1.lineTo(0, size.height);
    wave1.close();
    canvas.drawPath(wave1, paint);

    // Smooth Vector Wave 2 (Rotated layer)
    final wave2 = Path();
    wave2.moveTo(0, size.height * 0.7);
    wave2.quadraticBezierTo(size.width * 0.4, size.height, size.width * 0.8, size.height * 0.6);
    wave2.lineTo(size.width, size.height);
    wave2.lineTo(0, size.height);
    wave2.close();
    canvas.drawPath(wave2, Paint()..color = Colors.white.withValues(alpha: isDark ? 0.05 : 0.10));

    // Floating Vector Geometric Accents
    final circlePaint = Paint()
      ..color = Colors.white.withValues(alpha: isDark ? 0.12 : 0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(Offset(size.width * 0.88, size.height * 0.25), 24, circlePaint);
    canvas.drawCircle(Offset(size.width * 0.88, size.height * 0.25), 12, circlePaint);

    _drawStar(canvas, Offset(size.width * 0.15, size.height * 0.30), Colors.white.withValues(alpha: 0.35), 8);
    _drawStar(canvas, Offset(size.width * 0.55, size.height * 0.20), AppTheme.duoYellow.withValues(alpha: 0.5), 10);
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

  @override
  bool shouldRepaint(covariant HeaderBannerPainter oldDelegate) => oldDelegate.isDark != isDark;
}

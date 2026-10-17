import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AppBackgroundPainter extends CustomPainter {
  final bool isDark;

  AppBackgroundPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Clean Solid Background Base
    final bgPaint = Paint()
      ..color = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    canvas.drawRect(Offset.zero & size, bgPaint);

    // 2. Very subtle ambient atmospheric glowing spots for modern depth (no cartoon doodles)
    final spot1Center = Offset(size.width * 0.88, size.height * 0.08);
    final spot1Paint = Paint()
      ..shader = RadialGradient(
        colors: [
          (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)).withValues(alpha: isDark ? 0.25 : 0.40),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: spot1Center, radius: size.width * 0.65));
    canvas.drawCircle(spot1Center, size.width * 0.65, spot1Paint);

    final spot2Center = Offset(size.width * 0.10, size.height * 0.85);
    final spot2Paint = Paint()
      ..shader = RadialGradient(
        colors: [
          (isDark ? const Color(0xFF1E2638) : const Color(0xFFF1F5F9)).withValues(alpha: isDark ? 0.20 : 0.35),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: spot2Center, radius: size.width * 0.55));
    canvas.drawCircle(spot2Center, size.width * 0.55, spot2Paint);
  }

  @override
  bool shouldRepaint(covariant AppBackgroundPainter oldDelegate) => oldDelegate.isDark != isDark;
}

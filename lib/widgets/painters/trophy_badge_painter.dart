import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class TrophyBadgeCanvas extends StatelessWidget {
  final double size;
  final Color color;

  const TrophyBadgeCanvas({
    super.key,
    this.size = 48.0,
    this.color = AppTheme.accentAmber,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: TrophyBadgePainter(badgeColor: color),
      ),
    );
  }
}

class TrophyBadgePainter extends CustomPainter {
  final Color badgeColor;

  TrophyBadgePainter({required this.badgeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final width = size.width;
    final height = size.height;

    // Glowing Outer Hexagon Shield
    final shieldPath = Path();
    final r = width * 0.45;
    shieldPath.moveTo(center.dx, center.dy - r);
    shieldPath.lineTo(center.dx + r * 0.866, center.dy - r * 0.5);
    shieldPath.lineTo(center.dx + r * 0.866, center.dy + r * 0.5);
    shieldPath.lineTo(center.dx, center.dy + r);
    shieldPath.lineTo(center.dx - r * 0.866, center.dy + r * 0.5);
    shieldPath.lineTo(center.dx - r * 0.866, center.dy - r * 0.5);
    shieldPath.close();

    canvas.drawPath(
      shieldPath,
      Paint()
        ..color = badgeColor
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      shieldPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Vector Cup Trophy Center
    final cupPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final cupPath = Path();
    cupPath.moveTo(center.dx - width * 0.20, center.dy - height * 0.20);
    cupPath.lineTo(center.dx + width * 0.20, center.dy - height * 0.20);
    cupPath.quadraticBezierTo(center.dx + width * 0.18, center.dy + height * 0.10, center.dx, center.dy + height * 0.18);
    cupPath.quadraticBezierTo(center.dx - width * 0.18, center.dy + height * 0.10, center.dx - width * 0.20, center.dy - height * 0.20);
    cupPath.close();

    canvas.drawPath(cupPath, cupPaint);

    // Trophy Stand Base
    final baseRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(center.dx, center.dy + height * 0.24), width: width * 0.26, height: height * 0.08),
      const Radius.circular(3),
    );
    canvas.drawRRect(baseRect, cupPaint);
  }

  @override
  bool shouldRepaint(covariant TrophyBadgePainter oldDelegate) => oldDelegate.badgeColor != badgeColor;
}
